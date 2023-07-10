#!/usr/bin/env bash
#SBATCH --cpus-per-task=32
#SBATCH --mem='40gb'
#SBATCH --time='10:00:00'
#SBATCH --constraint=cal
#SBATCH --error=job.%J.err
#SBATCH --output=job.%J.out
hostname

module load samtools/1.3
module load star/2.5.3a

# example line
#STAR --runThreadN 32 --genomeDir /mnt/home/users/pab_001_uma/pedro/references/hsGRc38/STAR_index --readFilesIn /mnt2/fscratch/users/bio_267_uma/elenarojano/NGS_projects/sarcoma/results/clean_and_map/CTL_1_cell/seqtrimbb_0000/output_files/paired_1.fastq.gz /mnt2/fscratch/users/bio_267_uma/elenarojano/NGS_projects/sarcoma/results/clean_and_map/CTL_1_cell/seqtrimbb_0000/output_files/paired_2.fastq.gz --readFilesCommand 'zcat' --quantMode TranscriptomeSAM GeneCounts --outSAMtype BAM SortedByCoordinate --outReadsUnmapped Fastx

if  [[ $1=='paired' ]]
then
	# Paired
	STAR --runThreadN 32 --genomeDir /mnt/home/users/pab_001_uma/pedro/references/hsGRc38/STAR_index --readFilesIn $2 $3 --readFilesCommand 'zcat' --quantMode TranscriptomeSAM GeneCounts --outSAMtype BAM SortedByCoordinate --outReadsUnmapped Fastx
	STAR --runThreadN 32 --genomeDir /mnt/home/users/pab_001_uma/pedro/references/hsGRc38/STAR_index --readFilesIn Unmapped.out.mate1 Unmapped.out.mate2 --outSAMtype BAM SortedByCoordinate --outFilterScoreMinOverLread 0 --outFilterMatchNminOverLread 0

elif [[ $1=='single' ]]
	# Single
	STAR --runThreadN 32 --genomeDir /mnt/home/users/pab_001_uma/pedro/references/hsGRc38/STAR_index --readFilesIn $2 --readFilesCommand 'zcat' --quantMode TranscriptomeSAM GeneCounts --outSAMtype BAM SortedByCoordinate --outReadsUnmapped Fastx
	STAR --runThreadN 32 --genomeDir /mnt/home/users/pab_001_uma/pedro/references/hsGRc38/STAR_index --readFilesIn Unmapped.out.mate1 --outSAMtype BAM SortedByCoordinate --outFilterScoreMinOverLread 0 --outFilterMatchNminOverLread	
fi

samtools index Aligned.sortedByCoord.out.bam

# Note: open file with IGV to track coordinates
