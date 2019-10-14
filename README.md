# DEG_workflow
Workflow to perform Differential Expression Gene analysis from raw fastq files.

USAGE:
1º: Create manage_input_files.sh manually, from which all raw samples must be linked with a suitable name to another custom folder (e.g. "raw_files", "samples" or "renamed_sample"). This step must be performed for customizate samples according to the experiment and keep original sample names in order to facilitate sample backtracking (In case of failure) at same time. New sample names must be easy to interpret and short.

2º: Customize all parametres from config_daemon (there you will find a more detailed description).

3º: Launch step by step all daemon modules. daemon.sh must be launched from his original location by default. The module must be indicated in the firt argument.
  Modules:
  1 -> Download all reference files.
  1b -> Index the reference.
  2 -> Launch trimming and mapping steps. (Eventually, second argument '-v' can be used to launch AutoFlow vervose mode)
  2b -> Check trimming and mapping workflow.
  3 -> Compare all samples with DEgenesHunter.
  4 -> Functionally analyze gene expression data. 
