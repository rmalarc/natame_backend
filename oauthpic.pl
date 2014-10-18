#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use JSON;
use WWW::Curl::Easy;
use WWW::Curl::Form;
 
use AnyEvent::Twitter::Stream;
use Log::Minimal;

binmode STDOUT, ":utf8";

$Log::Minimal::AUTODUMP=1;
$Log::Minimal::COLOR=1;

#my $parsepipe;
#open($parsepipe,"|/home/ubuntu/parsetweet.pl");



my $consumer_key = '';
my $consumer_secret = '';
my $token = '-';
my $token_secret= '';
  # to use OAuth authentication
my $done = AnyEvent->condvar;

my $listener = AnyEvent::Twitter::Stream->new(
      consumer_key    => $consumer_key,
      consumer_secret => $consumer_secret,
      token           => $token,
      token_secret    => $token_secret,
      method          => "filter",
      track           => "#SOSVenezuela",
      locations       => "-72.750143528,5.5130759013,-59.8863677979,12.2471804463",
#      locations       => "2.2933084,48.8574753,2.2956897,48.8590465", # eifel tower
#	locations => "-73.9871944107,40.7558974421,-73.9852115,40.7585818", #times square
#	locations => "-73.847891,40.73992,-73.835351,40.752712", #arthur ashe
      timeout => 500,
#      on_tweet        => sub { print "tweet"; },
on_tweet => sub {
    my $tweet = shift;
#    print $tweet;
    my $enc_tweet = encode_json $tweet;
    $enc_tweet .= "\n";
#    print $enc_tweet;
                if (defined($tweet->{entities}->{media}[0]->{media_url})){
#                        print $tweet->{id}." ".$tweet->{place}->{full_name}." ".$tweet->{text}." ";
#			print $tweet->{id}." ";
#                        print $tweet->{entities}->{media}[0]->{media_url}."\n";

			my $curl = WWW::Curl::Easy->new;
    			my $curlf = WWW::Curl::Form->new;
        
		        $curl->setopt(CURLOPT_HEADER,1);
		        $curl->setopt(CURLOPT_URL, 'http://natame.com/instagram/callbacktweeter.php');

    			$curlf->formadd("URL",$tweet->{entities}->{media}[0]->{media_url} );
    			$curlf->formadd("ID",$tweet->{id});
    			$curlf->formadd("HASHTAG","sosvenezuela");

    			$curl->setopt(CURLOPT_HTTPPOST, $curlf);

		        # A filehandle, reference to a scalar or reference to a typeglob can be used here.
		        my $response_body;
		        $curl->setopt(CURLOPT_WRITEDATA,\$response_body);

	        	# Starts the actual request
        		my $retcode = $curl->perform;

		
                }

#    print encode_json $tweet;
#    print "\n";
#    print($tweet->{user}{screen_name}.' : '.$tweet->{text}."\n");
  },

  on_error => sub {
    my $error = shift;
    warn "ERROR: $error";
    $done->send;
#    sleep 2;

#    $done->recv;
#    $done->recv;
  },
  on_eof => sub {
#     return;
   $done->send;
  },
  );


$done->recv;
