#! /usr/bin/env bash
source ~soft_bio_267/initializes/init_degenes_hunter

INPUT_FOLDER=$1
RESULTS_FOLDER=$2
TARGET_FILE=$3
REPORT_TEMPLATES_FOLDER=$4

mkdir $RESULTS_FOLDER
cat $INPUT_FOLDER/*/metrics > $RESULTS_FOLDER'/all_metrics'
create_metric_table.rb $RESULTS_FOLDER'/all_metrics' sample $RESULTS_FOLDER'/metric_table'
create_report.R -t $REPORT_TEMPLATES_FOLDER/alignments_report.Rmd -o $RESULTS_FOLDER/alignments_report.html -d $RESULTS_FOLDER/metric_table -H t
# Exit so as to not keep going unnecessarily to folder generation... for now
exit
controls=`grep 'Ctrl' $TARGET_FILE | cut -f 1 | tr "\n" ","`
controls=${controls%?}
treatments=`grep 'Treat' $TARGET_FILE | cut -f 1 | tr "\n" ","`
treatments=${treatments%?}
## Join all results of each sample in a general table
maps2DEGhunter.rb $TARGET_FILE $INPUT_FOLDER STAR_000*/selected_counts $RESULTS_FOLDER no
grep -v '^N_' $RESULTS_FOLDER'/selected_counts' | sum_counts_by_isoform.rb - > $RESULTS_FOLDER'/final_counts.txt'

#degenes_Hunter.R -i $RESULTS_FOLDER'/final_counts.txt' -C $controls -T $treatments -o $RESULTS_FOLDER 
degenes_Hunter.R -i $RESULTS_FOLDER'/final_counts.txt' -C $controls -T $treatments -o $RESULTS_FOLDER -m 'DEN'

