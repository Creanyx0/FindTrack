#!/bin/bash


	########################################################################################################
        #                                                                                                      #
        #    Script interconectado con el principal que obtiene el nick de una persona en redes sociales       #
        #                                                                                                      #
        ########################################################################################################

################## Muestra nicks de una persona en diferentes redes sociales que se encuentren suyas  ######################



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




## Obtiene el nick y URL de twitter ##
rutaT=$(cat $directorio/resultados/rutas.txt | grep 'https://twitter.com')
nickT=$(cat $directorio/resultados/rutas.txt | grep 'https://twitter.com' | cut -d '/' -f 4 | tail -1)




## Obtiene el nick y URL de Facebook ##
rutaF=$(cat $directorio/resultados/rutas.txt | grep 'facebook.com/')
nickF=$(cat $directorio/resultados/rutas.txt | grep 'facebook.com/' | cut -d '/' -f 4 | tail -1)




## Obtiene el nick y URL de Instagram ##
rutaI=$(cat $directorio/resultados/rutas.txt | grep 'instagram.com/')
nickI=$(cat $directorio/resultados/rutas.txt | grep 'instagram.com/' | cut -d '/' -f 4 | tail -1)



## Obtener el nick y URL de Linkedin ##
rutaL=$(cat $directorio/resultados/rutas.txt | grep 'linkedin.com/')
nickL=$(cat $directorio/resultados/rutas.txt | grep 'linkedin.com/' | cut -d '/' -f 5 | tail -1)



## Obtiene el nick y URL de Youtube ##
rutaY=$(cat $directorio/resultados/rutas.txt | grep 'youtube.com/')
nickY=$(cat $directorio/resultados/rutas.txt | grep 'youtube.com/' | cut -d '/' -f 5 | tail -1)



## Obtiene el nick y URL de GitHub ##
rutaG=$(cat $directorio/resultados/rutas.txt | grep 'github.com/')
nickG=$(cat $directorio/resultados/rutas.txt | grep 'github.com/' | cut -d '/' -f 4 | tail -1)




## Escribe en el fichero de resultados ##
echo -e "------------------------------------------------------------------------------------------------\n" >> $rutaFichero
echo -e "| USERNAMES OBTENIDOS DE LA PERSONA INVESTIGADA: $nombre $apellidos      \n" >> $rutaFichero
echo -e "------------------------------------------------------------------------------------------------\n" >> $rutaFichero


if [ -n "$nickT" ] # Si no esta vacio, lo escribe
then
	echo -e "Username Twitter: $nickT -> $rutaT \n" >> $rutaFichero
	existeT="lime" # Para mostrarlo en verde si existe
else
	nickT="No se encuentra"
	rutaT="X"
	existeT="red" # Si no existe lo muestra en rojo
fi



if [ -n "$nickF" ]
then
	echo -e "Username Facebook: $nickF -> $rutaF \n" >> $rutaFichero
	existeF="lime"
else
	nickF="No se encuentra"
	rutaF="X"
	existeF="red"
fi



if [ -n "$nickI" ]
then
	echo -e "Username Instagram: $nickI -> $rutaI \n" >> $rutaFichero
        existeI="lime"
else
	nickI="No se encuentra"
        rutaI="X"
        existeI="red"
fi



if [ -n "$nickL" ]
then
	echo -e "Username Linkedln: $nickL -> $rutaL \n" >> $rutaFichero
        existeL="lime"
else
	nickL="No se encuentra"
        rutaL="X"
        existeL="red"
fi




if [ -n "$nickY" ]
then
        echo -e "Username Youtube: $nickY -> $rutaY \n" >> $rutaFichero
        existeY="lime"
else
        nickY="No se encuentra"
        rutaY="X"
        existeY="red"
fi



if [ -n "$nickG" ]
then
        echo -e "Username Github: $nickG -> $rutaG \n" >> $rutaFichero
        existeG="lime"
else
        nickG="No se encuentra"
        rutaG="X"
        existeG="red"
fi




echo -e "\n\n" >> $rutaFichero


resultados="\n[Twitter]<span color='$existeT'>  $nickT </span>-> $rutaT \n\n[Facebook]<span color='$existeF'>  $nickF </span>-> $rutaF \n\n[Instagram]<span color='$existeI'>  $nickI </span>-> $rutaI \n\n[Linkedln]<span color='$existeL'>  $nickL </span>-> $rutaL \n\n[Youtube]<span color='$existeY'>  $nickY </span>-> $rutaY \n\n[Github]<span color='$existeG'>  $nickG </span>-> $rutaG \n\n"



## Ventana que muestra los resultados obtenidos ##
yad --title="FindTrack" --window-icon=images/icon.png --center \
    --width=500 --justify=left \
    --text="\n   USERNAMES OBTENIDOS DE LA PERSONA: $nombre $apellidos \n---------------------------------------------------------------------\n ${resultados}\n" \
    --button="Volver al menu:0" --button="Visualizar Fichero Resultados:1"



respuesta=$? # Variable que recoge lo que pulsa el usuario


if [ $respuesta -eq 1 ] # Si se elige visualizar el fichero de resultados
then
        xterm -geometry 200x100 -e "cat $rutaFichero; $SHELL" # Abre terminal y muestra el fichero
fi




## Borra el que solo contiene las rutas y deja el que tiene todos los resultados ##
`rm $directorio/resultados/rutas.txt`

