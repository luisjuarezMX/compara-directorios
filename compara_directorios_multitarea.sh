#!/bin/bash
# Script para comparar los archivos de dos directorios incluyendo archivos de subdirectorios.
# Para su funcionamiento, este script requiere de dos scripts adicionales:
#   - /usr/local/bin/proceso1_compara_directorios.sh
#   - /usr/local/bin/proceso2_compara_directorios.sh
# Luis Manuel Juarez <http://espaciolmx.ddns.net>
# Mexico - 22/mar/2020

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
EJECUTABLE="compara_directorios_multitarea.sh"
EJECUTABLE_SECUENCIAL="compara_directorios_secuencial.sh"
FECHA_CREACION="22_mar_2020"
AUTOR="Luis Manuel Juárez"

echo "'$EJECUTABLE' por $AUTOR - $FECHA_CREACION"
echo ""
echo "Este script es muy útil para comparar el contenido de dos directorios que están"
echo "en DIFERENTES medios de almacenamiento."
echo "Cuando los directorios a comparar están en el mismo medio de almacenamiento, se"
echo "recomienda usar el script '$EJECUTABLE_SECUENCIAL' ya que es más"
echo "rápido accesar los archivos uno a la vez, que accesar dos o más al mismo tiempo."
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

# Pregunta si se deben eliminar los archivos de trabajo y 'bandera'.
echo ""
echo "Este script generará dos archivos de trabajo con el"
echo "hash MD5 (md5sum) de cada archivo de cada directorio:"
echo "  - 'dir1.txt' para el primer directorio."
echo "  - 'dir2.txt' para el segundo directorio."
echo "También generará dos archivos 'bandera' que son utilizados"
echo "para saber cuándo termina cada proceso:"
echo "  - 'proceso1_terminado.OK' para el primer directorio."
echo "  - 'proceso2_terminado.OK' para el segundo directorio."
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

echo "Procesando simultáneamente ambos directorios..."
echo "-----------------------------------------------"
echo "Hora de inicio:      "$(date)
echo ""
TIMESTAMP1=$(date --utc +%s)

# Borra los archivos 'bandera' que sirven para saber cuando terminan los procesos.
# Cuando se genera un archivo 'bandera', significa que el proceso asociado a el ha terminado.
rm -f proceso1_terminado.OK proceso2_terminado.OK

# Proceso para generar los hash MD5 del primer directorio.
echo "Procesando primer directorio..."
# El simbolo "&" al final del comando, es un operador de control que sirve para indicarle
# al shell (interprete de comandos) que ejecute el comando en segundo plano en un subshell.
# De esta manera, el shell no espera a que el comando termine y el control del programa
# pasara al comando que sigue.
# Muy util para procesos multitarea.
/usr/local/bin/proceso1_compara_directorios.sh "$1" &

# Proceso para generar los hash MD5 del segundo directorio.
echo "Procesando segundo directorio..."
# El simbolo "&" al final del comando, es un operador de control que sirve para indicarle
# al shell (interprete de comandos) que ejecute el comando en segundo plano en un subshell.
# De esta manera, el shell no espera a que el comando termine y el control del programa
# pasara al comando que sigue.
# Muy util para procesos multitarea.
/usr/local/bin/proceso2_compara_directorios.sh "$2" &

# El comando "until" evalua la condicion antes de ejecutar los comandos dentro de "do-done",
# si la condicion es verdadera, NO EJECUTA LOS COMANDOS, el ciclo sera terminado y el control
# del programa sera pasado al comando que sigue.
# Si la condicion es falsa, EJECUTA LOS COMANDOS indefinidamente hasta que la condicion sea
# verdadera.
until [ -f "proceso1_terminado.OK" -a -f "proceso2_terminado.OK" ]
    do
        # No se hace nada hasta que la condicion sea verdadera y termine el ciclo.
        sleep 0
    done

# Retraso de 0.5 segundos para permitir que los scritps 'proceso1_compara_directorios.sh' y
# 'proceso2_compara_directorios.sh' muestren correctamente sus mensajes.
sleep 0.5
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
        rm dir1.txt dir2.txt proceso1_terminado.OK proceso2_terminado.OK
        echo "Los archivos de trabajo y 'bandera' fueron borrados."
    else
        echo "Los archivos de trabajo 'dir1.txt' y 'dir2.txt' NO fueron borrados."
        echo "Los archivos bandera 'proceso1_terminado.OK' y 'proceso2_terminado.OK'"
        echo "NO fueron borrados."
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
