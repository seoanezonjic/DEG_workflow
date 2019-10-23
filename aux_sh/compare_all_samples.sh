#! /usr/bin/env bash
#SBATCH --mem='4gb'
#SBATCH --error=DEGenesHunter.%J.err
#SBATCH --output=DEGenesHunter.%J.out
source ~soft_bio_267/initializes/init_degenes_hunter
REPORT_TEMPLATES_FOLDER=$CODE_PATH'/templates/reports'
mkdir $HUNTER_RESULTS_FOLDER
cat $MAPPING_RESULTS_FOLDER/*/metrics | sed "s/'//g" > $HUNTER_RESULTS_FOLDER'/all_metrics'

create_metric_table.rb $HUNTER_RESULTS_FOLDER'/all_metrics' sample $HUNTER_RESULTS_FOLDER'/metric_table'
create_report.R -t $REPORT_TEMPLATES_FOLDER/alignments_report.Rmd -o $HUNTER_RESULTS_FOLDER/alignments_report.html -d $HUNTER_RESULTS_FOLDER/metric_table -H t
for TARGET_FILE in `echo $TARGET | tr "," " "`
do
	target_results_folder=$HUNTER_RESULTS_FOLDER'/'`echo $TARGET_FILE | sed 's/_target.txt//'`
	mkdir $target_results_folder
	controls=`awk '{if($3 == "Ctrl") print $1}' $TARGET_FILE | tr "\n" ","`;controls=${controls%?}
	treatments=`awk '{if($3 == "Treat") print $1}' $TARGET_FILE | tr "\n" ","`;treatments=${treatments%?}
	
	## Join all results of each sample in a general table
	maps2DEGhunter.rb $TARGET_FILE $MAPPING_RESULTS_FOLDER STAR_000*/selected_counts target_results_folder no
	grep -v '^N_' target_results_folder'/selected_counts' | sum_counts_by_isoform.rb - > target_results_folder'/final_counts.txt'

	## Launch DEGenesHunter
	degenes_Hunter.R -p $de_pvalue -m $de_packages -c $de_min_pack -i target_results_folder'/final_counts.txt' -C $controls -T $treatments -o target_results_folder -m 'DEN' &
done
