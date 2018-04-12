#!/bin/bash

# Runs MECAT: mecat2cns on test data
#
# $1 - path to fasta input
#
# Compares gpu version performance with cpu version

#Assumes you're on the alienware server...
# TODO - generalize
mecat_bin=../Linux-amd64/bin

work="./work"
mkdir -p $work

#Check input
if [ "$#" -ne 1 ]; then
    echo "Usage: ./testMecat.sh input.fasta"
    exit 1
fi

if [ ! -f $1 ]; then
    echo "File: $1 does not exist"
    exit 1
fi
fasta_in=$1 #./MAP006-PCR-1_2D_pass.fasta

#local variables
candidate="./$work/candidate.txt"
fasta_mid="./$work/corrected_ecoli.fasta"
fasta_ext="./$work/corrected_ecolix25"
results="./test_results_$(date +%h_%d_%H:%M).txt"

#some commands rely on having mecat's bin in the path
export PATH="$PATH:$mecat_bin"

#fist step done quickly
mecat2pw -j 0 -d $fasta_in -o $candidate -w $work -t 12 -x 1

#Perform calculation on cpu and gpu
cpu_s=$(date +%s)
mecat2cns -i 0 -t 1 -x 1 $candidate $fasta_in $fasta_mid.cpu
cpu_p=$(date +%s)

gpu_s=$(date +%s)
mecat2cns_gpu -i 0 -t 1 -x 1 $candidate $fasta_in $fasta_mid.gpu
gpu_p=$(date +%s)


#report results
let gpu_time=( $gpu_p - $gpu_s )
let cpu_time=( $cpu_p - $cpu_s )

echo "GPU time: $gpu_time" | tee $results
echo "CPU time: $gpu_time" | tee -a $results


echo "GPU size: $(ls -sh $fasta_mid".gpu")" | tee -a $results
echo "CPU size: $(ls -sh $fasta_mid".cpu")" | tee -a $results

#delete run artifacts
rm -rf $work


#Ignore other steps for now... compare file sizes of output until a better output validation metric is needed


#extracts the 25 longest reads to another intermediate fasta
#extract_sequences $fasta_mid $fasta_ext 4800000 25

#assemble the genome
#mecat2canu -trim-assemble -p ecoli -d ecoli genomeSize=4800000 ErrorRate=0.06 maxMemory=8 maxThreads=12 useGrid=0 Overlapper=mecat2asmpw -nanopore-corrected $fasta_ext.fasta
