import json
import boto3
import stripe
import jwt
import os
from datetime import datetime, timezone

dynamodb = boto3.resource('dynamodb')
secrets_client = boto3.client('secretsmanager')

def get_stripe_keys():
    secret = secrets_client.get_secret_value(SecretId=os.environ['APP_SECRETS_ARN'])
    return json.loads(secret['SecretString'])

def get_jwt_secret():
    secret = secrets_client.get_secret_value(SecretId=os.environ['APP_SECRETS_ARN'])
    return json.loads(secret['SecretString'])['jwt_secret']

def get_user_from_token(event):
    auth_header = event.get('headers', {}).get('Authorization', '')
    if not auth_header.startswith('Bearer '):
        raise Exception('No valid token')
    
    token = auth_header.split(' ')[1]
    try:
        # JWT library automatically checks expiration here
        payload = jwt.decode(token, get_jwt_secret(), algorithms=['HS256'])
        return payload['user_id']
    except jwt.ExpiredSignatureError:
        raise Exception('Token expired')
    except jwt.InvalidTokenError:
        raise Exception('Invalid token')

def get_user_email(user_id):
    users_table = dynamodb.Table(os.environ['USERS_TABLE'])
    response = users_table.get_item(Key={'user_id': user_id})
    return response['Item']['email'] if 'Item' in response else None

def handle_webhook_event(event_type, data):
    users_table = dynamodb.Table(os.environ['USERS_TABLE'])
    subscriptions_table = dynamodb.Table(os.environ['SUBSCRIPTIONS_TABLE'])
    
    if event_type == 'customer.subscription.created':
        subscription = data['object']
        # Get user_id from subscription metadata
        user_id = subscription.get('metadata', {}).get('user_id')
        
        if user_id:
            # Use Stripe's current_period_end for accurate renewal date
            renews_at = datetime.fromtimestamp(subscription['current_period_end'], timezone.utc)
            
            subscriptions_table.put_item(Item={
                'user_id': user_id,
                'subscription_id': subscription['id'],
                'status': subscription['status'],
                'renews_at': renews_at.isoformat(),
                'created_at': datetime.utcnow().isoformat(),
                'will_cancel': False
            })
            
            users_table.update_item(
                Key={'user_id': user_id},
                UpdateExpression='SET subscription_active = :active',
                ExpressionAttributeValues={':active': subscription['status'] == 'active'}
            )
    
    elif event_type in ['customer.subscription.updated', 'customer.subscription.deleted']:
        subscription = data['object']
        # Get user_id from subscription metadata
        user_id = subscription.get('metadata', {}).get('user_id')
        
        if user_id:
            if event_type == 'customer.subscription.deleted':
                subscriptions_table.delete_item(Key={'user_id': user_id})
                users_table.update_item(
                    Key={'user_id': user_id},
                    UpdateExpression='SET subscription_active = :active',
                    ExpressionAttributeValues={':active': False}
                )
            else:
                will_cancel = subscription.get('cancel_at_period_end', False)
                renews_at = datetime.fromtimestamp(subscription['current_period_end'], timezone.utc)
                subscriptions_table.update_item(
                    Key={'user_id': user_id},
                    UpdateExpression='SET #status = :status, will_cancel = :will_cancel, renews_at = :renews_at',
                    ExpressionAttributeNames={'#status': 'status'},
                    ExpressionAttributeValues={
                        ':status': subscription['status'],
                        ':will_cancel': will_cancel,
                        ':renews_at': renews_at.isoformat()
                    }
                )
                users_table.update_item(
                    Key={'user_id': user_id},
                    UpdateExpression='SET subscription_active = :active',
                    ExpressionAttributeValues={':active': subscription['status'] == 'active'}
                )

