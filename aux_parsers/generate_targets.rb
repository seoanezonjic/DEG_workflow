#!/usr/bin/env ruby


######################################################
######## INIT
######################################################

require "optparse" 
CTRL = 0
TREAT = 1

######################################################
######## METHODS
######################################################

def load_list(input)
	list = File.readlines(input).map {|line| line.chomp!}
	return list
end



def load_table(input_file, blacklist = nil, whitelist = nil, filter = nil)
	header = nil 
	table = {}
	blacklist = [] if blacklist.nil?
	File.open(input_file).each do |line|
		line = line.chomp.split("\t")
		if header.nil?
			line.shift
			header = line
			next
		end
		next if blacklist.include?(line[0])
		if !whitelist.nil?
			next unless whitelist.include?(line[0])
		end 
		unless filter.nil?
			next unless filter[1].include?(line[header.index(filter[0]) + 1]) 
		end
		table[line[0].to_sym] = {}
		header.each_with_index do |feature_name, feat_index|
			table[line[0].to_sym][feature_name.to_sym] = line[feat_index + 1]
		end
	end
	return table
end


def parse_targets(targets_string)
	parsed_targets = {}
	feature_names = []
	targets_string.split(";").each do |target|
		target = target.split(">")
		target_name = target.shift
		features = target.shift.split(":")
		feature_name = features.shift
		feature_names << feature_name
		features = features.shift.split(",")
		features = features.map{|feature| feature = feature.split("/")}
		parsed_targets[target_name.to_sym] = {feature_name.to_sym => features}
	end

	return parsed_targets, feature_names
end


def build_targets(table, targets)
	new_targets = {}
	targets.each do |target_name, all_features|
		new_target = {"Ctrl" => [], "Treat" => []}
		all_features.each do |feature_name, features|
			new_target["Ctrl"] = find_features(feature_name, features[CTRL], table)
			new_target["Treat"] = find_features(feature_name, features[TREAT], table)
		end
		new_targets[target_name] = new_target
	end	
	return new_targets

end

def find_features(feature_name, features, table)
	samples_list = []
	table.each do |sample, all_features|
		if features.include?(all_features[feature_name.to_sym])  
			samples_list << sample 
		end
	end
	return samples_list
end

def save_targets(targets, experiment_design, additional_columns)
	targets.each do |target_name, treats|
		File.open(target_name.to_s + "_target.txt",'w') do |out_file|
			header = "sample\ttreat"
			header = "sample\ttreat\t#{additional_columns.join("\t")}" if additional_columns.length > 0

			out_file.puts header

			treats.each do |treat, samples|
				samples.each do |sample|
					if additional_columns.length > 0
						features_by_sample = []
						additional_columns.each do |additional_feature|
							features_by_sample << experiment_design[sample][additional_feature]
						end
						out_file.puts "#{sample}\t#{treat}\t#{features_by_sample.join("\t")}" if !sample.nil?
					else
						out_file.puts "#{sample}\t#{treat}" if !sample.nil?
					end

				end
			end
		end
	end
end

def parse_filter(string)
	feature_name, features = string.split("=")
	filter = [feature_name, features.split(",")]
	return filter
end
######################################################
######## OPTONS
######################################################
options = {}

OptionParser.new do |opts|

	options[:table] = nil
	opts.on("-e FILE", "--exp_file FILE", "Tabulated file which describes current experiment") do |file|
		options[:table] = file
	end

	options[:filter] = nil
	opts.on("-f STRING", "--filter STRING", "Set filter as string 'FEATURE_NAME=feature'") do |string|
		options[:filter] = string
	end

	options[:targets] = nil
	opts.on("-t STRING", "--targets STRING", "String which describes targets. EXAMPLE: 'TARGET_A>COLUMN_A:FEAT_CTL1,FEAT_TRT1;TARGET_B>COLUMN_B:FEAT_CTL1/FEAT_CTL2,FEAT_TRT1/FEAT_TRT2'") do |string|
		options[:targets] = string
	end

	options[:additional_features] = []
	opts.on("--additional_features STRING", "String with extra factors separated by commas to be added to targets.") do |string|
		options[:additional_features] = string.split(",")
	end

	options[:blacklist] = nil
	opts.on("-b FILE/STRING", "--blacklist FILE/STRING", "List with samples name to exclude from targets. File or comma separated string") do |file|
		options[:blacklist] = file
	end

	options[:whitelist] = nil
	opts.on("-w FILE/STRING", "--whitelist FILE/STRING", "List with samples name to acept from targets. File or comma separated string") do |file|
		options[:whitelist] = file
	end

end.parse!

######################################################
######## MAIN
######################################################
blacklist = load_list(options[:blacklist]) if !options[:blacklist].nil?
whitelist = load_list(options[:whitelist]) if !options[:whitelist].nil?

filter = parse_filter(options[:filter]) if !options[:filter].nil?
experiment_design = load_table(options[:table], blacklist, whitelist, filter)
targets, features = parse_targets(options[:targets])
targets = build_targets(experiment_design, targets) # meter aqui lo de guardar columnas y quitar la columna replicate
save_targets(targets, experiment_design, options[:additional_features].map!{|feature| feature.to_sym})