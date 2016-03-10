#!/usr/bin/env perl
# Author: Boris Sadkhin
# Summary : This tool combines the blasts
#Get Configurations
use strict;
use Config::Simple;
my %Config;
if(not -s 'blast_config.ini'){
	die "Blast config not found!\n";
}
Config::Simple->import_from('blast_config.ini', \%Config);
my $base_dir = $Config{'basedir'};
my $organism_list = "$base_dir/list_of_protein_databases";
if(not -s $organism_list){
	die "Cannot find organism list ($organism_list)";
}

#Load list and chomp list of orgs
open F, $organism_list or die $!;
my @list_of_organisms = <F>;
foreach my $org(@list_of_organisms){
	chomp $org;
}
use File::Basename;

foreach my $org(@list_of_organisms){
	my $org_name = basename($org);
	

}

