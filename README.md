# DEG_workflow
##Workflow to perform Differential Expression Gene analysis from raw fastq files.

##usaGE:

###	Initializing experiment: 
Create manage_input_files.sh manually, from which all raw samples must be linked with a suitable name to another custom folder (e.g. "raw_files", "samples" or "renamed_sample"). This step must be performed for customizate samples according to the experiment and keep original sample names in order to facilitate sample backtracking (In case of failure) at same time. New sample names must be easy to interpret and it is recommended short and non redundant names. 

After that create samples_to_process.lst: Is a file containing a list of new sample names. IMPORTANT: Sample name must not include paired-end related information and file extension.

### mRNA-seq or miRNA-seq differential expression analysis 
1º: Create an experiment design table. Experiment design table must include sample names as first column (with header: sample_name) and all features as other columns, and it also must include a header with feature names. 

#### Experiment design example:

|sample_name|id|clinical_status|age_group|location|
|-|-|-|-|-|
|ch_dis_1|patien1|diseased|child|usa|
|ad_dis_2|patien2|diseased|adult|europe|
|ch_hl_3|patien3|healthy|child|europe|
|ad_hl_4|patien4|healthy|adult|usa|
|ch_dis_5|patien5|diseased|child|usa|
|ad_hl_6|patien6|healthy|adult|europe|
|ad_dis_7|patien7|diseased|senior|usa|
|ad_dis_8|patien8|diseased|adult|usa|
|ch_hl_9|patien9|healthy|child|usa|


2º: Create all target (comparison) files. The target comparison file is used in DEGenesHunter comparison. It consist in a table with 3 columns (sample name, replicate number and treatment). To generate target files it is recommended to use ./aux_parsers/generate_targets.rb. This script takes the experiment design table as input (***-e***), and it generate target by parsing a config string. The config string is given by ***-t*** flag and must be designed manually and it can generate all possible targets according filtering criteria (explanined later). The config string consist in information for one or more targets (divided by '**;**': "TargetA**;**TargetB"). In target information target name and conditions mus be indicated. Target name and conditions are separated by '**>**' and control and treatment features mus be indicated as feature_name**:**control_feature1**/**control_feature2**,**treatment_feature1**,**treatment_feature2. Example. For **healthy vs disease** and **child vs others** comparisons according example experimen design table, the target string should be **'**hl_vs_dis**>**clinical_status**:**healthy**,**diseased**;**ch_vs_other**>**age_group**:**child**,**adult**/**senior**'**. 

Filtering criteria can also be used. You can select only samples that fulfill a specific feature using ***-f*** flag with an argument like "FEATURE_NAME**=**feature". For select only USA samples must be used ***-f*** "location**=**usa". This script also admit a blacklist file (one column table) with samples that will not be included in experiment using ***-b*** flag (This is very useful for reject noisy samples). 



3º: Change name of config_daemon_default to config_daemon

4º: Customize all parametres from config_daemon (there you will find a more detailed description).

5º: Launch step by step all daemon modules. daemon.sh must be launched from his original location by default. The module must be indicated in the firt argument.
  Modules:
  1 -> Download all reference files.
  1b -> Index the reference.
  2 -> Launch trimming and mapping steps. (Eventually, second argument '-v' can be used to launch AutoFlow vervose mode)
  2b -> Check trimming and mapping workflow.
  3 -> Compare all samples with DEgenesHunter.
  4 -> Functionally analyze gene expression data. 
