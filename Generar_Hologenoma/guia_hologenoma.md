## Generación del hologenoma: `Generacion_Hologenoma_con_Dsub_TFM_NCBI.sh`

### Descripción
Este script genera un hologenoma concatenando genomas de distintas especies. También procesa el genoma de referencia de *Drosophila subobscura*.

### Requisitos y uso
El fichero está probado y genera los ficheros de salida en dos sistemas operativos:
- En un entorno **Windows** hacer dobleclic sobre el fichero - se inicia la ejecución y genera el hologenoma y procesa el genoma de referencia de *Drosophila subobscura*.
- En un entorno **Linux** ejecutar el script bash directamente desde la línea de comandos.
 ```bash
./Generacion_Hologenoma_con_Dsub_TFM_NCBI.sh
```
### Salida
- Fichero `multifasta` con el hologenoma y las cabeceras de los cromosomas editados.
- Genoma de *Drosophila subobscura* de referencia con la cabecera adaptada.
