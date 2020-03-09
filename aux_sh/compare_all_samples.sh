#! /usr/bin/env bash
#SBATCH --mem='10gb'
#SBATCH --constraint=cal
#SBATCH --cpus=2

hostname


export PATH=~/software/DEgenesHunter/:$PATH

source ~soft_bio_267/programs/x86_64/R/init_custom

#source ~soft_bio_267/initializes/init_degenes_hunter
mkdir $report_folder
## Collection information and mapping report generation
cat $MAPPING_RESULTS_FOLDER/*/metrics | sed "s/'//g" > $report_folder'/all_metrics'
create_metric_table.rb $report_folder'/all_metrics' sample $report_folder'/metric_table'
full_path_tagets=`ls $TARGETS_FOLDER/*_target.txt | tr "\n" ","` 
full_path_tagets=${full_path_tagets%?}
headers="t"
for target_path in `echo $full_path_tagets| tr "," " "`; do 
	headers=$headers",t"
done
counts_tables=''
all_samples=''
while IFS= read sample; do
	counts_tables=$counts_tables$MAPPING_RESULTS_FOLDER/$sample/qualimap_0000/selected_counts','
	all_samples=$all_samples$sample,
done < $SAMPLES_FILE
counts_tables=${counts_tables%?}
all_samples=${all_samples%?}
headers=$headers",t"
merge_count_tables.rb -i $counts_tables -t $all_samples > $report_folder/all_counts
echo create_report.R -t $REPORT_TEMPLATES_FOLDER/alignments_report.Rmd -o $report_folder/mapping_report.html -d $report_folder/metric_table,$full_path_tagets,$report_folder/all_counts -H $headers
create_report.R -t $REPORT_TEMPLATES_FOLDER/alignments_report.Rmd -o $report_folder/mapping_report.html -d $report_folder/metric_table,$full_path_tagets,$report_folder/all_counts -H $headers
exit
if [[ $experiment_type == "miRNAseq_detection" ]]; then
	. ~soft_bio_267/initializes/init_ruby
	module load cdhit
	## miRNA result unificaton and comparison in report # test
	cat $MAPPING_RESULTS_FOLDER/*/miRDeep2.pl_0000/total_miRNAs.fasta > $mapping_ref'/all_miRNA.fasta'
	cd-hit-est -T 1 -M 0 -i $mapping_ref'/all_miRNA.fasta' -o $mapping_ref'/miRNA_nr.fasta' -c 1
	report_html -t $REPORT_TEMPLATES_FOLDER/all_miRNA_report.erb -d $report_folder/metric_table -o $report_folder/all_miRNA_report

elif [[ $experiment_type == "RNAseq_genome" || $experiment_type == "RNAseq_transcriptome" ]];then
	mkdir $HUNTER_RESULTS_FOLDER
	echo $TARGETS
	for TARGET_FILE in `echo $TARGETS | tr "," " "`
	do
		export target_path=$TARGETS_FOLDER/$TARGET_FILE
		target_results_folder=$HUNTER_RESULTS_FOLDER'/'`echo $TARGET_FILE | sed 's/_target.txt//'`
		mkdir $target_results_folder
		
		## Join all results of each sample in a general table
		maps2DEGhunter.rb $target_path $MAPPING_RESULTS_FOLDER qualimap_0000/selected_counts $target_results_folder no
		grep -v '^N_' $target_results_folder'/selected_counts' | sum_counts_by_isoform.rb - > $target_results_folder'/final_counts.txt'

		degenes_hunter_options=`generate_DGHunter_command.rb -m "degenes_Hunter"`
		## Launch DEGenesHunter
		/usr/bin/time -o $target_results_folder/process_data_degenes_hunter -v degenes_Hunter.R $degenes_hunter_options -i $target_results_folder'/final_counts.txt' -o $target_results_folder &>$target_results_folder/'degenes_Hunter.log' #&
	done
	wait
fi
