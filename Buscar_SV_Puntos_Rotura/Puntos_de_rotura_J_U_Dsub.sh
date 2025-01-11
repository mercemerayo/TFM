#!/bin/bash

# Detectar SV y puntos de rotura con Breakdancer siguiendo la misma estrategia que en el TFM de Delgado
# Se guardan los ficheros txt generados en una carpeta aparte para mejorar la visibilidad de los resultados

mkdir Puntos_rotura/

echo "Generando archivo de configuración para Breakdancer..."
bam2cfg.pl -g -h OF58_mate_proc_dupmarc_bwamem2.bam > Puntos_rotura/OF58_puntos_rotura_bwamem2.cfg

echo "Detectando puntos de rotura en el cromosoma J"
breakdancer-max -o Drosophila_subobscura_NC_048532.1 Puntos_rotura/OF58_puntos_rotura_bwamem2.cfg > Puntos_rotura/OF58_breakpoints_bwamem2_J.txt

echo "Detectando puntos de rotura en el cromosoma U"
breakdancer-max -o Drosophila_subobscura_NC_048534.1 Puntos_rotura/OF58_puntos_rotura_bwamem2.cfg > Puntos_rotura/OF58_breakpoints_bwamem2_U.txt

