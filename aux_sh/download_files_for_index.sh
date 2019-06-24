#!/usr/bin/env bash

#module load bowtie/2.2.9
#bowtie2-build -f $1 $2/ref

## STAR
# https://www.biostars.org/p/221781/
genome_files_folder=$1
mkdir -p $genome_files_folder
wget 'ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_19/gencode.v19.annotation.gtf.gz' -O  $genome_files_folder'/annotation.gtf.gz'
wget 'ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_19/GRCh37.p13.genome.fa.gz' -O $genome_files_folder'/genome.fa.gz'
gunzip $genome_files_folder/*.gz

## Lift over of g38 data over g37 genome
### ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/_README_GRCh37_mapping.txt
## wget 'ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_30/GRCh37_mapping/gencode.v30lift37.annotation.gtf.gz' -O  $1'/gencode.v30lift37.annotation.gtf.gz'

