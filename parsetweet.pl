#!/usr/bin/perl

use JSON;
use Encode;
use DBI;
#use strict;

#local $/;
#open(fh, '>>:encoding(UTF-8)','tweet');
#open(fh2, '>>:encoding(UTF-8)','tweetdata');

#open(fhlog, '>>:encoding(UTF-8)','tweetlog');

my $host = "";
my $database = "";
my $user = "";
my $pw = "";

my $dbh = DBI->connect("DBI:mysql:$database;host=$host", $user, $pw)||die "Could not connect to database: $DBI::errstr"
	or die "Couldn't connect to database: " . DBI->errstr;

my $sth = $dbh->prepare("INSERT INTO `tweets`(`tid`, `match`, `text`, `lang`,`name`, `screen_name`,`profile_image_url`, `full_name`, `city`, `state`, `latitude`, `longitude`, `location`, `isjunk`,`dt`) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,curdate())")
	or die "Couldn't prepare statement: " . $dbh->errstr;
#my $sth = $dbh->prepare("INSERT INTO `tweets`(`tid`, `match`, `text`, `lang`,`name`, `screen_name`,`profile_image_url`, `full_name`, `city`, `state`, `latitude`, `longitude`, `location`, `isjunk`) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)")
#	or die "Couldn't prepare statement: " . $dbh->errstr;


my %states = (
albany => 'NY',
atl => 'GA',
atlanta => 'GA',
austin => 'TX',
baltimore => 'MD',
bayarea => 'CA',
boston => 'MA',
boulder => 'CO',
bronx => 'NY',
brooklyn => 'NY',
buffalo => 'NY',
charlotte => 'NC',
chicago => 'IL',
cleveland => 'OH',
dallas => 'TX',
dearborn => 'MI',
delaware => 'DE',
detroit => 'MI',
fayetteville => 'NC',
houston => 'TX',
jacksonville => 'FL',
lasvegas => 'NV',
la => 'CA',
losangeles => 'CA',
memphis => 'TN',
miami => 'FL',
milwaukee => 'WI',
minneapolis => 'MN',
nashville => 'TN',
neworleans => 'LA',
newyork => 'NY',
oakland => 'CA',
orlando => 'FL',
philadelphia => 'PA',
philly => 'PA',
pittsburgh => 'PA',
sacramento => 'CA',
seattle => 'WA',
tampa => 'FL',
washington => 'DC'
);

my %cities = (
atl => 'atlanta',
bayarea => 'san francisco',
delaware => 'dover',
lasvegas => 'las vegas',
la => 'los angeles',
losangeles => 'los angeles',
neworleans => 'new orleans',
newyork => 'new york',
philly => 'philadelphia'
);

#my $json_text = <$fh>;
#my $json_text = <>;
#my $logmeforlater = 0;

