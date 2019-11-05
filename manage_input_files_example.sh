#! /usr/bin/env bash

source_folder=/path/to/raw/data
output_folder=`pwd`'/raw_data'

mkdir -p $output_folder

ln -s $source_folder'/2-2_MARZO_17_1.fastq.gz' $output_folder'/Treated_2_1.fastq.gz'
ln -s $source_folder'/2-2_MARZO_17_2.fastq.gz' $output_folder'/Treated_2_2.fastq.gz'
ln -s $source_folder'/2_4MARZO17_1.fastq.gz' $output_folder'/Control_4_1.fastq.gz'
ln -s $source_folder'/2_4MARZO17_2.fastq.gz' $output_folder'/Congrol_4_2.fastq.gz'
