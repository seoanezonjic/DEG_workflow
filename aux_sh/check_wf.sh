#!/usr/bin/env bash
. ~soft_bio_267/initializes/init_autoflow
while read sample; do
	echo $sample
	flow_logger -e $1/$sample -r all
done < $2
