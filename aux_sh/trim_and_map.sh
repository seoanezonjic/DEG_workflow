. ~soft_bio_267/initializes/init_autoflow

mkdir $OUTPUT_FOLDER

while IFS= read sample; do

	if [[ $experiment_type == "miRNAseq" ]]; then
		AF_VARS=`echo "
		\\$read_folder=$read_path,
		\\$sample=$sample,
		\\$miRNA_trim_template=$MIRNA_TRIM_TEMPLATE,
		\\$ref=$mapping_ref
		" | tr -d [:space:]`
	elif [[ $experiment_type == "RNAseq" ]]; then

		AF_VARS=`echo "
		\\$read_folder=$read_path,
		\\$sample=$sample,
		\\$stranded=$stranded,
		\\$min_read_length=$MIN_READ_LENGTH,
		\\$read_layout=$read_layout,
		\\$ref=$mapping_ref
		" | tr -d [:space:]`
	fi

	AutoFlow -w $TEMPLATE -V "$AF_VARS" -o "$MAPPING_RESULTS_FOLDER"/"$sample" "$RESOURCES" $AF_ADD_OPTIONS 

done < $SAMPLES_FILE



