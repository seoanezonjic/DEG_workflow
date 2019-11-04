#!/usr/bin/env bash

source ~soft_bio_267/initializes/init_degenes_hunter

for TARGET_FILE in `echo $TARGET | tr "," " "`
do
	TARGET_NAME=`echo $TARGET_FILE | sed 's/_target.txt//'`
	target_results_folder=$HUNTER_RESULTS_FOLDER'/'$TARGET_NAME; cd $target_results_folder
	#functional_Hunter.R -i ./Common_results/hunter_results_table.txt -c ./filtered_count_data.txt -m Human -G 'MBC' -t E 
	if [ $fun_remote_mode ]; then
		functional_Hunter.R -f $fun_an_type -G $GO_modules -A $fun_an_performance -r $fun_remote_mode -T $fun_pvalue -i ./Common_results/hunter_results_table.txt -c ./filtered_count_data.txt -m Human -t E -o functional_enrichment 1>$logs'/'$CODE_PATH'/functional_hunter'_$TARGET_NAME'_local.out' 2>$logs'/'$CODE_PATH'/functional_hunter'_$TARGET_NAME'_local.err' &
	else
		functional_Hunter.R -f $fun_an_type -G $GO_modules -A $fun_an_performance -T $fun_pvalue -i ./Common_results/hunter_results_table.txt -c ./filtered_count_data.txt -m Human -t E -o functional_enrichment &
	fi
done
wait
