#!/bin/bash

# Verificar si se pasan los parámetros 
if [ "$#" -ne 3 ]; then
    echo "Uso: $0 <coordenada_inicio> <coordenada_fin> <ID_CROM_REFSEQ>"
    exit 1
fi

# Parámetros de entrada
COORD_INICIO=$1
COORD_FIN=$2
ID_CROM_REFSEQ=$3

# Descarga de ficheros 
echo "Descargando archivos gff y gene ontology"
wget -q "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/008/121/235/GCF_008121235.1_UCBerk_Dsub_1.0/GCF_008121235.1_UCBerk_Dsub_1.0_genomic.gff.gz" -O genomic_D_subobscura.gff.gz
wget -q "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/008/121/235/GCF_008121235.1_UCBerk_Dsub_1.0/GCF_008121235.1_UCBerk_Dsub_1.0_gene_ontology.gaf.gz" -O gene_ontology_D_subobscura.gaf.gz


# Identificación del cromosoma basado en el ID RefSeq
case "$ID_CROM_REFSEQ" in
    "NC_048530.1") CROMOSOMA="A" ;;
    "NC_048531.1") CROMOSOMA="E" ;;
    "NC_048532.1") CROMOSOMA="J" ;;
    "NC_048533.1") CROMOSOMA="O" ;;
    "NC_048534.1") CROMOSOMA="U" ;;
    "NC_048535.1") CROMOSOMA="dot" ;;
    "NC_045530.1") CROMOSOMA="MT" ;;
    *)
        echo "Error: ID RefSeq no reconocido."
        exit 1
        ;;
esac

# Filtrar genes en el cromosoma y coordenadas
echo "Filtrando genes del cromosoma $CROMOSOMA ($ID_CROM_REFSEQ) en el rango $COORD_INICIO - $COORD_FIN..."
zcat genomic_D_subobscura.gff.gz | grep "$ID_CROM_REFSEQ" > cromosoma_${CROMOSOMA}.gff
awk -v start="$COORD_INICIO" -v end="$COORD_FIN" '$4 >= start && $5 <= end && $3 == "gene"' cromosoma_${CROMOSOMA}.gff > genes_filtrados_${CROMOSOMA}.gff

# Extraer nombres de genes
awk -F'\t' '$3 == "gene"' genes_filtrados_${CROMOSOMA}.gff | \
awk -F';' '{for(i=1;i<=NF;i++){if($i ~ /gene=/){print $i}}}' | \
sed 's/gene=//' > ID_genes_${CROMOSOMA}.txt

# Generar archivo de coordenadas
awk -F'\t' '{split($9, attributes, ";"); for (i in attributes) {if (attributes[i] ~ /gene=/) {split(attributes[i], a, "="); print a[2] "," $1 "," $4 "," $5}}}' genes_filtrados_${CROMOSOMA}.gff > coordenadas_${CROMOSOMA}.csv

# Filtrar anotaciones GO
zcat gene_ontology_D_subobscura.gaf.gz | grep -f ID_genes_${CROMOSOMA}.txt > anotaciones_${CROMOSOMA}.gaf

# Generar archivo final con anotaciones GO
awk -F'\t' '{print $3 "," $5 "," $9}' anotaciones_${CROMOSOMA}.gaf > anotaciones_GO_${CROMOSOMA}.csv

# Merge de coordenadas y anotaciones GO
awk -F',' 'NR==FNR {coords[$1] = $0; next} $1 in coords {print coords[$1] "," $2 "," $3}' coordenadas_${CROMOSOMA}.csv anotaciones_GO_${CROMOSOMA}.csv > anotaciones_estudio_${CROMOSOMA}.csv

# Ordenar por coordenadas de inicio
sort -t',' -k3,3n anotaciones_estudio_${CROMOSOMA}.csv > anotaciones_estudio_coord_${CROMOSOMA}.csv

# Eliminar archivos intermedios
rm -f cromosoma_${CROMOSOMA}.gff
rm -f genes_filtrados_${CROMOSOMA}.gff
rm -f ID_genes_${CROMOSOMA}.txt
rm -f coordenadas_${CROMOSOMA}.csv
rm -f anotaciones_${CROMOSOMA}.gaf
rm -f anotaciones_GO_${CROMOSOMA}.csv
rm -f anotaciones_estudio_${CROMOSOMA}.csv
echo "Archivos intermedios eliminados."

echo "Primeras líneas de las anotaciones GO ordenado por coordenadas de inicio:"
head -n 10 anotaciones_estudio_coord_${CROMOSOMA}.csv
