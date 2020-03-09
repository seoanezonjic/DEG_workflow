#!/usr/bin/env ruby


require 'optparse'
#############################
## METHODS
#############################


def load_all_tables(all_files)
	all_tables = []
	all_files.each do |filename|
		all_tables << load_table(filename)
	end
	return all_tables
end

def load_table(filename)
	count_table = []
	File.open(filename).each do |line|
		line.chomp!
		next if line =~ /^N_/
		line = line.split("\t")
		line[0] = line[0].split(".").first
		count_table << line
	end
	return count_table
end

def merge_all_tables(all_tables, tags)
	formatted_tables = {
		"header" => nil
	}
	all_tables.each_with_index do |count_table, table_index|
		count_table.each_with_index do |line, line_index|
			gene_name, value = line
			gene_name,value = ["header",tags[table_index]] if line_index == 0
			if formatted_tables[gene_name].nil?	
					formatted_tables[gene_name] = [value]
			else
					formatted_tables[gene_name] << value
			end
		end
	end
	return formatted_tables
end

def output_tables(merged_table)
	merged_table.each do |name, line|
		name = "" if name == "header"
		puts "#{name}\t#{line.join("\t")}"
	end
end

#############################
## OPTIONS
#############################

options = {}

OptionParser.new do |opt|
	options[:input] = []
	opt.on("-i FILES", "--input FILES", "A comma separated list selected_counts paths") do |files|
		options[:input] = files.split(",")
	end

	options[:tags] = []
	opt.on("-t TAGS", "--tags TAGS", "A comma separated list of selected_counts tags") do |tags|
		options[:tags] = tags.split(",")
	end
end.parse!

#############################
## MAIN
#############################
all_counts_tables = load_all_tables(options[:input])
merged_tables = merge_all_tables(all_counts_tables, options[:tags])
output_tables(merged_tables)


