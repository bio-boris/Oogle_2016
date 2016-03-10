#!/usr/bin/env perl
# Author: Boris Sadkhin
# Summary : This tool does a blast, based on a list of organisms called organism_list
#Get Configurations
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
open F, $organism_list or die $!;
my @list_of_orgs = <F>;
print "My orgs:
