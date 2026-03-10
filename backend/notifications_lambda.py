import json
import boto3
import uuid
import jwt
import os
from datetime import datetime
from decimal import Decimal

def decimal_default(obj):
    if isinstance(obj, Decimal):
        return int(obj)
    raise TypeError

dynamodb = boto3.resource('dynamodb')
secrets_client = boto3.client('secretsmanager')

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

def lambda_handler(event, context):
    print(f"Notifications Lambda - Full event: {json.dumps(event)}")
    print(f"Notifications Lambda - Method: {event.get('httpMethod')}, Path: {event.get('path')}")
    
    cors_headers = {
        'Access-Control-Allow-Origin': 'https://overlandtrackavailability.com',
        'Access-Control-Allow-Headers': 'Content-Type,Authorization',
        'Access-Control-Allow-Methods': 'GET,PUT,DELETE,OPTIONS'
    }
    
    try:
        print("Authenticating user...")
        user_id = get_user_from_token(event)
        print(f"User authenticated: {user_id}")
        method = event['httpMethod']
        path = event['path']
        
        notifications_table = dynamodb.Table(os.environ['NOTIFICATIONS_TABLE'])
        
        if path == '/notifications' and method == 'GET':
            print("Getting user notifications")
            # Get user's notification preferences
            response = notifications_table.query(
                KeyConditionExpression='user_id = :user_id',
                ExpressionAttributeValues={':user_id': user_id}
            )
            print(f"Found {len(response['Items'])} notifications")
            
            return {
                'statusCode': 200,
                'headers': cors_headers,
                'body': json.dumps(response['Items'], default=decimal_default)
            }
            
        elif path == '/notifications' and method == 'PUT':
            print("Creating new notification")
            # Save notification preference
            body = json.loads(event['body'])
            print(f"Notification data: {body}")
            notification_id = str(uuid.uuid4())
            
            item = {
                'user_id': user_id,
                'notification_id': notification_id,
                'dates': body['dates'],
                'quantity': body['quantity'],
                'contact_method': body['contact_method'],
                'contact_value': body['contact_value'],
                'active': body.get('active', True),
                'created_at': datetime.utcnow().isoformat()
            }
            
            notifications_table.put_item(Item=item)
            
            return {
                'statusCode': 201,
                'headers': cors_headers,
                'body': json.dumps(item, default=decimal_default)
            }
            
        elif path.startswith('/notifications/') and method == 'DELETE':
            print("Deleting notification")
            # Delete notification preference
            notification_id = path.split('/')[-1]
            print(f"Deleting notification ID: {notification_id}")
            
            notifications_table.delete_item(
                Key={
                    'user_id': user_id,
                    'notification_id': notification_id
                }
            )
            
            return {
                'statusCode': 204,
                'headers': cors_headers,
                'body': ''
            }
        
        return {
            'statusCode': 404,
            'headers': cors_headers,
            'body': json.dumps({'error': 'Not found'})
        }
        
    except Exception as e:
        print(f"Notifications Lambda error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': cors_headers,
            'body': json.dumps({'error': str(e)})
        }