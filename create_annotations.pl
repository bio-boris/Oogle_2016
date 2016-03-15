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
my $annotation_headers = "$base_dir/list_of_annotations";
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

#Get Headers Line
open F, $annotation_headers or die $!;
my $header = <F>;
close F;
$header = "phytozomeName\t$header";

foreach my $org(@list_of_organisms){
	my $annotation_directory = dirname("$base_dir/$org");
	my $org_name = basename($org);
	$org_name =~ s/\.protein\.fa//g;
	my $annotation_file = "$annotation_directory/$org_name.annotation_info.txt";
	print "Opening $annotation_file to prepend the organism_name";
	open F, $annotation_file or die $!;
	open O, ">$annotation_file.table.tmp";
	while(<F>){
		if($. == 1){
			print O $header;
		}
		else{
			print O "$org_name\t$_";
		}
	}
	close O;
	system("mv $annotation_file.table.tmp $annotation_file.table");
	print "Printed to $annotation_file.table\n";

}

