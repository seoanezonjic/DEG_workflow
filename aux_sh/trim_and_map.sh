. ~soft_bio_267/initializes/init_autoflow

TEMPLATE=$1
OUTPUT_FOLDER=$2
SAMPLE_LIST=$3
RESOURCES=$4
OTHER_VARS=$5
REF=$6
READ_LAYOUT=$7
VERBOSE=$8


mkdir $OUTPUT_FOLDER
while IFS= read sample; do
	AutoFlow -w $TEMPLATE -V "$OTHER_VARS,\$sample=$sample,\$read_layout=$READ_LAYOUT,\$ref=$REF" -o "$OUTPUT_FOLDER"/"$sample" "$RESOURCES" $VERBOSE
done < $SAMPLE_LIST



