#!/usr/bin/env ruby
#This script takes the miRDeep2 raw output and generates known miRNA coordinated file


def get_last_mirdeep_folder(result_folders)
	dates = result_folders.map do |folder| 
		folder.gsub(/.*run_/,"").gsub("_t_", "").gsub("_", "").to_i
	end
	last_folder = result_folders[dates.rindex(dates.max)]
	return last_folder
end

def load_mature_precursors_from_signature(arf, organism)
	mature_miRNAs = []
	File.open(arf).each do |entry|
		entry = entry.chomp.split("\t")
		mature_miRNAs << [entry[5], entry[0]] if entry[0].include?(organism)
	end
	return mature_miRNAs
end

def load_precursor_coords(precursors_file)
	precursors_coords = {}
	File.open(precursors_file).each do |line|
		line = line.chomp.gsub(/^>/,"").split("\t")
		identif = line[0].dup
		line[0] = line[0].split("_").first

		precursors_coords[identif] = line 		
	end
	return precursors_coords
end

def extract_mature_precursors_coords(mature_precursors, coords, o_path)
	File.open("#{o_path}/known_miRNA.coord2", 'w') do |o_file| 
		mature_precursors.each do |precursor, mature_id|

			chr, strand, start_p, end_p = coords[precursor]
			o_file.puts [chr, start_p, end_p, mature_id, "#{chr}:#{start_p}:#{end_p}"].join("\t")
		end
	end
end

executions = Dir.glob("#{ARGV[0]}/mirdeep_runs/*")

run_folder = get_last_mirdeep_folder(executions)

signature = "#{run_folder}/tmp/signature.arf"
precursors_coords = "#{run_folder}/tmp/precursors.coords" 

mature_miRNAs_precursors = load_mature_precursors_from_signature(signature, ARGV[1])
all_precursors_coords = load_precursor_coords(precursors_coords)
extract_mature_precursors_coords(mature_miRNAs_precursors, all_precursors_coords, ARGV[0])