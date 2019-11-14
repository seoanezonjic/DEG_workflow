# DEG_workflow
##Workflow to perform Differential Expression Gene analysis from raw fastq files.

##USAGE:

###	Initializing experiment: 
Create manage_input_files.sh manually, from which all raw samples must be linked with a suitable name to another custom folder (e.g. "raw_files", "samples" or "renamed_sample"). This step must be performed for customizate samples according to the experiment and keep original sample names in order to facilitate sample backtracking (In case of failure) at same time. New sample names must be easy to interpret and it is recommended short and non redundant names. 

After that create samples_to_process.lst: Is a file containing a list of new sample names. IMPORTANT: Sample name must not include paired-end related information and file extension.

### mRNA-seq or miRNA-seq differential expression analysis 
1º: Create an experiment design table. Experiment design table must include sample names as first column (with header: sample_name) and all features as other columns, and it also must include a header with feature names. 

2º: Create all target (comparison) files. The target comparison file is used in DEGenesHunter comparison. It consist in a table with 3 columns (sample name, replicate number and treatment). To generate target files it is recommended to use ./aux_parsers/generate_targets.rb. This script takes the experiment design table as input (-e), and it generate target by parsing a config string. The config string is given by '-t' flag and must be designed manually and it can generate all possible targets according filtering criteria (explanined later). The config string consist in information for one or more targets (divided by ';': "TargetA;TargetB"). In target information target name and conditions mus be indicated. Target name and conditions are separated by '>' and control and treatment features mus be indicated as feature_name:control_feature1/control_feature2,treatment_feature1,treatment_feature2. For example, for experiment

|test|tets|test|test|
|-|-|-|-|
|test1|test2|test3|test4|


4º: Customize one or more target files. A 'target_example.txt' is provided. First column, called 'sample', must include sample names (as same as samples_to_process.lst), second column, called 'replicate', must include a replicate number and third column, called 'treat', must include a tag indicating control samples ('Ctrl') and treatment samples ('Treat').

5º: Change name of config_daemon_default to config_daemon

6º: Customize all parametres from config_daemon (there you will find a more detailed description).

7º: Launch step by step all daemon modules. daemon.sh must be launched from his original location by default. The module must be indicated in the firt argument.
  Modules:
  1 -> Download all reference files.
  1b -> Index the reference.
  2 -> Launch trimming and mapping steps. (Eventually, second argument '-v' can be used to launch AutoFlow vervose mode)
  2b -> Check trimming and mapping workflow.
  3 -> Compare all samples with DEgenesHunter.
  4 -> Functionally analyze gene expression data. 
