 #!/usr/bin/env bash

## STAR
# https://www.biostars.org/p/221781/


## Lift over of g38 data over g37 genome
### ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/_README_GRCh37_mapping.txt
## wget 'ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_30/GRCh37_mapping/gencode.v30lift37.annotation.gtf.gz' -O  $1'/gencode.v30lift37.annotation.gtf.gz'
mkdir -p $mapping_ref
if [ "$only_read_ref" != "" ]; then
	ln -s `ls -d $only_read_ref/* |tr "\n" " "` $mapping_ref/
	exit
fi

if [ $experiment_type == "miRNAseq_detection" ] ; then 
	source  ~soft_bio_267/initializes/init_python
	
	ref_miRNA=$mapping_ref/ref_miRNA
	mkdir -p $ref_miRNA
	echo "Downloading miRBASE for $organism"
	wget "https://www.mirbase.org/download/CURRENT/hairpin.fa" -O $ref_miRNA/prev_hairpin.fa
	wget "https://www.mirbase.org/download/CURRENT/mature.fa" -O $ref_miRNA/prev_mature.fa
	sed 's/<br>/\n/g' $ref_miRNA/prev_mature.fa | sed -r 's/(<p>)|(<\/p>)|(^\s$)//g' | sed 's/&gt;/>/g' |  sed '/^$/d' |  sed -n "/"$MIRBASE_ORGANISM"/{N;p}" > $ref_miRNA/mature.fa
	sed 's/<br>/\n/g' $ref_miRNA/prev_hairpin.fa | sed -r 's/(<p>)|(<\/p>)|(^\s$)//g' | sed 's/&gt;/>/g' |  sed '/^$/d' |  sed -n "/"$MIRBASE_ORGANISM"/{N;p}" > $ref_miRNA/hairpin.fa

	cut -f 1 -d " " $ref_miRNA/hairpin.fa > $ref_miRNA/miRNA_precursors.fasta
	cut -f 1 -d " " $ref_miRNA/mature.fa > $ref_miRNA/miRNA_mature.fasta

	cat $ref_miRNA/mature.fa $ref_miRNA/hairpin.fa  | grep "^>" | tr -d ">"| cut -f 1,2 -d " "| tr " " "\t" > $ref_miRNA/prev_aliases.txt
	aggregate_column_data -i $ref_miRNA/prev_aliases.txt -x 2 -s ";" -a 1 > $ref_miRNA/aliases.txt
	rm $ref_miRNA/*hairpin.fa $ref_miRNA/*mature.fa $ref_miRNA/prev_aliases.txt
fi

if [[ $experiment_type == "RNAseq_genome" || $experiment_type == "miRNAseq_detection" ]];then
	if [ ! -s $mapping_ref/annotation.gtf ] || [ ! -s $mapping_ref/genome.fa ]; then
		if [ $organism == "human" ]; then
			#wget 'ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_19/gencode.v19.annotation.gtf.gz' -O $mapping_ref/annotation.gtf.gz
			#wget 'ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_19/GRCh37.p13.genome.fa.gz' -O $mapping_ref/genome.fa.gz 
			wget 'ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_35/gencode.v35.annotation.gtf.gz' -O $mapping_ref/annotation.gtf.gz
			wget 'ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_35/GRCh38.p13.genome.fa.gz' -O $mapping_ref/genome.fa.gz
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
