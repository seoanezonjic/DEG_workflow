#!/usr/bin/env bash
sample=$1
reference=$2
threads=$3
unmapped_ratio=$4

module load star/2.5.3a
source ~soft_bio_267/initializes/init_python


STAR --runThreadN $threads --genomeDir $reference/STAR_index --readFilesIn $sample --outSAMtype BAM SortedByCoordinate --outFilterScoreMinOverLread 0 --outFilterMatchNminOverLread 0

get_too_short.py Aligned.sortedByCoord.out.bam unaligned $unmapped_ratio

module purge
module load cdhit
cd-hit-est -T $threads -M 0 -i unaligned.fasta -o unaligned_no_redundant.fasta -c 1

