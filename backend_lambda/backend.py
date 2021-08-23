import json
import boto3
from botocore.exceptions import ClientError

dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):
    res = None
    try:
        symbol = event['queryStringParameters']['symbol']
        if event['path'] == '/shareprice':
            [price, price_alarm] = get_price(symbol)
            hData = get_h_data(symbol)
            res = {'price': str(price), 'price_alarm': str(price_alarm), 'hData': hData}
        elif event['path'] == '/updatealarm':
            res = update_alarm(symbol, event['queryStringParameters']['price'])
        elif event['path'] == '/updatealarm/turnoff':
            res = turnoff_alarm(symbol)
    except Exception as e:
        print(e)
        return "Error"
        
    return {
        "statusCode": 200,
        "headers": {
            "Access-Control-Allow-Origin": "*",
        },
        "body": json.dumps({
            "message": res,
        })
    }

def get_price(symbol):
    table = dynamodb.Table('Stock_prices')
    price = table.get_item(Key={'symbol': symbol})['Item']['price']
    price_alarm = table.get_item(Key={'symbol': symbol})['Item']['price_alarm']
    return [price, price_alarm]
    
def get_h_data(symbol):
    table = dynamodb.Table('Historical_data')
    hData = table.get_item(Key={'symbol': symbol})['Item']['hData']
    hData = json.loads(hData)
    return hData
    
def update_alarm(symbol, price):
    table = dynamodb.Table('Stock_prices')

    response = table.update_item(
        Key={
            'symbol': symbol
        },
        UpdateExpression="set price_alarm = :p",
        ExpressionAttributeValues={
            ':p': price,
        },
        ReturnValues="UPDATED_NEW"
    )
    return response
    
def turnoff_alarm(symbol):
    table = dynamodb.Table('Stock_prices')
    response = table.update_item(
        Key={
            'symbol': symbol
        },
        UpdateExpression="set price_alarm = :p",
        ExpressionAttributeValues={
            ':p': 'null',
        },
        ReturnValues="UPDATED_NEW"
    )
    return response