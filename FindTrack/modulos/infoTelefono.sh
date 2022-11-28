#!/bin/bash


        ################################################################################################################
        #                                                                                                               #
        #   Script interconectado con el principal que obtiene informacion sobre un numero de telefono movil dado       #
        #                                                                                                               #
        #################################################################################################################

######################## Muestra informacion sobre el telefono (si existe, localizacion, zona horaria, etc.) ##########################



## Exporta la variable ##
export telefono


## Funcion Python que obtiene info de un numero de telefono ##
function infoTelefono {
python - <<START
import os
import phonenumbers
from phonenumbers import geocoder, carrier, timezone


# Se convierte al formato
formato = phonenumbers.parse(os.environ['telefono'])
print(formato)


print ("\nTeléfono consultado: ", os.environ['telefono'])


# Valida si existe
valid = str(phonenumbers.is_valid_number(formato))



if (valid == 'False'): # Si no es valido el telefono consultado, mensaje indicandolo
        print ("\nExiste: NO \n")

else: # Si existe, se indica tambien y se comienza con la obtencion de informacion

        print ("\nExiste: SI \n")

        # Ubicacion
        ubicacion = geocoder.description_for_number(formato,"es") # Muestra ubicacion en formato espaniol
        print("Ubicación del telefono: " + ubicacion + "\n")

        # Compania original del terminal
        formatoC = phonenumbers.parse(os.environ['telefono'], "RO")
        compania = carrier.name_for_number(formatoC, "es")
        print("Compania: " + compania + "\n")

        # Zona horaria
        formatoZ = phonenumbers.parse(os.environ['telefono'], "GB")
        timeZone = str(timezone.time_zones_for_number(formatoZ))
        print("Zona horaria: " + timeZone)

START
}




## Llamada a la funcion ##
infoTelefono


## Obtencion de la salida de la funcion ##
result=$(infoTelefono)




## Escribe resultados en el fichero de resultados ##
echo -e "------------------------------------------------------------------\n" >> $rutaFichero
echo -e "| INFORMACION DEL TELEFONO CONSULTADO: $telefono                |\n" >> $rutaFichero
echo -e "------------------------------------------------------------------\n" >> $rutaFichero

echo -e "$result\n\n" >> $rutaFichero





## Ventana con resultados ##
yad --title="FindTrack" --window-icon=images/icon.png --center \
                --width=500 --heigth=300 --justify=left \
                --text="\n  INFORMACION DEL TELEFONO INVESTIGADO:   $telefono \n -------------------------------------------------------------------------- \n\n${result}\n" \
		--button="Volver al menu:0" --button="Visualizar Fichero Resultados:1"



respuesta=$? # Variable que recoge lo que pulsa el usuario


if [ $respuesta -eq 1 ] # Si se elige visualizar el fichero de resultados
then
        xterm -geometry 200x100 -e "cat $rutaFichero; $SHELL" # Abre terminal y muestra el fichero
fi

