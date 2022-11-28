#!/bin/bash

        ########################################################################################################
        #                                                                                                      #
        #   Script interconectado con el principal que obtiene rutas de Google relacionadas con una persona    #
        #                                                                                                      #
        ########################################################################################################

######################## Muestra URLs de Google que tienen relacion con la persona investigada ##########################



## Exporta variables ##
export nombre
export apellidos





## Funcion Python que obtiene rutas de google relacionadas con dicha persona ##
function obtenerRutasGoogle {

python - <<START
import os
import requests


# Importar la libreria y funcion de busqueda
from googlesearch import search


# Variable que almacena los apellidos sin espacio entre ellos
apellidosSinEspacio=os.environ['apellidosSinEspacio']


# Variable que contiene el paramentro o consulta de busqueda (nombre y apellidos todo junto sin espacios)
q = "$nombre$apellidosSinEspacio"

# Ejecuta la busqueda con la funcion search y pasa como parametro la consulta
results = search(q)


# Crea fichero con los resultados recorriendo el generator anterior
with open('$directorio/resultados/rutas.txt', 'w') as f:
    for r in results:
        f.write(str(r) + "\n\n")


START
}





## Crea variable que almacena los apellidos sin espacios entre ellos ##
apellidosSinEspacio=$(echo "$apellidos" | tr -d '[[:space:]]')



## Exporta variable ##
export apellidosSinEspacio




## Escribe encabezado en el fichero ##
echo -e "RUTAS DE GOOGLE OBTENIDAS DE LA PERSONA: $nombre $apellidos \n" >> $directorio/resultados/rutas.txt





## Llama a funcion que obtiene rutas de Google relacionadas con esa  persona ##
## y muestra ventana de progreso que finaliza cuando termina ejecucion       ##
((rutas=$(obtenerRutasGoogle)) | yad --progress --title="FindTrack" --window-icon=images/icon.png \
                                                --progress-text="Calculando..." \
                                                --center \
                                                --width=300 \
                                                --height=100 \
	                                        --auto-kill \
                                                --auto-close )



## Variable que tiene ruta del fichero que se a creado ##
directorioFichero="$directorio/resultados/rutas.txt"



## Elimina lineas del fichero que tengan & para poder mostrarlo con yad ##
sed -i '/&/d' $directorio/resultados/rutas.txt




## Escribe en el fichero de resultados ##
echo -e "------------------------------------------------------------------------------------------------------------------\n" >> $rutaFichero
echo -e "| RUTAS DE GOOGLE OBTENIDAS CON RELACIONA A LA PERSONA INVESTIGADA: $nombre $apellidos                            |\n" >> $rutaFichero
echo -e "------------------------------------------------------------------------------------------------------------------\n" >> $rutaFichero


# Copia lo del fichero rutas al fichero que contiene todos los resultados ##
`cat $directorio/resultados/rutas.txt >> $rutaFichero`




## Ventana que muestra los resultados obtenidos (con scroll) ##
ans=$(zenity --text-info \
    --title="FindTrack" --window-icon=images/icon.png \
    --width=700 --height=800 \
    --filename=$directorioFichero \
    --ok-label="Volver al menu" \
    --cancel-label="Salir" \
    --extra-button="Visualizar Fichero Resultados" )


respuesta=$? # Variable que recoge lo que pulsa el usuario

#echo $ans valor del boton


if [[ $ans = "Visualizar Fichero Resultados" ]]
then
        xterm -geometry 200x100 -e "cat $rutaFichero; $SHELL" # Abre terminal y muestra el fichero

elif [[ $ans = "Salir" ]]
then
	exit 0
fi






## Borra el que solo contiene las rutas y deja el que tiene todos los resultados ##
`rm $directorio/resultados/rutas.txt`
