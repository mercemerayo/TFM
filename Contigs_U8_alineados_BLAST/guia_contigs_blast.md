## Búsqueda de contigs: `busqueda_contigs_regiones_flanqueantes_puntos_rotura_U.sh`

### Descripción
Este *script* está adaptado para encontrar los *contigs* de las regiones flanqueantes de los puntos de rotura compatibles con la inversión cromosómica $U_8$.
- Se preparan las lecturas usando `Samtools`
- Genera *contigs* en regiones flanqueantes de puntos de rotura mediante un ensamblaje *de novo* con `SPAdes`
- Se alinean los *contigs* al genoma de referencia con `BLAST`.

### Uso

Se pasan como argumentos:
- Un fichero tabulado con los nombres de la ventana y carpetas de salida ademas de las coordenadas de inicio y fin de los puntos de rotura proximal y distal, del tipo:
```bash
ven_1	ensamblaje_ven_1	7772887	7778000	14722000	14727000
```
- El fichero .bam de la lecturas de la cepa OF58 mapeadas y procesadas.
- El genoma de referencia en formato fasta 
```bash
./busqueda_contigs_regiones_flanqueantes_puntos_rotura.sh ventanas_flanqueantes.txt \
OF58_mate_proc_dupmarc_bwamem2.bam Drosophila_subobscura_genoma_referencia.fa
```

### Requisitos
- Instalación de `Samtools` en https://anaconda.org/bioconda/samtools
- Instalación de `SPAdes` en https://anaconda.org/bioconda/spades
- Instalación de `BLAST` en https://anaconda.org/bioconda/blast

### Salida
- Contigs ensamblados en las regiones flanqueantes de los .
- Resultados de alineamiento BLAST.

### Manuales y referencias
- Manual de `Samtools`: https://www.htslib.org/doc/samtools.html
- Manual de `SPAdes`: https://home.cc.umanitoba.ca/~psgendb/doc/spades/manual.html
- Manual de `BLAST`: [https://home.cc.umanitoba.ca/~psgendb/doc/spades/manual.html](https://www.animalgenome.org/bioinfo/resources/manuals/blast2.2.24/user_manual.pdf)
