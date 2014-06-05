#!/usr/bin/perl

use JSON;
use Encode;
use DBI;
#use strict;

#local $/;
#open(fh, '>>:encoding(UTF-8)','tweet');
#open(fh2, '>>:encoding(UTF-8)','tweetdata');

#open(fhlog, '>>:encoding(UTF-8)','tweetlog');

my $host = "localhost";
my $database = "nowtracking";
my $user = "nowtracking";
my $pw = "";

my $dbh = DBI->connect("DBI:mysql:$database;host=$host", $user, $pw)||die "Could not connect to database: $DBI::errstr"
	or die "Couldn't connect to database: " . DBI->errstr;

my $sth = $dbh->prepare("INSERT INTO `tweets`(`tid`, `match`, `text`, `lang`,`name`, `screen_name`,`profile_image_url`, `full_name`, `city`, `state`, `latitude`, `longitude`, `location`, `isjunk`,`dt`) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,curdate())")
	or die "Couldn't prepare statement: " . $dbh->errstr;
#my $sth = $dbh->prepare("INSERT INTO `tweets`(`tid`, `match`, `text`, `lang`,`name`, `screen_name`,`profile_image_url`, `full_name`, `city`, `state`, `latitude`, `longitude`, `location`, `isjunk`) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)")
#	or die "Couldn't prepare statement: " . $dbh->errstr;



#my $json_text = <$fh>;
#my $json_text = <>;
#my $logmeforlater = 0;

while (<>){
  	my @objs = JSON->new->incr_parse ($_);
#  	my @objs = JSON->new->parse ($_);
    	while (my ($key1,$value1) = each (@objs)){
	  	my $logme =0;
#		print $value1[0];
#		$value1->{entities}->{media}->{media_url} = $value1->{entities}->{media}->{media_url}||"";
		if (defined($value1->{entities}->{media}[0]->{media_url})){
	  		print $value1->{id}." ".$value1->{place}->{full_name}." ".$value1->{text}." ";
			print $value1->{entities}->{media}[0]->{media_url}."\n";
		}
#	  	$value1->{place}->{country} = $value1->{place}->{country}||"";
#	  	$value1->{user}->{time_zone} = $value1->{user}->{time_zone}||"";
#	  	$value1->{user}->{location} = $value1->{user}->{location}||"";
 #         	$value1->{coordinates} = $value1->{coordinates}||"";
  #      	$value1->{coordinates}->{latitude} = $value1->{coordinates}->{coordinates}[1]||0;
#		$value1->{coordinates}->{longitude} = $value1->{coordinates}->{coordinates}[0]||0;
#				$sth->execute($value1->{id},$value1->{match},$value1->{text},$value1->{user}->{lang}
#						,$value1->{user}->{name},$value1->{user}->{screen_name},""
#						,$value1->{place}->{full_name},$value1->{user}->{city},$value1->{user}->{state}
#						,$value1->{coordinates}->{latitude},$value1->{coordinates}->{longitude},$value1->{user}->{location}
#						,$isjunk
#					)
#					or die "Couldn't execute statement: " . $sth->errstr;

	}#close parser
}# close while

$dbh->disconnect(); 
