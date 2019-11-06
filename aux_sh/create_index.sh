#! /usr/bin/env bash
#SBATCH --cpus=1
#SBATCH --mem='20gb'
#SBATCH --time='7-00:00:00'
#SBATCH --error=job.%J.err
#SBATCH --output=job.%J.out

if [ $experiment_type == "RNAseq" ]; then
	module load star/2.5.3a
	out=$mapping_ref'/STAR_index'
	mkdir -p $out
	STAR --runThreadN 16 --runMode genomeGenerate --genomeDir $out --genomeFastaFiles $mapping_ref'/genome.fa' --sjdbGTFfile $mapping_ref'/annotation.gtf' --sjdbOverhang 100
elif [ $experiment_type == "miRNAseq" ]; then
	. ~josecordoba/proyectos/raw_code/init_mirdeep2
	out=$mapping_ref'/bowtie_index'
	mkdir -p $out
	bowtie-build $mapping_ref'/genome.fa' $out'/genome'
fi