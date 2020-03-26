#!/usr/bin/env bash
#SBATCH --mem='20gb'
#SBATCH --cpus=16
#SBATCH --constraint=cal

hostname
functional_launch=$1
source ~soft_bio_267/initializes/init_degenes_hunter
export PATH=~/software/merge/DEgenesHunter:$PATH
functional_hunter_options=`generate_DGHunter_command.rb -m "functional_Hunter"`
for TARGET_FILE in `echo $TARGETS | tr "," " "`
do
	TARGET_NAME=`echo $TARGET_FILE | sed 's/_target.txt//'`
	target_results_folder=$HUNTER_RESULTS_FOLDER'/'$TARGET_NAME
	rm -r $target_results_folder/functional_enrichment
	if [ "$functional_launch" == "4a" ]; then 
		/usr/bin/time -o $target_results_folder/process_data_functional_hunter -v functional_Hunter.R $functional_hunter_options -i $target_results_folder -t E --Debug $target_results_folder/debug_files/DH_debug_session.RData -o $target_results_folder/functional_enrichment &>$target_results_folder'/functional_Hunter.log' #&#-c 6
	elif [ "$functional_launch" == "4b" ]; then 
		/usr/bin/time -o $target_results_folder/process_data_cluster_report -v render_corr_report.R -i $target_results_folder -o $target_results_folder/functional_enrichment &>$target_results_folder'/functional_Hunter.log' &
	fi
done
wait
