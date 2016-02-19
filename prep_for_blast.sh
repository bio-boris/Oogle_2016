#!/usr/bin/env sh

# Author Boris Sadkhin
# Date 02-03-2016
# Description:
# This script unzips the downloaded genomes and formats them with blastall v 2.6

#Unzip
cd /home/sadkhin2/scratch/phytozome_11
find | grep protein.fa.gz$ | xargs gunzip

#Format
find | grep protein.fa$  | grep -v early_release > list_of_protein_databases
for db in `cat list_of_protein_databases`
do
        command="time formatdb -pT -i $db"
        echo $command
        $command
done

#Create directories
cat list_of_protein_databases  | xargs -n1 dirname | perl -lne 'mkdir "$_/blast"'