while (<>){
  	my @objs = JSON->new->incr_parse ($_);
    	while (my ($key1,$value1) = each (@objs)){
	  my $logme =0;
	  if(($value1->{user}->{lang} eq "en" ||  $value1->{user}->{lang} eq "es")
	   	    &&($value1->{place}->{country}||$value1->{user}->{time_zone})
	    ){
	     $value1->{place}->{country} = $value1->{place}->{country}||"";
	     $value1->{user}->{time_zone} = $value1->{user}->{time_zone}||"";
	     $value1->{user}->{location} = $value1->{user}->{location}||"";
             $value1->{coordinates} = $value1->{coordinates}||"";
	     if (($value1->{place}->{country} eq "United States") || 
		 ( ($value1->{user}->{time_zone}=~m/.*Time \(US \& Canada\)/) && (($value1->{user}->{location} =~ /\,/) || $value1->{coordinates}->{coordinates}) ) 
		){
#	 	if (($value1->{user}->{location} =~ /\,/)){
		$value1->{user}->{state} = $value1->{user}->{state}||"";
		$value1->{coordinates}->{latitude} = $value1->{coordinates}->{coordinates}[1]||0;
		$value1->{coordinates}->{longitude} = $value1->{coordinates}->{coordinates}[0]||0;
		my $loc2parse = $value1->{place}->{full_name}?$value1->{place}->{full_name}:$value1->{user}->{location};
	 	if ($loc2parse =~ /([a-z\s\.]+)\,([a-z\s\.]+)/i){
			$value1->{user}->{city} = $1;
			$value1->{user}->{state} = $2;
                        $value1->{user}->{city} =~ s/\s+$//;
                        $value1->{user}->{city} =~ s/^St\.? /Saint /i;
                        $value1->{user}->{city} =~ s/^Mt\.? /Mount /i;
                        $value1->{user}->{city} =~ s/^\s*//i;
#                        $value1->{user}->{city} =~ s/^ATL$/Atlanta/i;
#                        $value1->{user}->{city} =~ s/^LA$/Los Angeles/i;
                        $value1->{user}->{city} =~ s/^Bay Area$/San Francisco/i;
#                        $value1->{user}->{city} =~ s/^Philly$/Philadelphia/i;
		       	$_ = $value1->{user}->{state};
		       	$_ =~ s/\s|\W|\.//gi;
		       	s/^Alabama$|^ala$|^AL$/AL/i|s/^Alaska$|^AK$/AK/i|s/^Arizona$|^AZ$/AZ/i|s/^Arkansas$|^AR$/AR/i|s/^California$|^cali$|^CA$/CA/i|s/^Colorado$|^CO$/CO/i|s/^Connecticut$|^CT$/CT/i|s/^Delaware$|^DE$/DE/i|s/^Florida$|^FL$/FL/i|s/^Georgia$|^GA$/GA/i|s/^Hawaii$|^HI$/HI/i|s/^Idaho$|^ID$/ID/i|s/^Illinois$|^IL$/IL/i|s/^Indiana$|^IN$/IN/i|s/^Iowa$|^IA$/IA/i|s/^Kansas$|^KS$/KS/i|s/^Kentucky$|^KY$/KY/i|s/^Louisiana$|^LA$/LA/i|s/^Maine$|^ME$/ME/i|s/^Maryland$|^MD$/MD/i|s/^Massachusetts$|^MA$/MA/i|s/^Michigan$|^MI$/MI/i|s/^Minnesota$|^MN$/MN/i|s/^Mississippi$|^MS$/MS/i|s/^Missouri$|^MO$/MO/i|s/^Montana$|^MT$/MT/i|s/^Nebraska$|^NE$/NE/i|s/^Nevada$|^NV$/NV/i|s/^NewHampshire$|^NH$/NH/i|s/^NewJersey$|^NJ$/NJ/i|s/^NewMexico$|^NM$/NM/i|s/^NewYork$|^NY$/NY/i|s/^NorthCarolina$|^NC$/NC/i|s/^NorthDakota$|^ND$/ND/i|s/^Ohio$|^OH$/OH/i|s/^Oklahoma$|^OK$/OK/i|s/^Oregon$|^OR$/OR/i|s/^Pennsylvania$|^PA$/PA/i|s/^RhodeIsland$|^RI$/RI/i|s/^SouthCarolina$|^SC$/SC/i|s/^SouthDakota$|^SD$/SD/i|s/^Tennessee$|^TN$/TN/i|s/^Texas+$|^TX$/TX/i|s/^Utah$|^UT$/UT/i|s/^Vermont$|^VT$/VT/i|s/^Virginia$|^VA$/VA/i|s/^Washington$|^WA$/WA/i|s/^WestVirginia$|^WV$/WV/i|s/^Wisconsin$|^WI$/WI/i|s/^Wyoming$|^WY$/WY/i|s/^DistrictofColumbia$|^DC$/DC/i;
		       	if (/^AL$|^AK$|^AZ$|^AR$|^CA$|^CO$|^CT$|^DE$|^FL$|^GA$|^HI$|^ID$|^IL$|^IN$|^IA$|^KS$|^KY$|^LA$|^ME$|^MD$|^MA$|^MI$|^MN$|^MS$|^MO$|^MT$|^NE$|^NV$|^NH$|^NJ$|^NM$|^NY$|^NC$|^ND$|^OH$|^OK$|^OR$|^PA$|^RI$|^SC$|^SD$|^TN$|^TX$|^UT$|^VT$|^VA$|^WA$|^WV$|^WI$|^WY$|^DC$/){
				$value1->{user}->{state} = $_;
#					print $value1->{user}->{city}.", ".$value1->{user}->{state}."\n";
		  	} else {
		       		$_ = $value1->{user}->{city};
		       		$_ =~ s/\s|\W|\.//gi;
				if (/^(albany|atl|atlanta|austin|baltimore|bayarea|boston|boulder|bronx|brooklyn|buffalo|charlotte|chicago|cleveland|dallas|dearborn|delaware|detroit|fayetteville|houston|jacksonville|la|lasvegas|losangeles|memphis|miami|milwaukee|minneapolis|nashville|neworleans|newyork|oakland|orlando|philly|philadelphia|pittsburgh|sacramento|seattle|tampa|washington)/i){
					$value1->{user}->{city} = $cities{$1}||$1;
					$value1->{user}->{state} = $states{$1};	
				} else {
					$value1->{user}->{state} = "";
#					$logme = 1;
				}
			}
		}
#		$value1->{coordinates}->{latitude}= $value1->{coordinates}->{latitude}||0;
#		$value1->{coordinates}->{longitude}= $value1->{coordinates}->{longitude}||0;
		if( $value1->{coordinates}->{latitude} == 0
		    &&($value1->{user}->{location} =~ /^.+T:\s([234][0-9]\.\d+)\,(-\d{2,3}\.\d+)$/)
		    &&($1<=49 && $1 >=24 && $2<=-66 && $2>=-160)){
				$value1->{coordinates}->{latitude}= $1;
				$value1->{coordinates}->{longitude}= $2;
		}
# else {
#		}
		if ($value1->{user}->{state}||$value1->{coordinates}->{latitude}){
#					print $value1->{user}->{city}.", ".$value1->{user}->{state}."\n";
#	 		print fh to_json($value1);
##			print fh "\n";
		  	$value1->{text} =~ s/\n|\r//g;
			my $isjunk = 1;
			if ($value1->{text} =~ /(?:^|\s|\W|\-|\.|\*|\"|\'|\#)(ufo|floods|wildfire|blizzard|thunder storms|heatwave|earthquake|hurricane|gripa|tornado|resfrio|resfriado|congestion nasal|nariz congestionada|influenza|adenovirus|h1n1|h3n2|h5n1|ah1n1|Gastroenteritis|stomach flu|flu|gastroenteritides|gastroenterities|food poisoning|campylobacter|colitis|gastroenterocolitis|gastrointestinal disorder|gastrointestinal disease|sick to stomach|upset stomach|diarrhea and vomiting|vomitt?ing|diarrhea and cramp|diarrheas|diarrhoea|norovirus|rotavirus|gastritis|stomach bug|stomach virus|intestinal illness|intestinal sickness|Measles|measle|morbilliform rash|rubeola|morbilli|Koplik spots|Coryza|bronchoPneumonia|pneumococcal|pneumonia|pneumocystis|pneum|lung infection|chest infection|walking pneumonia|Tuberculosis|tuberculoses|tuberculose|tuberculosi|MDR TB|XDR TB|TDR TB|BCG vaccine|BCG vaccination|Pott's disease|tuberculosys|tuberculous|consumption|Koch's disease|phthisis|Mantoux test|Pertussis|pertusses|whooping cough|pertuss|bordetella|the whoops|whooping|whoop|bordetellosis|croup|paroxysmal cough\/coughing|Varicel(:?l)?a|chicken pox|chickenpox|herpes zoster|herpes virus 3|herpesvirus 3|varicella zoster|varicellovirus|herpes varicella|shingles|zoster|VZV|Meningitis|meningitide|meningitides|brain infection|neisseria meningitidis|meningities|meningiti|encephalitis|lymphocytic choriomeningitis|LCMV|choriomeningitis|LCM|meningococcal|mollarets|meningitys|meningococcus|meningoencephalitis|encephalities|tick borne disease|tick virus|tick fever|tick paralysis|babesiosis|ehrlichiosis|lyme disease|Rocky Mountain Spotted Fever|RMSF|Anaplasmosis|rickettsiosis|STARI|Southern Tick-Associated Rash Illness|TB|Tickborne Relapsing Fever|tularemia|relapsing fever|Cholera|vibrio cholera|choleragen|choleras|Dengue fever|dengue haemorrhagic fever|dengue hemorrhagic fever|dengue virus|dengue|Common Cold|colds|a cold|bad cold|nasty cold|terrible cold|cold|respiratory tract infection|rhinovirus|nasopharyngitis|rhinopharyngitis|runny nose|pharyngitis|sinusitis|nasal congestion|URI|upper respiratory infection|HRV|coronavirus|URTI|Sexually Transmitted Disease|STD|chlamydia|psitacci|the clap|trachomatis|gonorrhea|herpes|HIV|AIDS|Human Papillomavirus|HPV|Pelvic Inflammatory Disease|PID|Syphilis|Trichomoniasis|Bacterial Vaginosis|Public Lice|Public Crabs|herp|trich|Hepatitis|drip|personal problem|nature problem|urinary infection|kidney infection|discharge|Legionella|Pontiac Fever|Legionnaires' Disease|legionellosis|Malaria|Plasmodium|blackwater fever|falciparum|biduoterian fever|mosquito borne disease|West Nile Virus|WNV|mosquito virus|west nile encephalitis|west nile fever|west nile|equine encephalitis|la crosse encephalitis|japanese encephalitis|st\. louis encephalitis|anthrax|Diphtheria|Mumps|acute viral parotitis|epidemic partotitis|poliomyelitis|infantile paralysis|poliovirus|polio|Rabies|lyssa|Smallpox|Variola|Tetanus|Lockjaw|Typhoid|Enteric Fever|Typhoid Fever|Salmonella typhi|Yellow Fever|Yellow Jack|Black Vomit|vomit|hib|coke|pepsi|coca cola)(?:$|\;|\,|\s|\.|\*|\"|\'|\#)/i
			 	    || ($value1->{text}=~/ (WEE|BV|EEE|TBRF)/)				
				){
				$value1->{match} = lc($1);
				if (
				    !($value1->{text} =~ /a cold(?: |-|, )(?:self|cold|ginger|brew|cock|arizona tea|cup|bitch|salad|mill|bud|heart|place|shower|one|beer|weather|wine|day|water|world|person|summer|winter|fall|nite|drink|refreshment|bever|room|glass|and rainy|girl|dude|bottle|war|stone|dark|rainy|bath|pepsi|pop|soda|coke|front)/i)
				    && !($value1->{text} =~ /(?:drink) a cold/i)
	   	    		    &&( 
					!($value1->{text} =~ /^ ?RT/i)
#					(!($value1->{text} =~ /^ ?RT/)) || ($value1->{text} =~ /^ ?RT.*( |\b|\#)(epidemic|outbreak|plague|surge|increase|rise|alert|watch|warning)/i)
		       		    )
				    && !($value1->{text} =~ /flu.?game/i)
#			 	    && !($value1->{text}=~/http/i)
			 	    && !($value1->{text}=~/lmf?ao/i)
			 	    && !($value1->{text}=~/ nigg/i)
				    && !($value1->{text} =~ /\@$value1->{match}/i)
				    && !($value1->{text} =~ /hearing.?aids/i)
				    && !(($value1->{text} =~ /malaria/i) && ($value1->{text} =~ /(?:africa|congo)/i))
				    && !(($value1->{text} =~ /flu/i) && ($value1->{text} =~ /(?:Kobe|Jordan)/i) && ($value1->{text} =~ /game/i))
				    && !($value1->{text} =~ /band.?aid/i)
				   ){
					if ($value1->{text} =~ /head cold|chest cold|bad cold|nasty cold|terrible cold/i){
						$value1->{match} = "cold symptoms";
					} elsif ($value1->{text} =~ /resfrio|resfriado|congestion nasal|nariz congestionada/i){
						$value1->{match} = "resfrio";
					} elsif ($value1->{text} =~ /this [a-z]+ cold|this cold/i){
						$value1->{match} = "this cold";
					} elsif ($value1->{match} =~ /vomitting/i){
						$value1->{match} = "vomiting";
					} elsif (($value1->{text} =~ /gripa|gripe/i) && ($value1->{user}->{lang} eq "es")){
						$value1->{match} = "gripa";
					}
					$isjunk = 0;
				}
				#INSERT INTO tweets (tid,match,text,lang,screen_name,full_name,city,state,latitude,longitude,location)
				$sth->execute($value1->{id},$value1->{match},$value1->{text},$value1->{user}->{lang}
#						,$value1->{user}->{name},$value1->{user}->{screen_name},$value1->{user}->{profile_image_url}
						,$value1->{user}->{name},$value1->{user}->{screen_name},""
#						,$value1->{user}->{name},$value1->{user}->{screen_name},$value1->{user}->{profile_background_image_url_https}
						,$value1->{place}->{full_name},$value1->{user}->{city},$value1->{user}->{state}
						,$value1->{coordinates}->{latitude},$value1->{coordinates}->{longitude},$value1->{user}->{location}
						,$isjunk
					)
					or die "Couldn't execute statement: " . $sth->errstr;
#					print "F".$value1->{user}->{city}.", ".$value1->{user}->{state}."\n";
#				print fh2 "w=".$1."|";
#		  		print fh2 $value1->{id}."|";
#				print fh2 $value1->{user}->{city}."|";
#				print fh2 $value1->{user}->{state}."|";
#				print fh2 $value1->{coordinates}->{latitude}."|";
#				print fh2 $value1->{coordinates}->{longitude}."|";
#		  		print fh2 $value1->{place}->{country}."|";
#				print fh2 $value1->{place}->{full_name}."|";
#				print fh2 $value1->{user}->{time_zone}."|";
#				print fh2 $value1->{user}->{screen_name}."|";
#				print fh2 $value1->{user}->{lang}."|";
#				$value1->{user}->{location} =~ s/[\.\s\n]//g;
#				print fh2 $value1->{user}->{location}."|";
#				print fh2 $value1->{coordinates}->{coordinates}[1]."|";
#				print fh2 $value1->{coordinates}->{coordinates}[0]."|";
#				print fh2 $value1->{coordinates}->{type}."|";
	
#			  	print fh2 $value1->{text};
#				print fh2 "\n";
			} else {
		             	print fhlog "NOMATCH: ".$value1->{text};
				print fhlog "\n";
			}
		}
	     } else {
		#no match for country name, comma in location or coordinates
		#$logme = 1;
	     } #close location matching
	   } #close language matching
	   if ($logme ==1){
#             	print fhlog $value1->{place}->{country}."|";
#             	print fhlog $value1->{user}->{time_zone}."|";
             	print fhlog $value1->{user}->{location};
		print fhlog "\n";
	   }

	}#close parser
}# close while

$dbh->disconnect(); 
