#! /usr/bin/env bash
#SBATCH --cpus=1
#SBATCH --mem='4gb'
#SBATCH --time='1-00:00:00'
#SBATCH --error=job.%J.err
#SBATCH --output=job.%J.out

source_folder=/path/to/raw/data
project_folder='project_execution'
output_folder=$project_folder'/raw_data'

mkdir -p $output_folder

ln -s $source_folder'/2-2_MARZO_17_1.fastq.gz' $output_folder'/Treated_2_1.fastq.gz'
ln -s $source_folder'/2-2_MARZO_17_2.fastq.gz' $output_folder'/Treated_2_2.fastq.gz'
ln -s $source_folder'/2_4MARZO17_1.fastq.gz' $output_folder'/Control_4_1.fastq.gz'
ln -s $source_folder'/2_4MARZO17_2.fastq.gz' $output_folder'/Congrol_4_2.fastq.gz'
