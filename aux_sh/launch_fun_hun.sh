#!/usr/bin/env bash

source ~soft_bio_267/initializes/init_degenes_hunter
functional_hunter_options=`generate_DGHunter_command.rb -m "functional_Hunter"`
for TARGET_FILE in `echo $TARGETS | tr "," " "`
do
	TARGET_NAME=`echo $TARGET_FILE | sed 's/_target.txt//'`
	target_results_folder=$HUNTER_RESULTS_FOLDER'/'$TARGET_NAME
	functional_Hunter.R $functional_hunter_options -i $target_results_folder -t E -o $target_results_folder/functional_enrichment &
done
wait
