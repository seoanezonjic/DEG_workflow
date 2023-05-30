#!/usr/bin/env ruby



########### METHODS
def parse_mirbase(mirBase_translation)
	parsed_translation = {}
	mirBase_translation.each do |mirb_id, mature_ids|
		mature_ids = mature_ids.split(";")
		mature_ids.each do |mat_id|
			next if mat_id.empty?
			
			if parsed_translation[mat_id].nil?
				parsed_translation[mat_id] = mirb_id
			else
				counter = 1
				mat_id_transformed = "#{mat_id}_transformed_#{counter}" #this check for repeated mature ids
				while !parsed_translation[mat_id_transformed].nil?
					counter =+ 1
					mat_id_transformed = "#{mat_id}_transformed_#{counter}"
				end
			end
		end
	end
	return parsed_translation
end

def translate_ids(mature_to_coord, parsed_mirBase)
	mirb_id_to_coor = []
	mature_to_coord.each do |chr, start_c, end_c, mature_id, coord_n, strand|
		if parsed_mirBase[mature_id].nil?
			p "#{mature_id} has not been translated"
		else
			mirb_id_to_coor << [chr, start_c, end_c, parsed_mirBase[mature_id], coord_n, strand]
		end
	end
	return mirb_id_to_coor
end
 

def write_output(translated_ids, output_file)
	File.open(output_file, 'w') do |output|
		translated_ids.each do |line|
		output.puts line.join("\t")
		end
	end
end


########## MAIN

miRNA_to_coor_file = ARGV[0]
miRBase_tr = ARGV[1]
output_file = ARGV[2]

miRBase_translation = File.readlines(miRBase_tr).map {|line| line = line.chomp.split("\t")}

miRNA_mature_to_coor = File.readlines(miRNA_to_coor_file).map {|line| line = line.chomp.split("\t")}

parsed_mirBase = parse_mirbase(miRBase_translation)


translated_ids = translate_ids(miRNA_mature_to_coor, parsed_mirBase)

write_output(translated_ids, output_file)
