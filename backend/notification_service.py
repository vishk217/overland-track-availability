import json
import boto3
import os
from datetime import datetime, timedelta
from automation import OverlandTrackAutomation

dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')
s3 = boto3.client('s3')

def get_previous_availability():
    try:
        response = s3.get_object(
            Bucket=os.environ['S3_BUCKET'],
            Key='availability.json'
        )
        return json.loads(response['Body'].read())
    except:
        return None

def check_rate_limit(user_id):
    history_table = dynamodb.Table(os.environ['NOTIFICATION_HISTORY_TABLE'])
    today = datetime.utcnow().strftime('%Y-%m-%d')
    
    response = history_table.query(
        KeyConditionExpression='user_id = :user_id AND begins_with(sent_at, :today)',
        ExpressionAttributeValues={
            ':user_id': user_id,
            ':today': today
        }
    )
    
    return len(response['Items']) < 5  # Max 5 notifications per day

def send_notification(user_id, contact_method, contact_value, message):
    if not check_rate_limit(user_id):
        print(f"Rate limit exceeded for user {user_id}")
        return
    
    try:
        if contact_method == 'email':
            sns.publish(
                TopicArn=os.environ['EMAIL_TOPIC_ARN'],
                Message=message,
                Subject='Overland Track Availability Alert',
                MessageAttributes={
                    'email': {'DataType': 'String', 'StringValue': contact_value}
                }
            )
        elif contact_method == 'sms':
            sns.publish(
                PhoneNumber=contact_value,
                Message=message
            )
        
        # Log notification
        history_table = dynamodb.Table(os.environ['NOTIFICATION_HISTORY_TABLE'])
        history_table.put_item(Item={
            'user_id': user_id,
            'sent_at': datetime.utcnow().isoformat(),
            'contact_method': contact_method,
            'message': message,
            'expires_at': int((datetime.utcnow() + timedelta(days=30)).timestamp())
        })
        
    except Exception as e:
        print(f"Failed to send notification: {e}")

def check_availability_changes(current_data, previous_data):
    if not previous_data:
        return []
    
    changes = []
    current_response = current_data.get('response', {})
    previous_response = previous_data.get('response', {})
    
    for date, availability in current_response.items():
        previous_availability = previous_response.get(date, 'Unknown')
        
        # Check if availability improved
        if (previous_availability == 'Fully Booked' and 
            availability != 'Fully Booked' and 
            'spots left' in availability):
            
            spots = int(availability.split()[0]) if availability.split()[0].isdigit() else 0
            changes.append({
                'date': date,
                'availability': availability,
                'spots': spots
            })
    
    return changes

def lambda_handler(event, context):
    print(f"Lambda execution started at {datetime.utcnow().isoformat()}")
    try:
        # Get current availability data
        print("Fetching current availability data...")
        automation = OverlandTrackAutomation()
        current_data = automation.automation()
        
        if not current_data:
            print("ERROR: Failed to get availability data")
            return {'statusCode': 500, 'body': 'Failed to get availability data'}
        
        print(f"Current data retrieved: {len(current_data.get('response', {}))} dates")
        
        # Get previous data
        print("Fetching previous availability data...")
        previous_data = get_previous_availability()
        print(f"Previous data: {'Found' if previous_data else 'Not found'}")
        
        # Check for changes
        print("Checking for availability changes...")
        changes = check_availability_changes(current_data, previous_data)
        print(f"Changes detected: {len(changes)}")
        
        if changes:
            print(f"Processing {len(changes)} availability changes")
            for change in changes:
                print(f"  - {change['date']}: {change['availability']}")
            
            # Get all active notification preferences with pagination
            notifications_table = dynamodb.Table(os.environ['NOTIFICATIONS_TABLE'])
            notifications_sent = 0
            
            last_evaluated_key = None
            while True:
                scan_kwargs = {
                    'FilterExpression': 'active = :active',
                    'ExpressionAttributeValues': {':active': True},
                    'Limit': 100  # Process 100 items at a time
                }
                
                if last_evaluated_key:
                    scan_kwargs['ExclusiveStartKey'] = last_evaluated_key
                
                response = notifications_table.scan(**scan_kwargs)
                print(f"Processing {len(response['Items'])} notification preferences")
                
                for notification in response['Items']:
                    user_dates = notification['dates']
                    min_quantity = notification['quantity']
                    
                    # Check if any changes match user preferences
                    for change in changes:
                        if (change['date'] in user_dates and 
                            change['spots'] >= min_quantity):
                            
                            message = f"Overland Track availability alert!\n\n"
                            message += f"Date: {change['date']}\n"
                            message += f"Availability: {change['availability']}\n"
                            message += f"Book now: https://azapps.customlinc.com.au/tasparksoverland/"
                            
                            print(f"Sending notification to user {notification['user_id']} for {change['date']}")
                            send_notification(
                                notification['user_id'],
                                notification['contact_method'],
                                notification['contact_value'],
                                message
                            )
                            notifications_sent += 1
                            break  # Only send one notification per user per run
                
                # Check if there are more items to process
                last_evaluated_key = response.get('LastEvaluatedKey')
                if not last_evaluated_key:
                    break
        
        # Upload current data to S3
        print("Uploading current data to S3...")
        s3.put_object(
            Bucket=os.environ['S3_BUCKET'],
            Key='availability.json',
            Body=json.dumps(current_data, indent=2),
            ContentType='application/json',
            CacheControl='max-age=300'
        )
        print("S3 upload completed")
        
        result = {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Notification check completed',
                'changes_found': len(changes),
                'notifications_sent': notifications_sent if changes else 0,
                'lastUpdated': current_data.get('lastUpdated'),
                'dataCount': len(current_data.get('response', {}))
            })
        }
        print(f"Lambda execution completed successfully: {result['body']}")
        return result
        
    except Exception as e:
        print(f"ERROR: Lambda execution failed: {str(e)}")
        import traceback
        print(f"Traceback: {traceback.format_exc()}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }