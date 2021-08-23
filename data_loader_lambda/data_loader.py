import json
import finnhub
import boto3
from decimal import Decimal
import datetime
import requests

finnhub_client = finnhub.Client(api_key="YOUR_ACCESS_KEY")
dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):
    timeToPullHD = check_market_time()
    print(timeToPullHD)
    if timeToPullHD:
        for symbol in ['AAPL', 'GME', 'PFE', 'AMC', 'AMZN', 'MSFT', 'BA', 'NVDA', 'AMD', 'SPCE']:
            resp = put_historical_data(symbol) # ~2200ms
    
    for symbol in ['AAPL', 'GME', 'PFE', 'AMC', 'AMZN', 'MSFT', 'BA', 'NVDA', 'AMD', 'SPCE']:
        put_data(symbol) # ~1500ms

    return {
        "statusCode": 200,
        "body": "Success",
    }

def put_data(symbol):
    table = dynamodb.Table('Stock_prices')
    stock_info = finnhub_client.quote(symbol)

    response = table.update_item(
        Key={
            'symbol': symbol
        },
        UpdateExpression="set price = :p",
        ExpressionAttributeValues={
            ':p': Decimal(str(stock_info['c'])),
        },
        ReturnValues="UPDATED_NEW"
    )
    return response

def check_market_time():
    now = datetime.datetime.now().time()
    start = datetime.time(19,50)
    end = datetime.time(19,51)
    return start <= now <= end
    
def put_historical_data(symbol):
    table = dynamodb.Table('Historical_data')
    params = {'access_key': 'YOUR_ACCESS_KEY'}
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
        UpdateExpression="set hData = :d",
        ExpressionAttributeValues={
            ':d': json.dumps(finalData),
        },
        ReturnValues="UPDATED_NEW"
    )
    return response