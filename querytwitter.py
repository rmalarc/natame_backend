#!/usr/bin/python

from twitter import *

CONSUMER_KEY = 'RMej64Q9Sl5qGby1tRGGwA';
CONSUMER_SECRET = 'jqzIW9kIdfB18SFZK1l41PjQd7vtnG7oYXrxAENQ';
OAUTH_TOKEN = '95967905-1pi86CDekGvOnCaAUwdqKUFFyM6tYo30KSGknW94';
OAUTH_SECRET= 'IllhrT4zB1mkrIV2ZxwP1aH9msPeQzl26HOSs4';

# see "Authentication" section below for tokens and keys
t = Twitter(
            auth=OAuth(OAUTH_TOKEN, OAUTH_SECRET,
                       CONSUMER_KEY, CONSUMER_SECRET)
           )

#t.statuses.home_timeline()
#t.statuses.update(status="test")
query = t.search.tweets(q="cold")

#print query

for result in query["statuses"]:
	print result["user"]["screen_name"]
#import json
#response = urllib.urlopen("https://search.twitter.com/search.json?q=microsoft")
#pyresponse = json.load(response)
#print pyresponse
