#! /usr/bin/env bash
source ~soft_bio_267/initializes/init_degenes_hunter

mkdir $HUNTER_RESULTS_FOLDER
cat $MAPPING_HUNTER_RESULTS_FOLDER/*/metrics | sed "s/'//g" > $HUNTER_RESULTS_FOLDER'/all_metrics'

create_metric_table.rb $HUNTER_RESULTS_FOLDER'/all_metrics' sample $HUNTER_RESULTS_FOLDER'/metric_table'
create_report.R -t $REPORT_TEMPLATES_FOLDER/alignments_report.Rmd -o $HUNTER_RESULTS_FOLDER/alignments_report.html -d $HUNTER_RESULTS_FOLDER/metric_table -H t

controls=`awk '{if($3 == "Ctrl") print $1}' $TARGET_FILE | tr "\n" ","`
controls=${controls%?}
treatments=`awk '{if($3 == "Treat") print $1}' $TARGET_FILE | tr "\n" ","`
treatments=${treatments%?}
## Join all results of each sample in a general table
maps2DEGhunter.rb $TARGET_FILE $MAPPING_HUNTER_RESULTS_FOLDER STAR_000*/selected_counts $HUNTER_RESULTS_FOLDER no
grep -v '^N_' $HUNTER_RESULTS_FOLDER'/selected_counts' | sum_counts_by_isoform.rb - > $HUNTER_RESULTS_FOLDER'/final_counts.txt'

#degenes_Hunter.R -i $HUNTER_RESULTS_FOLDER'/final_counts.txt' -C $controls -T $treatments -o $HUNTER_RESULTS_FOLDER 
degenes_Hunter.R -p $de_pvalue -m $de_packages -c $de_min_pack -i $HUNTER_RESULTS_FOLDER'/final_counts.txt' -C $controls -T $treatments -o $HUNTER_RESULTS_FOLDER -m 'DEN'
