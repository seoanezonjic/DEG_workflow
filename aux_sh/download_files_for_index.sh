#!/usr/bin/env bash

## STAR
# https://www.biostars.org/p/221781/


## Lift over of g38 data over g37 genome
### ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/_README_GRCh37_mapping.txt
## wget 'ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_30/GRCh37_mapping/gencode.v30lift37.annotation.gtf.gz' -O  $1'/gencode.v30lift37.annotation.gtf.gz'
mkdir -p $mapping_ref
cd $mapping_ref

if [[ "$organism" == "hsa" ]]; then
	if [ ! -s annotation.gtf.gz ] || [ ! -s genome.fa ]; then
		wget 'ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_19/gencode.v19.annotation.gtf.gz' -O annotation.gtf.gz ; gunzip -f annotation.gtf.gz
		wget 'ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_19/GRCh37.p13.genome.fa.gz' -O genome.fa.gz ; gunzip -f genome.fa.gz
	else 
		echo "Genome and annotations has been downloaded"
	fi 
fi 

if [ $experiment_type=="miRNAseq" ] ; then 
	. ~josecordoba/proyectos/raw_code/init_mirdeep2
	echo "Downloading miRBASE for $organism"
	wget "ftp://mirbase.org/pub/mirbase/CURRENT/hairpin.fa.gz" -O hairpin.fa.gz 
	gunzip -f hairpin.fa.gz 
	extract_miRNAs.pl hairpin.fa $organism > $organism'_precursors.fa'
	wget "ftp://mirbase.org/pub/mirbase/CURRENT/mature.fa.gz" -O mature.fa.gz
	gunzip -f mature.fa.gz
	extract_miRNAs.pl mature.fa $organism > $organism'_mature.fa'
	wget "http://mirdb.org/download/miRDB_v6.0_prediction_result.txt.gz" -O miRDB_v6.0_prediction_result.txt.gz
	gunzip -f miRDB_v6.0_prediction_result.txt.gz
	grep $organism miRDB_v6.0_prediction_result.txt > $organism'_targets.txt'
else 
	echo "miRNA precursors are already downloaded"
fi


cd $CODE_PATH