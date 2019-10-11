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
#STAGE 1 CREATING_INDEX
	download_files_for_index.sh $mapping_ref
elif [ "$1" == "1b" ] ; then
	export mapping_ref
    echo "Launching stage 1"
	$CODE_PATH'/aux_sh/create_index.sh'
	
elif [ "$1" == "2" ] ; then
#STAGE 2 
	echo "Launching stage 2"
	GENERAL_VARS="\$read_folder=$read_path,\$stranded=$stranded" 
	trim_and_map.sh $TEMPLATE $MAPPING_RESULTS_FOLDER $SAMPLES_FILE "$RESOURCES" "$GENERAL_VARS" $mapping_ref $read_layout "$2"

elif [ "$1" == "2b" ] ; then
	check_wf.sh $MAPPING_RESULTS_FOLDER $SAMPLES_FILE

elif [ "$1" == "3" ] ; then
#STAGE 2 (Sample comparison)
	echo "Launching stage 3"
	compare_all_samples.sh $MAPPING_RESULTS_FOLDER $HUNTER_RESULTS_FOLDER $TARGET_FILE $REPORT_TEMPLATES_FOLDER

elif [ "$1" == "4" ] ; then
	cd $HUNTER_RESULTS_FOLDER
	#launch_fun_hun.sh
	sbatch launch_fun_hun.sh
	cd $project_folder
fi
