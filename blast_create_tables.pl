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
	my $data_base = "$base_dir/$org";
	my $dir = (dirname($data_base))."/blast";
	my $cat_blast =" $dir/$org_name.cat";
	#remove tmp file
	unlink("$cat_blast.tmp");

	my $count=0;
	my $zip_count=0;
	foreach my $org2(@list_of_organisms){
		my $org2_name = basename($org2);
		my $blast_output_file = "$dir/$org_name---$org2_name";
		if(-s $blast_output_file){
			$count++;
		}
		if(-s "$blast_output_file.gz"){
			$zip_count++;
		}
	}
	if($count == $zip_count && $zip_count == scalar @list_of_organisms){
		print "Proceeding to create blast tables for $org($count,$zip_count)\n";
	}
	else{
		print "Failure for $org";
		next;
	}
	my $line_count=0;
	foreach my $org2(reverse @list_of_organisms){
		my $org2_name = basename($org2);
		my $blast_output_file = "$dir/$org_name---$org2_name";
		open F, $blast_output_file or die $!. "($blast_output_file)";
		open O, ">>$cat_blast.tmp";

		while ( my $line=<F>){
			$line_count++;
			chomp $line;
			my @line = split "\t", $line;

#Blast m8 queryId0, subjectId1, percIdentity2, alnLength3, mismatchCount4, 
#gapOpenCount5, queryStart6, queryEnd7, subjectStart8, subjectEnd9, eVal10, bitScore11
			my $temp = "$org_name\t$org2_name\t" , join "\t",( $line[0], $line[1], $line[2],
					$line[3],$line[10],$line[11]) , "\n" ; 
			$temp =~ s/\.protein\.fa//;
			print O $temp;
		}
	}
	print "Completed printing $line_count to $cat_blast.tmp, mving\n";
	system("mv $cat_blast.tmp $cat_blast");

#my $data_base_basename = basename($data_base);
#my $output_file = "$blast_dir/$query_fasta_basename---$data_base_basename";

}

