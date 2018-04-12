#!/bin/bash

# compare mecat2cns and mecat2cns_gpu outpt. Fails if they differ
#
# $1 - path to fasta input

#won't work if you have more than one bin dir under MECAT
mecat_bin=$(realpath $(find .. -name "bin"))

#Check input args
if [ "$#" -ne 1 ]; then
    echo "Usage: ./testMecat.sh input.fasta"
    exit 1
fi

if [ ! -f $1 ]; then
    echo "Expected fasta input file: $1 does not exist"
    exit 1
fi
fasta_in=$1

#local variables
work=$(realpath "./diff_work")
mkdir -p $work
candidate="$work/candidate.txt"
fasta_mid="$work/corrected_ecoli.fasta"

#some commands rely on having mecat's bin in the path
export PATH="$PATH:$mecat_bin"

#do first step
mecat2pw -j 0 -d $fasta_in -o $candidate -w $work -t 12 -x 1

#Perform calculation on cpu and gpu to look at outputs
mecat2cns -i 0 -t 1 -x 1 $candidate $fasta_in $fasta_mid.cpu
mecat2cns_gpu -i 0 -t 1 -x 1 $candidate $fasta_in $fasta_mid.gpu

diff $fasta_mid.cpu $fasta_mid.gpu > diff_report

if [ $? -eq 1 ]; then
    echo "GPU and CPU outputs differ. Check diff_report and diff_work for details."
    exit 1
else
    rm diff_report
    rm -rf $work
    exit 0
fi
