#!/bin/sh
#BSUB -J prep-input

file=$1
grep -v "#" $file | sort -k1,1 -k4,4n -k5,5n -t$'\t' | bgzip -c > $file.gz
tabix -p gff $file.gz
