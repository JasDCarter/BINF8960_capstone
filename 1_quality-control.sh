#! /bin/bash

# PERFORM QUALITY CONTROL ON FASTQ FILES

#(1) Run FASTQC
module load FastQC/0.12.1-Java-11  #module load FastQC
fastqc data/untrimmed_fastq/*.fastq.gz  #run FastQC on all the .fastq.gz files

# Move FASTQC results into appropriate results folder
mkdir results/untrimmed_fastqc
mv data/untrimmed_fastq/*.zip results/untrimmed_fastqc
mv data/untrimmed_fastq/*.html results/untrimmed_fastqc

# Comine FASTQC reports with multiQC
module load MultiQC/1.28-foss-2024a
multiqc results/untrimmed_fastqc -o results/untrimmed_multiqc

# Trim FASTQ files with trimmomatic
# Call the program to process paired-end files (PE), output file for forward paired reads --> then a file for the reads that are no longer paired (unpaired)... and same for reverse reads 
 module load Trimmomatic/0.39-Java-17
 mkdir data/trimmed_fastq
 for EACH in data/untrimmed_fastq/*_1.fastq.gz
 do
     sample=$(basename $EACH _1.fastq.gz)
     echo "Processing $sample"
     trimmomatic PE data/untrimmed_fastq/${sample}_1.fastq.gz data/untrimmed_fastq/${sample}_2.fastq.gz \
                 data/trimmed_fastq/${sample}_1.trim.fastq.gz data/trimmed_fastq/${sample}_1un.trim.fastq.gz \
                 data/trimmed_fastq/${sample}_2.trim.fastq.gz data/trimmed_fastq/${sample}_2un.trim.fastq.gz \
                 SLIDINGWINDOW:4:20 MINLEN:25 ILLUMINACLIP:data/NexteraPE-PE.fa:2:40:15
 done

#Run FASTQC on the trimmed files
module load FastQC/0.12.1-Java-11
fastqc data/trimmed_fastq/*_1.trim.fastq.gz data/trimmed_fastq/*_2.trim.fastq.gz

#Move FASTQC results into appropriate results folder
mkdir results/trimmed_fastqc
mv data/trimmed_fastq/*.zip results/trimmed_fastqc
mv data/trimmed_fastq/*.html results/trimmed_fastqc

#Combine FASTQC reports with multiQC
module load MultiQC/1.28-foss-2024a
multiqc results/trimmed_fastqc -o results/trimmed_multiqc
