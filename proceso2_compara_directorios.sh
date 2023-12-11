#!/bin/bash
# Script para calcular el hash MD5 (md5sum) de cada archivo del directorio pasado como parametro.
# Como resultado, generara el archivo 'dir2.txt' con los hash MD5 de cada archivo.
# Este script es una subrutina del script 'compara_directorios_multitarea.sh'.
# Luis Manuel Juarez <http://espaciolmx.ddns.net>
# Mexico - 22/mar/2020

# echo "Proceso 2 .................."
find "$1" -type f -exec md5sum {} + | sort -k 2 | sed 's/ .*\// /' > dir2.txt
touch proceso2_terminado.OK
echo "Terminado el procesamiento del segundo directorio..."
