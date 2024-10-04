#! /usr/bin/env bash

# This code create symbolic links to the clean fastq and bam files (if specified to be kept on the system)
# It will be executed after the creation of the result packages.

main_folder=$MAPPING_RESULTS_FOLDER
output_folder="$CODE_PATH/symLinks"

fastq_subfolder="/seqtrimbb_0000/output_files"
symlinks_fastq_folder=$output_folder"/fastq_files"
rm -rf $symlinks_fastq_folder
mkdir -p $symlinks_fastq_folder


if [ "$keep_bam" == TRUE ]; then 
    bam_subfolder="/qualimap_0000"
    symlinks_bam_folder=$output_folder"/bam_files"
    rm -rf $symlinks_bam_folder
    mkdir -p $symlinks_bam_folder
fi

for dir in "$main_folder"/*/; do
    subfolder_name=$(basename "$dir")
    ln -s "$main_folder/$subfolder_name$fastq_subfolder/paired_1.fastq.gz" $symlinks_fastq_folder"/"$subfolder_name"_paired_1.fastq.gz"
    ln -s "$main_folder/$subfolder_name$fastq_subfolder/paired_2.fastq.gz" $symlinks_fastq_folder"/"$subfolder_name"_paired_2.fastq.gz"
    if [ "$keep_bam" == TRUE ]; then 
        ln -s "$main_folder/$subfolder_name$bam_subfolder/sorted_mappings.bam" $symlinks_bam_folder"/"$subfolder_name"_sorted_mappings.bam"
    fi
done


