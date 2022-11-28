#!/bin/bash


	 ################################################################################################################
        #                                                                                	                        #
        #   Script interconectado con el principal que obtiene rutas de Google Imagenes relacionadas con una persona    #
        #                                                                                         	                #
        #################################################################################################################

######################## Muestra URL de Google Imagenes que tienen relacion con la persona investigada ##########################



## Exporta variables ##
export nombre
export apellidos




## Funcion Python que obtiene la URL de google imagenes de la persona investigada ##
function rutaImagGoogle (){
python - <<START
import os
import requests
import urllib.parse

# Formato URL para buscar imagenes en Google: ‘https://www.google.com/search?hl=jp&q=' + urlKeyword + ‘&btnG=Google+Search&tbs=0&safe=off&tbm=isch’

# variable que tiene los apellidos sin espacio entre ellos
apellidosSinEspacio=os.environ['apellidosSinEspacio']

# Variable que tiene la consulta entera
buscar = "$nombre$apellidosSinEspacio"

# Se codifica en URLencode el nombre de la persona
buscarURLEncode=urllib.parse.quote(buscar)

# Calcula URL google imagenes que da de resultado buscar esa persona
url_imagen = "https://www.google.com/search?hl=jp&amp;q=" + buscarURLEncode + "&amp;btnG=Google+Search&amp;tbs=0&amp;safe=off&amp;tbm=isch"
print(url_imagen)


START
}




## Calcular variable con apellidos sin espacio entre ellos ##
apellidosSinEspacio=$(echo "$apellidos" | tr -d '[[:space:]]')


## Exporta variable ##
export apellidosSinEspacio



## Llama a la funcion que calcula la ruta ##
rutaImagenesGoogle=$(rutaImagGoogle)



## Escribe resultado en el fichero de resultados ##
echo -e "--------------------------------------------------------------------------------\n" >> $rutaFichero
echo -e "| URL Google Imagenes de la persona analizada: $nombre $apellidos              |\n" >> $rutaFichero
echo -e "--------------------------------------------------------------------------------\n" >> $rutaFichero

echo -e "$rutaImagenesGoogle\n\n" >> $rutaFichero





## Ventana que muestra los resultados ##
yad --title="FindTrack" --window-icon=images/icon.png \
                --width=500 --justify=left \
                --text="\n   RUTAS DE GOOGLE OBTENIDAS DE LA PERSONA: $nombre $apellidos \n---------------------------------------------------------------------------------\n\n<span color='#00a3e8'> ${rutaImagenesGoogle}</span>\n\n" \
		--button="Volver al menu:0" --button="Visualizar Fichero Resultados:1"



respuesta=$? # Variable que recoge lo que pulsa el usuario


if [ $respuesta -eq 1 ] # Si se elige visualizar el fichero de resultados
then
        xterm -geometry 200x100 -e "cat $rutaFichero; $SHELL" # Abre terminal y muestra el fichero
fi

