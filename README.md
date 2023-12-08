# compara-directorios
Comparar el contenido de dos directorios para confirmar si se hizo correctamente un respaldo.

## 'compara_directorios_multitarea.sh' por Luis Manuel Juárez - 22_mar_2020

Este script es muy útil para comparar el contenido de dos directorios que están
en DIFERENTES medios de almacenamiento.
Cuando los directorios a comparar están en el mismo medio de almacenamiento, se
recomienda usar el script 'compara_directorios_secuencial.sh' ya que es más
rápido accesar los archivos uno a la vez, que accesar dos o más al mismo tiempo.

Modo de empleo:
  compara_directorios_multitarea.sh "/RUTA/COMPLETA/AL/DIRECTORIO_1" "/RUTA/COMPLETA/AL/DIRECTORIO_2"

NOTA: Las rutas completas a los directorios deben estar entre comillas.

