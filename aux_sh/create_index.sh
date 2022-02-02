#! /usr/bin/env bash
#SBATCH --mem='15gb'
#SBATCH --time='7-00:00:00'
#SBATCH --error=index.%J.err
#SBATCH --output=index.%J.out
#SBATCH --cpus-per-task=2
#SBATCH --constraint=sd


if [ $experiment_type == "RNAseq_genome" ] || [ $experiment_type == "miRNAseq_detection" ]; then
	if [ -L $mapping_ref/genome.fa ];then
		echo "Genome has not been processed because has been linked from other proyect."
	else
		mv $mapping_ref/genome.fa $mapping_ref/raw_genome.fa
		cut -f 1 -d " " $mapping_ref/raw_genome.fa > $mapping_ref/genome.fa 
		#fasta_editor.rb -i $mapping_ref/raw_genome.fa -r "CLEAN" -c a -o $mapping_ref/genome.fa
		if [ `grep -c -e '^>' $mapping_ref/raw_genome.fa` ==  `grep -c -e '^>' $mapping_ref/genome.fa` ]; then
			rm $mapping_ref/raw_genome.fa
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
		module load samtools/1.9
		. ~josecordoba/proyectos/initializes/init_mirdeep2
		mkdir -p $out
		bowtie-build $mapping_ref'/genome.fa' $out'/genome'
		samtools faidx $mapping_ref'/genome.fa'
	else
		echo "Reference seems to be indexed. If not, remove "$mapping_ref'/bowtie_index_mirna'" folder"
	fi
fi 
