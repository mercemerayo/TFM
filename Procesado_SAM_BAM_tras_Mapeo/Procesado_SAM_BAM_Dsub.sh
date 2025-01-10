#!/bin/bash

# Procesado de ficheros SAM/BAM del mapeo (alineamiento) de las
# lecturas OF58 usando samtools

echo "Convirtiendo SAM a BAM"
samtools view -Sb OF58_alineado_hologenoma_dsub_2.sam > OF58_mapeado_bwamem2.bam

echo "Ordenando archivo BAM por coordenadas"
samtools sort OF58_mapeado_bwamem2.bam -o OF58_ordenado.bam

echo "Indexando archivo BAM ordenado"
samtools index OF58_ordenado.bam

echo "Ordenando archivo BAM por nombres"
samtools sort -n OF58_ordenado.bam -o OF58_ordenado_nombres.bam
rm -f OF58_ordenado.bam

echo "Corrigiendo inconsistencias con fixmate"
samtools fixmate -m OF58_ordenado_nombres.bam OF58_corregido_fixmate.bam
rm -f OF58_ordenado_nombres.bam

echo "Reordenando archivo BAM por coordenadas"
samtools sort OF58_corregido_fixmate.bam -o OF58_ordenado_coordenadas.bam
rm -f OF58_corregido_fixmate.bam

echo "Marcando duplicados"
samtools markdup OF58_ordenado_coordenadas.bam OF58_mate_proc_dupmarc_bwamem2.bam
rm -f OF58_ordenado_coordenadas.bam

echo "Indexando archivo BAM con duplicados marcados"
samtools index OF58_mate_proc_dupmarc_bwamem2.bam

# Generación de estadísticas 
samtools flagstat -t 4 OF58_mate_proc_dupmarc_bwamem2.bam > OF58_estadisticas_maporddup.txt
