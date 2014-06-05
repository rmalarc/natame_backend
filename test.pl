#!/usr/bin/perl
exit;
#use JSON;
#use Encode;
use DBI;
#use LWP::UserAgent;
use Data::Dumper;

die "test";

while (<STDIN>){
print;
}
exit;

my $pTAX_ID = $ARGV[0]||0;
my $host = "localhost";
my $database = "nowtracking";
my $user = "nowtracking";
my $pw = "";
my $DAYS = 1;

#print "Hello; $pTAX_ID";


my $dbh = DBI->connect("DBI:mysql:$database;host=$host", $user, $pw)||die "Could not connect to database: $DBI::errstr"
	or die "Couldn't connect to database: " . DBI->errstr;

if ($pTAX_ID){
	$DAYS = 15;
	dotax($pTAX_ID);
	exit;
}

my $sthtax = $dbh->prepare("SELECT text
			FROM tweets
			where isjunk = 1 and text like '%http://%'
			limit 20
; 

#			where isactive = 1;
	");
	
$sthtax->execute() or die $dbh->errstr;

while (my $tax = $sthtax->fetchrow_hashref) {
	$_ = $tax->{text};
	$_ =~ s/http\:\/\/[\w\.\/]*/\#\@URL/ig;
#s/http/\#\@URL/ig;
	print "$tax->{text}\n$_\n\n";
    }

$dbh->disconnect(); 

exit;


sub dotax(){

my $TAX_ID = $_[0];
my $sth = $dbh->prepare("
			SELECT tisjunk, concat(text,' _DOW_',cast(dayofweek(`dtm`) as char(2))) as text
			#SELECT tisjunk,text
			FROM tweets 
			where tisjunk is not null 
				and tax_id = $TAX_ID
			order by dtm desc");
	
$sth->execute() or die $dbh->errstr;

my @junk_files = ();
my @notjunk_files = ();

my $i =0;
while (my $results = $sth->fetchrow_hashref) {
	$i++;
	$results->{text} = lc($results->{text});
	$results->{text} =~ s/\@[\S]*/\#\@USERNAME/g;
#	$results->{text} =~ s/http\:\/\/[^\s$]*/\#\@URL/g;
	if ($results->{tisjunk}){
		push(@junk_files,$results->{text});
	} else {
		push(@notjunk_files,$results->{text});
	}
    }

if ($i <20){
	return;
}

my %junk_tokens = ();
my %notjunk_tokens = ();

foreach my $file (@junk_files) {
  my %tokens = tokenize($file);
  %junk_tokens = combine_hash(\%junk_tokens, \%tokens);
}

foreach my $file (@notjunk_files) {
  my %tokens = tokenize($file);
  %notjunk_tokens = combine_hash(\%notjunk_tokens, \%tokens);
}


my %total_tokens = combine_hash(\%junk_tokens, \%notjunk_tokens);

my %tax_total_tokens = ();


$sth = $dbh->prepare("SELECT tid, concat(text,' _DOW_',cast(dayofweek(`dtm`) as char(2))) as text
			FROM tweets 
			where 
			     dt >= curdate() - interval $DAYS day
			     #and tisjunk is null
			     AND 
				ISJUNK =0 
			     and tax_id = $TAX_ID
			order by dtm desc");
	
$sth->execute() or die $dbh->errstr;

my $total_junk_files = scalar(@junk_files);
my $total_notjunk_files = scalar(@notjunk_files);
my $total_files = $total_junk_files + $total_notjunk_files;
my $probability_junk = $total_junk_files / $total_files;
my $probability_notjunk = $total_notjunk_files / $total_files;




while (my $results = $sth->fetchrow_hashref) {
	$results->{text} = lc($results->{text});
	$results->{text} =~ s/\@[\S]*/\#\@USERNAME/g;
	#print "$results->{tid}\n";
	my %test_tokens = tokenize($results->{text});

	my $junk_accumulator = 1;
	my $notjunk_accumulator = 1;
	my $total_tokens = scalar(keys(%test_tokens));



	foreach my $token (keys(%test_tokens)) {
	  if (exists($total_tokens{$token})) {
	    my $p_t_w = (($junk_tokens{$token} || 0) + 1) / ($total_tokens + $total_junk_files );
	    $junk_accumulator = $junk_accumulator * $p_t_w;
	#    print "my $p_t_w = (($junk_tokens{$token} || 0) + 1) / ($total_junk_files + $total_tokens)\n";
	
	#    print "my $p_t_nw = (($notjunk_tokens{$token} || 0) + 1) / ($total_notjunk_files + $total_tokens)\n";
	    my $p_t_nw = (($notjunk_tokens{$token} || 0) + 1) / ($total_tokens + $total_notjunk_files );
	    $notjunk_accumulator = $notjunk_accumulator * $p_t_nw;
	  }
	}

	my $score_junk = bayes( $probability_junk,
	                        $total_tokens,
	                        $junk_accumulator);
	
	my $score_notjunk = bayes( $probability_notjunk,
	                           $total_tokens,
	                           $notjunk_accumulator);

	my $likelihood_junk = $score_junk / ($score_junk + $score_notjunk);
	my $likelihood_notjunk = $score_notjunk / ($score_junk + $score_notjunk);
#	my $query = "UPDATE `tweets` set pisjunk = $likelihood_junk where `tid` = $results->{tid}";
	my $sthupdate = $dbh->prepare("UPDATE `tweets` set pisjunk = $likelihood_junk where `tid` = $results->{tid}")
        	or die "Couldn't prepare statement: " . $dbh->errstr;

        $sthupdate->execute()
                                        or die "Couldn't execute statement: " . $sth->errstr;
#	printf("likelihood of junk tweet: %0.2f %%\n", ($likelihood_junk * 100));
#	printf("likelihood of good tweet: %0.2f %%\n", ($likelihood_notjunk * 100));
}


return;
}


sub bayes {
  my ($p_w, $p_t, $p_t_w) = @_;

  my $p_w_t = ($p_t_w * $p_w) / $p_t;

  return $p_w_t;
}





sub combine_hash {
  my ($hash1, $hash2) = @_;

  my %resulthash = %{ $hash1 };

  foreach my $key (keys(%{ $hash2 })) {
    if ($resulthash{$key}) {
      $resulthash{$key} += $hash2->{$key};
    } else {
      $resulthash{$key} = $hash2->{$key};
    }
  }

  return %resulthash;
}




sub tokenize {
  my $contents = shift;

  my %tokens = map { $_ => 1 } split(/\s+/, $contents);
  return %tokens;
}


sub tokenize_file {
  my $filename = shift;

  my $contents = '';
  open(FILE, $filename);
  read(FILE, $contents, -s FILE);
  close(FILE);

  return tokenize($contents);
}


