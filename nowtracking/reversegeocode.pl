#!/usr/bin/perl
#exit;
use JSON;
use Encode;
use DBI;
use LWP::UserAgent;
my $curl = LWP::UserAgent->new( timeout => 120 );


my $host = "";
my $database = "";
my $user = "";
my $pw = "";

my $dbh = DBI->connect("DBI:mysql:$database;host=$host", $user, $pw)||die "Could not connect to database: $DBI::errstr"
	or die "Couldn't connect to database: " . DBI->errstr;




$sth = $dbh->prepare("SELECT `tid`, latitude, longitude 
			FROM tweets t
			inner join TAXONOMY tx on tx.tax_id = t.tax_id
			where latitude <>0 and longitude <>0 
				and isjunk = 0 
				and (pisjunk is null or pisjunk <= bayes_p)
				and feature_id is null 
				and county is null 
				and (deleteme <> 1 or deleteme is null)
				and dt <= curdate() - interval 1 day
#				and date(dtm) = '2012-05-31'
			order by dt desc, pisjunk asc limit 0,2500");
	
$sth->execute() or die $dbh->errstr;
my $count = 0;
while (my $results = $sth->fetchrow_hashref) {
	$count++;
	my $url = "http://maps.googleapis.com/maps/api/geocode/json?latlng=$results->{latitude},$results->{longitude}&sensor=true";
	my $response = $curl->post($url, Content => $xml);
#	print "$url\n";
	my $jloc = JSON->new->decode ($response->decoded_content);


	if ($response->is_success) {
	#     print $response->decoded_content;  # or whatever
	}
	else {
	     print "Exiting due to: $response->status_line. $count records processed, TID: $results->{tid}, $results->{latitude},$results->{longitude}\n";
	     die;
	}


	my $state = "";
	my $city = "";
	my $city2 = "";
	my $county = "";
	my $country = "";


	for( my $i=0; $i<scalar(@{$jloc->{results}[0]->{address_components}});$i++){
		if ($jloc->{results}[0]->{address_components}[$i]->{types}[0] eq "administrative_area_level_1"){
			$state = $jloc->{results}[0]->{address_components}[$i]->{short_name};
		};
		if ($jloc->{results}[0]->{address_components}[$i]->{types}[0] eq "administrative_area_level_2"){
			$county = $jloc->{results}[0]->{address_components}[$i]->{long_name};
		};
		if ($jloc->{results}[0]->{address_components}[$i]->{types}[0] eq "locality"){
			$city  = $jloc->{results}[0]->{address_components}[$i]->{long_name};
		}
		if ($jloc->{results}[0]->{address_components}[$i]->{types}[0] eq "sublocality"){
			$city2 = $jloc->{results}[0]->{address_components}[$i]->{long_name};
		};
		if ($jloc->{results}[0]->{address_components}[$i]->{types}[0] eq "country"){
			$country = $jloc->{results}[0]->{address_components}[$i]->{short_name};
		};
#		print $jloc->{results}[0]->{address_components}[$i]->{short_name}." - ". $jloc->{results}[0]->{address_components}[$i]->{types}[0]."\n";
	}
	if( $city eq ""){
		$city = $city2;
	}
#        print $results->{tid}." - ". $results->{latitude} . ", " . $results->{longitude};
#	print "$results->{tid} $city, $state $country\n";
#	if (!( $city eq "" || $state eq "" || !($country eq "US"))){
#		$results->{tid} =~ s/\'//;
#		my $query = "UPDATE `tweets` SET CITY = '$city', state = '$state', county = '$county' where `tid` = $results->{tid};";
##	} else {
#		my $query = "UPDATE `tweets` SET DELETEME 1 where `tid` = $results->{tid};";
#			print "print $jloc->{status} Blank city/state\n";
#	}
	if (!($jloc->{status} eq "OK")){
		print "Marking for deletion due to: $jloc->{status}. $count records processed, TID: $results->{tid}, $results->{latitude},$results->{longitude}\n";
		my $sth2 = $dbh->prepare("UPDATE `tweets` SET DELETEME = 1, COUNTY='' where `tid` = ?;")
        		or die "Couldn't prepare statement: " . $dbh->errstr;
		$sth2->execute($results->{tid}) or die $dbh->errstr;
#		exit;
	}
	if (length($state) <= 2 && $country eq "US"){
		my $sth2 = $dbh->prepare("UPDATE `tweets` SET CITY = ?, state = ?, county = ? where `tid` = ?;")
        		or die "Couldn't prepare statement: " . $dbh->errstr;
		$city =~ s/^St /Saint /;
		$city =~ s/^Mt /Mount /;
#		print "UPDATE `tweets` SET CITY = '$city', state = '$state', county = '$county' where `tid` = $results->{tid};";
		$sth2->execute($city, $state, $county, $results->{tid}) or die $dbh->errstr;
	} else {
		my $sth2 = $dbh->prepare("UPDATE `tweets` SET DELETEME = 1, COUNTY=? where `tid` = ?;")
        		or die "Couldn't prepare statement: " . $dbh->errstr;
#		print "UPDATE `tweets` SET DELETEME = 1, COUNTY='$country' where `tid` = $results->{tid};\n";
		$sth2->execute($country, $results->{tid}) or die $dbh->errstr;
	};
	select(undef, undef, undef, 0.25);
	#sleep 1;
    }

print "Exiting gracefully. $count records processed";

$dbh->disconnect(); 

exit;


