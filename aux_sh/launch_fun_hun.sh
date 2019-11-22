#!/usr/bin/env bash

source ~soft_bio_267/initializes/init_degenes_hunter

functional_hunter_options=`generate_DGHunter_command.rb -m "functional_Hunter"`

for TARGET_FILE in `echo $TARGETS | tr "," " "`
do
	TARGET_NAME=`echo $TARGET_FILE | sed 's/_target.txt//'`
	target_results_folder=$HUNTER_RESULTS_FOLDER'/'$TARGET_NAME
	cd $target_results_folder
	functional_Hunter.R $functional_hunter_options -i ./Common_results/hunter_results_table.txt -c ./filtered_count_data.txt -t E -o functional_enrichment &
done
wait