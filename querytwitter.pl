#!/usr/bin/perl

my $consumer_key = 'QydRA7nKevVURVXWmX7Iw';
my $consumer_secret = 'I2fo7aYdPn1y74BQyjD2A5UesR6i6JxAHRpwRJk3Mo';
my $token = '95967905-xBftxEcsRtbc0qaZRXwkCJ8T0aRV8Dm5iGB9sL88m';
my $token_secret= 'EtIc0w0GglRalaRaZGJJxCNBV2ZEAqaXaj3rVkj9FA';


  use Net::Twitter;
  use Scalar::Util 'blessed';

  # When no authentication is required:
  my $nt = Net::Twitter->new(legacy => 0);

  # As of 13-Aug-2010, Twitter requires OAuth for authenticated requests
  my $nt = Net::Twitter->new(
      traits   => [qw/API::RESTv1_1/],
      consumer_key        => $consumer_key,
      consumer_secret     => $consumer_secret,
      access_token        => $token,
      access_token_secret => $token_secret,
  );


    my $r = $nt->search("cold");
    for my $status ( @{$r->{statuses}} ) {
        print "$status->{text}\n";
    }

exit;

  my $result = $nt->update('Hello, world!');

  eval {
      my $statuses = $nt->friends_timeline({ since_id => $high_water, count => 100 });
      for my $status ( @$statuses ) {
          print "$status->{created_at} <$status->{user}{screen_name}> $status->{text}\n";
      }
  };
  if ( my $err = $@ ) {
      die $@ unless blessed $err && $err->isa('Net::Twitter::Error');

      warn "HTTP Response Code: ", $err->code, "\n",
           "HTTP Message......: ", $err->message, "\n",
           "Twitter error.....: ", $err->error, "\n";
  }
