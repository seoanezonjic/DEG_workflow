#! /usr/bin/env bash

framework_dir=`dirname $0`
export CODE_PATH=$(readlink -f $framework_dir )
module=$1
export ADD_OPTIONS=$2
CONFIG_DAEMON=$CODE_PATH'/config_daemon'
if [ "$3" != "" ] ; then
	CONFIG_DAEMON=$3
fi
export AUXSH_PATH=$CODE_PATH'/aux_sh'
export MASK_YPAR_BEDS=$CODE_PATH'/bed_YPAR'
export PATH=$AUXSH_PATH:$PATH
export PATH=$CODE_PATH'/aux_parsers:'$PATH
source $CONFIG_DAEMON

## STAGE EXECUTION
#######################################################################
mkdir -p  $MAPPING_RESULTS_FOLDER


if [ "$module" == "1a" ] ; then
	#STAGE 1 DOWNLOADING REFERENCE
	echo "Launching stage 1: Downloading reference"
	download_files_for_index.sh
       exit	
fi
if [ "$module" == "1b" ] ; then
	#STAGE 1 INDEXING REFERENCE
	echo "Launching stage 1: Indexing reference"
	if [ $launch_login == TRUE ]; then	
		create_index.sh
	else
		sbatch $AUXSH_PATH/create_index.sh
	fi
	exit
fi
if [ "$module" == "2a" ] ; then
	#STAGE 2 TRIMMING AND MAPPING SAMPLES
	echo "Launching stage 2: Trimming and mapping samples"
	trim_and_map.sh
	exit
fi

if [ "$module" == "2b" ] ; then
	check_wf.sh
	exit
fi

export TARGETS=1
if [ $experiment_type != "miRNAseq_detection" ] ; then 

	rm -r $TARGETS_FOLDER
	mkdir $TARGETS_FOLDER
	eval "$generate_targets"
	export TARGETS=`ls $TARGETS_FOLDER/*_target.txt | rev | cut -f 1 -d "/" | rev | tr "\n" ","` ; TARGETS=${TARGETS%?}	#-------#	Target file location, including a short sample description	
	

fi 
n_target=`echo $TARGETS |tr "," "\n" | wc -l `
tasks=`echo $n_target"+1" | bc`


if [ "$module" == "3" ] ; then
	#STAGE 3 SAMPLES COMPARISON
	echo "Launching stage 3: Comparing samples"
	if [ $launch_login == TRUE ]; then
		compare_all_samples.sh 
	else
		sbatch --cpus-per-task="$tasks" $AUXSH_PATH/compare_all_samples.sh  
	fi
	exit
fi
if [ "$module" == "4a" ] ; then
	#STAGE 4A : FUNCTIONAL ANALYSIS
	echo "Launching stage 4a: Launching functional hunter"
	if [ `echo $fun_remote_mode | grep -q -G "[kb]"` ] || [ $launch_login == TRUE ]; then	
		launch_fun_hun.sh $module
	else
		sbatch $AUXSH_PATH/launch_fun_hun.sh $module	
	fi
	exit
fi
if [ "$module" == "4b" ]; then
	#STAGE 4B : Creating Clusters specific report
	echo "Launching stage 4b: Creating Cluster specific report"
	if [ $launch_login == TRUE ]; then	
		launch_fun_hun.sh $module
	else
		sbatch $AUXSH_PATH/launch_fun_hun.sh $module
	fi
fi
if [ "$module" == "5" ]; then
	echo "Creating ExpHunterSuite results pack"
	create_hunter_pack.sh $ADD_OPTIONS
	create_symlinks.sh $ADD_OPTIONS
	if [ "$keep_bam" == TRUE ]; then
		create_symlinks.sh $keep_bam $ADD_OPTIONS
	fi
	exit
fi

