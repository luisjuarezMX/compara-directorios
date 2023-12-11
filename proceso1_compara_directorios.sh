#!/bin/bash
# Script para calcular el hash MD5 (md5sum) de cada archivo del directorio pasado como parametro.
# Como resultado, generara el archivo 'dir1.txt' con los hash MD5 de cada archivo.
# Este script es una subrutina del script 'compara_directorios_multitarea.sh'.
# Luis Manuel Juarez <http://espaciolmx.ddns.net>
# Mexico - 22/mar/2020

# echo "Proceso 1 .................."
find "$1" -type f -exec md5sum {} + | sort -k 2 | sed 's/ .*\// /' > dir1.txt
touch proceso1_terminado.OK
echo "Terminado el procesamiento del primer directorio..."
