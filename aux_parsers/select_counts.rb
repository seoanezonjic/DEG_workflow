#! /usr/bin/env ruby

require 'optparse'

#################################################################################################
## METHODS
#################################################################################################
def load_file(path)
	counts = []
	select_col = nil
	File.open(path).each do |line|
		fields = line.chomp.split("\t")
		if fields[0] == 'N_noFeature'
			# https://groups.google.com/d/msg/rna-star/gZRJx3ElRNo/cDInEONVCAAJ #STAR author comment
			noFcounts = fields[2..3].map{|i| i.to_i }
			min_count = noFcounts.min
			select_col = noFcounts.index(min_count) + 2
		end
		counts << fields
	end
	return counts, select_col
end

#################################################################################################
## INPUT PARSING
#################################################################################################
options = {}

optparse = OptionParser.new do |opts|
        options[:input] = nil
        opts.on( '-i', '--input_file PATH', 'File to process' ) do |string|
            options[:input] = string
        end

        options[:stranded] = 'no'
        opts.on( '-s', '--stranded STRING', 'Strand attribute to select column counts' ) do |string|
            options[:stranded] = string
        end


       # Set a banner, displayed at the top of the help screen.
        opts.banner = "Usage: #{__FILE__} options \n\n"

        # This displays the help screen
        opts.on( '-h', '--help', 'Display this screen' ) do
                puts opts
                exit
        end

end # End opts

# parse options and remove from ARGV
optparse.parse!

##########################################################################################
## MAIN
##########################################################################################

counts, select_col = load_file(options[:input])
select_col = 2 if options[:stranded] == 'no'

counts.each do |record|
	puts "#{record[0]}\t#{record[select_col]}"
end

