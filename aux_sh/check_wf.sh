#!/usr/bin/env bash
. ~soft_bio_267/initializes/init_python
echo $ADD_OPTIONS
while read sample; do
	echo $sample

	if [ "$ADD_OPTIONS" == "" ]; then
		flow_logger -w -e $MAPPING_RESULTS_FOLDER/$sample -r all
	else
		flow_logger -w -e $MAPPING_RESULTS_FOLDER/$sample $ADD_OPTIONS
	fi	
done < $SAMPLES_FILE
 
