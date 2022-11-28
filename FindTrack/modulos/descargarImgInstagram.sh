#!/bin/bash


        #######################################################################################################
        #                                                                                            	      #
        #   Script interconectado con el principal que descarga las fotografias de una cuenta de Instagram    #
        #                                                                                                     #
        #######################################################################################################

############################# Descarga imagenes de una cuenta de Instagram ##############################################

# Tambien obtiene su ID y mas info de su perfil
# No utilizar muchas veces seguidas, Instagram lo bloquea


## Exporta variable ##
export username



## Escribe en fichero ##
echo -e "----------------------------------------------------------------------------\n" >> $rutaFichero
echo -e "| DESCARGA DE IMAGENES DE INSTAGRAM DE LA CUENTA: $username\n              |" >> $rutaFichero
echo -e "----------------------------------------------------------------------------\n" >> $rutaFichero




## Comprueba si tiene instagram ##
instagram=$(curl -v https://www.instagram.com/${username}/ 2>&1 | grep user?username)




if [ -z "$instagram" ] # Si lo que devuelve el comando anterior es vacio, no tiene cuenta
then
        existeI="red" # Para mostrar el texto en rojo
	mensaje="\nEl usuario consultado no tiene Instagram"
        echo -e "\n[Instagram] -> No existe esta cuenta\n" >> $rutaFichero

else # Si devuelve info, tiene cuenta
        existeI="lime" # Para mostrar el texto en verde
	mensaje="\nEl usuario consultado si tiene Instagram y se intentan descargar sus imagenes"
        echo -e "\n[Instagram] https://www.instagram.com/${username}/ \n" >> $rutaFichero # Escribe en el fichero de resultados

        `instaloader profile $username` # Descarga las fotos y videos del perfil de instagram
fi






## Ventana que muestra si existe o no el usuario consultado ##
yad --title="FindTrack" --window-icon=images/icon.png \
    --width=500 --height=300 --justify=left \
    --text="\n  USUARIO CONSULTADO: $username\n\n-------------------------------------------------------------------------------\n  $mensaje " \
    --button="Volver al menu:0"
