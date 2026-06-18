#! /usr/bin/env bash
#SBATCH --mem='100gb'
#SBATCH --time='7-00:00:00'
#SBATCH --error=index.%J.err
#SBATCH --output=index.%J.out
#SBATCH --cpus-per-task=16
#SBATCH --constraint=cal


if [ $experiment_type == "RNAseq_genome" ]; then
	out=$mapping_ref'/STAR_index'
	if ! [[ -d $out || -L $out ]]; then
		module load star/2.7.11b
		mkdir -p $out
		#STAR --runThreadN 8 --runMode genomeGenerate --genomeDir $out --genomeFastaFiles $mapping_ref'/genome.fa' --sjdbGTFfile $mapping_ref'/annotation.gtf' --sjdbOverhang 100
		module purge
		module load gatk # for variant calling on rnaseq
		rm genome.dict
		gatk CreateSequenceDictionary -R $mapping_ref'/genome.fa' -O $mapping_ref'/genome.dict'

	else
		echo "Reference seems to be indexed. If not, remove "$mapping_ref'/STAR_index'" folder"
	fi
	if [[ $organism == 'human' ]]; then # only human has PAR regions well defined
		out=$mapping_ref'/Y_PAR_MASKED/STAR_index'
		if ! [[ -d $out || -L $out ]]; then
			module load star/2.7.11b
			mkdir -p $out
			STAR --runThreadN 8 --runMode genomeGenerate --genomeDir $out --genomeFastaFiles $mapping_ref'/Y_PAR_MASKED/genome_Ymask.fa' --sjdbGTFfile $mapping_ref'/annotation.gtf' --sjdbOverhang 100
		else
			echo "Reference seems to be indexed. If not, remove "$mapping_ref'/Y_PAR_MASKED/STAR_index'" folder"
		fi
	fi

elif [ $experiment_type == "RNAseq_transcriptome" ]; then
	module load bowtie/2.2.9
	if [ "$transcriptome" == "" ] ; then
		transcriptome=$mapping_ref'/miRNA_nr.fasta'	#-------#	Transcriptome or custom fasta to use as reference. Default options is set for miRNA differential expresion analysis usin as reference the miRNAs determinated in 'miRNAseq_detection' mode
	fi
	out=$mapping_ref'/bowtie_index_tr'
	mkdir -p $out
	bowtie2-build -f $transcriptome $out/reference
elif [ $experiment_type == "miRNAseq_detection" ]; then
	out=$mapping_ref'/bowtie_index_mirna'
	if ! [[ -d $out || -L $out ]]; then
		module load samtools/1.16
		. ~soft_bio_267/initializes/init_mirdeep2
		mkdir -p $out
		bowtie-build $mapping_ref'/genome.fa' $out'/genome'
		samtools faidx $mapping_ref'/genome.fa'
	else
		echo "Reference seems to be indexed. If not, remove "$mapping_ref'/bowtie_index_mirna'" folder"
	fi
fi 
