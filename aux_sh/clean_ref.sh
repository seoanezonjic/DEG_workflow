#!/usr/bin/env bash
. ~soft_bio_267/initializes/init_python
grep -v '#' annotation.gtf | cut -f 1 | sort -u > annotated_seq_ids
lista2fasta.py annotated_seq_ids genome_orig.fa > genome.fa
