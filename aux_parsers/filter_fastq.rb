#!/usr/bin/env ruby

require 'optparse'

NAME = 0
SEQUENCE = 1
################################### METHODS
def filter_fastq(input_file, size_filter)
	entry = []
	attributes_parsed = 0
	File.open(input_file).each do |line| 
        	line.chomp!
		attributes_parsed += 1
        	if attributes_parsed < 4
        	        entry << line
        	else
			entry << line
        	        puts entry.join("\n") if entry[SEQUENCE].length >= size_filter
        	        entry = []
			attributes_parsed = 0
        	end
	end
end
############################### OPT

options = {}

OptionParser.new do |opts|

	opts.on("-i FILE", "--input FILE", "Set input file") do |file|
		options[:input] = file
	end

	opts.on("-m INT", "--min_length INT", "Set minimun length size") do |int|
		options[:min_length] = int.to_i
	end
end.parse!
############################# MAIN
filter_fastq(options[:input], options[:min_length])

	

