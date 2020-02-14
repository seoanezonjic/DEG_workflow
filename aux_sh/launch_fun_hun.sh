#!/usr/bin/env bash
#SBATCH --mem='20gb'
hostname

source ~soft_bio_267/initializes/init_degenes_hunter
functional_hunter_options=`generate_DGHunter_command.rb -m "functional_Hunter"`
for TARGET_FILE in `echo $TARGETS | tr "," " "`
do
	TARGET_NAME=`echo $TARGET_FILE | sed 's/_target.txt//'`
	target_results_folder=$HUNTER_RESULTS_FOLDER'/'$TARGET_NAME
	echo $degenes_hunter_options > $target_results_folder/'functional_Hunter.log'
        /usr/bin/time -o $target_results_folder/process_data -v functional_Hunter.R $functional_hunter_options -i $target_results_folder -t E -o $target_results_folder/functional_enrichment &>$target_results_folder'/functional_Hunter.log' &
done
wait
