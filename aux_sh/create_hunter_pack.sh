#! /usr/bin/env bash

source ~soft_bio_267/initializes/init_degenes_hunter
output_folder=$CODE_PATH/DEG_workflow_results
miRNA_det_path=$1

mkdir -p $output_folder
cp $report_folder/mapping_report.html $output_folder
if [ ! -z "$miRNA_det_path" ]; then
    echo 'A'
    cp $miRNA_det_path/mapping_reports/mapping_report.html $output_folder/mapping_report_detection.html # use this to add files from other execution (miRNA DEA plus miRNA detection)
    cp $miRNA_det_path/mapping_reports/all_miRNA_report.html $output_folder/all_miRNA_report.html
    cp $miRNA_det_path/mapping_reports/miRNA_nr.fasta $output_folder/miRNA_detected.fasta
fi

for comparison_path in $HUNTER_RESULTS_FOLDER/*
do
    out_comparison="$output_folder/$(basename "$comparison_path")"
    mkdir -p $out_comparison
    cp $comparison_path/DEG_report.html $out_comparison
    cp $comparison_path/control_treatment.txt $out_comparison

    miRNA=`grep -c 'MIMAT' $comparison_path/Common_results/hunter_results_table.txt`
    if [ "$miRNA" -gt 0 ]; then
        mode_annot="-m"
    gene_id=""
    else
        mode_annot=""
    gene_id="-I ENSEMBL"
    fi
  
    add_annotation.R -i $comparison_path/filtered_count_data.txt -o $out_comparison/filtered_count_data.txt $mode_annot $gene_id
    add_annotation.R -i $comparison_path/final_counts.txt -o $out_comparison/final_counts.txt $mode_annot $gene_id
    add_annotation.R -i $comparison_path/Common_results/hunter_results_table.txt -o $out_comparison/hunter_results_table.txt $mode_annot -c rownames $gene_id
    add_annotation.R -i $comparison_path/Results_default/Normalized_counts_default.txt -o $out_comparison/Normalized_counts_default.txt $mode_annot $gene_id

    cp -r $comparison_path/functional_enrichment $out_comparison
    cp -r $comparison_path/Results_WGCNA $out_comparison
    cp -r $comparison_path/PCA_results $out_comparison
    rm -rf $out_comparison/Results_WGCNA/*.RData
done
