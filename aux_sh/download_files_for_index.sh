 #!/usr/bin/env bash

## STAR
# https://www.biostars.org/p/221781/


## Lift over of g38 data over g37 genome
### ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/_README_GRCh37_mapping.txt
## wget 'ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_30/GRCh37_mapping/gencode.v30lift37.annotation.gtf.gz' -O  $1'/gencode.v30lift37.annotation.gtf.gz'
mkdir -p $mapping_ref

if [ $experiment_type == "miRNAseq_detection" ] ; then 
	. ~josecordoba/proyectos/initializes/init_mirdeep2
	echo "Downloading miRBASE for $organism"
	wget "ftp://mirbase.org/pub/mirbase/CURRENT/hairpin.fa.gz" -O $mapping_ref/hairpin.fa.gz 
	gunzip -f $mapping_ref/hairpin.fa.gz 
	extract_miRNAs.pl $mapping_ref/hairpin.fa $MIRBASE_ORGANISM > $mapping_ref/miRNA_precursors.fasta
	rm $mapping_ref/hairpin.fa
	wget "ftp://mirbase.org/pub/mirbase/CURRENT/mature.fa.gz" -O $mapping_ref/mature.fa.gz
	gunzip -f $mapping_ref/mature.fa.gz
	extract_miRNAs.pl $mapping_ref/mature.fa $MIRBASE_ORGANISM > $mapping_ref/miRNA_mature.fasta
	rm $mapping_ref/mature.fa
#elif [  $experiment_type == "miRNAseq_detection" ]; then
	# wget "http://carolina.imis.athena-innovation.gr/diana_tools/downloads/e2de248e81009d5a5s33ebe9906fa32c/TarBase_v8_download.tar.gz" -O miRNA_targets.txt.gz
	# gunzip -f miRDB_v6.0_prediction_result.txt.gz
	# grep $MIRBASE_ORGANISM miRDB_v6.0_prediction_result.txt > targets.txt
fi

if [[ $experiment_type == "RNAseq_genome" || $experiment_type == "miRNAseq_detection" ]];then
	if [ ! -s $mapping_ref/annotation.gtf ] || [ ! -s $mapping_ref/genome.fa ]; then
		if [ $organism == "human" ]; then
			wget 'ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_19/gencode.v19.annotation.gtf.gz' -O $mapping_ref/annotation.gtf.gz
			wget 'ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_19/GRCh37.p13.genome.fa.gz' -O $mapping_ref/genome.fa.gz 
		elif [ $organism == "mouse" ]; then
			wget 'ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M23/gencode.vM23.annotation.gtf.gz' -O $mapping_ref/annotation.gtf.gz
			wget 'ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M23/GRCm38.p6.genome.fa.gz' -O $mapping_ref/genome.fa.gz 
		fi
		gunzip -f $mapping_ref/*
		echo "$organism genome and annotations has been downloaded"
	else 
		echo "$organism genome and annotations has been downloaded"
	fi 
fi 
