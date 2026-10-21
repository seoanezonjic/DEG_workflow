#!/usr/bin/env python3
import argparse
import glob
import os


########################################################
### METHODS
########################################################

def load_files(all_files): # takes a files list and returns an list for each file
    all_info = []
    for file_name in all_files:
        with open(file_name, "r") as f:
            for line in f:
                line = line.rstrip("\n").split("\t")
                line[1] = int(line[1])
                line[2] = int(line[2])
                all_info.append(line)
    return all_info


def format_miRNA_coords(all_miRNAs, column_idx):  # take a bidimensional list and return a dict of lists with [column] as keys
    formatted_miRNAs = {}
    for miRNA in all_miRNAs:
        coords = [miRNA[1], miRNA[2]]
        miRNA[1] = min(coords)
        miRNA[2] = max(coords)

        key = miRNA[column_idx]
        if key in formatted_miRNAs:
            formatted_miRNAs[key].append(miRNA)
        else:
            formatted_miRNAs[key] = [miRNA]

    for group, entries in formatted_miRNAs.items():
        formatted_miRNAs[group] = sorted(entries, key=lambda x: x[1])

    return formatted_miRNAs


def merge_coords(formatted_miRNAs, distance): # takes a dict of lists and merges overlapping entries
    merged_miRNAs = {}
    for group, entries in formatted_miRNAs.items():
        merged_miRNAs[group] = []

        counter = 0
        ref_entry = entries[counter]
        while counter < len(entries) - 1:
            counter += 1
            actual_entry = entries[counter]
            if do_overlap(ref_entry[1:3], actual_entry[1:3], distance):
                ref_entry[2] = max(ref_entry[2], actual_entry[2])
            else:
                merged_miRNAs[group].append(ref_entry)
                ref_entry = actual_entry

        merged_miRNAs[group].append(ref_entry)

    return merged_miRNAs


def do_overlap(coord_A, coord_B, distance):
    overlap = (
        min(coord_B) >= min(coord_A) and min(coord_B) <= max(coord_A) + distance
    ) or (
        min(coord_A) >= min(coord_B) and min(coord_A) <= max(coord_B) + distance
    )
    return overlap


########################################################
### OPTARSE
########################################################
parser = argparse.ArgumentParser(description="Merge miRNA coordinate files.")

parser.add_argument("-k", "--known_mirnas", dest="known_mirnas",
	help="Set known miRNAs coordinates files. You must write path between quotes")
parser.add_argument("-n", "--novel_mirnas", dest="novel_mirnas",
	help="Set novel miRNAs coordinates files. You must write path between quotes")
parser.add_argument("-d", "--max_distance", dest="distance", type=int, default=0,
	help="Maximum distance in chain to consider the sequences are the same. Default = 0")
parser.add_argument("-o", "--output", dest="output_path", default="./",
	help="Define path to write output files. Default = ./")
parser.add_argument("-h", "--help", action="help",
	help="Displays help")

args = parser.parse_args()

########################################################
### MAIN
########################################################
if args.known_mirnas is not None:
    known_files = glob.glob(args.known_mirnas)
    known_mirnas = load_files(known_files)
    known_mirnas = format_miRNA_coords(known_mirnas, 3)
    known_mirnas = merge_coords(known_mirnas, args.distance)

    os.makedirs(args.output_path, exist_ok=True)

    with open(os.path.join(args.output_path, "known_miRNA.coord"), "w") as outfile:
        for miRNA, findings in known_mirnas.items():
            for counter, finding in enumerate(findings):
                if counter > 0: finding[3] = f"{finding[3]}_like_{counter}"
                outfile.write("\t".join(str(x) for x in finding) + "\n")

if args.novel_mirnas is not None:
    novel_files = glob.glob(args.novel_mirnas)
    novel_mirnas = load_files(novel_files)
    novel_mirnas = format_miRNA_coords(novel_mirnas, 0)
    novel_mirnas = merge_coords(novel_mirnas, args.distance)

    os.makedirs(args.output_path, exist_ok=True)

    with open(os.path.join(args.output_path, "novel_miRNA.coord"), "w") as outfile:
        for chromosome, findings in novel_mirnas.items():
            for finding in findings:
                finding[3] = ":".join(str(x) for x in finding[0:3])
                outfile.write("\t".join(str(x) for x in finding) + "\n")