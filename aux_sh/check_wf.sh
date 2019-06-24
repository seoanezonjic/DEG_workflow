#!/usr/bin/env bash
. ~soft_cvi_114/initializes/init_autoflow
while read sample; do
	flow_logger -e $1/$sample -r all
done < $2
