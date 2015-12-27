#!/usr/bin/perl -w

use strict;
use warnings;
use Time::HiRes qw(usleep);


use Fcntl ':flock'; # import LOCK_* constants

INIT{
  open  *{0}
        or die "What!? $0:$!";
  flock *{0}, LOCK_EX|LOCK_NB
    or die "$0 is already running !\n";
}


my $currFileGz;
my $currFile;
my $copyStatus=0;
my $firstSeq=`ls -tr1 /data_files/stlprd/billing/unit1/veraz7  |  awk -F\. '{print \$6}' | tail -1  ` ;
my $lastSeq=`ssh ics\@192.114.69.10 ls -ltr /cdr/ICDR/raw/M_\* | awk '{print \$9}' | awk -F\. '{print \$6}'|  tail -1`;


#logged the date
my $date=`date`;
print "$date";


# Will always miss the last one in case the last one is still busy writing.
for (my $currSeq = $firstSeq+1; $currSeq < $lastSeq; $currSeq++) {
   $currFileGz=`ssh ics\@192.114.69.10 "ls -t1 /cdr/ICDR/raw/M_*  " | awk -F\. '\$6 == $currSeq' | tail -1`;
   chomp($currFileGz);
   $currFile = $currFileGz;
   $currFile =~ s/\/cdr\/ICDR\/raw\///;
   if (-e "/data_files/stlprd/billing/unit1/veraz7/$currFile") {
      print "File has already copied processed, continue to the next one...\n";
   } else {
      print "Copying file- $currFileGz \n " ;
      #scp("ics\@192.114.69.10:/cdr/ICDR/raw/$currFileGz","/data_files/stlprd/billing/unit1/veraz7") or die $!;
      `scp ics\@192.114.69.10:$currFileGz /data_files/stlprd/billing/unit1/veraz7 && chown operstl:operstl /data_files/stlprd/billing/unit1/veraz7/$currFile`;


   }
}


print "first=$firstSeq" . "last=$lastSeq\n";
exit $copyStatus;

