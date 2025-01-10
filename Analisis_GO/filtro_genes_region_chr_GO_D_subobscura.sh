#!/bin/bash

# Los argumentos que hay que pasar al script son las coordenadas de inicio y final y el codigo RefSeq de un cromosoma de Drosophila subobscura
COORD_INICIO=$1
COORD_FIN=$2
ID_CROM_REFSEQ=$3

# Descarga de ficheros con control de que ha empezado la descarga y se simplifica el nombre -O para que los comandos posteriores no sean tan largos
echo "Descargando archivos gff y gene ontology"
wget -q "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/008/121/235/GCF_008121235.1_UCBerk_Dsub_1.0/GCF_008121235.1_UCBerk_Dsub_1.0_genomic.gff.gz" -O genomic_D_subobscura.gff.gz
wget -q "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/008/121/235/GCF_008121235.1_UCBerk_Dsub_1.0/GCF_008121235.1_UCBerk_Dsub_1.0_gene_ontology.gaf.gz" -O gene_ontology_D_subobscura.gaf.gz

# Identificacion del cromosoma segun su ID RefSeq para Drosophila subobscura para poner en los ficheros de salida en vez de ID RefSeq
case "$ID_CROM_REFSEQ" in
 "NC_048530.1") CROMOSOMA="A" ;;
 "NC_048531.1") CROMOSOMA="E" ;;
 "NC_048532.1") CROMOSOMA="J" ;;
 "NC_048533.1") CROMOSOMA="O" ;;
 "NC_048534.1") CROMOSOMA="U" ;;
 "NC_048535.1") CROMOSOMA="dot" ;;
 "NC_045530.1") CROMOSOMA="MT" ;;

# Para evitar problemas tipográficos al entrar en ID del cromosoma se avisa que hay un error en el ID y se sale del script
 *)
  echo "Error: ID RefSeq en D. subobscura no reconocido."
  exit 1
  ;;
esac

echo "Filtrando genes del cromosoma $CROMOSOMA ($ID_CROM_REFSEQ) en el intervalo $COORD_INICIO - $COORD_FIN..."
zcat genomic_D_subobscura.gff.gz | grep "$ID_CROM_REFSEQ" > cromosoma_${CROMOSOMA}.gff

# En el fichero .gff la columna 4 contiene coordenadas de inicio y la 4 las del final
# En la columna 3 del .gff filtrado se identifica si la información de la fila pertecene a un gen (o un exon, sRNA, etc)
awk -v inicio="$COORD_INICIO" -v final="$COORD_FIN" '$4 >= inicio && $5 <= final && $3 == "gene"' cromosoma_${CROMOSOMA}.gff > genes_filtrados_${CROMOSOMA}.gff

#  En este caso se quiere extraer los nombres de genes que estan en una estructura separada por ; en la columna 3 

# En este caso se quiere extraer los nombres de los genes que estan en una estructura separada por ";" del .gff.
# El primer awk filtra las filas donde la columna ($3) es = "gene". El segundo `awk` recorre cada elemento separado por ";" en la columna 9, buscan
# los que contienen "gene=", extrae su valor y lo imprime. El sed elimina el prefijo "gene=" y guarda solo el nombre del gen en el txt de salida.
awk -F'\t' '$3 == "gene"' genes_filtrados_${CROMOSOMA}.gff | awk -F';' '{for(i=1;i<=NF;i++){if($i ~ /gene=/){print $i}}}' | \
sed 's/gene=//' > ID_genes_${CROMOSOMA}.txt

# Fichero de coordenadas CSV con el nombre del gen, el cromosoma, las coordenadas de inicio y fin. El awk divide la columna 9 del .gff en subcampos separados por ";" y busca el que contiene "gene=".
# Extrae el nombre del gen y lo combina con ID cromosoma ($1), la coordenada de inicio ($4) y fin ($5). Se separan los atributos por comas para el .csv: "gen, cromosoma, inicio, fin".
awk -F'\t' '{split($9, atributos, ";"); for (indice in atributos) {if (atributos[indice] ~ /gene=/) {split(atributos[indice], gen_info, "="); print gen_info[2] "," $1 "," $4 "," $5}}}' \
genes_filtrados_${CROMOSOMA}.gff > coordenadas_${CROMOSOMA}.csv

# Filtra las anotaciones de GO de los genes seleccionados. grep busca anotaciones GO en todas las líneas que coincidan con los nombres de los genes extraídos.
# Se utiliza el fichero `ID_genes_${CROMOSOMA}.txt` como guia para buscar
zcat gene_ontology_D_subobscura.gaf.gz | grep -f ID_genes_${CROMOSOMA}.txt > anotaciones_${CROMOSOMA}.gaf

# .csv con anotaciones GO que contiene: nombre del gen, término GO y descripción.
# awk filtra y extrae las columnas 3 (nombre del gen), 5 (ID GO) y 9 (descripción GO) y separa con comas para el .csv
awk -F'\t' '{print $3 "," $5 "," $9}' anotaciones_${CROMOSOMA}.gaf > anotaciones_GO_${CROMOSOMA}.csv

# Merge de coordenadas y anotaciones GO. Se crea el fichero con todas las columnas. Se usa el nombre del gen como clave en coords
awk -F',' 'NR==FNR {coords[$1] = $0; next} $1 in coords {print coords[$1] "," $2 "," $3}' coordenadas_${CROMOSOMA}.csv anotaciones_GO_${CROMOSOMA}.csv > anotaciones_estudio_${CROMOSOMA}.csv

# Se ordena por cordenadas de inicio para luego usar el fichero en un análisis con R de los términos GO
sort -t',' -k3,3n anotaciones_estudio_${CROMOSOMA}.csv > anotaciones_estudio_coord_${CROMOSOMA}.csv

# Eliminar los ficheros intermedios usados para crear el .csv con los genes y terminos GO
rm -f cromosoma_${CROMOSOMA}.gff
rm -f genes_filtrados_${CROMOSOMA}.gff
rm -f ID_genes_${CROMOSOMA}.txt
rm -f coordenadas_${CROMOSOMA}.csv
rm -f anotaciones_${CROMOSOMA}.gaf
rm -f anotaciones_GO_${CROMOSOMA}.csv
rm -f anotaciones_estudio_${CROMOSOMA}.csv

echo "Primeras 10 lineas de las anotaciones GO ordenado por coordenadas de inicio:"
head -n 10 anotaciones_estudio_coord_${CROMOSOMA}.csv
