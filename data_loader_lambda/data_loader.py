import json
import finnhub
import boto3
from decimal import Decimal
import datetime
import requests
from botocore.exceptions import ClientError

dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):
    finnhub_secret = json.loads(get_secret('finnhub'))
    finnhub_client = finnhub.Client(api_key=finnhub_secret['finnhub_api_key'])
    marketstack_secret = json.loads(get_secret('marketstack'))

    timeToPullHD = check_market_time()
    print('timeToPullHD: ' + str(timeToPullHD))
    if timeToPullHD:
        for symbol in ['AAPL', 'GME', 'PFE', 'AMC', 'AMZN', 'MSFT', 'BA', 'NVDA', 'AMD', 'SPCE']:
            resp = put_historical_data(symbol, marketstack_secret) # ~2200ms
    
    for symbol in ['AAPL', 'GME', 'PFE', 'AMC', 'AMZN', 'MSFT', 'BA', 'NVDA', 'AMD', 'SPCE']:
        put_data(symbol, finnhub_client) # ~1500ms

    return {
        'statusCode': 200,
        'body': 'Success',
    }

def get_secret(provider):
    secret_name = 'prod/data_loader/' + provider
    region_name = 'us-east-1'
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        raise e
    else:
        if 'SecretString' in get_secret_value_response:
            return get_secret_value_response['SecretString']
        else:
            return base64.b64decode(get_secret_value_response['SecretBinary'])

def put_data(symbol, client):
    table = dynamodb.Table('Stock_prices')
    stock_info = client.quote(symbol)

    response = table.update_item(
        Key={
            'symbol': symbol
        },
        UpdateExpression='set price = :p',
        ExpressionAttributeValues={
            ':p': Decimal(str(stock_info['c'])),
        },
        ReturnValues='UPDATED_NEW'
    )
    return response

def check_market_time():
    now = datetime.datetime.now().time()
    start = datetime.time(21,50)
    end = datetime.time(21,51)
    return start <= now <= end
    
def put_historical_data(symbol, secret):
    table = dynamodb.Table('Historical_data')
    params = {'access_key': secret['marketstack_api_key']}
    currentDate = datetime.datetime.now().date().isoformat()

    api_result = requests.get('http://api.marketstack.com/v1/eod?&symbols=' + symbol + '&date_from=2021-07-15&date_to=' +
        str(currentDate), params)
    api_result = api_result.json()
    data = api_result['data']

    keys = ['close', 'date']
    finalData = []
    for dict1 in data:
        finalData.append({x:(dict1[x][:10] if x == 'date' else dict1[x]) for x in keys})

    response = table.update_item(
        Key={
            'symbol': symbol
        },
        UpdateExpression='set hData = :d',
        ExpressionAttributeValues={
            ':d': json.dumps(finalData),
        },
        ReturnValues='UPDATED_NEW'
    )
    return response