#
# Usage: myscript.sh SRAnumber lIMIT windowSize requiredQuality 
#the LIMIT, windowSize, and requiredQuality are optional inputs.
# Example: bash myscript.sh SRR1553607 1000 4 30
#
# This program gets data from SRA and trims it with trimmomatic

#To run this script, one needs to install fastq-dump, trimmomatic and fastqc



#Stop on undefined variables and on errors and also print commands as these are are executed
set -uex

#Get the SRA run number from the first input while execution and save it in SRR.
SRR=$1

#Set the output name.

READ2=trimmed.fq


#set the LIMIT variable to the second parameter $2 or 1000 if that was not specified:

LIMIT=${2:-1000}

#Get data from SRA.

fastq-dump -X $LIMIT --split-files $SRR

windowSize=${3:-4}
requiredQuality=${4:-30}

# Run trimmomatic in single end mode

#SLIDINGWINDOW:<windowSize>:<requiredQuality>
#windowSize: specifies the number of bases to average across
#requiredQuality: specifies the average quality required.

trimmomatic SE ${SRR}_2.fastq ${READ2} SLIDINGWINDOW:${windowSize}:${requiredQuality}

# Generate fastqc reports on both datasets.
fastqc ${SRR}_1.fastq ${READ2} 

