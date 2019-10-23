#!/usr/bin/env bash
#SBATCH --mem='4gb'
#SBATCH --time='10:00:00'
#SBATCH --error=functionalHunter.%J.err
#SBATCH --output=functionalHunter.%J.out

source ~soft_bio_267/initializes/init_degenes_hunter

for TARGET_FILE in `echo $TARGET | tr "," " "`
do
	target_results_folder=$HUNTER_RESULTS_FOLDER'/'`echo $TARGET_FILE | sed 's/_target.txt//'`; cd $target_results_folder
	#functional_Hunter.R -i ./Common_results/hunter_results_table.txt -c ./filtered_count_data.txt -m Human -G 'MBC' -t E 
	if [ $fun_remote_mode ]; then
		functional_Hunter.R -f $fun_an_type -G $GO_modules -A $fun_an_performance -r $fun_remote_mode -T $fun_pvalue -i ./Common_results/hunter_results_table.txt -c ./filtered_count_data.txt -m Human -G 'MB' -t E -f 'G' &
	else
		functional_Hunter.R -f $fun_an_type -G $GO_modules -A $fun_an_performance -T $fun_pvalue -i ./Common_results/hunter_results_table.txt -c ./filtered_count_data.txt -m Human -G 'MB' -t E -f 'G' &
	fi
done
