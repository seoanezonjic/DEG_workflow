# DEG_workflow
## Workflow to perform Differential Expression Gene analysis from raw fastq files.

## USAGE:

###	Initializing experiment for both mRNA-seq and miRNA-seq analysis: 
The first step will be creating manage_input_files.sh manually, where all raw samples will be linked to a custom folder called 'raw_data' by default (you may choose a different name and change the 'read_path' variable accordingly in the config_daemon file). This step must be performed to customize sample names based on the experiment while keeping the original sample names, which will facilitate sample backtracking in case of failure. New sample names must be easy to interpret and short and non-redundant names are recommended. 

The second step will be creating the samples_to_process.lst file, which will contain a list of the new sample names linked in the previous step. IMPORTANT: Sample names must not include paired-end related information and file extension. For example: if we have 'Sample_A_1' and 'Sample_A_2' (paired-end), only 'Sample_A' will be added to samples_to_process.lst.

The third step will be creating a copy of config_daemon_default called config_daemon, which we'll be customized (explained below).

The final common step will be creating the experiment design file, a table with sample names in the first column (with header 'sample') and all known features in the rest of the columns with their corresponding header. 

#### Experiment design example:

|sample|id|clinical_status|age_group|location|
|-|-|-|-|-|
|ch_dis_1|patient_1|diseased|child|usa|
|ad_dis_2|patient_2|diseased|adult|europe|
|ch_hl_3|patient_3|healthy|child|europe|
|ad_hl_4|patient_4|healthy|adult|usa|
|ch_dis_5|patient_5|diseased|child|usa|
|ad_hl_6|patient_6|healthy|adult|europe|
|ad_dis_7|patient_7|diseased|senior|usa|
|ad_dis_8|patient_8|diseased|adult|usa|
|ch_hl_9|patient_9|healthy|child|usa|


### mRNA-seq differential expression analysis 

1º. To perform mRNA-seq analysis, the config_daemon file must be customized. You can find a detailed description for each parameter in said file.
When creating all target (comparison) files in the 'DEgenesHunter comparisons' section, the generate_targets.R will be used. This script takes the experiment design table as input (***-e***) and it generates each target by parsing a config string. The config string is given by the ***-t*** flag and must be designed manually. The structure is as follows: 'name of the comparison **>** feature_name:control_feature1,treatment_feature_1'. For example: adult_vs_child**>**age_group:adult,child. You can also compare one group of samples against two others by adding a **/** in the corresponding feature. For example, if we had samples from healthy controls and two groups of patients (soft, severe), we could compare the controls to the patients by creating the string 'control_vs_patient**>**clinical_status:healthy,soft/severe'. 
We can also create more than one target by separating them with **;** or duplicate the lines and execute the generate_target.R script as many times as needed. An example for the first option would be for **healthy vs disease** and **child vs others** comparisons: **'**hl_vs_dis**>**clinical_status**:**healthy**,**diseased**;**ch_vs_other**>**age_group**:**child**,**adult**/**senior**'**. 
Filtering criteria can also be used. You can select only samples that fulfill a specific feature using the ***-f*** flag with an argument like "FEATURE_NAME=feature". To select only USA samples, for example, we would add ***-f*** "location=usa". This script also admits a blacklist file (one column table) with samples that will not be included in the experiment using the ***-b*** flag. This feature is very useful to discard certain samples in the analysis without needing to change the samples_to_process.lst. On the contrary, there is also a ***-w*** flag to include a whitelist file with the samples you want to select for the analysis. 
In the event of wanting to add quantitative or qualitative features for the Principal Components Analysis, you may define the corresponding column headers of the experiment design file in the 'string_features' and 'numeric_features' parameters and follow the specified structure in the config_daemon file.

2º. Launch all daemon modules step by step. The daemon.sh script must be launched from its original location by default. The module must be indicated in the first argument.
  Modules:
  1a -> Download all reference genome files. If saved from previous analyses, you can specify the path to 'only_read_ref'.
  1b -> Index the reference (omit if saved reference is already indexed)
  2a -> Trimming and mapping steps (a second argument '-v' can be used to launch AutoFlow verbose mode).
  2b -> Check trimming and mapping workflow.
  3  -> Creation of mapping report and Differential Expression Analysis (DEA).
  4a  -> Functional analysis of DEA results.
  5  -> Create hunter results package. 

### miRNA-seq differential expression analysis

To perform miRNA-seq analysis, there is a first 'miRNA detection' step and the following 'Differential Expression Analysis' step. Each step will have its own config_daemon file.

#### Step 1: miRNA detection
The experiment type specified in the config_daemon file must be 'miRNAseq_detection' and the trimming template path (TRIM_TEMPLATE parameter) must be "$CODE_PATH"/templates/trimming/miRNA.txt.
Launch the following daemon.sh modules:
1a  -> Download all reference genome files. If saved from previous analyses, you can specify the path to 'only_read_ref'.
1b  -> Index the reference (omit if saved reference is already indexed)
2a  -> Trimming, mapping and miRNA detection steps (a second argument '-v' can be used to launch AutoFlow verbose mode).
2b  -> Check trimming, mapping and miRNA detection workflow. 
3   -> Creation of mapping_report and all_miRNA_report.

Once those two reports are created, the miRNA detection step will be finished and a copy of the config_daemon file will be created with the name config_daemon_DET. 

#### Step 2: Differential Expression Analysis
The first step will be changing the experiment type to 'RNAseq_transcriptome', changing the project_folder parameter path to the previous one '**_**DEA' and add the path to the clean_and_map results folder from the miRNA detection step to the 'link_path' parameter.
Launch the following daemon.sh modules: 
1b  -> Index the FASTA file that contains miRNA reads for he mapping step. 
2a  -> Create soft link to clean reads from miRNA detection step and maps reads to transcriptome. 
2b  -> Check mapping workflow.
3   -> Creation of mapping_report and Differential Expression Analysis.
4a  -> Functional analysis of DEA results.

