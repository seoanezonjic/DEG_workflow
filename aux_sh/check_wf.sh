#!/usr/bin/env bash
. ~soft_bio_267/initializes/init_autoflow
while read sample; do
	echo $sample
	flow_logger -e $MAPPING_RESULTS_FOLDER/$sample -r all
done < $SAMPLES_FILE
