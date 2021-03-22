#! /usr/bin/env bash

framework_dir=`dirname $0`
export CODE_PATH=$(readlink -f $framework_dir )
module=$1
export ADD_OPTIONS=$2
CONFIG_DAEMON=$CODE_PATH'/config_daemon'
if [ "$3" != "" ] ; then
	CONFIG_DAEMON=$3
fi
export PATH=$CODE_PATH'/aux_sh:'$PATH
export PATH=$CODE_PATH'/aux_parsers:'$PATH
source $CONFIG_DAEMON
	

if [ $experiment_type != "miRNAseq_detection" ] ; then 

	rm -r $TARGETS_FOLDER
	mkdir $TARGETS_FOLDER
	eval "$generate_targets"
	export TARGETS=`ls $TARGETS_FOLDER/*_target.txt | rev | cut -f 1 -d "/" | rev | tr "\n" ","` ; TARGETS=${TARGETS%?}	#-------#	Target file location, including a short sample description	
	n_target=`echo $TARGETS |tr "," "\n" | wc -l `
	tasks=`echo $n_target"+1" | bc`

	if [ "$ADD_triming_opt" != "" ]; then 
		export ADD_triming_opt=";"$ADD_triming_opt
	fi
fi 


## STAGE EXECUTION
#######################################################################
mkdir -p  $MAPPING_RESULTS_FOLDER


if [ "$module" == "1a" ] ; then
	#STAGE 1 DOWNLOADING REFERENCE
	echo "Launching stage 1: Downloading reference"
	download_files_for_index.sh 

elif [ "$module" == "1b" ] ; then
	#STAGE 1 INDEXING REFERENCE
	echo "Launching stage 1: Indexing reference"
	if [ $launch_login == TRUE ]; then	
		create_index.sh
	else
		sbatch create_index.sh
	fi

elif [ "$module" == "2a" ] ; then
	#STAGE 2 TRIMMING AND MAPPING SAMPLES
	echo "Launching stage 2: Trimming and mapping samples"
	trim_and_map.sh

elif [ "$module" == "2b" ] ; then
	check_wf.sh

elif [ "$module" == "3" ] ; then
	#STAGE 3 SAMPLES COMPARISON
	echo "Launching stage 3: Comparing samples"
	if [ $launch_login == TRUE ]; then
		compare_all_samples.sh
	else
		sbatch compare_all_samples.sh
	fi
elif [ "$module" == "4a" ] ; then
	#STAGE 4A : FUNCTIONAL ANALYSIS
	echo "Launching stage 4a: Launching functional hunter"
	if [ `echo $fun_remote_mode | grep -q -G "[kb]"` ] || [ $launch_login == TRUE ]; then	
		launch_fun_hun.sh $module
	else
		sbatch launch_fun_hun.sh $module	
	fi
elif [ "$module" == "4b" ]; then
	#STAGE 4B : Creating Clusters specific report
	echo "Launching stage 4b: Creating Cluster specific report"
	if [ $launch_login == TRUE ]; then	
		launch_fun_hun.sh $module
	else
		sbatch launch_fun_hun.sh $module
	fi
fi
