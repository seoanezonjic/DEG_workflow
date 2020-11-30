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

			option.on("-v VARIABLES", "--model_variables VARIABLES") do |item|
				options["de_add_factors"] = ["-v", item]
			end

			option.on("-S FACTORS", "--string_factors FACTORS") do |item|
				options["string_features"] = ["-S", item]
			end

			option.on("-N FACTORS", "--numeric_factors FACTORS") do |item|
				options["numeric_features"] = ["-N", item]
			end

			option.on("--WGCNA_min_genes_cluster integer") do |item|
				options["WGCNA_min_genes_cluster"] = ["--WGCNA_min_genes_cluster", item]
			end

			option.on("--WGCNA_detectcutHeight integer") do |item|
				options["WGCNA_detectcutHeight"] = ["--WGCNA_detectcutHeight", item]  
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
			
			option.on("-w WGCNA_ALL", "--WGCNA_all") do |item|
				options["WGCNA_ALL"] = ["-w", "BOOLEAN"]
			end			

			option.on("-r READS", "--reads READS") do |item|
				options["min_reads"] =["-r", item]
			end

			option.on("-l MINLIBRARIES", "--minlibraries") do |item|
				options["min_libraries"] =["-l", item]
			end

			#option.on("--debug") do
            #    options["debug"] = ["--debug", "BOOLEAN"]
            #end
            
			################### Options to complete
			#	-M CUSTOM_MODEL, --custom_model
			#	-b WGCNA_MEMORY, --WGCNA_memory
			#	--WGCNA_deepsplit
			#	-l MINLIBRARIES, --minlibraries
			# --WGCNA_blockwiseNetworkType
			# --WGCNA_blockwiseTOMType
			
		end

	elsif mode == 'functional_Hunter'
		optparse = OptionParser.new do |option|
			option.on("-m MODEL_ORGANISM", "--model_organism") do |item|
				options["fun_organism"] = ["-m", item]
			end

			option.on("-a ANNOT_FILE", "--annot_file") do |item|
				options["annotation_list"] = ["-a", item]
			end

			option.on("-t BIOMART_FILTER", "--biomaRt_filter") do |item|
				options["biomart_filter"] = ["-t", item]
			end

			option.on("-f FUNCTIONAL_ANALYSIS", "--functional_analysis") do |item|
				options["fun_an_type"] = ["-f", item]
			end

			option.on("-G GO_GRAPHS", "--GO_graphs") do |item|
				options["GO_modules"] = ["-G", item]
			end

			option.on("-A ANALYSIS", "--analysis") do |item|
				options["fun_an_performance"] = ["-A", item]
			end

			#option.on("-K KEGG_ORGANISM", "--Kegg_organism") do |item|
			#end

			option.on("-r REMOTE", "--remote") do |item|
				options["fun_remote_mode"] = ["-r", item]
			end

			option.on("-C CUSTOM", "--custom") do |item|
				options["custom_nomenclature"] = ["-C", item]
			end

			option.on("-P THRESHOLD", "--threshold") do |item|
				options["fun_pvalue"] = ["-P", item]
			end

#			option.on("-Q QTHRESHOLD", "--qthreshold") do |item|

#			end

			#option.on("--debug") do 
			#	options["debug"] = ["--debug", "BOOLEAN"]
			#end
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
	"min_reads" => ["-r"],
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
