#!/bin/bash

# Fastp sobre las lecturas Illumina de la cepa OF58 de D. subobcura
fastp -i D1EFBACXX_4_9_1.fastq-001.gz -I D1EFBACXX_4_9_2.fastq-002.gz -o of58_r1_fp_clean.fastq.gz -O of58_r2_fp_clean.fastq.gz -h informe_fastp_of58.html 
