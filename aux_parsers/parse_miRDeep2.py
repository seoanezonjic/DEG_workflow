#!/usr/bin/env python3

import re
import sys

KNOWN_MIRNA_NAME = 9
POSITION = 16


###################################################################
############### => METHODS
###################################################################

def load_file(input_file):
    raw_file = []
    with open(input_file, "r") as f:
        for line in f:
            line = line.rstrip("\n")
            if line != '': raw_file.append(line.rstrip("\t"))
    return raw_file


def get_from_table(raw_file, start_string, end_string):
    table_start = raw_file.index([start_string]) + 1
    table_end = raw_file.index([end_string]) - 1
    table = raw_file[table_start:table_end + 1]
    return table


def write_table(table, out_file, column_name):
    with open(out_file, "w") as output_file:

        for i, line in enumerate(table):
            novel_to_keep = (line[8] == "yes" and line[3] == "-")

            if i == 0:
                line[0] = "miRNA_name"
            else:
                if out_file == "novel_miRDeep_miRNAs" and not novel_to_keep: continue
                line[0] = line[column_name]

            output_file.write(re.sub(r" +", "_", "\t".join(line)) + "\n")


###################################################################
############### => MAIN
###################################################################

raw_file = load_file(sys.argv[1])
novel_mirnas = get_from_table(raw_file, "novel miRNAs predicted by miRDeep2", "mature miRBase miRNAs detected by miRDeep2")
known_mirnas = get_from_table(raw_file, "mature miRBase miRNAs detected by miRDeep2", "#miRBase miRNAs not detected by miRDeep2")

write_table(novel_mirnas, "novel_miRDeep_miRNAs", POSITION)
write_table(known_mirnas, "known_miRDeep_miRNAs", KNOWN_MIRNA_NAME)