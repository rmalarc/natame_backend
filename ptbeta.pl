	 	  $value1->{user}->{location} =~ /([a-z\s]+)\,([a-z\s]+)/i;
		  $_ = $2;
		  $_ =~ s/\s|\.//gi;
		  s/^Alabama$|^ala$|^AL$/AL/i|s/^Alaska$|^AK$/AK/i|s/^Arizona$|^AZ$/AZ/i|s/^Arkansas$|^AR$/AR/i|s/^California$|^cali$$|^CA$/CA/i|s/^Colorado$|^CO$/CO/i|s/^Connecticut$|^CT$/CT/i|s/^Delaware$|^DE$/DE/i|s/^Florida$|^FL$/FL/i|s/^Georgia$|^GA$/GA/i|s/^Hawaii$|^HI$/HI/i|s/^Idaho$|^ID$/ID/i|s/^Illinois$|^IL$/IL/i|s/^Indiana$|^IN$/IN/i|s/^Iowa$|^IA$/IA/i|s/^Kansas$|^KS$/KS/i|s/^Kentucky$|^KY$/KY/i|s/^Louisiana$|^LA$/LA/i|s/^Maine$|^ME$/ME/i|s/^Maryland$|^MD$/MD/i|s/^Massachusetts$|^MA$/MA/i|s/^Michigan$|^MI$/MI/i|s/^Minnesota$|^MN$/MN/i|s/^Mississippi$|^MS$/MS/i|s/^Missouri$|^MO$/MO/i|s/^Montana$|^MT$/MT/i|s/^Nebraska$|^NE$/NE/i|s/^Nevada$|^NV$/NV/i|s/^NewHampshire$|^NH$/NH/i|s/^NewJersey$|^NJ$/NJ/i|s/^NewMexico$|^NM$/NM/i|s/^NewYork$|^NY$/NY/i|s/^NorthCarolina$|^NC$/NC/i|s/^NorthDakota$|^ND$/ND/i|s/^Ohio$|^OH$/OH/i|s/^Oklahoma$|^OK$/OK/i|s/^Oregon$|^OR$/OR/i|s/^Pennsylvania$|^PA$/PA/i|s/^RhodeIsland$|^RI$/RI/i|s/^SouthCarolina$|^SC$/SC/i|s/^SouthDakota$|^SD$/SD/i|s/^Tennessee$|^TN$/TN/i|s/^Texas+$|^TX$/TX/i|s/^Utah$|^UT$/UT/i|s/^Vermont$|^VT$/VT/i|s/^Virginia$|^VA$/VA/i|s/^Washington$|^WA$/WA/i|s/^WestVirginia$|^WV$/WV/i|s/^Wisconsin$|^WI$/WI/i|s/^Wyoming$|^WY$/WY/i|s/^DistrictofColumbia$|^DC$/DC/i;
		  if (/^AL$|^AK$|^AZ$|^AR$|^CA$|^CO$|^CT$|^DE$|^FL$|^GA$|^HI$|^ID$|^IL$|^IN$|^IA$|^KS$|^KY$|^LA$|^ME$|^MD$|^MA$|^MI$|^MN$|^MS$|^MO$|^MT$|^NE$|^NV$|^NH$|^NJ$|^NM$|^NY$|^NC$|^ND$|^OH$|^OK$|^OR$|^PA$|^RI$|^SC$|^SD$|^TN$|^TX$|^UT$|^VT$|^VA$|^WA$|^WV$|^WI$|^WY$|^DC$/){
			$value1->{user}->{state} = $_;
		  } elsif($value1->{user}->{location} =~ /^.+T:\s([234][0-9]\.\d+)\,(-\d{2,3}\.\d+)$/){
			if ($1<=49 && $1 >=24 && $2<=-66 && $2>=-160){
				$value1->{coordinates}->{latitude}= $1;
				$value1->{coordinates}->{longitude}= $2;
				print $1.",".$2." ".$value1->{coordinates}->{coordinates}[1]." ".$value1->{coordinates}->{coordinates}[0]. "\n";
			}			
		  }
