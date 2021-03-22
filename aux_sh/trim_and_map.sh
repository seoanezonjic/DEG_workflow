. ~soft_bio_267/initializes/init_autoflow

while IFS= read sample; do

	#############################################################
	####	GLOBAL VARS
	#############################################################
	AF_VARS=`echo "
	\\$read_folder=$read_path,
	\\$trim_template=$TRIM_TEMPLATE,
	\\$sample=$sample,
	\\$ref=$mapping_ref,
	\\$ADD_triming_opt=$ADD_triming_opt,
	\\$link_path=\"$link_path\"
	" | tr -d [:space:]`

	if `echo $experiment_type | grep -q "^RNAseq"`; then

		AF_VARS=$AF_VARS,`echo "
		\\$min_read_length=$MIN_READ_LENGTH,
		\\$read_layout=$read_layout,
		\\$experiment_type=$experiment_type
		" | tr -d [:space:]`
	fi
	if [[ $experiment_type == "RNAseq_genome" ]]; then
		AF_VARS=$AF_VARS,`echo "
		\\$stranded=$stranded
		" | tr -d [:space:]`
	fi

	AutoFlow -e -w $TEMPLATE -V "$AF_VARS" -o "$MAPPING_RESULTS_FOLDER"/"$sample" "$RESOURCES" $ADD_OPTIONS
done < $SAMPLES_FILE



