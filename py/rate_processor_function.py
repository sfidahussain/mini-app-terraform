import boto3, urllib, json
s3 = boto3.client('s3')

def lambda_handler(event, context):
    #1 - Get the bucket name
    bucket = event['Records'][0]['s3']['bucket']['name']
    dynamodb = boto3.resource('dynamodb', endpoint_url="https://dynamodb.us-east-1.amazonaws.com")
    table = dynamodb.Table('Rates')

    #2 - Get the file/key name
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    
    try:
        #3 - Fetch the file from S3
        response = s3.get_object(Bucket=bucket, Key=key)
        
        #4 - Deserialize the file's content
        text = response["Body"].read().decode()
        data = json.loads(text)
        
        #5 - Print the content
        print(data)
        
        #6 - Parse and print the transactions
        transactions = data['transactions']
        for record in transactions:
            print(record)
            #7 - Parse and save the transactions
            response = table.put_item(
                   Item={
                        'value': record['value'],
                        'type': record['type'],
                        'timestamp': record['timestamp']
                    }
                )
                
        return 'Success'
        
    except Exception as e:
        print(e)
        raise e
