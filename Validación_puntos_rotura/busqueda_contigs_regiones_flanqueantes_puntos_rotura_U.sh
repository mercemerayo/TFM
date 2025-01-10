#!/bin/bash

# Se pasa un fichero tabulado con las ventanas de las regiones de interes, el alineamiento BAM y el genoma de referencia como argumento

FICHERO_TAB_IN=$1
MAPEO_BAM=$2
GENOMA_REF=$3 # Genoma de referencia en formato fasta

# IFS=$'\t'para leer linea a linea del fichero_tabulado.txt y crear carpetas de reads y ensamblaje (para obtener los contigs) para cada ventana
while IFS=$'\t' read -r ID_ventana carpeta_salida inicio_proximal fin_proximal inicio_distal fin_distal; do

# Las carpetas de salida de reads y ensamblaje se generan para que no se mezclen los ficheros y se puedan controlar los resultados facilmente
 carpeta_reads="${carpeta_salida}/reads_separados"
 carpeta_ensamblaje="${carpeta_salida}/ensamblaje_contigs"
 mkdir -p "$carpeta_reads" "$carpeta_ensamblaje"

# Se extraen los reads para los puntos de rotura del cromosoma U (RefSeq: NC_048534.1) los nombres de las variables indican si es para 
# el punto de rotura proximal o distal 
 samtools view -h "$MAPEO_BAM" "Drosophila_subobscura_NC_048534.1:${inicio_proximal}-${fin_proximal}" > "${carpeta_reads}/${ID_ventana}_reads_proximal.sam"
 samtools view -h "$MAPEO_BAM" "Drosophila_subobscura_NC_048534.1:${inicio_distal}-${fin_distal}" > "${carpeta_reads}/${ID_ventana}_reads_distal.sam"

# Se consideran reads discordantes solo los relacionados con no mapeados (en el manual de samtools la combinación de los no mapeados implica -12)
 samtools view -f 12 "${carpeta_reads}/${ID_ventana}_reads_proximal.sam" > "${carpeta_reads}/${ID_ventana}_discordantes_proximal.sam"
 samtools view -f 12 "${carpeta_reads}/${ID_ventana}_reads_distal.sam" > "${carpeta_reads}/${ID_ventana}_discordantes_distal.sam"

# Separar los reads R1, R2 y singles en FASTQ del punto de rotura proximal 
 samtools fastq -1 "${carpeta_reads}/${ID_ventana}_proximal_R1.fastq" \
 -2 "${carpeta_reads}/${ID_ventana}_proximal_R2.fastq" \
 -s "${carpeta_reads}/${ID_ventana}_proximal_singles.fastq" \
 "${carpeta_reads}/${ID_ventana}_reads_proximal.sam"

# Lo mismo pero para los reads discordantes del punto de rotura proximal 
 samtools fastq -1 "${carpeta_reads}/${ID_ventana}_discordantes_proximal_R1.fastq" \
 -2 "${carpeta_reads}/${ID_ventana}_discordantes_proximal_R2.fastq" \
 -s "${carpeta_reads}/${ID_ventana}_discordantes_proximal_singles.fastq" \
 "${carpeta_reads}/${ID_ventana}_discordantes_proximal.sam"

# Separación de los reads del punto de rotura distal
 samtools fastq -1 "${carpeta_reads}/${ID_ventana}_distal_R1.fastq" \
 -2 "${carpeta_reads}/${ID_ventana}_distal_R2.fastq" \
 -s "${carpeta_reads}/${ID_ventana}_distal_singles.fastq" \
 "${carpeta_reads}/${ID_ventana}_reads_distal.sam"
 
 samtools fastq -1 "${carpeta_reads}/${ID_ventana}_discordantes_distal_R1.fastq" \
 -2 "${carpeta_reads}/${ID_ventana}_discordantes_distal_R2.fastq" \
 -s "${carpeta_reads}/${ID_ventana}_discordantes_distal_singles.fastq" \
 "${carpeta_reads}/${ID_ventana}_discordantes_distal.sam"

