#! /usr/bin/env bash
#SBATCH --mem='60gb'
#SBATCH --constraint=cal
#SBATCH --time='02:00:00'
hostname

source ~soft_bio_267/initializes/init_degenes_hunter

mkdir $report_folder
## Collection information and mapping report generation
cat $MAPPING_RESULTS_FOLDER/*/metrics | sed "s/'//g" | awk 'BEGIN {IFS="\t";OFS="\t"}{if($3 != "" )print $0}' > $report_folder'/all_metrics'
create_metric_table.rb $report_folder'/all_metrics' sample $report_folder'/metric_table'
full_path_tagets=`ls $TARGETS_FOLDER/*_target.txt | tr "\n" ","` 
full_path_tagets=${full_path_tagets%?}
headers="t"
all_report_files=$report_folder/metric_table

if [[ $experiment_type != "miRNAseq_detection" ]]; then
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
	all_report_files=$all_report_files,$report_folder/all_counts
	if [ "$TARGETS" != "" ]; then
		all_report_files=$all_report_files,$full_path_tagets
		for target_path in `echo $full_path_tagets| tr "," " "`; do
		        headers=$headers",t"
		done
	fi
fi

create_report.R -t $REPORT_TEMPLATES_FOLDER/mapping_report.Rmd -o $report_folder/mapping_report.html -d $all_report_files -H $headers
if [[ $experiment_type == "miRNAseq_detection" ]]; then
	. ~soft_bio_267/initializes/init_ruby
	module load cdhit
	## miRNA result unificaton and comparison in report # test
	
	## THIS BLOCK TAKE MIRNA COORDS AND RETURN FASTA FILE
	merge_miRNA_coord.rb -d 20 -k "`echo $MAPPING_RESULTS_FOLDER`/*/miRDeep2.pl_0000/translated_known_miRNA.coord" -n "`echo $MAPPING_RESULTS_FOLDER`/*/miRDeep2.pl_0000/novel_miRNA.coord" -o $mapping_ref
	cat $MAPPING_RESULTS_FOLDER/*/miRDeep2.pl_0000/known_per_sample > $report_folder/known_per_sample
	cat $mapping_ref/*_miRNA.coord > $mapping_ref/final_miRNA.coord
	fasta_editor.rb -i $mapping_ref/genome.fa -f $mapping_ref/final_miRNA.coord -c a -o $mapping_ref/all_miRNA.fasta

	cd-hit-est -T 1 -M 0 -i $mapping_ref/all_miRNA.fasta -o $mapping_ref/miRNA_nr.fasta -c 1
	report_html -t $REPORT_TEMPLATES_FOLDER/all_miRNA_report.erb -d $report_folder/metric_table -o $report_folder/all_miRNA_report
elif [[ $experiment_type == "RNAseq_genome" || $experiment_type == "RNAseq_transcriptome" ]];then
	mkdir $HUNTER_RESULTS_FOLDER
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
		/usr/bin/time -o $target_results_folder/process_data_degenes_hunter -v degenes_Hunter.R $degenes_hunter_options -i $target_results_folder'/final_counts.txt' -o $target_results_folder &>$target_results_folder/'degenes_Hunter.log' &
	done
	wait
fi
