#! /usr/bin/env python
import sys
import re

def mask_fasta(mask_regs, path):
    with open(path) as f:
        s_id = None
        seq = ''
        for line in f:
            line = line.rstrip()
            if re.search('^>', line):
                line = line.replace('>', '')
                regs = mask_regs.get(s_id)
                if regs != None: seq = mask_seq(seq, regs)
                print(f">{s_id}\n{seq}")
                s_id = line
                seq = ''
            else:
                seq = seq + line
    regs = mask_regs.get(s_id)
    if regs != None: seq = mask_seq(seq, regs)
    print(f">{s_id}\n{seq}")

#bed file formated taking into account info in https://www.ensembl.org/info/genome/genebuild/human_PARS.html
def load_bed(path):
    regs = {}
    with open(path) as f: 
        for line in f: 
            chrm_id, start, stop = line.rstrip().split("\t")
            chrm = regs.get(chrm_id)
            if chrm == None:
                chrm = []
                regs[chrm_id] = chrm
            chrm.append([int(start) -1, int(stop) -1])
    return regs

def mask_seq(seq, regs):
    new_seq = ''
    current_coord = 0
    for start, stop in regs:#slicing gets +1 position
        new_seq = new_seq + seq[current_coord:start] + 'N' * (stop +1 - start)
        current_coord = stop + 1
    new_seq = new_seq + seq[current_coord:]
    return new_seq

seq_ids = load_bed(sys.argv[1])
mask_fasta(seq_ids, sys.argv[2])
