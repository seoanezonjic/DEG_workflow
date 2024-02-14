#! /usr/bin/env python

import sys
import pysam
input = sys.argv[1]
output = sys.argv[2]
min_soft_clip_rate = float(sys.argv[3])

bamfile = pysam.AlignmentFile(sys.argv[1], "rb")
outfile = pysam.AlignmentFile(output + ".bam", "w", template=bamfile)
outFasta = open(output + ".fasta",'w')
unaligned_reads = 0
for read in bamfile:#.fetch('chr1'):
    if read.is_secondary or read.is_supplementary: continue
    read_len = read.infer_read_length()
    cigar_nucleotides, cigar_blocks = read.get_cigar_stats()
    #print(f"{cigar_nucleotides[0]} {cigar_nucleotides[4]} {read_len}")
    soft_clipping_rate = cigar_nucleotides[4]/read_len
    if soft_clipping_rate >= min_soft_clip_rate:
        outfile.write(read)
        pair_read = 1
        if read.is_read2: pair_read = 2
        outFasta.write(f">{read.query_name}_{pair_read}\n{read.query_sequence}\n")
        unaligned_reads += 1

print(f"unaligned_reads: {unaligned_reads}")
outFasta.close()
