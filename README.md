# Interest Rate Terraform
Configuration in this directory creates a set of resources for a user uploading interest rates to an S3 and persisting those rates to a datastore.

## Installation
Must have AWS CLI Configured

```terraform
terraform init
terraform apply
terraform destroy
```

## Workflow
![Workflow Diagram](https://user-images.githubusercontent.com/6472383/112086693-ae265f80-8b5a-11eb-8d4d-84b3a40e1b56.jpg)


## Endpoints
After the following commands you will see the following services initialized: 

| URL | Sample Input | 
| --- | ------------ | 
| API Gateway -> GET /all  | Test this in API Gateway to see a list of all uploaded rates. (Only need to click test, no parameters needed) | 
| API Gateway -> GET /rate | Run this in API Gateway to see the latest upload rate. (Only need to click test, no parameters needed) | 
| API Gateway -> POST /rate | Run this in API Gateway to get a record with a specified timestamp. Use this as a reference to put in the Request Body `{"timestamp":"2019-03-29"}` |
| S3 Bucket | Upload .json with content like this and make sure to set this to publicly available: (This is also in the repo as reference as transaction.json) 
<img width="673" alt="Screen Shot 2021-03-22 at 10 51 58 PM" src="https://user-images.githubusercontent.com/6472383/112097339-d2d80280-8b6d-11eb-882a-f0648a4d8e33.png">

```json
{
    "transactions": [
        {
            "value": "0.3",
            "type": "Simple",
            "timestamp": "2019-03-29"
        }
    ]
}
```

## Considerations
### Costs
- DynamoDB - Pay for what you use. Good for unpredictable application traffic.
- API Gateway  -With an API Requests price as low as $0.90 per million requests at the highest tier, you can decrease your costs as your API usage increases per region across your AWS accounts.
- Lambda - First 1 million requests are free.
- S3 - Pay for what you use. First 50 TB / Month	$0.023 per GB

### Efficiency
- Execution context is a temporary runtime environment that initializes any external dependencies of your Lambda function code, like database connections. This would help ensure lambda would maintain the execution context for some time in anticipation of another.
- Could also implement Transfer Acceleration to help faster upload to S3.

### Monitoring and Logging
- Currently there is monitoring implemented by default in the four lambda functions deployed. They show invocations, duration, and error count.
- For the DynamoDB Table, there is a way to add logging via CloudTrail with any DynamoDB operation.
- For the S3 Bucket, there is also an option to log s3 api calls with cloudtrail.
- Overall though that is per each service. To handle it on a more global scale, I would look to AWS Config.

### Authorization and Authentication
- Use security groups and ensuring correct roles per service with resource policies.
- Amazon Cognito user pools let you create customizable authentication and authorization solutions for your REST APIs. Amazon Cognito user pools are used to control who can invoke REST API methods. 

### Scalability and Availability
Lambda, API Gateway, and S3 are built in to be scalable.

- DynamoDB - I would enable multi-region replication with global tables. In addition, if one of the AWS Regions were to become temporarily unavailable, your customers could still access the same  data in the other Regions. It is spread across 3 geographically distinct data centers. If it was to be scaled, I would switch to use a Postgres DB rather than a DynamoDB database. 
- S3 - It wouldn't be a huge problem since it's designed to have 99.9% availability. It's a regional service. AWS automatically uses the available AZs in that region to keep the data available and safeguarded
- Lambda - Lambda runs your function in multiple Availability Zones to ensure that it is available to process events in case of a service interruption in a single zone.
- API Gateway - Can throttle requests to prevent attacks
