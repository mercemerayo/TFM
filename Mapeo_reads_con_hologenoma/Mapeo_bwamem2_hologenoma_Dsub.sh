#!/bin/bash

# Indexar y alinear lecturas usando bwa-mem2 con hologenoma de D. subobscura

#Indexar el hologenoma
echo "Indexando el hologenoma con bwa-mem2..."
bwa-mem2 index hologenoma_con_dsub.fa

# Alinear (mapear) lecturas al hologenoma y generar un archivo SAM
echo "Alineando lecturas al hologenoma..."
bwa-mem2 mem -t 4 -M -R '@RG\tID:HWI-ST459_121:4\tPL:ILLUMINA\tLB:OF58\tPU:HWI-ST459_121:4\tSM:OF58' hologenoma_con_dsub.fa of58_r1_fp_clean.fastq.gz of58_r2_fp_clean.fastq.gz > OF58_alineado_hologenoma_dsub_2.sam

