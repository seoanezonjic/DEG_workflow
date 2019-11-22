#!/usr/bin/env bash

raw_report=$1


if `grep -q "overall alignment rate" $raw_report`; then

	#unmapped=`grep 'aligned concordantly 0 times' $raw_report |sed -r 's/ +/ /' | cut -f 2 -d ' '` 
	unmapped_per=`grep 'aligned 0 times' $raw_report |sed -r 's/ +/ /' | cut -f 3 -d ' '|tr -d ")" | tr -d "(" | tr -d "%"`
	echo $unmapped_per
	echo -e "bowtie2_unmapped_per\t"$unmapped_per
	
	mapped_uniq=`grep 'aligned exactly 1 time' $raw_report |sed -r 's/ +/ /' | cut -f 2 -d ' '`
	mapped_uniq_per=`grep 'aligned exactly 1 time' $raw_report |sed -r 's/ +/ /' | cut -f 3 -d ' '|tr -d ")" | tr -d "(" | tr -d "%"`
	echo -e "bowtie2_uniq_mapped\t$mapped_uniq"
	echo -e "bowtie2_uniq_mapped_per\t$mapped_uniq_per"

	multimapping=`grep 'aligned >1 times' $raw_report |sed -r 's/ +/ /' | cut -f 2 -d ' '`
	multimapping_per=`grep 'aligned >1 times' $raw_report |sed -r 's/ +/ /' | cut -f 3 -d ' '|tr -d ")" | tr -d "(" | tr -d "%"`
	echo -e "bowtie2_multimapping\t$multimapping"
	echo -e "bowtie2_multimapping_per\t$multimapping_per"

	all_mapping=`echo "$mapped_uniq + $multimapping" | bc`
	echo -e "aligned_to_feature\t$all_mapping"
	echo -e "bowtie2_mapped_reads\t$all_mapping"

elif `grep -q "reads with at least one reported alignment" $raw_report`; then

	echo -e "bowtie1_multimapping\t`grep 'reads with alignments suppressed due to -m' $raw_report | cut -f2 -d ':' | cut -f 2 -d ' '`"
	echo -e "bowtie1_multimapping_per\t`grep 'reads with alignments suppressed due to -m' $raw_report | cut -f2 -d ':' | cut -f 3 -d ' ' | tr -d "("| tr -d ")"| tr -d "%"`"

	echo -e "bowtie1_unmapped\t`grep 'failed to align' $raw_report | cut -f2 -d ':' | cut -f 2 -d ' '`"
	echo -e "bowtie1_unmapped_per\t`grep 'failed to align' $raw_report | cut -f2 -d ':' |  cut -f 3 -d ' ' | tr -d "("| tr -d ")"| tr -d "%"`"
	echo -e "bowtie1_mapped_per\t`grep 'reads with at least one reported alignment' $raw_report | cut -f2 -d ':' |  cut -f 3 -d ' ' | tr -d "("| tr -d ")"| tr -d "%"`"
	echo -e "bowtie1_mapped\t`grep 'reads with at least one reported alignment' $raw_report | cut -f2 -d ':' | cut -f 2 -d ' '`"
	echo -e "bowtie1_filtered_reads\t`grep 'reads processed' $raw_report | cut -f2 -d ':' | tr -d " "`"
fi