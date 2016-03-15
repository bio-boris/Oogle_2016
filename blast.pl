#!/usr/bin/env perl
# Author: Boris Sadkhin
# Summary : This tool does a blast, based on a list of organisms called organism_list
#Get Configurations
use strict;
my $job_id = shift @ARGV;
if(length $job_id < 1){
	die "Please enter a job id\n";
}
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
my $query_fasta = $list_of_organisms[$job_id];
my $query_fasta_fullpath = "$base_dir/$query_fasta";
my $query_fasta_basename = basename($query_fasta);
my $blast_dir = $base_dir . "/" . dirname($query_fasta) . "/blast";
if(not -d $blast_dir){
	mkdir($blast_dir);
}
if(not -d $blast_dir){
	die "Couldn't make $blast_dir";
}
print "Created $blast_dir";

foreach my $org(@list_of_organisms){
	print "Checking to see if blast is complete for $org\n";
	my $data_base = "$base_dir/$org";
	my $data_base_basename = basename($data_base);
	my $output_file = "$blast_dir/$query_fasta_basename---$data_base_basename";
	#Check for Zip File
	if(not -s "$output_file.gz"){
		print "Only need to zip the file\n";
		zip($output_file);
	}
	#Check for Blast File
	if(-s $output_file){
		if(-s "$output_file.gz"){
			print "No need to blast/zip $output_file\n";
		}
		else{
			zip($output_file);
		}
	}


	else{
		blast($query_fasta_fullpath,$data_base,$output_file);
		zip($output_file);
	}
}


sub zip{
	my $file = shift ;
        system("pigz -k $file");	
}

sub blast{
	print "About to blast\n";
	my $i = shift ;
	my $d = shift ;
	my $o = shift ;
	my $hits = $Config{'tophits'};
	my $o_temp = "$o.tmp";
	
	my $blast_command ="blastall -p blastp -i $i -d $d " . 
	"-e 1e-5 -m8 -a12 " . 
	"-o $o_temp -b$hits -v$hits -K 1 ";
	print "$blast_command\n";
	system("$blast_command; mv $o_temp $o; pigz -k $o");
}



