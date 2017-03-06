#!/usr/local/bin/python
import base64

def jpl(rawdata):
	secret = base64.b64encode(bytes(rawdata, encoding='utf-8'))
	return secret
	
def jpu(secret):
	rawdata = base64.b64decode(secret)
	return rawdata.decode('utf-8')
