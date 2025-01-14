## Búsqueda de contigs: `busqueda_contigs_regiones_flanqueantes_puntos_rotura.sh`

### Descripción
- Se preparan las lecturas con usando `Samtools`
- Genera *contigs* en regiones flanqueantes de puntos de rotura mediante un ensamblaje *de novo* con `SPAdes`usando `Samtools` y `BLAST`.

### Uso
```bash
./busqueda_contigs_regiones_flanqueantes_puntos_rotura.sh ventanas_flanqueantes.txt \
OF58_mate_proc_dupmarc_bwamem2.bam Drosophila_subobscura_genoma_referencia.fa
```

### Requisitos
- Instalación de `Samtools` en https://anaconda.org/bioconda/samtools
- Instalación de `SPAdes` en https://anaconda.org/bioconda/spades
- Instalación de `BLAST` en https://anaconda.org/bioconda/blast

### Salida
- Contigs ensamblados.
- Resultados de alineamiento BLAST.

### Manuales y referencias
- Manual de `Samtools`: https://www.htslib.org/doc/samtools.html
- Manual de `SPAdes`: https://home.cc.umanitoba.ca/~psgendb/doc/spades/manual.html
- Manual de `BLAST`: [https://home.cc.umanitoba.ca/~psgendb/doc/spades/manual.html](https://www.animalgenome.org/bioinfo/resources/manuals/blast2.2.24/user_manual.pdf)
