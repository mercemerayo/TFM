## Control de calidad y preprocesado: `fastp`

### Descripción
Este *script* utiliza la herramienta `fastp` para realizar control de calidad y preprocesar lecturas Illumina.

### Requisitos
Instalación desde [https://anaconda.org/bioconda/fastp].

### Uso 
Ejecutar el script bash directamente desde la línea de comandos.
```bash
./fastp_ctrl_calidad_limpiar_OF58.sh
```
### Salida
- Ficheros FASTQ limpios.
- Informe HTML con los resultados de calidad anteriores y posteriores al procesado.

### Manuales y referencias
Manual de `fastp` en https://github.com/OpenGene/fastp
