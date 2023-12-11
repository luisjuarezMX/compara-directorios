#!/bin/bash
# Script para comparar los archivos de dos directorios incluyendo archivos de subdirectorios.
# Luis Manuel Juarez <http://espaciolmx.ddns.net>
# Mexico - 23/nov/2019

# Para la comparacion de archivos, se calculan los hash MD5 y luegos se comparan.
# Para el calculo de los tiempos de procesamiento, se utilizan los Timestamps de Linux.

# Las Linux Timestamps son los segundos que han pasado desde
# "01/01/1970 00:00:00" Tiempo Universal Coordinado (UTC)
# Antes de esa fecha, los Timestamps serán negativos.

# El Formato es AAAA-MM-DD HH:MM:SS (Anio-Mes-Dia Hora:Minutos:Segundos)
# Se recomienda agregar la opcion '--utc' al comando 'date' de la siguiente manera:
# 'date --utc --date="2009-02-03 12:20:30" +%s' para usar horas UTC y asi evitar
# errores de calculo provocados por los cambios de horario que existen en horarios locales.
#
# Por ejemplo, para calcular el tiempo que tarda en ejecutarse un proceso, en primer lugar
# se calcula y almacena en una variable el Timestamp justo ANTES de iniciar el proceso,
# luego, se calcula y almacena en otra variable el Timestamp justo DESPUES de finalizar el
# proceso, luego con una resta obtenemos los segundos transcurridos; si durante el tiempo
# que se estuvo ejecutando el proceso cambia el horario de verano a invierno o viceversa, al
# hacer los calculos usando horarios locales, existiria un error de 1 hora de mas o de menos.


# Nombre que tiene el Script
EJECUTABLE="compara_directorios_secuencial.sh"
EJECUTABLE_MULTITAREA="compara_directorios_multitarea.sh"
FECHA_CREACION="23_nov_2019"
AUTOR="Luis Manuel Juárez"

echo "'$EJECUTABLE' por $AUTOR - $FECHA_CREACION"
echo ""
echo "Este script es muy útil para comparar el contenido de dos directorios que están"
echo "en el MISMO medio de almacenamiento."
echo "Cuando los directorios a comparar están en medios de almacenamiento distintos,"
echo "se recomienda usar el script '$EJECUTABLE_MULTITAREA' ya que es"
echo "mucho más rápido."
echo ""