# Se combinan todos los reads segun su tipo; R1, R2 y singles en su propio fichero FASTQ para poder hacer
# el ensamblaje de novo 
 cat "${carpeta_reads}/${ID_ventana}_proximal_R1.fastq" \
 "${carpeta_reads}/${ID_ventana}_discordantes_proximal_R1.fastq" \
 "${carpeta_reads}/${ID_ventana}_distal_R1.fastq" \
 "${carpeta_reads}/${ID_ventana}_discordantes_distal_R1.fastq" > "${carpeta_reads}/${ID_ventana}_reads_R1.fastq"
 
 cat "${carpeta_reads}/${ID_ventana}_proximal_R2.fastq" \
 "${carpeta_reads}/${ID_ventana}_discordantes_proximal_R2.fastq" \
 "${carpeta_reads}/${ID_ventana}_distal_R2.fastq" \
 "${carpeta_reads}/${ID_ventana}_discordantes_distal_R2.fastq" > "${carpeta_reads}/${ID_ventana}_reads_R2.fastq"
 
 cat "${carpeta_reads}/${ID_ventana}_proximal_singles.fastq" \
 "${carpeta_reads}/${ID_ventana}_discordantes_proximal_singles.fastq" \
 "${carpeta_reads}/${ID_ventana}_distal_singles.fastq" \
 "${carpeta_reads}/${ID_ventana}_discordantes_distal_singles.fastq" > "${carpeta_reads}/${ID_ventana}_reads_singles.fastq"

# El ensamblaje con SPAdes se hace siguiendo la misma estrategia que en TFM de Delgado pero los resultados se guardan
# en las carpetas de ensamblaje que se van generando segun las ventanas que haya definidas en el fichero tab
 spades.py -k 21,33,55,77 --careful -1 "${carpeta_reads}/${ID_ventana}_reads_R1.fastq" \
 -2 "${carpeta_reads}/${ID_ventana}_reads_R2.fastq" -s "${carpeta_reads}/${ID_ventana}_reads_singles.fastq" -o "$carpeta_ensamblaje"

# Los contigs se pueden filtrar con BLAST por linea de comandos y se ve la coincidencia con el genoma de referencia que se ha pasado como argumento "$GENOMA_REF"
 blastn -query "${carpeta_ensamblaje}/contigs.fasta" -subject "$GENOMA_REF" -out "${carpeta_salida}/${ID_ventana}_blast_resultados.txt" -outfmt 6

# En las pruebas con BLASTn en la web vemos que los contigs a veces se alinean con otros cromosomas que no son el U (el que nos interesa)
# con una coincidencia baja, para facilitar el análisis solo se filtran resultados BLAST NC_048534.1 (crom. U)
 grep "Drosophila_subobscura_NC_048534.1" "${carpeta_salida}/${ID_ventana}_blast_resultados.txt" > "${carpeta_salida}/${ID_ventana}_blast_filtrado.txt"
 
# Aumento de la ventana de flanqueantes 5Kb antes y despues de las regiones flanqueantes de estudio para asegurar
# que se captan toda la region de interes para poder analizar los resultados
 awk '($9 >= ('$inicio_proximal' - 5000) && $9 <= ('$fin_proximal' + 5000)) || ($9 >= ('$inicio_distal' - 5000) && $9 <= ('$fin_distal' + 5000))' \
 "${carpeta_salida}/${ID_ventana}_blast_filtrado.txt" > "${carpeta_salida}/${ID_ventana}_blast_flanqueantes.txt"
 
# BLAST de los contigs filtrado solo con las regiones alrededor de la inversion
cat "${carpeta_salida}/${ID_ventana}_blast_flanqueantes.txt"
done < "$FICHERO_TAB_IN"
