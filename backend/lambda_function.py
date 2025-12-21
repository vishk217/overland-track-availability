import json
import boto3
import os
from automation import OverlandTrackAutomation

def lambda_handler(event, context):
    try:
        # Run the automation
        automation = OverlandTrackAutomation()
        result = automation.automation()
        
        # Check if automation returned valid data
        if not result or not result.get('response'):
            raise Exception("Automation failed to return valid data")
        
        # Upload to S3 only if automation succeeded
        s3 = boto3.client('s3')
        bucket_name = os.environ.get('S3_BUCKET', 'overland-track-data')
        
        s3.put_object(
            Bucket=bucket_name,
            Key='availability.json',
            Body=json.dumps(result, indent=2),
            ContentType='application/json',
            CacheControl='max-age=300'
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Automation completed successfully',
                'lastUpdated': result.get('lastUpdated'),
                'dataCount': len(result.get('response', {}))
            })
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e)
            })
        }