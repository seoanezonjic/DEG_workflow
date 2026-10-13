#! /usr/bin/env bash


seq_reference=$1

module load bowtie/2.5.1
module load samtools
source ~soft_bio_267/initializes/init_R
mkdir unmapped_mapping
bowtie2-build $seq_reference unmapped_mapping'/alt_seq'
bowtie2 -p 4 -x unmapped_mapping'/alt_seq' -q -1 'Unmapped.out.mate1' -2 'Unmapped.out.mate2' 2>bowtie_alt_log | samtools sort -o unmapped_mapping'/sorted_mappings.bam'
samtools flagstat unmapped_mapping'/sorted_mappings.bam' > unmapped_mapping'/alignment_stats.txt'
samtools idxstats unmapped_mapping'/sorted_mappings.bam' > unmapped_mapping'/idxstats.txt'
head -n-1 unmapped_mapping'/idxstats.txt' > unmapped_mapping'/relevant_stats'
total_reads=`grep 'Number_of_input_reads' star_log | cut -f 3`
total_unmapped_reads=`cut -f 4 unmapped_mapping'/idxstats.txt' | paste -sd+ - | bc`
unm_reads_pct=`echo "$total_unmapped_reads/$total_reads*100" | bc -l`
rounded_unm_pct=`Rscript -e "cat(round($unm_reads_pct,2))"`
echo -e "unmapped_reads_pct\t$rounded_unm_pct" | awk '{print "$sample" "\t" $0}' >> ../metrics
unm_unaligned_pct=`echo '100'`
while IFS= read -r line; do
        array=( $line )
        echo -e "aligned_to_${array[0]}\t${array[2]}" |  awk '{print "$sample" "\t" $0}' >> ../metrics
        aligned_pct=`echo "${array[2]}/$total_reads*100" | bc -l`
        rounded_aligned_pct=`Rscript -e "cat(round($aligned_pct,2))"`
        echo -e "${array[0]}_total_percentage\t$rounded_aligned_pct" | awk '{print "$sample" "\t" $0}' >> ../metrics
        unm_aligned_pct=`echo "${array[2]}/$total_unmapped_reads*100" | bc -l`
        rounded_unm_aligned_pct=`Rscript -e "cat(round($unm_aligned_pct,2))"`
        echo -e "${array[0]}_unmapped_pct\t$rounded_unm_aligned_pct" | awk '{print "$sample" "\t" $0}' >> ../metrics
        unm_unaligned_pct=`echo "$unm_unaligned_pct-$rounded_unm_aligned_pct" | bc -l`
done < unmapped_mapping'/relevant_stats'
echo -e "unmapped_reads_unaligned_pct\t$unm_unaligned_pct" | awk '{print "$sample" "\t" $0}' >> ../metrics

