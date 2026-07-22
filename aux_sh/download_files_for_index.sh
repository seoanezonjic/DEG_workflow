 #!/usr/bin/env bash

mkdir -p $mapping_ref
if [ "$only_read_ref" != "" ]; then
	ln -s `ls -d $only_read_ref/* |tr "\n" " "` $mapping_ref/
	exit
fi

source  ~soft_bio_267/initializes/init_python

if [ $experiment_type == "miRNAseq_detection" ] ; then 
	
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
	cmdtabs --aggregate -i $ref_miRNA/prev_aliases.txt --agg_ref_col_index 2 --agg_col 1 --agg_sep ";" > $ref_miRNA/aliases.txt
	rm $ref_miRNA/*hairpin.fa $ref_miRNA/*mature.fa $ref_miRNA/prev_aliases.txt
fi

if [[ $experiment_type == "RNAseq_genome" || $experiment_type == "miRNAseq_detection" ]];then
	if [ ! -s $mapping_ref/annotation.gtf ] || [ ! -s $mapping_ref/genome.fa ]; then
		if [ $organism == "human" ]; then
			#wget 'ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_19/gencode.v19.annotation.gtf.gz' -O $mapping_ref/annotation.gtf.gz
			#wget 'ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_19/GRCh37.p13.genome.fa.gz' -O $mapping_ref/genome.fa.gz 
			#wget 'ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_35/gencode.v35.annotation.gtf.gz' -O $mapping_ref/annotation.gtf.gz
			#wget 'ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_35/GRCh38.p13.genome.fa.gz' -O $mapping_ref/genome.fa.gz
			wget 'ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_49/gencode.v49.annotation.gtf.gz' -O $mapping_ref/annotation.gtf.gz
			wget 'ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_49/GRCh38.p14.genome.fa.gz' -O $mapping_ref/genome.fa.gz
		elif [ $organism == "mouse" ]; then
			#wget 'ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M23/gencode.vM23.annotation.gtf.gz' -O $mapping_ref/annotation.gtf.gz
			#wget 'ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M23/GRCm38.p6.genome.fa.gz' -O $mapping_ref/genome.fa.gz 
			wget 'https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M39/gencode.vM39.annotation.gtf.gz' -O $mapping_ref/annotation.gtf.gz
			wget 'https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M39/GRCm39.genome.fa.gz' -O $mapping_ref/genome.fa.gz
		fi
		gunzip -f $mapping_ref/*

		mv $mapping_ref/genome.fa $mapping_ref/raw_genome.fa
		cut -f 1 -d " " $mapping_ref/raw_genome.fa > $mapping_ref/genome.fa 
		if [ `grep -c -e '^>' $mapping_ref/raw_genome.fa` ==  `grep -c -e '^>' $mapping_ref/genome.fa` ]; then
			rm $mapping_ref/raw_genome.fa
			
			# This process removes all genome sequences without annotation
			. ~soft_bio_267/initializes/init_python
			mv $mapping_ref/genome.fa $mapping_ref/genome_orig.fa
			grep -v '#' $mapping_ref/annotation.gtf | cut -f 1 | sort -u > $mapping_ref/annotated_seq_ids
			lista2fasta $mapping_ref/annotated_seq_ids $mapping_ref/genome_orig.fa > $mapping_ref/genome.fa

			if [ `wc -l $mapping_ref/annotated_seq_ids |cut -f 1 -d " "` == `grep -c -e '^>' $mapping_ref/genome.fa` ]; then
				rm $mapping_ref/genome_orig.fa
			fi
		else
			echo "IDs cleaning has failed"
			exit
		fi

		echo "$organism genome and annotations has been downloaded"
	else 
		echo "$organism genome and annotations has been downloaded"
	fi
	if [[ $organism == 'human' ]]; then # only human has PAR regions well defined
		mkdir -p $mapping_ref/Y_PAR_MASKED
		maskFasta $MASK_YPAR_BEDS/$organism.bed $mapping_ref/genome.fa > $mapping_ref/Y_PAR_MASKED/genome_Ymask.fa
	fi
fi 
