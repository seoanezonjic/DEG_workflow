#! /usr/bin/env bash
#SBATCH --mem='40gb'
#SBATCH --time='7-00:00:00'
#SBATCH --error=index.%J.err
#SBATCH --output=index.%J.out
#SBATCH --cpus-per-task=16
#SBATCH --constraint=cal


if [ $experiment_type == "RNAseq_genome" ] || [ $experiment_type == "miRNAseq_detection" ]; then
	if [ -L $mapping_ref/genome.fa ];then
		echo "Genome has not been processed because has been linked from other proyect."
	else
		mv $mapping_ref/genome.fa $mapping_ref/raw_genome.fa
		cut -f 1 -d " " $mapping_ref/raw_genome.fa > $mapping_ref/genome.fa 
		#fasta_editor.rb -i $mapping_ref/raw_genome.fa -r "CLEAN" -c a -o $mapping_ref/genome.fa
		if [ `grep -c -e '^>' $mapping_ref/raw_genome.fa` ==  `grep -c -e '^>' $mapping_ref/genome.fa` ]; then
			rm $mapping_ref/raw_genome.fa
			
			# This process removes all genome sequences without annotation
			. ~soft_bio_267/initializes/init_python
			mv $mapping_ref/genome.fa $mapping_ref/genome_orig.fa
			grep -v '#' $mapping_ref/annotation.gtf | cut -f 1 | sort -u > $mapping_ref/annotated_seq_ids
			lista2fasta.py $mapping_ref/annotated_seq_ids $mapping_ref/genome_orig.fa > $mapping_ref/genome.fa
			if [ `wc -l $mapping_ref/annotated_seq_ids |cut -f 1 -d " "` == `grep -c -e '^>' $mapping_ref/genome.fa` ]; then
				rm $mapping_ref/genome_orig.fa
			fi
		else
			echo "IDs cleaning has failed"
		fi
	fi
fi 

if [ $experiment_type == "RNAseq_genome" ]; then
	out=$mapping_ref'/STAR_index'
	if ! [[ -d $out || -L $out ]]; then
		module load star/2.5.3a
		mkdir -p $out
		STAR --runThreadN 2 --runMode genomeGenerate --genomeDir $out --genomeFastaFiles $mapping_ref'/genome.fa' --sjdbGTFfile $mapping_ref'/annotation.gtf' --sjdbOverhang 100
	else
		echo "Reference seems to be indexed. If not, remove "$mapping_ref'/STAR_index'" folder"
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
