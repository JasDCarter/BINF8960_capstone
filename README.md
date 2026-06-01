# BINF7960 Capstone - E. coli Genomics Analysis
# DATE: 31 May 2026
# AUTHOR: Jasmine Carter

# (1) 0_setup.sh
CREATE FOLDERS
Create setup.sh to create directory structure (data, results) and get input data files.

DOWNLOAD RAW DATA
Download and extracted FASTQ files from the European Nucleotide Archive.

COPY METADATA
Copy over associated metadata from instructor_data file

# (2) 1_quality-control.sh
PERFORM QC ANALYSIS
Run FastQC on each raw fastq files

COMBINE FASTQC RESULTS INTO A SINGLE REPORT USING MULTIQC 
  -> CONCLUSION = must trim adapters + low-quality sequences from the ends of the reads

TRIM RAW FASTQ FILES USING TRIMMOMATIC
- Sliding window: width 4, score 20
- Illumina adapter removal
- Minimum length 25

RERUN FASTQC AND MULTIQC ON TRIMMED FILES
--> CONCLUSION: Successfully removed low quality reads and adapters

# (3) 2_alignment.sh
ALIGN READS TO E.COLI REFERENCE GENOME
Run alignment using bcftools to generate .sam files

CONVERT .sam FILES (human-readable) INTO .bam FILES (computer-readable)

SORT AND INDEX .bam FILES (ORGANIZE THE OUTPUT)
use samtools sort to order reads by genomic coordinate
use samtools index to create a table of contents (improve downstream data processing)

IDENTIFY AND CALL VARIANTS
use bcftools mpileup to identify mismatches 
use bcftools call to determine which mismatches are real mutations (variants) and which are just sequencing errors -> .vcf file
- Ploidy = 1

QUALITY CONTROL
use vcfutils.pl varFilter on the .vcf file to filter additional erroneous mutations using default filters (i.e. mutations with very low read depth)

# (4) 3_summary_stats.sh
QUANTIFY RAW READS
hard-code a loop for each sample 
total the number of lines in each raw (untrimmed) file
divide the total by 4 (1 read = 4 lines in fastq files)

QUANTIFY TRIMMED READS
total the number of lines in each trimmed file
divide the total by 4 (1 read = 4 lines in fastq files)

QUANTIFY ALIGNED READS
use samtools view -c -F 0x4 to view each BAM file, count the rows, and ignore rows flagged with 0x4
-c = count
-F = does NOT have this flag (CAPITAL F)
0x4 = read UNMAPPED

QUANTIFY VARIANTS
setup an if-then condition that works with the initial hard-coded loop
    sanity-check that column 10 = SRR2584863 -> for SRR2584863, ignore all rows that start with #, cut column 10, count every instance of "1:" (1 = variant; 0 = reference match)
    sanity-check that column 10 = SRR2584866 -> for SRR2584866, ignore all rows that start with #, cut column 11, count every instance of "1:"
    sanity-check that column 10 = SRR2589044 -> for SRR2589044, ignore all rows that start with #, cut column 12, count every instance of "1:"

ADD COUNTS TO A TIDY, COMMA-SEPARATED OUTPUT FILE
