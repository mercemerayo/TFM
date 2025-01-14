## Filtrado de genes y términos GO: `filtrar_genes_GO_D_subobscura.sh`

### Descripción
Filtra genes en una región específica del genoma de *Drosophila subobscura* en base al identificador del cromosoma y las coordenadas genómicas. Con esto genera un fichero con los identificadores de los genes, sus coordenadas genómicas y los términos GO.

### Uso
Se pasan como argumentos las coordenadas genómica de inicio y final de la región de interés y el identificador RefSeq del cromosoma de estudio.

```bash
./filtrar_genes_GO_D_subobscura.sh 7772887 14722269 NC_048534.1
```

### Requisitos
- Asegurar que desde la `bash` (linux) están disponibles los comandos `awk` y `sed`

### Salida
- Fichero CSV con genes filtrados y términos GO, ademas de las coordenadas genómicas y cromosoma de interés.

