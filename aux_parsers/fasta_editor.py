#!/usr/bin/env python3

import argparse
import math
import re
import sys

###############################
## FUNCTIONS
###############################

def load_file(file_list):
    all_fastas = {}
    for file_path in file_list:
        sequences = {}
        name = None
        seq = ""

        with open(file_path, "r") as f:
            for raw_line in f:
                line = raw_line.rstrip("\n")
                if re.match(r"^>", line):
                    if name is not None and seq:
                        key = name.split()[0]
                        sequences[key] = seq
                    seq = ""
                    name = line.replace(">", "", 1)
                else:
                    line = re.sub(r"[^actgnACTGN]", "N", line)
                    seq += line

        if name is not None and seq:
            key = name.split()[0]
            sequences[key] = seq

        all_fastas[file_path] = sequences

    return all_fastas


def load_fragments_table(files):
    fragments = []
    for file_path in files:
        with open(file_path, "r") as f:
            for raw_line in f:
                line = raw_line.rstrip("\n")
                if len(line) > 0: fragments.append(line.split("\t"))
    return fragments


def find_fragments(all_fastas, fragments, tail_length):
    output_fasta = {}

    for filename, fastas in all_fastas.items():
        output_seq = {}

        for seq_id, seq in fastas.items():
            fragment_number = 0

            for fragment in fragments:
                name = fragment[0]
                start = int(fragment[1])
                stop = int(fragment[2])

                if seq_id == name:
                    fragment_number += 1
                    starting = start - tail_length - 1
                    if starting < 0: starting = 0

                    ending = stop + tail_length - 1
                    if ending > len(seq): ending = len(seq) - 1

                    if len(fragment) < 4 or fragment[3] is None or fragment[3] == "":
                        seq_name = f"{name}:{starting + 1}:{ending + 1}_seq_num_fasta_editor_{fragment_number}"
                    else:
                        seq_name = fragment[3]

                    output_seq[seq_name] = seq[starting:ending + 1]

        if output_seq: output_fasta[filename] = output_seq

    return output_fasta


def save_output_in_a_file(filename, output_fasta, chunk_size=None):
    with open(filename, "w") as outfile:
        for file_key, fastas in output_fasta.items():
            for seq_id, seq in fastas.items():
                if seq_id is None: continue

                seq_length = len(seq)
                header = seq_id.split("_seq_num_fasta_editor_")[0]
                outfile.write(f">{header}\n")

                if chunk_size is None:
                    outfile.write(seq + "\n")
                else:
                    start = 0
                    stop = int(chunk_size)
                    iterations = int(math.ceil(seq_length / int(chunk_size)))

                    for n in range(iterations):
                        padding = 1
                        if n == iterations:
                            padding = 0
                        outfile.write(seq[start:stop - padding] + "\n")
                        start += int(chunk_size)
                        stop += int(chunk_size)

###############################
## OPTPARSE
###############################
parser = argparse.ArgumentParser(description="Fasta editor subset translation")
parser.add_argument("-i", "--file", dest="input",
	help="Open file(s) as a comma-separated list")
parser.add_argument("-f", "--fragments", dest="fragments",
	help="Find fragments in fasta sequences. It takes one or more tabulated files with chr\\tstart\\tstop")
parser.add_argument("-T", "--tail", dest="tail", type=int, default=0,
	help="Length of the tails of the fragments. Require '-f'. [DEFAULT = 0]")
parser.add_argument("-c", "--create", dest="create", default="",
	help="Create an output: 'a' for export all fastas of all files")
parser.add_argument("-o", "--save", dest="output", default="",
	help="Save in a file with other name (require -c)")
parser.add_argument("--split", dest="split", type=int, default=None,
	help="Split sequences in different lines of length INTEGER")
args = parser.parse_args()

###############################
## MAIN
###############################

files = [x.strip() for x in args.input.split(",") if x.strip()]
all_fastas = load_file(files)

if args.fragments is not None:
	fragment_files = [x.strip() for x in args.fragments.split(",") if x.strip()]
	fragments = load_fragments_table(fragment_files)
	sequences_to_process = find_fragments(all_fastas, fragments, args.tail)
else:
	sequences_to_process = all_fastas

if args.output:
	if "a" in args.create:
		output_fasta = sequences_to_process
		save_output_in_a_file(args.output, output_fasta, args.split)