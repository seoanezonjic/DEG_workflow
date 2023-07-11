#!/usr/bin/env bash
#SBATCH --cpus-per-task=32
#SBATCH --mem='40gb'
#SBATCH --time='10:00:00'
#SBATCH --constraint=cal
#SBATCH --error=job.%J.err
#SBATCH --output=job.%J.out

hostname

module load star/2.5.3a

STAR --runThreadN 32 --genomeDir /mnt/home/users/pab_001_uma/pedro/references/hsGRc38/STAR_index --readFilesIn /mnt2/fscratch/users/bio_267_uma/elenarojano/NGS_projects/sarcoma/results/clean_and_map/CTL_2_cell/seqtrimbb_0000/output_files/paired_1.fastq.gz /mnt2/fscratch/users/bio_267_uma/elenarojano/NGS_projects/sarcoma/results/clean_and_map/CTL_2_cell/seqtrimbb_0000/output_files/paired_2.fastq.gz --readFilesCommand 'zcat' --quantMode TranscriptomeSAM GeneCounts --outSAMtype BAM SortedByCoordinate --outReadsUnmapped Fastx
STAR --runThreadN 32 --genomeDir /mnt/home/users/pab_001_uma/pedro/references/hsGRc38/STAR_index --readFilesIn Unmapped.out.mate1 Unmapped.out.mate2 --outSAMtype BAM SortedByCoordinate --outFilterScoreMinOverLread 0 --outFilterMatchNminOverLread 0

module unload star/2.5.3a
module load samtools/1.3

samtools index Aligned.sortedByCoord.out.bam

