. ~soft_bio_267/initializes/init_autoflow

VERBOSE=$1
LOGIN=''
if [ $launch_login == TRUE ]; then
	LOGIN='-b'
fi

mkdir $OUTPUT_FOLDER

while IFS= read sample; do

	AF_VARS=`echo "
	\\$read_folder=$read_path,
	\\$stranded=$stranded,
	\\$min_read_length=$MIN_READ_LENGTH,
	\\$sample=$sample,
	\\$read_layout=$read_layout,
	\\$ref=$mapping_ref
	" | tr -d [:space:]`

	AutoFlow -w $TEMPLATE -V "$AF_VARS" -o "$MAPPING_RESULTS_FOLDER"/"$sample" "$RESOURCES" $VERBOSE $LOGIN

done < $SAMPLES_FILE



