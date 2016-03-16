#!/usr/bin/perl
use strict;
use warnings;

my @file_list = split "\n", `ls | grep protein.fa\$`;
use DBI;

my $dsn      = "dbi:mysql:dbname=orim";
my $user     = "orim";
my $password = "mypass";
my $dbh = DBI->connect($dsn, $user, $password, {
                PrintError       => 0,
                RaiseError       => 1,
                AutoCommit       => 1,
                FetchHashKeyName => 'NAME_lc',
                });


chomp(my $pwd = `pwd`);
mkdir("completed");
foreach my $file(@file_list){
        print "Inserting $pwd/$file\n";

        my $command = "LOAD DATA INFILE '$pwd/$file'
                INTO TABLE BLAST
                FIELDS TERMINATED BY " . "'\t'"  ;
        my $sth = $dbh->prepare($command);
        $sth->execute();
        system("mv $file completed/$file");

}
