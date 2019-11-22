#!/usr/bin/env ruby

require 'optparse'


#####################################################
## METHODS

def parse_env_variables(variables)
	variables.each do |variable, attributes|
		attributes << ENV[variable]
	end
	return variables
end

def generate_command(variables)
	command = ''
	variables.each do |variable, attributes|
		flag, value = attributes
		next if (value.nil? || value.empty?) && attributes.length > 1
		if variable.include?("additional_options")
			command += "#{attributes.join("")} "
		else
			command += "#{flag} #{value} "
		end
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
	"de_logfc" => ["-f"],
	"de_pvalue" => ["-p"],
	"de_packages" => ["-m"],
	"de_min_pack" => ["-c"],
	"de_additional_options" => []
}

fun_variables = {
	"fun_remote_mode" => ["-r"],
	"custom_nomenclature" => ["-C"],
	"fun_an_type" => ["-f"],
	"GO_modules" => ["-G"],
	"fun_an_performance" => ["-A"],
	"fun_pvalue" => ["-T"],
	"fun_organism" => ["-m"],
	"fun_additional_options" => []
}

if options[:mode] == 'degenes_Hunter'
	variables = parse_env_variables(de_variables)
elsif options[:mode] == 'functional_Hunter'
	variables = parse_env_variables(fun_variables)
end

command = generate_command(variables)
print command