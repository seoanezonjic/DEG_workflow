#! /usr/bin/env bash

source ~soft_bio_267/initializes/init_python
source ~soft_bio_267/initializes/init_blast

project_path=$1
samples=$2
mkdir blastn_results

IFS=',' read -r -a sampleNames <<< $samples
for i in "${sampleNames[@]}"
do
	mkdir -p blastn_results/$i"_results"
	unm_path=$project_path"/$i/qualimap_0000"
	head -n 20 $unm_path/unaligned_no_redundant.fasta > blastn_results/$i"_results"/selected_sequences.fasta # use non-redundant after cdhit
	blastn -query blastn_results/$i"_results"/selected_sequences.fasta -db nt -remote -qcov_hsp_perc 90 -subject_besthit -perc_identity 90 -max_target_seqs 3 -out blastn_results/$i"_results"/blast.out -outfmt '7 std sscinames qcovs qcovhsp qlen' &
	wait
	grep -v '#' blastn_results/$i"_results"/blast.out | cut -f 1,2,3,4,13,14 > blastn_results/$i"_results"/blast_filt.txt
	awk 'BEGIN {FS="\t"} { if ($3 >= 95 && $6 >= 95) print $1"\t"$2"\t"$5}' blastn_results/$i"_results"/blast_filt.txt | sort -u > blastn_results/$i"_results"/inputTable.txt
	report_html -t templates/reports/blastResults.txt -o blastn_results/$i"_results"/reads_analysis_report -d blastn_results/$i"_results"/inputTable.txt
done

