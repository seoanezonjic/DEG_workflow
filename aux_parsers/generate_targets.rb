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

def load_blacklist(input)
	blacklist = File.readlines(input).map {|line| line.chomp!}
	return blacklist
end

def load_table(input_file,blacklist = nil, filter = nil)
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
		next if blacklist.include?(line[0]) if !blacklist.nil?
		next if  !filter[1].include?(line[header.index(filter[0]) + 1]) if !filter.nil?
		table = index_features(header, line, table)
	end
	return table
end

def index_features(features,values, indexed_features = {}) 
	sample_name = values.shift
	features.each_with_index do |feature, index|
		feature = feature.to_sym
		indexed_features[feature] = {} if indexed_features[feature].nil?
		indexed_features[feature][values[index].to_sym] = [] if indexed_features[feature][values[index].to_sym].nil?
		indexed_features[feature][values[index].to_sym] << sample_name
	end
	return indexed_features
end

def parse_targets(targets_string)
	parsed_targets = {}
	targets_string.split(";").each do |target|
		target = target.split(">")
		target_name = target.shift
		features = target.shift.split(":")
		feature_name = features.shift
		features = features.shift.split(",")
		features = features.map{|feature| feature = feature.split("/")}
		parsed_targets[target_name.to_sym] = {feature_name.to_sym => features}
	end
	return parsed_targets
end

def build_targets(table, targets)
	new_targets = {}
	targets.each do |target_name, all_feature|
		new_target = {"Ctrl" => [], "Treat" => []}
		all_feature.each do |feature_name, features|
			new_target["Ctrl"] = find_features(feature_name,features[CTRL], table)
			new_target["Treat"] = find_features(feature_name,features[TREAT], table)
		end
		new_targets[target_name] = new_target
	end	
	return new_targets

end

def find_features(feature_name, features, table)
	samples_list = []
	features.each do |feature|
		feature = feature.to_sym
		(samples_list << table[feature_name][feature]).flatten!
	end
	return samples_list
end

def save_targets(targets)
	targets.each do |target_name,treats|
		File.open(target_name.to_s + "_target.txt",'w') do |out_file|
			out_file.puts "sample\treplicate\ttreat"
			treats.each do |treat, samples|
				counter = 1
				samples.each do |sample|
					out_file.puts "#{sample}\t#{counter}\t#{treat}" if !sample.nil?
					counter +=1 
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

	options[:blacklist] = nil
	opts.on("-b FILE/STRING", "--blacklist FILE/STRING", "List with samples name to exclude from targets. File or comma separated string") do |file|
		options[:blacklist] = file
	end

end.parse!

######################################################
######## MAIN
######################################################
blacklist = load_blacklist(options[:blacklist]) if !options[:blacklist].nil?
filter = parse_filter(options[:filter]) if !options[:filter].nil?
experiment_design = load_table(options[:table], blacklist, filter)
targets = parse_targets(options[:targets])
targets = build_targets(experiment_design, targets)
save_targets(targets)