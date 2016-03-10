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

#print "About check " . scalar @list_of_orgs . " orgs\n";

my %hash;
use File::Basename;
foreach my $org(@list_of_orgs){
	chomp $org;
	my $dir_name = dirname($org);
	my $org_name = basename($org);
	
	foreach my $org2(@list_of_orgs){
		chomp $org2;
		my $org2_name = basename($org);
		my $output_file = "$base_dir/$dir_name/blast/$org_name---$org2_name";
		if(-s $output_file){
			$hash{$org}{'blast'}++;
		}
		if(-s "$output_file.gz"){
			$hash{$org}{'gz'} ++;
		}
		
		push @{$hash{$org}{'file'}} , "$output_file.gz";
	}
}
#Check to see if there are N orgs complete!
open O, ">blast_check_error" or die$!;
foreach my $org (keys %hash){
	print "$org $hash{$org}{'blast'} $hash{$org}{'gz'}\n";
	my @output_files = @{$hash{$org}{'file'}};
	print O join "\n", @output_files;
	print O "\n";
}
close O;
