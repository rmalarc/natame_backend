#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use JSON;
 
use AnyEvent::Twitter::Stream;
use Log::Minimal;

binmode STDOUT, ":utf8";

$Log::Minimal::AUTODUMP=1;
$Log::Minimal::COLOR=1;

#my $parsepipe;
#open($parsepipe,"|/home/ubuntu/parsetweet.pl");

my $consumer_key = '';
my $consumer_secret = '';
my $token = '';
my $token_secret= '';
  # to use OAuth authentication
my $done = AnyEvent->condvar;

my $listener = AnyEvent::Twitter::Stream->new(
      consumer_key    => $consumer_key,
      consumer_secret => $consumer_secret,
      token           => $token,
      token_secret    => $token_secret,
      method          => "filter",
      track           => "ufo,blizzard,earthquake,tornado,gripa,resfrio,resfriado,congestion nasal,nariz congestionada,nasty cold,bad cold,terrible cold,tornado,influenza,a cold,Flu,adenovirus,h1n1,h3n2,h5n1,ah1n1,Gastroenteritis,stomach flu,gastroenteritides,gastroenterities,food poisoning,campylobacter,colitis,gastroenterocolitis,gastrointestinal disorder,gastrointestinal disease,sick to stomach,upset stomach,vomit,diarrhea and vomiting,vomiting,vomitting,diarrhea and cramp,diarrheas,diarrhoea,norovirus,rotavirus,gastritis,stomach bug,stomach virus,intestinal illness,intestinal sickness,Measles,measle,morbilliform rash,rubeola,morbilli,Koplik spots,Coryza,Pneumonia,pneum,pneumococcal,bronchopneumonia,pneumocystis,lung infection,chest infection,walking pneumonia,Tuberculosis,TB,tuberculose,tuberculoses,tuberculosi,MDR TB,XDR TB,TDR TB,BCG vaccine,BCG vaccination,Pott's disease,tuberculosys,tuberculous,consumption,Koch's disease,phthisis,Mantoux test,Pertussis,pertuss,whooping cough,pertusses,bordetella,whoop,whooping,the whoops,bordetellosis,croup,paroxysmal cough/coughing,varicela,Varicella,chicken pox,chickenpox,herpes zoster,herpes virus 3,herpesvirus 3,varicella zoster,varicellovirus,herpes varicella,shingles,zoster,VZV,Meningitis,meningiti,meningitide,meningitides,brain infection,neisseria meningitidis,meningities,encephalitis,Hib,lymphocytic choriomeningitis,LCMV,choriomeningitis,LCM,meningococcal,mollarets,meningitys,meningococcus,meningoencephalitis,encephalities,tick borne disease,tick virus,tick fever,tick paralysis,babesiosis,ehrlichiosis,lyme disease,Rocky Mountain Spotted Fever,RMSF,Anaplasmosis,rickettsiosis,STARI,Southern Tick-Associated Rash Illness,TBRF,Tickborne Relapsing Fever,tularemia,relapsing fever,Cholera,vibrio cholera,choleragen,choleras,Dengue,dengue fever,dengue haemorrhagic fever,dengue hemorrhagic fever,dengue virus,Common Cold,colds,respiratory tract infection,rhinovirus,nasopharyngitis,rhinopharyngitis,runny nose,pharyngitis,sinusitis,nasal congestion,URI,upper respiratory infection,HRV,coronavirus,URTI,Legionella,Pontiac Fever,Legionnaires' Disease,legionellosis,Malaria,Plasmodium,blackwater fever,falciparum,biduoterian fever,mosquito borne disease,West Nile Virus,WNV,mosquito virus,west nile encephalitis,west nile fever,west nile,equine encephalitis,EEE,la crosse encephalitis,japanese encephalitis,st. louis encephalitis,WEE,anthrax,Diphtheria,Mumps,acute viral parotitis,epidemic partotitis,Polio,poliomyelitis,infantile paralysis,poliovirus,Rabies,lyssa,Smallpox,Variola,Tetanus,Lockjaw,Typhoid,Enteric Fever,Typhoid Fever,Salmonelle typhi,Yellow Fever,Yellow Jack,Black Vomit",
      timeout => 5,
#      on_tweet        => sub { print "tweet"; },
on_tweet => sub {
    my $tweet = shift;
    print $tweet;
#    my $enc_tweet = encode_json $tweet;
#    $enc_tweet .= "\n";
#    print $enc_tweet;
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
