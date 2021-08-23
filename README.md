# Serverless workflow for stock prices movement

The application consists of multiple serverless AWS services put together for the purpose of getting hands-on experience of AWS cloud services as well as using an IaC tool such as Terraform.
The dashboard interface of the application is rather simple and easy to use, providing users with the current stock prices of 10 companies listed on NYSE as well as a one-month stock prices chart for each company.

### The app interface is available at www.aws-gabriel.de

## Overview
![Diagram](https://github.com/gabyvlad96/Serverless-workflow-for-stock-prices-movement/blob/master/.github/architecture_diagram.png)

The architecture is composed mainly of three parts:
- front-end - where the react app is served through AWS S3, Cloudwatch and Route53
- back-end - the service is composed of a lambda function that servers the data to an endpoint using API Gateway
- data-loader - this is a service that automatically scrapes data from two API sources and uploads it to AWS DynamoDB. It also can trigger automatic email alerts based on stocks price changes.

Stocks data is provided using the free-plans of these two APIS: Marketstack API and Finnhub Stock API. The data is then parsed and loaded into the DynamoDB database using `data_loader` Lambda function which is triggered at a rate of 1 minute by a CloudWatch Alarm. The database has also DynamoDB Streams enabled so it is possible to set up an alarm that is triggered by a price change in order to alert the user. Currently, only verified emails are allowed on AWS Simple Email Service(SES) so this feature has some limitations though, by building the architecture from the ground one can make use of this service.

## Get It Working
0. Prerequisites

    - AWS account with configured AWS CLI for deploying your own files
    - Terraform CLI
    - [Finnhub](https://finnhub.io) and [Marketstack](https://marketstack.com) account to get the stocks data

2. Replace secret keys for API services inside data_loader.py with your own
    - also you need to add your own verified SES emails to `prices_processor.py`

2. Zip the python files
    - Python files need to be zipped in order to be used and create the Lambda functions. Use `zip function_file_name.zip *` from inside the lambda function folder
    - You need to do this for all three functions as well as install the third-party packages where needed. [Explanation here](https://stackoverflow.com/a/57531938/13746736)
    
3. Deploy the stack
    - The current configuration uses a custom domain, so you can simply skip the Route53 configurations or use your own domain 

4. Build and upload the front-end app to S3
    - You will need to provide the react app with the API Gateway endpoints inside: `App.js` and `Dashboard.js` files.
    - Build the React application using `npm build` and upload the files to AWS S3
    
    
    
## About
The application is solely built to put my AWS skills at work and to showcase my cloud knowledge. There are many optimizations that could be done to the point where the application can be reduced to a ReactJS application only. The point was to make use of as many AWS resources as possible to test my cloud architecture and knowledge while also maintaining close to 0 costs.
