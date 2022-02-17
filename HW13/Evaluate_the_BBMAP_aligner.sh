# How to set up your new environment.
#
# conda create --clone bioinfo --name bbmap
# conda activate bbmap
# mamba install bbmap

# Reference genome accession number.
ACC=CM000684

# The SRR number for the sequencing data.
SRR=SRR1039508

# Alignment files for both methods.
BAM_BWA=${SRR}-${ACC}-bwa.bam

BAM_BBMAP=${SRR}-${ACC}-bbmap.bam

# Readcount
N=10000

# The name for the read pairs.
R1=reads/${SRR}_1.fastq
R2=reads/${SRR}_2.fastq

# The reference genome stored locally.
REF=refs/${ACC}.fa

genome:
	mkdir -p refs
	bio fetch -format fasta ${ACC} > ${REF}
	samtools faidx ${REF}
	time bwa index ${REF}
	time bbmap.sh ref=${REF}

data:
	# Obtain the FASTQ sequences for the SRR number.
	mkdir -p reads
	fastq-dump -F -X ${N} --split-files ${SRR} -O reads

bwa:
	# Run the bwa aligner. Creates a SAM file.
	bwa mem -t 4 ${REF} ${R1} ${R2} | samtools sort > ${BAM_BWA}
	samtools index ${BAM_BWA}
	samtools flagstat ${BAM_BWA}

bbmap:
	# Run the bwa aligner. Creates a SAM file.
	bbmap.sh in1=${R1} in2=${R2} ref=${REF} out=out.sam trd=t
	cat out.sam | samtools sort > ${BAM_BBMAP}
	samtools index ${BAM_BBMAP}
	samtools flagstat ${BAM_BBMAP}

bbmap2:
	# Run the bwa aligner with "different" parameters.
	bbmap.sh in1=${R1} in2=${R2} ref=${REF} out=out.sam k=8 maxindel=200 minratio=0.1 trd=t
	cat out.sam | samtools sort > ${BAM_BBMAP}
	samtools index ${BAM_BBMAP}
	samtools flagstat ${BAM_BBMAP}

coverage:
	bedtools bamtobed -i ${BAM_BWA} > test.bed