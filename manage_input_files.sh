#! /usr/bin/env bash
#SBATCH --cpus=1
#SBATCH --mem='4gb'
#SBATCH --time='1-00:00:00'
#SBATCH --error=job.%J.err
#SBATCH --output=job.%J.out

source_folder=~jperkins/raw-data/PMM2CDG/RNA_Seq_NEBNext\(DianaGallego\)
project_folder='./'
output_folder=$project_folder'/raw_data'

mkdir -p $output_folder
#gunzip -c $source_folder'/Sample_S_1__DianaGallego_RNA_Seq_NEBNext/S_1__DianaGallego_RNA_Seq_NEBNext_S37_L004_R1_001.fastq.gz' \
# $source_folder'/Sample_S_2__DianaGallego_RNA_Seq_NEBNext/S_2__DianaGallego_RNA_Seq_NEBNext_S38_L004_R1_001.fastq.gz' | gzip -c > $output_folder'/ctrl1_noChap.fastq.gz'

#gunzip -c $source_folder'/Sample_S_3__DianaGallego_RNA_Seq_NEBNext/S_3__DianaGallego_RNA_Seq_NEBNext_S39_L004_R1_001.fastq.gz' \
# $source_folder'/Sample_S_4__DianaGallego_RNA_Seq_NEBNext/S_4__DianaGallego_RNA_Seq_NEBNext_S40_L004_R1_001.fastq.gz' | gzip -c > $output_folder'/ctrl1_Chap.fastq.gz'

gunzip -c $source_folder'/Sample_S_5__DianaGallego_RNA_Seq_NEBNext/S_5__DianaGallego_RNA_Seq_NEBNext_S41_L004_R1_001.fastq.gz' \
 $source_folder'/Sample_S_6__DianaGallego_RNA_Seq_NEBNext/S_6__DianaGallego_RNA_Seq_NEBNext_S25_L003_R1_001.fastq.gz' | gzip -c > $output_folder'/ctrl2_noChap.fastq.gz'

gunzip -c $source_folder'/Sample_S_7__DianaGallego_RNA_Seq_NEBNext/S_7__DianaGallego_RNA_Seq_NEBNext_S42_L004_R1_001.fastq.gz' \
 $source_folder'/Sample_S_8__DianaGallego_RNA_Seq_NEBNext/S_8__DianaGallego_RNA_Seq_NEBNext_S26_L003_R1_001.fastq.gz' | gzip -c > $output_folder'/ctrl2_Chap.fastq.gz'

gunzip -c $source_folder'/Sample_S_9__DianaGallego_RNA_Seq_NEBNext/S_9__DianaGallego_RNA_Seq_NEBNext_S43_L004_R1_001.fastq.gz' \
 $source_folder'/Sample_S_10__DianaGallego_RNA_Seq_NEBNext/S_10__DianaGallego_RNA_Seq_NEBNext_S27_L003_R1_001.fastq.gz' | gzip -c > $output_folder'/ctrl3_noChap.fastq.gz'

gunzip -c $source_folder'/Sample_S_11__DianaGallego_RNA_Seq_NEBNext/S_11__DianaGallego_RNA_Seq_NEBNext_S44_L004_R1_001.fastq.gz' \
 $source_folder'/Sample_S_12__DianaGallego_RNA_Seq_NEBNext/S_12__DianaGallego_RNA_Seq_NEBNext_S28_L003_R1_001.fastq.gz' | gzip -c > $output_folder'/ctrl3_Chap.fastq.gz'

gunzip -c $source_folder'/Sample_S_13__DianaGallego_RNA_Seq_NEBNext/S_13__DianaGallego_RNA_Seq_NEBNext_S45_L004_R1_001.fastq.gz' \
 $source_folder'/Sample_S_14__DianaGallego_RNA_Seq_NEBNext/S_14__DianaGallego_RNA_Seq_NEBNext_S46_L004_R1_001.fastq.gz' | gzip -c > $output_folder'/pat1_noChap.fastq.gz'

gunzip -c $source_folder'/Sample_S_15__DianaGallego_RNA_Seq_NEBNext/S_15__DianaGallego_RNA_Seq_NEBNext_S29_L003_R1_001.fastq.gz' \
 $source_folder'/Sample_S_16__DianaGallego_RNA_Seq_NEBNext/S_16__DianaGallego_RNA_Seq_NEBNext_S47_L004_R1_001.fastq.gz' | gzip -c > $output_folder'/pat1_Chap.fastq.gz'

gunzip -c $source_folder'/Sample_S_17__DianaGallego_RNA_Seq_NEBNext/S_17__DianaGallego_RNA_Seq_NEBNext_S30_L003_R1_001.fastq.gz' \
 $source_folder'/Sample_S_18__DianaGallego_RNA_Seq_NEBNext/S_18__DianaGallego_RNA_Seq_NEBNext_S31_L003_R1_001.fastq.gz' | gzip -c > $output_folder'/pat2_noChap.fastq.gz'

gunzip -c $source_folder'/Sample_S_19__DianaGallego_RNA_Seq_NEBNext/S_19__DianaGallego_RNA_Seq_NEBNext_S32_L003_R1_001.fastq.gz' \
 $source_folder'/Sample_S_20__DianaGallego_RNA_Seq_NEBNext/S_20__DianaGallego_RNA_Seq_NEBNext_S33_L003_R1_001.fastq.gz' | gzip -c > $output_folder'/pat2_Chap.fastq.gz'

gunzip -c $source_folder'/Sample_S_21__DianaGallego_RNA_Seq_NEBNext/S_21__DianaGallego_RNA_Seq_NEBNext_S34_L003_R1_001.fastq.gz' \
 $source_folder'/Sample_S_22__DianaGallego_RNA_Seq_NEBNext/S_22__DianaGallego_RNA_Seq_NEBNext_S35_L003_R1_001.fastq.gz' | gzip -c > $output_folder'/pat3_noChap.fastq.gz'

gunzip -c $source_folder'/Sample_S_23__DianaGallego_RNA_Seq_NEBNext/S_23__DianaGallego_RNA_Seq_NEBNext_S48_L004_R1_001.fastq.gz' \
 $source_folder'/Sample_S_24__DianaGallego_RNA_Seq_NEBNext/S_24__DianaGallego_RNA_Seq_NEBNext_S36_L003_R1_001.fastq.gz' | gzip -c > $output_folder'/pat3_Chap.fastq.gz'