# Validacion para que solamente sean comparados 2 directorios.
if [ $# -lt 2 ]
    then
        if [ $# -eq 0 ]
            then
                echo "ERROR: NO SE PASARON DIRECTORIOS."
                echo "       Deben pasarse 2 directorios."
                echo ""
                echo "Modo de empleo:"
                echo "  $EJECUTABLE \"/RUTA/COMPLETA/AL/DIRECTORIO_1\" \"/RUTA/COMPLETA/AL/DIRECTORIO_2\""
                echo ""
                echo "NOTA: Las rutas completas a los directorios deben estar entre comillas."

                exit
        fi

        if [ $# -eq 1 ]
            then
                if [ -z "$1" -o "$1" == " " -o "$1" == "  " -o "$1" == "   " -o "$1" == "    " -o "$1" == "     " -o "$1" == "      " ]
                    then
                        echo "ERROR: SOLAMENTE SE PASÓ UN DIRECTORIO NULO."
                        echo "       Deben pasarse 2 directorios válidos."
                        echo ""
                        echo "Modo de empleo:"
                        echo "  $EJECUTABLE \"/RUTA/COMPLETA/AL/DIRECTORIO_1\" \"/RUTA/COMPLETA/AL/DIRECTORIO_2\""
                        echo ""
                        echo "NOTA: Las rutas completas a los directorios deben estar entre comillas."

                        exit
                fi
                if [ $1 == "--help" -o $1 == "-help" -o $1 == "help" ]
                    then
                        echo "Modo de empleo:"
                        echo "  $EJECUTABLE \"/RUTA/COMPLETA/AL/DIRECTORIO_1\" \"/RUTA/COMPLETA/AL/DIRECTORIO_2\""
                        echo ""
                        echo "NOTA: Las rutas completas a los directorios deben estar entre comillas."

                        exit
                    else
                        echo "ERROR: FALTA 1 directorio para comparar."
                        echo "       Deben pasarse 2 directorios."
                        echo ""
                        echo "Modo de empleo:"
                        echo "  $EJECUTABLE \"/RUTA/COMPLETA/AL/DIRECTORIO_1\" \"/RUTA/COMPLETA/AL/DIRECTORIO_2\""
                        echo ""
                        echo "NOTA: Las rutas completas a los directorios deben estar entre comillas."

                        exit
                fi
        fi
fi

if [ $# -gt 2 ]
    then
        echo "ERROR: SOBRAN directorios para comparar."
        echo "       Solamente deben pasarse 2 directorios y usted pasó $# directorios."
        echo ""
        echo "Modo de empleo:"
        echo "  $EJECUTABLE \"/RUTA/COMPLETA/AL/DIRECTORIO_1\" \"/RUTA/COMPLETA/AL/DIRECTORIO_2\""
        echo ""
        echo "NOTA: Las rutas completas a los directorios deben estar entre comillas."

        exit
fi

# Validar si existen los directorios a comparar
salir=0
if [ -d "$1" ]
    then
        echo "Primer directorio OK."
    else
        echo "ERROR: El primer directorio NO EXISTE."
        salir=1
fi
if [ -d "$2" ]
    then
        echo "Segundo directorio OK."
    else
        echo "ERROR: El segundo directorio NO EXISTE."
        salir=1
fi
if [ $salir -eq 1 ]
    then
        exit
fi

# Pregunta si se deben eliminar los archivos de trabajo.
echo ""
echo "Este script generará dos archivos de trabajo con el"
echo "hash MD5 (md5sum) de cada archivo de cada directorio:"
echo "  - 'dir1.txt' para el primer directorio."
echo "  - 'dir2.txt' para el segundo directorio."
echo ""
pregunta="S"
read -p "¿Desea borrarlos? [S/n]: " pregunta
# Validacion para que le sea asignado el string "S" a la variable "pregunta"
# en caso de que solamente sea presionada la tecla <ENTER> sin haber ingresado
# algun valor. Cuando NO se ingresa algun valor y se presiona la tecla <ENTER>,
# el valor NULL es asignado a la variable.
if [ -z "$pregunta" ]
    then
        pregunta="S"
fi

# Validacion para solamente aceptar como respuestas validas los caracteres "S", "s", "N" y "n".
while [ "$pregunta" != "S" -a "$pregunta" != "s" -a "$pregunta" != "N" -a "$pregunta" != "n" ]
    do
        read -p "Respuesta inválida. ¿Desea borrarlos? [S/n]: " pregunta
        # Validacion para que le sea asignado el string "S" a la variable "pregunta"
        # en caso de que solamente sea presionada la tecla <ENTER> sin haber ingresado
        # algun valor. Cuando NO se ingresa algun valor y se presiona la tecla <ENTER>,
        # el valor NULL es asignado a la variable.
        if [ -z "$pregunta" ]
            then
                pregunta="S"
        fi
    done

echo ""
echo "..."
echo ""

echo "Generando los hash MD5 de cada archivo de cada directorio..."
echo "Dependiendo de la cantidad de archivos, sus tamaños,"
echo "la velocidad de lectura de los dispositivos de almacenamiento"
echo "y la velocidad de la computadora, el proceso puede demorar"
echo "bastante tiempo."
echo "Para comprobar que el proceso se está ejecutando, puede"
echo "revisar el LED de actividad de los dispositivos de almacenamiento."
echo "¡POR FAVOR, SEA PACIENTE!"
echo ""

# Proceso para generar los hash MD5 del primer directorio.
echo "Procesando primer directorio..."
echo "-------------------------------"
echo "Hora de inicio:      "$(date)
TIMESTAMP1=$(date --utc +%s)
find "$1" -type f -exec md5sum {} + | sort -k 2 | sed 's/ .*\// /' > dir1.txt
TIMESTAMP2=$(date --utc +%s)
echo "Hora de terminación: "$(date)
# Calculo de Segundos transcurridos
SEGUNDOSTRANSCURRIDOS=$(echo "$TIMESTAMP2 - $TIMESTAMP1" | bc)
# Calculo de Minutos transcurridos. 'scale=2' indica que se hara el calculo con 2 decimales,
# '-l' activa la libreria matematica de 'bc' que incluye funciones y calculos con decimales.
MINUTOSTRANSCURRIDOS=$(echo "scale=2; $SEGUNDOSTRANSCURRIDOS/60" | bc -l )
echo "Tiempo en procesar el primer directorio: $SEGUNDOSTRANSCURRIDOS segundo(s) o"
echo "                                         $MINUTOSTRANSCURRIDOS minuto(s)."

# Proceso para generar los hash MD5 del segundo directorio.
echo "Procesando segundo directorio..."
echo "--------------------------------"
echo "Hora de inicio:      "$(date)
TIMESTAMP2=$(date --utc +%s)
find "$2" -type f -exec md5sum {} + | sort -k 2 | sed 's/ .*\// /' > dir2.txt
TIMESTAMP3=$(date --utc +%s)
echo "Hora de terminación: "$(date)
# Calculo de Segundos transcurridos
SEGUNDOSTRANSCURRIDOS=$(echo "$TIMESTAMP3 - $TIMESTAMP2" | bc)
# Calculo de Minutos transcurridos. 'scale=2' indica que se hara el calculo con 2 decimales,
# '-l' activa la libreria matematica de 'bc' que incluye funciones y calculos con decimales.
MINUTOSTRANSCURRIDOS=$(echo "scale=2; $SEGUNDOSTRANSCURRIDOS/60" | bc -l )
echo "Tiempo en procesar el segundo directorio: $SEGUNDOSTRANSCURRIDOS segundo(s) o"
echo "                                          $MINUTOSTRANSCURRIDOS minuto(s)."
echo ""

# Comparacion de los hash MD5 del primer directorio VS. el segundo directorio.
# NOTA: NO DEBE EJECUTARSE NINGUN COMANDO ENTRE LOS COMANDOS 'diff dir1.txt dir2.txt' Y 'if [ $? -eq 0 ]'
diff dir1.txt dir2.txt

if [ $? -eq 0 ]
    then
        echo "******************************************************"
        echo "** OK: AMBOS DIRECTORIOS TIENEN LOS MISMOS ARCHIVOS **"
        echo "******************************************************"
    else
        echo "****************************************************************"
        echo "** EXISTEN UNO O MÁS ARCHIVOS DIFERENTES EN AMBOS DIRECTORIOS **"
        echo "****************************************************************"
fi

echo ""
if [ "$pregunta" == "S" -o "$pregunta" == "s" ]
    then
        rm dir1.txt dir2.txt
        echo "Los archivos de trabajo fueron borrados."
    else
        echo "Los archivos de trabajo 'dir1.txt' y 'dir2.txt' NO fueron borrados."
        echo "Recuerde eliminarlos manualmente después que haya terminado de usarlos."
fi

TIMESTAMP4=$(date --utc +%s)
# Calculo de Segundos transcurridos
SEGUNDOSTRANSCURRIDOS=$(echo "$TIMESTAMP4 - $TIMESTAMP1" | bc)
# Calculo de Minutos transcurridos. 'scale=2' indica que se hara el calculo con 2 decimales,
# '-l' activa la libreria matematica de 'bc' que incluye funciones y calculos con decimales.
MINUTOSTRANSCURRIDOS=$(echo "scale=2; $SEGUNDOSTRANSCURRIDOS/60" | bc -l )
echo ""
echo "------------------------------------------------------"
echo "Tiempo total en todo el proceso: $SEGUNDOSTRANSCURRIDOS segundo(s) o"
echo "                                 $MINUTOSTRANSCURRIDOS minuto(s)."
echo "------------------------------------------------------"
