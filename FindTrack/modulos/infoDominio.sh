#!/bin/bash


 	##############################################################################################
        #                                                                                            #
        #   Script interconectado con el principal que obtiene correos electronicos de un dominio    #
        #                                                                                            #
        ##############################################################################################

################## Muestra correos electronicos de peronas del dominio analizado #############################



## Exporta variable ##
export dominio



## Crea carpeta (o comprueba que esta creada) para almacenar los resultados ##
mkdir $directorio/resultados



## Obtiene ruta donde esta el programa (es lo que contiene la variable directorio) ##
ruta="$(pwd)"


## Construye la ruta donde almacena los resultados ##
rutaResultados="$ruta/resultados"


## Obtiene info y correos de un dominio ##
(infoDominio="$(theHarvester -d $dominio -l 200 -b all -f $rutaResultados/infoDominio)" | yad --progress --title="FindTrack" --window-icon=images/icon.png \
                                               --progress-text="Calculando..." \
                                                --center \
                                                --width=300 \
                                                --height=100 \
                                                 --auto-kill \
                                                --auto-close )





## Extrae los correos del fichero XML que obtiene theHarvester ##
emails=$(xmllint --xpath '//theHarvester/email/text()' $rutaResultados/infoDominio.xml)




## Escribe resultados en el fichero de resultados ##
echo -e "---------------------------------------------------\n" >> $rutaFichero
echo -e "| EMAILS OBTENIDOS DEL DOMINIO: $dominio          |\n" >> $rutaFichero
echo -e "---------------------------------------------------\n" >> $rutaFichero

echo -e "$emails\n\n" >> $rutaFichero




## Ventana que muestra los correos que ha obtenido ##
yad --title="FindTrack" --window-icon=images/icon.png \
    --width=500 --height=300 --justify=left \
    --text="\n CORREOS OBTENIDOS DEL DOMINIO/ORGANIZACION: $dominio\n--------------------------------------------------------------------------\n\n${emails}" \
    --button="Volver al menu:0" --button="Visualizar Fichero Resultados:1"



respuesta=$? # Variable que recoge lo que pulsa el usuario


if [ $respuesta -eq 1 ] # Si se elige visualizar el fichero de resultados
then
        xterm -geometry 200x100 -e "cat $rutaFichero; $SHELL" # Abre terminal y muestra el fichero
fi



