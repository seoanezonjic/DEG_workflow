#!/usr/bin/env ruby
require 'optparse'


def get_adapters_reads(files_index)
	reads_after_adapters = []
	["adapters_5_trimming_stats_cmd.txt", "adapters_3_trimming_stats_cmd.txt"].map do |file|
		if files_index[file].nil?
			reads_after_adapters << nil 
			next
		end
		files_index[file].each do |line|
			reads_after_adapters << line[1].split("reads")[0].to_i if line[0] == "Result:"
		end
	end
	if reads_after_adapters.compact.min.nil?
		reads_after_adapters = "NA" 
	else
		reads_after_adapters = reads_after_adapters.compact.min
	end
	return reads_after_adapters
end


def get_contaminant_reads(files_index)
	return files_index["contaminants_contaminants_filtering_stats.txt"].to_i if files_index["contaminants_contaminants_filtering_stats.txt"].nil? 
	all_contaminants = 0
	files_index["contaminants_contaminants_filtering_stats.txt"].each do |contaminant_data|
		next if contaminant_data[0] == "name"
	
		all_contaminants += contaminant_data[7].to_i
	end
	return all_contaminants
end

def print_metrics(stbb_metrics)
	stbb_metrics.each do |metric_name, metric|
		puts [metric_name, metric].join("\t")
	end
end


options = {}

optparse = OptionParser.new do |opts|
        options[:input] = nil
        opts.on( '-i PATH', '--input_file PATH', 'SeqtrimBB plugin stats directory. This argument must be indicated between quotes' ) do |string|
            options[:input] = Dir.glob(string)
        end


       # Set a banner, displayed at the top of the help screen.
        opts.banner = "Usage: #{__FILE__} options \n\n"

        # This displays the help screen
        opts.on( '-h', '--help', 'Display this screen' ) do
                puts opts
                exit
        end


end
optparse.parse!



files_index = {}
Dir.glob(options[:input]).each do |file_path|
	filename = File.basename(file_path)
	files_index[filename] = File.readlines(file_path).map {|line| line = line.gsub("#","").gsub(/ +/, "").chomp.split("\t")}
end

stbb_metrics = {}
stbb_metrics["adapter_filter_passed"] = get_adapters_reads(files_index)
stbb_metrics["contaminants_reads"] = get_contaminant_reads(files_index)
print_metrics(stbb_metrics)