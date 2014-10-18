#!/usr/bin/python

from twitter import *

CONSUMER_KEY = '';
CONSUMER_SECRET = '';
OAUTH_TOKEN = '-';
OAUTH_SECRET= '';

# see "Authentication" section below for tokens and keys
t = TwitterStream(
            auth=OAuth(OAUTH_TOKEN, OAUTH_SECRET,
                       CONSUMER_KEY, CONSUMER_SECRET)
           )

# iterate over tweets matching this filter text
# IMPORTANT! this is not quite the same as a standard twitter search
#  - see https://dev.twitter.com/docs/streaming-api
tweet_iter = t.statuses.filter(track = "selfie")

print "1"
for tweet in tweet_iter:
	# check whether this is a valid tweet
	print "."
	if tweet.get('text'):
		# yes it is! print out the contents, and any URLs found inside
		print "(%s) @%s %s" % (tweet["created_at"], tweet["user"]["screen_name"], tweet["text"])
		for url in tweet["entities"]["urls"]:
			print " - found URL: %s" % url["expanded_url"]
