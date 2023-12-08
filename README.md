# compara-directorios
Scripts de linux para comparar el contenido de dos directorios con el objetivo de:
  - confirmar si se hizo correctamente un respaldo.
  - verificar el contenido y mostrar los archivos diferentes.


## 'compara_directorios_multitarea.sh' por Luis Manuel Juárez - 22_mar_2020

Este script es muy útil para comparar el contenido de dos directorios que están
en DIFERENTES medios de almacenamiento.
Cuando los directorios a comparar están en el mismo medio de almacenamiento, se
recomienda usar el script 'compara_directorios_secuencial.sh' ya que es más
rápido accesar los archivos uno a la vez, que accesar dos o más al mismo tiempo.

Modo de empleo:
  compara_directorios_multitarea.sh "/RUTA/COMPLETA/AL/DIRECTORIO_1" "/RUTA/COMPLETA/AL/DIRECTORIO_2"

NOTA: Las rutas completas a los directorios deben estar entre comillas.


## 'compara_directorios_secuencial.sh' por Luis Manuel Juárez - 23_nov_2019

Este script es muy útil para comparar el contenido de dos directorios que están
en el MISMO medio de almacenamiento.
Cuando los directorios a comparar están en medios de almacenamiento distintos,
se recomienda usar el script 'compara_directorios_multitarea.sh' ya que es
mucho más rápido.

Modo de empleo:
  compara_directorios_secuencial.sh "/RUTA/COMPLETA/AL/DIRECTORIO_1" "/RUTA/COMPLETA/AL/DIRECTORIO_2"

NOTA: Las rutas completas a los directorios deben estar entre comillas.
