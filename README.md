# ECS Api Gateway Terraform
Configuration in this directory creates a set of resources for a user to fetch pets to a datastore.

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
| API Gateway -> GET /petstore/pets/{petId} | Use the Invoke Url in API Gateway or can run requests with Postman. | 
| API Gateway -> POST /petstore/pets/{petId} | Use the Invoke Url in API Gateway or can run requests with Postman. Use this as a reference to put in the Request Body |

```json
{
  "name": "Spot"
}
```

## Considerations
### Resources
- VPC - defaults to 1 Public and 1 Private Subnet
- Internet Gateway for VPN to access Internet
- NAT Gateway for Private Subnet to Fetch Docker Image
- Security Group that Allows Access to ECS Containers
- ECS Cluster with a Service and Task Definition to Run Docker Containers
- DynamoDB Table that will store Pet Information
- API Gateway that will expose containerized services to the user. Composed of a route with a path "/petstore/pets/{petId}", and integration is done with a VPC link to AWS Cloud Map which points to the ECS Services. API Gateway uses that link in order to connect to them privately, that way ECS can be launched in a private subnet. Also API Gateway is the one that does authorization so that way it doesn't need to be done in the code itself.
- AWS CloudMap provides service discovery. API Gateway uses Cloud Map for the physical address of the ECS containers. This is also enabled on the ECS side for service discovery.
- Cognito (User Pools) for User Authentication. Once user is granted access, a JWT Access Token is used for authorizing requests. In this case, only the POST is authorized.

### Costs
- DynamoDB - Pay for what you use. Good for unpredictable application traffic.
- API Gateway  -With an API Requests price as low as $0.90 per million requests at the highest tier, you can decrease your costs as your API usage increases per region across your AWS accounts.
- ECS - Pay for what you use.
- CloudMap - $0.10 per registered resource (for example, an EC2 instance) per month*
* All the resources registered via Amazon ECS Service Discovery are free, and you pay for lookup queries and associated DNS charges only.

### API Gateway vs Application Load Balancer
- Authentication and Authorization (Token-Based Authorization)
- If replaced with ALB, can save more money.


### Monitoring and Logging
- Currently, there is default monitoring for ECS.
- For the DynamoDB Table, there is a way to add logging via CloudTrail with any DynamoDB operation.
- Overall though that is per each service. To handle it on a more global scale, I would look to AWS Config.

### Authorization and Authentication
- Use security groups and ensuring correct roles per service with resource policies.
- Amazon Cognito user pools let you create customizable authentication and authorization solutions for your APIs. Amazon Cognito user pools are used to control who can invoke the methods you choose. In this architecture, I have my GET available to everyone, but the PUT is what has authorization.

### Scalability and Availability
Lambda, API Gateway, and S3 are built in to be scalable.

- DynamoDB - I would enable multi-region replication with global tables. In addition, if one of the AWS Regions were to become temporarily unavailable, your customers could still access the same  data in the other Regions. It is spread across 3 geographically distinct data centers. If it was to be scaled, I would switch to use a Postgres DB rather than a DynamoDB database. 
- ECS - I purposely used Fargate so that the containers are launched on the Fargate serverless compute engine, and you don't have to provision or manage any ECS2 instances. Could also enable auto scaling.
- CloudMap - has Health checks to ensure all the tasks are healthy
- API Gateway - Can throttle requests to prevent attacks
