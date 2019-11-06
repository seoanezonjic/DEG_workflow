#!/usr/bin/env bash

#module load bowtie/2.2.9
#bowtie2-build -f $1 $2/ref

## STAR
# https://www.biostars.org/p/221781/


## Lift over of g38 data over g37 genome
### ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/_README_GRCh37_mapping.txt
## wget 'ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_30/GRCh37_mapping/gencode.v30lift37.annotation.gtf.gz' -O  $1'/gencode.v30lift37.annotation.gtf.gz'

cd $mapping_ref

if [ $experiment_type=="miRNAseq" ] ; then 
	. ~josecordoba/proyectos/raw_code/init_mirdeep2
	echo "Downloading miRBASE for $organism"
	wget "ftp://mirbase.org/pub/mirbase/CURRENT/hairpin.fa.gz" ; gunzip hairpin.fa.gz ; extract_miRNAs.pl hairpin.fa $organism > $organism'_precursors.fa'
	wget "ftp://mirbase.org/pub/mirbase/CURRENT/mature.fa.gz" ; gunzip mature.fa.gz ; extract_miRNAs.pl mature.fa $organism > $organism'_mature.fa'
	wget "http://mirdb.org/download/miRDB_v6.0_prediction_result.txt.gz" ; gunzip miRDB_v6.0_prediction_result.txt.gz ; grep $organism miRDB_v6.0_prediction_result.txt > $organism'_targets.txt'
else 
	echo "miRNA precursors are already downloaded"
fi

if [[ "$organism" == "hsa" ]]; then
	if [ ! -s annotation.gtf.gz ] || [ ! -s genome.fa ]; then
		wget 'ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_19/gencode.v19.annotation.gtf.gz' annotation.gtf.gz ; annotation.gtf.gz
		wget 'ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_19/GRCh37.p13.genome.fa.gz' genome.fa.gz ; gunzip genome.fa.gz
	else 
		echo "Genome and annotations has been downloaded"
	fi 
fi 