#! /usr/bin/env bash
#SBATCH --cpus=16
#SBATCH --mem='40gb'
#SBATCH --time='7-00:00:00'
#SBATCH --error=job.%J.err
#SBATCH --output=job.%J.out
module load star/2.5.3a
out=$mapping_ref'/index'
mkdir -p $out
STAR --runThreadN 16  --runMode genomeGenerate --genomeDir $out --genomeFastaFiles $mapping_ref'/genome.fa' --sjdbGTFfile $mapping_ref'/annotation.gtf' --sjdbOverhang 100
