#! /usr/bin/env bash
#SBATCH --cpus=2
#SBATCH --mem='4gb'
#SBATCH --time='7-00:00:00'
#SBATCH --error=job.%J.err
#SBATCH --output=job.%J.out

if [ $experiment_type == "RNAseq_genome" ] || [ $experiment_type == "miRNAseq_detection" ]; then
	mv $mapping_ref/genome.fa $mapping_ref/raw_genome.fa
	fasta_editor.rb -i $mapping_ref/raw_genome.fa -r "CLEAN" -c a -o $mapping_ref/genome.fa
	rm $mapping_ref/raw_genome.fa
fi 

if [ $experiment_type == "RNAseq_genome" ]; then
	module load star/2.5.3a
	out=$mapping_ref'/STAR_index'
	mkdir -p $out
	STAR --runThreadN 2 --runMode genomeGenerate --genomeDir $out --genomeFastaFiles $mapping_ref'/genome.fa' --sjdbGTFfile $mapping_ref'/annotation.gtf' --sjdbOverhang 100
elif [ $experiment_type == "RNAseq_transcriptome" ]; then
	module load bowtie/2.2.9
	if [ "$transcriptome" == "" ] ; then
		transcriptome=$mapping_ref'/miRNA_nr.fasta'	#-------#	Transcriptome or custom fasta to use as reference. Default options is set for miRNA differential expresion analysis usin as reference the miRNAs determinated in 'miRNAseq_detection' mode
	fi
	out=$mapping_ref'/bowtie_index_tr'
	mkdir -p $out
	bowtie2-build -f $transcriptome $out/reference
elif [ $experiment_type == "miRNAseq_detection" ]; then
	module load samtools/1.9
	. ~josecordoba/proyectos/initializes/init_mirdeep2
	out=$mapping_ref'/bowtie_index_mirna'
	mkdir -p $out
	bowtie-build $mapping_ref'/genome.fa' $out'/genome'
	samtools faidx $mapping_ref'/genome.fa'
fi 
