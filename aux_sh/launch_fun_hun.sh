#!/usr/bin/env bash
#SBATCH --cpus=1
#SBATCH --mem='4gb'
#SBATCH --time='10:00:00'
#SBATCH --error=job.%J.err
#SBATCH --output=job.%J.out

source ~soft_bio_267/initializes/init_degenes_hunter

#functional_Hunter.R -i ./Common_results/hunter_results_table.txt -c ./filtered_count_data.txt -m Human -G 'MBC' -t E 
if [ $fun_remote_mode ]; then
	functional_Hunter.R -f $fun_an_type -G $GO_modules -A $fun_an_performance -r $fun_remote_mode -T $fun_pvalue -i ./Common_results/hunter_results_table.txt -c ./filtered_count_data.txt -m Human -G 'MB' -t E -f 'G'
else
	functional_Hunter.R -f $fun_an_type -G $GO_modules -A $fun_an_performance -T $fun_pvalue -i ./Common_results/hunter_results_table.txt -c ./filtered_count_data.txt -m Human -G 'MB' -t E -f 'G'
fi
