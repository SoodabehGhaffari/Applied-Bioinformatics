# Stop on errors. Show all commands.
set -eux 

# Install bio if you don't have it.
#pip install bio --upgrade

# Substitute reference genome accession number.
ACC=AF086833

# Substitute the SRR run number.
SRR=SRR1972739

# The alignment file name.
BAM=${SRR}.bam

# All genotype likelihoods.
ALL=${SRR}.all.vcf

# The variants selected from all genotypes.
VCF=${SRR}.bcf.vcf

# The reference genome in FASTA format.
REF=refs/${ACC}.fa

# The reference genome in GFF format.
GFF=refs/${ACC}.gff

# Directory for various reference information.
mkdir -p refs

# Obtain the reference in FASTA format.
bio fetch -format fasta $ACC > $REF

# Obtain the reference in GFF format.
bio fetch -format gff $ACC > $GFF

# Index reference for the bwa aligner.
bwa index $REF

# Index the reference genome so that it can be loaded into IGV.
samtools faidx $REF

# The directory that stores the sequencing reads
mkdir -p reads

# Get sequencing data from a SRR number.
# Use fastq-dump-orig if you get an error
fastq-dump -X 10000 --split-files -O reads $SRR

# The paired end read names.
R1=reads/${SRR}_1.fastq
R2=reads/${SRR}_2.fastq

# Align and generate a sorted BAM file.
bwa mem $REF $R1 $R2 | samtools sort > $BAM

# Index the BAM file.
samtools index $BAM

# Compute all genotypes with bcftools.
bcftools mpileup -O v -f $REF $BAM > $ALL

# From all genotypes call only the variants.
cat $ALL | bcftools call --ploidy 1 -mv -O v -o $VCF 

# We can pipe the two into one call like so.
#bcftools mpileup -Ou -f $REF $BAM | bcftools call -mv -Ov -o $VCF