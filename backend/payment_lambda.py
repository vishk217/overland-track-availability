import json
import boto3
import stripe
import jwt
import os
import hmac
import hashlib
from datetime import datetime, timedelta

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

def verify_webhook_signature(payload, signature, webhook_secret):
    expected_signature = hmac.new(
        webhook_secret.encode(),
        payload.encode(),
        hashlib.sha256
    ).hexdigest()
    return hmac.compare_digest(f"sha256={expected_signature}", signature)

def handle_webhook_event(event_type, data):
    users_table = dynamodb.Table(os.environ['USERS_TABLE'])
    subscriptions_table = dynamodb.Table(os.environ['SUBSCRIPTIONS_TABLE'])
    
    if event_type == 'customer.subscription.created':
        subscription = data['object']
        # Get user_id from subscription metadata
        user_id = subscription.get('metadata', {}).get('user_id')
        
        if user_id:
            expires_at = datetime.utcnow() + timedelta(days=30)
            
            subscriptions_table.put_item(Item={
                'user_id': user_id,
                'subscription_id': subscription['id'],
                'status': subscription['status'],
                'expires_at': int(expires_at.timestamp()),
                'created_at': datetime.utcnow().isoformat()
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
                subscriptions_table.update_item(
                    Key={'user_id': user_id},
                    UpdateExpression='SET #status = :status',
                    ExpressionAttributeNames={'#status': 'status'},
                    ExpressionAttributeValues={':status': subscription['status']}
                )
                users_table.update_item(
                    Key={'user_id': user_id},
                    UpdateExpression='SET subscription_active = :active',
                    ExpressionAttributeValues={':active': subscription['status'] == 'active'}
                )

def lambda_handler(event, context):
    cors_headers = {
        'Access-Control-Allow-Origin': 'https://overlandtrackavailability.com',
        'Access-Control-Allow-Headers': 'Content-Type,Authorization',
        'Access-Control-Allow-Methods': 'GET,POST,OPTIONS'
    }
    
    try:
        stripe_keys = get_stripe_keys()
        
        if not stripe_keys.get('stripe_secret_key'):
            return {
                'statusCode': 500,
                'headers': cors_headers,
                'body': json.dumps({'error': 'Stripe secret key not configured'})
            }
            
        stripe.api_key = stripe_keys['stripe_secret_key']
        
        method = event['httpMethod']
        path = event['path']
        
        subscriptions_table = dynamodb.Table(os.environ['SUBSCRIPTIONS_TABLE'])
        
        if path == '/payment/events' and method == 'POST':
            # Handle Stripe webhook
            payload = event['body']
            signature = event['headers'].get('stripe-signature', '')
            
            if not verify_webhook_signature(payload, signature, stripe_keys['stripe_webhook_secret']):
                return {'statusCode': 400, 'headers': cors_headers, 'body': 'Invalid signature'}
            
            webhook_event = json.loads(payload)
            handle_webhook_event(webhook_event['type'], webhook_event['data'])
            
            return {'statusCode': 200, 'headers': cors_headers, 'body': 'OK'}
        
        # All other endpoints require authentication
        user_id = get_user_from_token(event)
        
        if path == '/payment/session' and method == 'POST':
            # Create Stripe checkout session
            try:
                user_email = get_user_email(user_id)
                if not user_email:
                    return {
                        'statusCode': 400,
                        'headers': cors_headers,
                        'body': json.dumps({'error': 'User email not found'})
                    }
                
                session = stripe.checkout.Session.create(
                    customer_email=user_email,
                    payment_method_types=['card'],
                    line_items=[{
                        'price': stripe_keys['stripe_price_id'],
                        'quantity': 1,
                    }],
                    mode='subscription',
                    success_url=f"{os.environ.get('FRONTEND_URL', 'http://localhost:4200')}/dashboard?success=true",
                    cancel_url=f"{os.environ.get('FRONTEND_URL', 'http://localhost:4200')}/billing?cancelled=true",
                    subscription_data={
                        'metadata': {
                            'user_id': user_id
                        }
                    }
                )
                
                return {
                    'statusCode': 200,
                    'headers': cors_headers,
                    'body': json.dumps({'checkout_url': session.url})
                }
                
            except stripe.error.StripeError as e:
                return {
                    'statusCode': 400,
                    'headers': cors_headers,
                    'body': json.dumps({'error': str(e)})
                }
                
        elif path == '/payment/status' and method == 'GET':
            # Get subscription status
            response = subscriptions_table.get_item(Key={'user_id': user_id})
            
            if 'Item' not in response:
                return {
                    'statusCode': 404,
                    'headers': cors_headers,
                    'body': json.dumps({'error': 'No subscription found'})
                }
            
            subscription = response['Item']
            return {
                'statusCode': 200,
                'headers': cors_headers,
                'body': json.dumps({
                    'subscription_id': subscription['subscription_id'],
                    'status': subscription['status'],
                    'expires_at': datetime.fromtimestamp(subscription['expires_at']).isoformat()
                })
            }
        
        return {
            'statusCode': 404,
            'headers': cors_headers,
            'body': json.dumps({'error': 'Not found'})
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': cors_headers,
            'body': json.dumps({'error': str(e)})
        }