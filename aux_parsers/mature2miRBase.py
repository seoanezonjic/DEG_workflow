#!/usr/bin/env python

import sys

######################################
########### METHODS
######################################

def parse_mirbase(mirbase_translation):
    parsed_translation = {}
    for mirb_id, mature_ids in mirbase_translation:
        mature_ids = mature_ids.split(";")
        for mat_id in mature_ids:
            if len(mat_id) == 0: continue

            if mat_id not in parsed_translation:
                parsed_translation[mat_id] = mirb_id
            else:
                counter = 1
                mat_id_transformed = f"{mat_id}_transformed_{counter}" 
                while mat_id_transformed in parsed_translation: #this check for repeated mature ids
                    counter += 1
                    mat_id_transformed = f"{mat_id}_transformed_{counter}"
                parsed_translation[mat_id_transformed] = mirb_id
    return parsed_translation


def translate_ids(mature_to_coord, parsed_mirbase):
    mirb_id_to_coor = []
    for row in mature_to_coord:
        if len(row) < 6: row = row + [""] * (6 - len(row)) # Fill empty miRNA fields

        chrm, start_c, end_c, mature_id, coord_n, strand = row[:6]
        if mature_id not in parsed_mirbase:
            print(f"{mature_id} has not been translated")
        else:
            mirb_id_to_coor.append([chrm, start_c, end_c, parsed_mirbase[mature_id], coord_n, strand])
    return mirb_id_to_coor

def write_output(translated_ids, output_file):
    with open(output_file, "w") as output:
        for line in translated_ids:
            output.write("\t".join(line) + "\n")

################################
########## MAIN
################################

miRNA_to_coor_file = sys.argv[1]
miRBase_tr = sys.argv[2]
output_file = sys.argv[3]

with open(miRBase_tr, "r") as f: miRBase_translation = [line.rstrip("\n").split("\t") for line in f if line.rstrip("\n")]
with open(miRNA_to_coor_file, "r") as f: miRNA_mature_to_coor = [line.rstrip("\n").split("\t") for line in f if line.rstrip("\n")]

parsed_mirbase = parse_mirbase(miRBase_translation)
translated_ids = translate_ids(miRNA_mature_to_coor, parsed_mirbase)
write_output(translated_ids, output_file)