#! /bin/bash

# QUANTIFY RAW vs TRIMMED READS + ALIGNMENT + VARIANTS

#(1) Create a tidy output file
OUTPUT_FILE="results/summary_stats.csv"
echo "sample,raw_reads,trimmed_reads,aligned_reads,variant_sites" > $OUTPUT_FILE

# for loop
for EACH in SRR2584863 SRR2584866 SRR2589044
do
    echo "Calculating statistics for sample $EACH"

#(2) Count Raw Reads 
    raw_lines=$(zcat data/untrimmed_fastq/${EACH}_1.fastq.gz | wc -l)
    raw_reads=$((raw_lines / 4)) #because there are 4 lines per 1 read

#(3) Count Trimmed Reads
    trimmed_lines=$(zcat data/trimmed_fastq/${EACH}_1.trim.fastq.gz | wc -l)
    trimmed_reads=$((trimmed_lines / 4))

#(4) Count Aligned Reads
    aligned_reads=$(samtools view -c -F 0x4 results/bam/${EACH}.sorted.bam) #view each BAM file -> count the rows + ignore rows flagged with 4 (-F 0x4), which means unmapped

#(5) Count Variant Sites
    variant_sites=$(grep -v '^#' results/vcf/variants_filtered.vcf | wc -l)
    #grab all lines that DON'T start with # (headers) -> count the number of lines

# add statistics to the tidy output file
    echo "${EACH},${raw_reads},${trimmed_reads},${aligned_reads},${variant_sites}" >> $OUTPUT_FILE
done