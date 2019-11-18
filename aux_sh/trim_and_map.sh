. ~soft_bio_267/initializes/init_autoflow


while IFS= read sample; do

	#############################################################
	####	GLOBAL VARS
	#############################################################
	AF_VARS=`echo "
	\\$read_folder=$read_path,
	\\$trim_template=$TRIM_TEMPLATE,
	\\$sample=$sample,
	\\$ref=$mapping_ref
	" | tr -d [:space:]`

	if [[ $experiment_type == "RNAseq" || $experiment_type == "miRNAseq_DEA" ]]; then

		AF_VARS=$AF_VARS,`echo "
		\\$stranded=$stranded,
		\\$min_read_length=$MIN_READ_LENGTH,
		\\$read_layout=$read_layout
		" | tr -d [:space:]`
	fi

	AutoFlow -w $TEMPLATE -V "$AF_VARS" -o "$MAPPING_RESULTS_FOLDER"/"$sample" "$RESOURCES" $AF_ADD_OPTIONS 

done < $SAMPLES_FILE



