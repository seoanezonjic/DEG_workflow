#!/usr/bin/env ruby

KNOWN_MIRNA_NAME = 9
POSITION = 16


###################################################################
############### =>	METHODS	
###################################################################

def load_file(input_file)  
	raw_file = File.readlines(input_file).map{ |line| line = line.chomp.split("\t") }.reject{ |line| line.empty? }
	return raw_file
end

def parse_table(raw_file, start_string, end_string)
	table_start = raw_file.index([start_string]) + 1 
	table_end = raw_file.index([end_string]) - 1
	table = raw_file[(table_start)..(table_end)]
	return table
end

def write_table(table, out_file, column_name)
	File.open(out_file, 'w') do |output_file|
		
		table.each_with_index do |line, i|
			novel_to_keep = (line[8] == "yes" && line[3] == "-")

			if i == 0
				line[0] = "miRNA_name"
			else
				next if out_file == "novel_miRDeep_miRNAs" && !novel_to_keep 
				line[0] = line[column_name]
			end
			output_file.puts line.join("\t").gsub(/ +/,'_')
		end
	end
end

###################################################################
############### => MAIN	
###################################################################

raw_file = load_file(ARGV[0])
novel_mirnas = parse_table(raw_file, "novel miRNAs predicted by miRDeep2", "mature miRBase miRNAs detected by miRDeep2")
known_mirnas = parse_table(raw_file, "mature miRBase miRNAs detected by miRDeep2", "#miRBase miRNAs not detected by miRDeep2")

write_table(novel_mirnas, "novel_miRDeep_miRNAs", POSITION)
write_table(known_mirnas, "known_miRDeep_miRNAs", KNOWN_MIRNA_NAME)