import json
import boto3
import bcrypt
import jwt
import uuid
from datetime import datetime, timedelta
import os

dynamodb = boto3.resource('dynamodb')
secrets_client = boto3.client('secretsmanager')

def get_jwt_secret():
    secret = secrets_client.get_secret_value(SecretId=os.environ['APP_SECRETS_ARN'])
    return json.loads(secret['SecretString'])['jwt_secret']

def hash_password(password):
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()

def verify_password(password, hashed):
    return bcrypt.checkpw(password.encode(), hashed.encode())

def generate_token(user_id, email):
    payload = {
        'user_id': user_id,
        'email': email,
        'exp': datetime.utcnow() + timedelta(days=2)
    }
    return jwt.encode(payload, get_jwt_secret(), algorithm='HS256')

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])
        path = event['path']
        method = event['httpMethod']
        
        users_table = dynamodb.Table(os.environ['USERS_TABLE'])
        
        if path == '/auth' and method == 'POST':
            # Login
            email = body['email']
            
            response = users_table.query(
                IndexName='email-index',
                KeyConditionExpression='email = :email',
                ExpressionAttributeValues={':email': email}
            )
            
            if not response['Items'] or not verify_password(body['password'], response['Items'][0]['password']):
                return {
                    'statusCode': 401,
                    'body': json.dumps({'error': 'Invalid credentials'})
                }
            
            user = response['Items'][0]
            token = generate_token(user['user_id'], user['email'])
            
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'token': token,
                    'user': {
                        'user_id': user['user_id'],
                        'email': user['email'],
                        'subscription_active': user.get('subscription_active', False)
                    }
                })
            }
            
        elif path == '/auth/register' and method == 'POST':
            # Register
            email = body['email']
            password = hash_password(body['password'])
            user_id = str(uuid.uuid4())
            
            # Check if user exists
            response = users_table.query(
                IndexName='email-index',
                KeyConditionExpression='email = :email',
                ExpressionAttributeValues={':email': email}
            )
            
            if response['Items']:
                return {
                    'statusCode': 400,
                    'body': json.dumps({'error': 'User already exists'})
                }
            
            # Create user
            users_table.put_item(Item={
                'user_id': user_id,
                'email': email,
                'password': password,
                'subscription_active': False,
                'created_at': datetime.utcnow().isoformat()
            })
            
            token = generate_token(user_id, email)
            
            return {
                'statusCode': 201,
                'body': json.dumps({
                    'token': token,
                    'user': {
                        'user_id': user_id,
                        'email': email,
                        'subscription_active': False
                    }
                })
            }
        
        return {
            'statusCode': 404,
            'body': json.dumps({'error': 'Not found'})
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }