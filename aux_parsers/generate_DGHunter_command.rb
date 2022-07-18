#!/usr/bin/env ruby

require 'optparse'


#####################################################
## METHODS

def parse_env_variables(variables, mode)
	variables.each do |variable, attributes|
		attributes << ENV[variable]
	end
	return variables
end

def parse_string_command(cmd, mode)
	options = {} 
	if mode == 'degenes_Hunter'
		optparse = OptionParser.new do |option|
			
			option.on("-C string", "--Control_columns string") do |item|
				options["Control_columns"] = ["--Control_columns", item]
			end

			option.on("--count_var_quantile integer") do |item|
                options["count_var_quantile"] = ["--count_var_quantile", item]
            end

			option.on("-T string", "--Treatment_columns string") do |item|
				options["Treatment_columns"] = ["--Treatment_columns", item]
			end
			
			option.on("-r READS", "--reads READS") do |item|
				options["min_reads"] =["-r", item]
			end
			
			option.on("-l MINLIBRARIES", "--minlibraries") do |item|
				options["min_libraries"] =["-l", item]
			end

			option.on("-F string", "--filter_type string") do |item|
				options["filter_type"] = ["--filter_type", item]
			end

			option.on("-p pval", "--p_val_cutoff pval") do |item|
				options["de_pvalue"] = ["-p", item]
			end

			option.on("-f lfc", "--lfc lfc") do |item|
				options['de_logfc'] = ['-f', item]
			end

			option.on("-m MODULES", "--modules MODULES") do |item|
				options["de_packages"] = ["-m", item]
			end

			option.on("-c MINPACK_COMMON", "--minpack_common MINPACK_COMMON") do |item|
				options["de_min_pack"] = ["-c", item]
			end

			option.on("-t TARGET", "--target_file TARGET") do |item|
				options["target_path"] = ["-t", item]
			end

			option.on("-e external_file", "--external_DEA_file external_file") do |item|
				options["external_DEA_file"] = ["--external_DEA_file", item]
			end

			option.on("-v VARIABLES", "--model_variables VARIABLES") do |item|
				options["de_add_factors"] = ["-v", item]
			end

			option.on("-S FACTORS", "--string_factors FACTORS") do |item|
				options["string_features"] = ["-S", item]
			end

			option.on("-N FACTORS", "--numeric_factors FACTORS") do |item|
				options["numeric_features"] = ["-N", item]
			end

			option.on("-b WGCNA_MEMORY", "--WGCNA_memory WGCNA_MEMORY") do |item|
                options["WGCNA_memory"] = ["--WGCNA_memory", item]
            end

            option.on("--WGCNA_norm_method string") do |item|
				options["WGCNA_norm_method"] = ["--WGCNA_norm_method", item]
			end
			
			option.on("--WGCNA_deepsplit integer") do |item|
                options["WGCNA_deepsplit"] = ["--WGCNA_deepsplit", item]
            end

			option.on("--WGCNA_min_genes_cluster integer") do |item|
				options["WGCNA_min_genes_cluster"] = ["--WGCNA_min_genes_cluster", item]
			end

			option.on("--WGCNA_detectcutHeight integer") do |item|
				options["WGCNA_detectcutHeight"] = ["--WGCNA_detectcutHeight", item]  
			end
			
			option.on("--WGCNA_mergecutHeight integer") do |item|
				options["WGCNA_mergecutHeight"] = ["--WGCNA_mergecutHeight", item]  
			end

			option.on("-w WGCNA_ALL", "--WGCNA_all") do |item|
				options["WGCNA_ALL"] = ["-w", "BOOLEAN"]
			end	

            option.on("--WGCNA_blockwiseNetworkType string") do |item|
				options["WGCNA_blockwiseNetworkType"] = ["--WGCNA_blockwiseNetworkType", item]
			end

			option.on("--WGCNA_blockwiseTOMType string") do |item|
				options["WGCNA_blockwiseTOMType"] = ["--WGCNA_blockwiseTOMType", item]
			end

  			option.on("--WGCNA_minCoreKME integer") do |item|
                options["WGCNA_detectcutHeight"] = ["--WGCNA_detectcutHeight", item]
            end
	
  			option.on("--WGCNA_minCoreKMESize integer") do |item|
                options["WGCNA_detectcutHeight"] = ["--WGCNA_detectcutHeight", item]
            end
  			
			option.on("--WGCNA_minKMEtoStay integer") do |item|
                options["WGCNA_detectcutHeight"] = ["--WGCNA_detectcutHeight", item]
            end

			option.on("--multifactorial string") do |item|
				options["multifactorial"] = ["--multifactorial", item]
			end
		end

	elsif mode == 'functional_Hunter'
		optparse = OptionParser.new do |option|
			option.on("-m MODEL_ORGANISM", "--model_organism") do |item|
				options["fun_organism"] = ["-m", item]
			end

			option.on("-a ANNOT_FILE", "--annot_file") do |item|
				options["annotation_list"] = ["-a", item]
			end

			option.on("-t BIOMART_FILTER", "--input_gene_id") do |item|
				options["input_gene_id"] = ["-t", item]
			end

			option.on("-f FUNCTIONAL_ANALYSIS", "--func_annot_db") do |item|
				options["func_annot_db"] = ["-f", item]
			end

			option.on("-G GO_GRAPHS", "--GO_subont") do |item|
				options["GO_subont"] = ["-G", item]
			end

			option.on("-C CUSTOM", "--custom") do |item|
				options["custom_nomenclature"] = ["-C", item]
			end
			
			option.on("-A ANALYSIS", "--analysis") do |item|
				options["fun_an_performance"] = ["-A", item]
			end

		    option.on("-r REMOTE", "--remote") do |item|
				options["fun_remote_mode"] = ["-r", item]
			end

			option.on("-P THRESHOLD", "--pthreshold") do |item|
				options["pthreshold"] = ["-P", item]
			end

			option.on("-Q THRESHOLD", "--qthreshold") do |item|
				options["qthreshold"] = ["-Q", item]
			end

			option.on("-c cores", "--cores") do |item|
				options["cores"] = ["-c", item]
			end

			option.on("-s TASK_SIZE", "--task_size") do |item|
				options["task_size"] = ["-s", item]
			end

		end
	end
	optparse.parse!(cmd.split)
	return options
end

def load_aux_options(aux_options_file)
	aux_options = File.open(aux_options_file)
	return_aux_options
end

def generate_command(variables)
	command = ''
	variables.each do |variable, attributes|
		flag, value = attributes
		next if (value.nil? || value.empty?) && attributes.length > 1
		option = "#{flag} #{value} "
		option = "#{flag} " if value == "BOOLEAN"
		command << option
	end
	return command
end
########################
## OPTIONS
########################

options = {}

OptionParser.new do |option|
	option.on("-m MODE", "--mode MODE", "Set DEGenesHunter mode. Available options are 'degenes_Hunter' and 'functional_Hunter'.") do |mode|
		options[:mode] = mode
	end
end.parse!
########################
## MADE
########################

de_variables = {
	"de_pvalue" => ["-p"],
	"de_packages" => ["-m"],
	"de_min_pack" => ["-c"],
	"de_logfc" => ["-f"],
	"WGCNA_mergecutHeight" => ["--WGCNA_mergecutHeight"],
	"WGCNA_min_genes_cluster"=>["--WGCNA_min_genes_cluster"],
	"WGCNA_detectcutHeight" => ["--WGCNA_detectcutHeight"], 
	"WGCNA_deepsplit" => ["--WGCNA_deepsplit"], 
	"min_reads" => ["-r"],
	"filter_type" => ["--filter_type"],
	"min_libraries" => ["-l"],
	"string_features" => ["-S"],
	"numeric_features" => ["-N"],
	"target_path" => ["-t"]
}

fun_variables = {
	"fun_remote_mode" => ["-r"],
	"custom_nomenclature" => ["-C"],
	"fun_an_type" => ["-f"],
	"GO_modules" => ["-G"],
	"fun_an_performance" => ["-A"],
	"fun_pvalue" => ["-P"],
	"fun_organism" => ["-m"],
	"annotation_list" => ["-a"]
}

if options[:mode] == 'degenes_Hunter'
	variables = parse_env_variables(de_variables, options[:mode])
elsif options[:mode] == 'functional_Hunter'
	variables = parse_env_variables(fun_variables, options[:mode])
end

addition_options = ENV['ADD_OPTIONS']
if !addition_options.nil?
	addition_opts = parse_string_command(addition_options, options[:mode]) 
	variables = variables.merge(addition_opts)
end

if options[:mode] == 'degenes_Hunter'
	aux_path = variables["target_path"][1].gsub(".txt", ".aux")
	if File.exists?(aux_path)
		aux_opts = parse_string_command(File.open(aux_path).read.chomp, options[:mode])
		variables = variables.merge(aux_opts)
	end
end

command = generate_command(variables)
print command
