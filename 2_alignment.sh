#! /bin/bash

# ALIGN TRIMMED READS TO E.COLI REFERENCE GENOME + CALL VARIANTS

#(1) Download reference genome
# mkdir data/ref_genome
# curl -L -o data/ref_genome/ecoli_rel606.fasta.gz ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/017/985/GCA_000017985.1_ASM1798v1/GCA_000017985.1_ASM1798v1_genomic.fna.gz
# gunzip /scratch/jdc83001/ecoli_variation/data/ref_genome/ecoli_rel606.fasta.gz

#(2) Index the reference genome
module load BWA/0.7.18-GCCcore-13.3.0
bwa index /scratch/jdc83001/ecoli_variation/data/ref_genome/ecoli_rel606.fasta

#(3) Make the output directories
mkdir results/sam results/bam results/bcf results/vcf

#(4) Align trimmed reads to E.coli reference genome
module load BWA/0.7.18-GCCcore-13.3.0
module load SAMtools/1.23.1-GCC-13.3.0

for fwd in data/trimmed_fastq/*_1.trim.fastq.gz
do
sample=$(basename $fwd _1.trim.fastq.gz)
echo "Processing sample $sample"

# Align
    bwa mem /scratch/jdc83001/ecoli_variation/data/ref_genome/ecoli_rel606.fasta \
         "$fwd" \
         data/trimmed_fastq/${sample}_2.trim.fastq.gz \
         > results/sam/${sample}.sam

# Convert to bam format
   samtools view -S -b results/sam/${sample}.sam \
   > results/bam/${sample}.bam

# Sort and index the bam file
 samtools sort -o results/bam/${sample}.sorted.bam results/bam/${sample}.bam
 samtools index results/bam/${sample}.sorted.bam
 done

# Variant calling
module load BCFtools/1.23.1-GCC-13.3.0
 bcftools mpileup -O b -o results/bcf/variants.bcf \
 -f data/ref_genome/ecoli_rel606.fasta results/bam/*.sorted.bam
 bcftools call --ploidy 1 -m -v -o results/vcf/variants.vcf \
   results/bcf/variants.bcf
vcfutils.pl varFilter results/vcf/variants.vcf > results/vcf/variants_filtered.vcf