#! /usr/bin/env bash

framework_dir=`dirname $0`
export CODE_PATH=$(readlink -f $framework_dir )
export PATH=$CODE_PATH'/aux_sh:'$PATH
export PATH=$CODE_PATH'/aux_parsers:'$PATH
REPORT_TEMPLATES_FOLDER=$CODE_PATH"/templates/reports"
source $CODE_PATH'/config_daemon'

## STAGE EXECUTION
#######################################################################
mkdir -p  $MAPPING_RESULTS_FOLDER


if [ "$1" == "1" ] ; then
#STAGE 1 DOWNLOADING REFERENCE
    echo "Launching stage 1: Downloading reference"
	download_files_for_index.sh 

elif [ "$1" == "1b" ] ; then
#STAGE 1 INDEXING REFERENCE
    echo "Launching stage 1: Indexing reference"
	if [ $launch_login == TRUE ]; then	
		create_index.sh
	else
		sbatch create_index.sh
	fi

elif [ "$1" == "2" ] ; then
#STAGE 2 TRIMMING AND MAPPING SAMPLES
	echo "Launching stage 2: Trimming and mapping samples"
	trim_and_map.sh $2

elif [ "$1" == "2b" ] ; then
	check_wf.sh

elif [ "$1" == "3" ] ; then
#STAGE 3 SAMPLES COMPARISON
	echo "Launching stage 3: Comparing samples"
	if [ $launch_login == TRUE ]; then
		compare_all_samples.sh
	else
		sbatch compare_all_samples.sh
	fi
elif [ "$1" == "4" ] ; then
#STAGE 4 : FUNCTIONAL ANALYSIS
	echo "Launching stage 4: Functional analysis"

	cd $HUNTER_RESULTS_FOLDER
	if [ $fun_remote_mode ] || [ $launch_login == TRUE ]; then	
		launch_fun_hun.sh
	else
		sbatch launch_fun_hun.sh
	fi
	cd $project_folder
fi
