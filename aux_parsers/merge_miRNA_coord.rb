#!/usr/bin/env ruby
require 'optparse'

########################################################
### METHODS
########################################################

def load_files(all_files) #takes a files array and return an array
	all_info = []
	all_files.each do |file_name|
		File.readlines(file_name).each do |line| 
			line = line.chomp.split("\t")
			line[1] = line[1].to_i
			line[2] = line[2].to_i
			all_info << line
		end
	end

	return all_info
end


def format_miRNA_coords(all_miRNAs, column_idx) #take a bidimensional array and return a hash of arrays with [column] as keys and an array with all sorted antries of [column] as value. Coordinates are sorted. 
	formatted_miRNAs = {}
	all_miRNAs.each do |miRNA|
		coords = [miRNA[1], miRNA[2]]
		miRNA[1] = coords.min
		miRNA[2] = coords.max

		if ! formatted_miRNAs[miRNA[column_idx]].nil? 
			formatted_miRNAs[miRNA[column_idx]] << miRNA 
		else
			formatted_miRNAs[miRNA[column_idx]] = [miRNA]
		end

	end

	formatted_miRNAs.each do |group, entries|
		formatted_miRNAs[group] = entries.sort_by{|chr, start_c, end_c, name| start_c}
	end

	return formatted_miRNAs
end



def merge_coords(formatted_miRNAs, distance) #takes a hash of arrays and merge array elements that overlap 
	merged_miRNAs = {}
	formatted_miRNAs.each do |group, entries|
		merged_miRNAs[group] = []
		counter = 0
		ref_entry = entries[counter]
		unless counter >= entries.length - 1
			counter += 1
			actual_entry = entries[counter]
			if do_overlap(ref_entry[1..2], actual_entry[1..2], distance)
				ref_entry[2] = [ref_entry[2], actual_entry[2]].max
			else
				merged_miRNAs[group] << ref_entry
				ref_entry = actual_entry
			end

		end
		merged_miRNAs[group] << ref_entry
	end
	return merged_miRNAs
end


def do_overlap(coord_A, coord_B, distance)
    overlap = coord_B.min.between?(coord_A.min, coord_A.max + distance) ||
            coord_A.min.between?(coord_B.min, coord_B.max + distance)
    return(overlap)
end


########################################################
### OPT
########################################################
options = {}

OptionParser.new do  |opts|
	opts.on("-k file(s)", "--known_mirnas file(s)", "Set known miRNAs coordinates files. You must write path between quotes") do |files|
		options[:known_mirnas] = Dir.glob(files)
	end

	opts.on("-n file(s)", "--novel_mirnas file(s)", "Set novel miRNAs coordinates files. You must write path between quotes") do |files|
		options[:novel_mirnas] = Dir.glob(files)
	end

	options[:distance] = 0
	opts.on("-d distance", "--max_distance distance", "Maximun distance in chain to consider that the sequences are the same. Default = #{options[:distance]}") do |number|
		options[:distance] = number.to_i
	end

	options[:output_path] = "./"
	opts.on("-o path", "--output path", "Define path to write output files. Default = #{options[:output_path]}") do |path|
		options[:output_path] = File.expand_path(path)
	end

    opts.on("-h", "--help", "Displays helps") do
            puts opts
            abort("Coordinates files must be a tabulated file with at least 4 columns:\n\nchromosome_name\tstart_coordinate\tend_coordinate\tsequence_name\n\nAdditional columns will not be parsed.")
    end

end.parse!

########################################################
### MAIN
########################################################


if !options[:known_mirnas].nil?

	known_mirnas = load_files(options[:known_mirnas])
	known_mirnas = format_miRNA_coords(known_mirnas, 3)
	known_mirnas = merge_coords(known_mirnas, options[:distance])


	File.open("#{options[:output_path]}/known_miRNA.coord", 'w') do |outfile|
		known_mirnas.each do |miRNA, findings|
			counter = 0
			findings.each do |finding|
				finding[3] = "#{finding[3]}_like_#{counter}" if counter > 0 
				outfile.puts finding.join("\t")
				counter += 1
			end
		end
	end
end



if !options[:novel_mirnas].nil?

	novel_mirnas = load_files(options[:novel_mirnas])
	novel_mirnas = format_miRNA_coords(novel_mirnas, 0)
	novel_mirnas = merge_coords(novel_mirnas, options[:distance])

	File.open("#{options[:output_path]}/novel_miRNA.coord", 'w') do |outfile|
		novel_mirnas.each do |chromosome, findings|
			findings.each do |finding|
				finding[3] = finding[0..2].join(":")
				outfile.puts finding.join("\t")
			end
		end
	end
end

