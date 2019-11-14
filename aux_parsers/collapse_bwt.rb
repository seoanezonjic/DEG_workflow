#!/usr/bin/env ruby

READ_NAME = 0
STRAND = 1
CHR = 2
COORD = 3
SEQ = 4

##########################################################
######	METHODS
##########################################################i
def load_bwt(input_file)
	bwt = File.readlines(input_file).map {|line| line = line.chomp.split("\t")}
	return bwt
end

def sort_bwt(raw_bwt)
	raw_bwt.sort_by! {|mapping| [mapping[CHR], mapping[COORD], mapping[SEQ]]}
	return raw_bwt
end

def index_bwt(sorted_bwt)
	indexed_bwt = {}
	sorted_bwt.each do |mapping|
		id = "#{mapping[CHR]}:#{mapping[STRAND]}:#{mapping[COORD]}:#{mapping[SEQ]}".to_sym
		if indexed_bwt[id].nil?
			indexed_bwt[id] = [mapping,1]
		else
			indexed_bwt[id][1] += 1
		end
	end
	return indexed_bwt
end

def build_collapsed_bwt(indexed_bwt)
	collapsed_bwt = []
	stacked_mappings = 0
	indexed_bwt.each do |id, attributes|
		bwt_entry,collapsed_mappings = attributes 
		stacked_mappings += collapsed_mappings
		collapsed_bwt << change_read_name(stacked_mappings, collapsed_mappings, bwt_entry)
	end
	return collapsed_bwt
end

def change_read_name(stacked_mappings, collapsed_mappings, bwt_entry)
	bwt_entry[READ_NAME] = "seq_#{stacked_mappings}_x#{collapsed_mappings}"
	return bwt_entry
end

def print_output(bwt)
	bwt.each do |bwt_entry|
		puts bwt_entry.join("\t")
	end
end

##########################################################
######  MAIN
##########################################################
input_bwt = ARGV[0]
abort("No input file set\n\n\tUSAGE:\tcollapse_bwt.rb uncollapsed.bwt > collapsed.bwt") if (File.size?(input_bwt)).nil?

bwt = load_bwt(input_bwt)
bwt = sort_bwt(bwt)
indexed_bwt = index_bwt(bwt)
collapsed_bwt = build_collapsed_bwt(indexed_bwt)
print_output(collapsed_bwt)
