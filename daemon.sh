#! /usr/bin/env bash

framework_dir=`dirname $0`
CODE_PATH=$(readlink -f $framework_dir )
export PATH=$CODE_PATH'/aux_sh:'$PATH

## DAEMON VARS
###################################
project_folder=`pwd`'/project_execution'
TEMPLATE=$CODE_PATH"/templates/mapping_template.txt"
SAMPLES_FILE=$project_folder"/samples_to_process.lst"
read_layout='single' # paired

MAPPING_RESULTS_FOLDER=$project_folder'/clean_and_map/'
HUNTER_RESULTS_FOLDER=$project_folder'/DEGenesHunter_results'
TARGET_FILE="target.txt"


## WORKFLOW VARS
##################################

# General
#-----------------
RESOURCES="-c 2 -t 10:00:00 -n cal"
read_path=$project_folder'/raw_data'
mapping_ref=$project_folder'/references'


## STAGE EXECUTION
#######################################################################
mkdir -p  $MAPPING_RESULTS_FOLDER


if [ "$1" == "1" ] ; then
#STAGE 1 CREATING_INDEX
	download_files_for_index.sh $mapping_ref
elif [ "$1" == "1b" ] ; then
	export mapping_ref
    echo "Launching stage 1"
	$CODE_PATH'/aux_sh/create_index.sh'
	
elif [ "$1" == "2" ] ; then
#STAGE 2 
	echo "Launching stage 2"
	GENERAL_VARS="\$read_folder=$read_path,\$star_count_column=2" 
	trim_and_map.sh $TEMPLATE $MAPPING_RESULTS_FOLDER $SAMPLES_FILE "$RESOURCES" "$GENERAL_VARS" $mapping_ref $read_layout $2

elif [ "$1" == "3" ] ; then
#STAGE 2 (Sample comparison)
	echo "Launching stage 3"
	compare_all_samples.sh $MAPPING_RESULTS_FOLDER $HUNTER_RESULTS_FOLDER $TARGET_FILE

elif [ "$1" == "4" ] ; then
	check_wf.sh $MAPPING_RESULTS_FOLDER $SAMPLES_FILE

elif [ "$1" == "5" ] ; then
	cd $HUNTER_RESULTS_FOLDER
	#launch_fun_hun.sh
	sbatch launch_fun_hun.sh
	cd $project_folder
fi