def lambda_handler(event, context):
    print(f"Payment Lambda - Full event: {json.dumps(event)}")
    print(f"Payment Lambda - Method: {event.get('httpMethod')}, Path: {event.get('path')}")
    
    cors_headers = {
        'Access-Control-Allow-Origin': 'https://overlandtrackavailability.com',
        'Access-Control-Allow-Headers': 'Content-Type,Authorization',
        'Access-Control-Allow-Methods': 'GET,POST,OPTIONS'
    }
    
    try:
        print("Getting Stripe keys...")
        stripe_keys = get_stripe_keys()
        print(f"Stripe keys loaded: {list(stripe_keys.keys())}")
        
        if not stripe_keys.get('stripe_secret_key'):
            print("ERROR: Stripe secret key not found")
            return {
                'statusCode': 500,
                'headers': cors_headers,
                'body': json.dumps({'error': 'Stripe secret key not configured'})
            }
            
        stripe.api_key = stripe_keys['stripe_secret_key']
        if stripe.api_key is None:
            print("Error: STRIPE_SECRET_KEY is not set or is None")
            return {
                'statusCode': 500,
                'headers': cors_headers,
                'body': json.dumps({'error': 'Stripe api key not set properly'})
            }
        print("Stripe API key set successfully")
        
        method = event['httpMethod']
        path = event['path']
        
        subscriptions_table = dynamodb.Table(os.environ['SUBSCRIPTIONS_TABLE'])
        
        if path == '/payment/events' and method == 'POST':
            # Handle Stripe webhook
            print(f"Webhook headers: {event.get('headers', {})}")
            payload = event['body']
            signature = event['headers'].get('stripe-signature', '') or event['headers'].get('Stripe-Signature', '')
            print(f"Found signature: {signature}")
            
            try:
                webhook_event = stripe.Webhook.construct_event(
                    payload, signature, stripe_keys['stripe_webhook_secret']
                )
                print(f"Webhook event type: {webhook_event['type']}")
                handle_webhook_event(webhook_event['type'], webhook_event['data'])
                return {'statusCode': 200, 'headers': cors_headers, 'body': 'OK'}
            except ValueError as e:
                print(f"Invalid payload: {e}")
                return {'statusCode': 400, 'headers': cors_headers, 'body': 'Invalid payload'}
            except stripe.error.SignatureVerificationError as e:
                print(f"Invalid signature: {e}")
                return {'statusCode': 400, 'headers': cors_headers, 'body': 'Invalid signature'}
        
        # All other endpoints require authentication
        print("Authenticating user...")
        user_id = get_user_from_token(event)
        print(f"User authenticated: {user_id}")
        
        if path == '/payment/session' and method == 'POST':
            print("Creating Stripe checkout session...")
            # Create Stripe checkout session
            try:
                user_email = get_user_email(user_id)
                print(f"User email: {user_email}")
                if not user_email:
                    print("ERROR: User email not found")
                    return {
                        'statusCode': 400,
                        'headers': cors_headers,
                        'body': json.dumps({'error': 'User email not found'})
                    }
                
                print("Creating Stripe session...")
                session = stripe.checkout.Session.create(
                    customer_email=user_email,
                    line_items=[{
                        'price': stripe_keys['stripe_price_id'],
                        'quantity': 1,
                    }],
                    mode='subscription',
                    success_url=f"{os.environ.get('FRONTEND_URL', 'http://localhost:4200')}/dashboard?success=true",
                    cancel_url=f"{os.environ.get('FRONTEND_URL', 'http://localhost:4200')}/dashboard",
                    subscription_data={
                        'metadata': {
                            'user_id': user_id
                        }
                    }
                )
                print(f"Stripe session created: {session.id}")
                
                return {
                    'statusCode': 200,
                    'headers': cors_headers,
                    'body': json.dumps({'checkout_url': session.url})
                }
                
            except stripe.error.StripeError as e:
                print(f"Stripe error: {str(e)}")
                return {
                    'statusCode': 400,
                    'headers': cors_headers,
                    'body': json.dumps({'error': str(e)})
                }
                
        elif path == '/payment/status' and method == 'GET':
            print(f"Getting subscription status for user: {user_id}")
            # Get subscription status
            response = subscriptions_table.get_item(Key={'user_id': user_id})
            print(f"DynamoDB response: {response}")
            
            if 'Item' not in response:
                return {
                    'statusCode': 404,
                    'headers': cors_headers,
                    'body': json.dumps({'error': 'No subscription found'})
                }
            
            subscription = response['Item']
            # Handle both old expires_at and new renews_at fields
            renews_at = subscription.get('renews_at') or subscription.get('expires_at')
            if isinstance(renews_at, str):
                renews_timestamp = int(datetime.fromisoformat(renews_at).timestamp() * 1000)
            else:
                # Handle legacy Unix timestamp data
                renews_timestamp = int(renews_at) * 1000
            
            return {
                'statusCode': 200,
                'headers': cors_headers,
                'body': json.dumps({
                    'subscription_id': subscription['subscription_id'],
                    'status': subscription['status'],
                    'renews_at': renews_timestamp,
                    'will_cancel': subscription.get('will_cancel', False)
                })
            }
        
        return {
            'statusCode': 404,
            'headers': cors_headers,
            'body': json.dumps({'error': 'Not found'})
        }
        
    except Exception as e:
        print(f"Payment Lambda error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': cors_headers,
            'body': json.dumps({'error': str(e)})
        }