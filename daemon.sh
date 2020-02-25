#! /usr/bin/env bash

framework_dir=`dirname $0`
export CODE_PATH=$(readlink -f $framework_dir )
export ADD_OPTIONS=$2
CONFIG_DAEMON=$CODE_PATH'/config_daemon'
if [ "$3" != "" ] ; then
	CONFIG_DAEMON=$3
fi
export PATH=$CODE_PATH'/aux_sh:'$PATH
export PATH=$CODE_PATH'/aux_parsers:'$PATH

source $CONFIG_DAEMON
n_target=`echo $TARGETS |tr "," "\n" | wc -l `
tasks=`echo $n_target"+1" | bc`

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
	trim_and_map.sh

elif [ "$1" == "2b" ] ; then
	check_wf.sh

elif [ "$1" == "3" ] ; then
	#STAGE 3 SAMPLES COMPARISON
	echo "Launching stage 3: Comparing samples"
	eval "$generate_targets"
	export TARGETS=`ls $TARGETS_FOLDER/*_target.txt | rev | cut -f 1 -d "/" | rev | tr "\n" ","` ; TARGETS=${TARGETS%?}	#-------#	Target file location, including a short sample description	
	if [ $launch_login == TRUE ]; then
		compare_all_samples.sh
	else
		sbatch -c $tasks compare_all_samples.sh
	fi
elif [ "$1" == "4" ] ; then
	#STAGE 4 : FUNCTIONAL ANALYSIS
	echo "Launching stage 4: Functional analysis"

	if [ `echo $fun_remote_mode | grep -q -G "[kb]"` ] || [ $launch_login == TRUE ]; then	
		launch_fun_hun.sh
	else
		sbatch -c $tasks launch_fun_hun.sh	
	fi
fi
