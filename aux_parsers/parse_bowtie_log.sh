#!/usr/bin/env bash

raw_report=$1

echo -e "reads_suppresed_by_multimapping\t`grep 'reads with alignments suppressed due to -m' $raw_report | cut -f2 -d ':' | cut -f 2 -d ' '`"
echo -e "multimapping_filtered_percentage\t`grep 'reads with alignments suppressed due to -m' $raw_report | cut -f2 -d ':' | cut -f 3 -d ' ' | tr -d "("| tr -d ")"| tr -d "%"`"

echo -e "unaligned_reads\t`grep 'failed to align' $raw_report | cut -f2 -d ':' | cut -f 2 -d ' '`"
echo -e "unaligned_reads_percentage\t`grep 'failed to align' $raw_report | cut -f2 -d ':' |  cut -f 3 -d ' ' | tr -d "("| tr -d ")"| tr -d "%"`"
echo -e "aligned_reads\t`grep 'reads with at least one reported alignment' $raw_report | cut -f2 -d ':' | cut -f 2 -d ' '`"
echo -e "aligned_reads_percentage\t`grep 'reads with at least one reported alignment' $raw_report | cut -f2 -d ':' |  cut -f 3 -d ' ' | tr -d "("| tr -d ")"| tr -d "%"`"


# reads processed: 13448817
# reads with at least one reported alignment: 6208770 (46.17%)
# reads that failed to align: 1997484 (14.85%)
# reads with alignments suppressed due to -m: 5242563 (38.98%)
#Reported 11322957 alignments to 1 output stream(s)
