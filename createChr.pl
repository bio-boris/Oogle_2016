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
	my $protein_file = "$base_dir/$org\n";
	my $annotations_dir = dirname(dirname($org)). "/annotation";
	open F, $protein_file or die $!;
	my $org_name = basename($org);
	$org_name =~ s/\.protein\.fa//g;
	my %hash;
	my $gff_file = "$base_dir/$annotations_dir/$org_name.gene.gff3";
#Load Up Protein File
	while(my $line = <F>){
		chomp $line;;
#>GRMZM6G175135_P01 pacid=30964399 transcript=GRMZM6G175135_T01
#locus=GRMZM6G175135 ID=GRMZM6G175135_T01.v6a annot-version=5b+
		next until (substr($line,0,1) eq ">");
		my @line = split " ", $line;
		my $id = $line[0];
		$id = substr($id,1);
		my $pac = $line[1];
		$pac =~ s/pacid=//;
		$hash{$pac}{'id'} = $id;
	}
	close F;
#Load UP MRNA
#scaffold_406	phytozomev11	mRNA	1	735	.	+	.	ID=GRMZM6G175135_T01.v6a;Name=GRMZM6G175135_T01;pacid=30964399;longest=1;Parent=GRMZM6G175135.v6a
	open F, $gff_file or die $! . " $gff_file";
	print "Reading GFF $gff_file\n";
	while( my $line = <F>){
		next until $line =~/mRNA/;
		my @line = split "\t", $line;
		my $chromosome = $line[0];
		my $start = $line[3];
		my $stop = $line[4];
		my $id_line = $line[-1];
		$id_line =~ /(pacid=[0-9]+)/;
		my $pac = $1;
		$pac =~ s/pacid=//g;
		$hash{$pac}{'start'} = $start;
		$hash{$pac}{'stop'} = $stop;
		$hash{$pac}{'chromosome'} = $chromosome;
	}
	close F;
	my $output_file = "$base_dir/$annotations_dir/$org_name.CHR";
	open O, ">$output_file.tmp" or die $!;
	print "About to print to $output_file.tmp\n";
	foreach my $pac(keys %hash){
		print O  join "\t", ($org_name,$hash{$pac}{'id'},$pac,$hash{$pac}{'chromosome'},
				$hash{$pac}{'start'},$hash{$pac}{'stop'});
		print O "\n";
	}
	close O;
	system("mv $output_file.tmp $output_file");
	print "Printed to $output_file\n";
}

