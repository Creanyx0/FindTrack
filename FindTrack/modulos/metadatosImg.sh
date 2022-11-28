#!/bin/bash


	##############################################################################################
        #                                                                                            #
        #       Script interconectado con el principal que obtiene metadatos de una imagen           #
        #                                                                                            #
        ##############################################################################################

################## Muestra metadatos de una imagen seleccionada (jpg o png) ################################




## Exporta variable (contiene ruta de la imagen seleccionada) ##
export archivo



## Funcion en Python que obtiene metadatos de la imagen seleccionada ##
function metadatos {
python - <<START
import os
import json
import requests

from PIL import Image
from PIL.ExifTags import TAGS


image = Image.open("$archivo")

exifdata = image.getexif()


for tagid in exifdata:

    tagname = TAGS.get(tagid, tagid)

    value = exifdata.get(tagid)

    print(f"{tagname:25}:	{value}")

START
}



## Llamada a la funcion ##
(metadatos | yad --progress --title="FindTrack" --window-icon=images/icon.png \
                                                --progress-text="Calculando..." \
                                                --center \
                                                --width=300 \
                                                --height=100 \
                                                --auto-kill \
                                                --auto-close )





## Obtiene la salida de la funcion ##
metadatosImg=$(metadatos)




## Escribe resultados en el fichero de resultados ##
echo -e "-------------------------------------------------------------------------------------------------------------\n" >> $rutaFichero
echo -e "| METADATOS OBTENIDOS DEL FICHERO: $archivo                                                                 \n" >> $rutaFichero
echo -e "-------------------------------------------------------------------------------------------------------------\n" >> $rutaFichero

echo -e "$metadatosImg\n\n" >> $rutaFichero




# Ventana que muestra esta informacion obtenida ##
yad --title="FindTrack" --window-icon=images/icon.png \
    --width=700 --height=400 --justify=left \
    --text="\n  METADATOS OBTENIDOS DE LA IMAGEN: $archivo\n------------------------------------------------------------------------------------------------------------------\n\n ${metadatosImg} \n" \
    --button="Volver al menu:0" --button="Visualizar Fichero Resultados:1"



respuesta=$? # Variable que recoge lo que pulsa el usuario


if [ $respuesta -eq 1 ] # Si se elige visualizar el fichero de resultados
then
        xterm -geometry 200x100 -e "cat $rutaFichero; $SHELL" # Abre terminal y muestra el fichero
fi

