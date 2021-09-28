import boto3, json
from botocore.exceptions import ClientError

FROM_EMAIL_ADDRESS = 'SENDER_EMAIL_ADDRESS'
ses = boto3.client('ses')

def lambda_handler(event, context):
	print(json.dumps(event))
	try:
		for record in event['Records']:
			if record['eventName'] == 'MODIFY':
				handle_modify(record)
	except Exception as e: 
		print(e)

def handle_modify(record):
	print('Handling MODIFY Event')
	newImage = record['dynamodb']['NewImage']
	oldImage = record['dynamodb']['OldImage']
	symbol = newImage['symbol']
	newPrice = newImage['price']
	oldPrice = oldImage['price']
	try:
		priceAlarm = newImage['price_alarm']
	except Exception as e: 
		priceAlarm = None

	if priceAlarm is not None:
		if (newPrice['N'] >= priceAlarm['S']) and (oldPrice['N'] < priceAlarm['S']): #second condition is to avoid repetitive emails
			print('ALERT!! current price has exceeded the price alarm ' + oldPrice['N'] + ' --> ' + newPrice['N'])
			try:
				response = ses.send_email(Source=FROM_EMAIL_ADDRESS,
					Destination={ 'ToAddresses': ['RECEIVER_EMAIL_ADDRESS'] },
						Message={ 'Subject': {'Data': 'Stock price has reached your price alert value'},
		            		'Body': {'Text': {'Data': symbol['S'] + ' stock price is over ' +  priceAlarm['S']}}}
				)
			except ClientError as e:
			    print(e.response['Error']['Message'])
			else:
			    print('Email sent! Message ID:'),
			    print(response['MessageId'])

		else:
			print('The current price didn\'t trigger an alarm')

