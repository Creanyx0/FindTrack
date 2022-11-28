#!/bin/bash

	########################################################################################################
	#												       #
	# Script interconectado con el principal que comprueba si existe un username en varias redes sociales  #
	#												       #
	########################################################################################################

################## Muestra URLs de color verde en las plataformas que si existe y rojo si no existe ######################



## Exporta variable
export username
export rutaFichero



## Escribe titulo dentro del fichero ##
echo -e "-------------------------------------------------------------------------------------------------\n" >> $rutaFichero
echo -e "| REDES SOCIALES QUE TIENE EL USERNAME: $username	              					 |\n" >> $rutaFichero
echo -e "-------------------------------------------------------------------------------------------------\n" >> $rutaFichero




## Funciones Python que reciben el username dado por el usuario y comprueban si tiene determinada red social o no ##


# Funcion que comprueba si ese usuario tiene Facebook
function facebook {
python - <<START
import os
import json
import requests

r = requests.get('https://graph.facebook.com/$username')

if ((r.json()['error']['code']) == 200):
  #print("El usuario $username tiene facebook")
  existeF="lime"
else:
  #print("El usuario $username no tiene facebook")
  existeF="red"

print(existeF)

#print "usuario:", os.environ['username']
START
}



# Funcion que comprueba si el username tiene github
function github {
python - <<START
import os
import json
import requests

rG = requests.get('https://github.com/$username')


if (rG.status_code == 200): # Si devuelve codigo 200 es que tiene hithub
  existeG="lime"

else: # Si devuelve cualquier otro, no tiene
  existeG="red"

print(existeG)

START
}






## Llama a funcion que comprueba si tiene facebook o no. Cuenta con ventana de progreso ##
(facebook | yad --progress --title="FindTrack" --window-icon=images/icon.png \
                                                --progress-text="Calculando..." \
                                                --center \
                                                --width=300 \
                                                --height=100 \
                                                --auto-kill \
                                                --auto-close )



existeF=$(facebook) # Obtiene la respuesta de la funcion (si tiene o no facebook)


if [ "$existeF" = "lime" ]
then
        echo -e "\n[Facebook] https://www.facebook.com/$username/ \n" >> $rutaFichero
elif [ "$existeF" = "red" ]
then
        echo -e "\n[Facebook] -> No existe esta cuenta\n" >> $rutaFichero
fi






## Comprueba si tiene instagram (realiza curl y busca la palabra username ##
instagram=$(curl -v https://www.instagram.com/${username}/ 2>&1 | grep user?username)


if [ -z "$instagram" ] # Si lo que devuelve el comando anterior es vacio, no tiene cuenta
then
	existeI="red" # Para mostrar el texto en rojo
	echo -e "\n[Instagram] -> No existe esta cuenta\n" >> $rutaFichero
else # Si devuelve info, tiene cuenta
	existeI="lime" # Para mostrar el texto en verde
	echo -e "\n[Instagram] https://www.instagram.com/${username}/ \n" >> $rutaFichero # Escribe en el fichero de resultados
fi





## Comprueba si tiene youtube ##
youtube="$(curl https://www.youtube.com/c/$username/ 2>&1 | grep /error?src=404)" # Realiza curl y consulta si devuelve ese error 404

if [ -z "$youtube" ] # Si no devuelve nada (vacio) es porque no devuelve 404, y tiene cuenta
then
	existeY="lime"
	echo -e "\n[YouTube] https://youtube.com/c/$username/ \n" >> $rutaFichero
else # Si devuelve 404, es que no existe y no tiene youtube
	existeY="red"
	echo -e "\n[YouTube] -> No existe esta cuenta\n" >> $rutaFichero
fi



## Comprueba si tiene twitter ##
twitter=$(curl https://api.instantusername.com/check/twitter/$username/ 2>&1 | grep '"available":true') # Realiza curl y si esta disponible el username consultado, es que no existe esa cuenta

if [ -z "$twitter" ]
then # Si no devuelve nada, es que existe
	existeT="lime"
	echo -e "\n[Twitter] https://twitter.com/$username/ \n" >> $rutaFichero
else # Si devuelve algo (available:true) es que esa cuenta no existe
	existeT="red"
	echo -e "\n[Twitter] -> No existe esta cuenta\n" >> $rutaFichero
fi





## Llama a funcion que comprueba si tiene github o no ##
(github | yad --progress --title="FindTrack" --window-icon=images/icon.png \
                                                --progress-text="Calculando..." \
                                                --center \
                                                --width=300 \
                                                --height=100 \
                                                --auto-kill \
                                                --auto-close )


existeG=$(github)


if [ "$existeG" = "lime" ]
then
        echo -e "\n[Github] https://github.com/$username/ \n" >> $rutaFichero
elif [ "$existeG" = "red" ]
then
        echo -e "\n[Github] -> No existe esta cuenta\n" >> $rutaFichero
fi




## Variable que almacena los resultados de todas las redes sociales de ese username para mostrarlo en la ventana de yad ##
resultados="[Instagram] \t<span color='$existeI'>  https://www.instagram.com/${username}/ </span> \n\n [Facebook] \t<span color='$existeF'>  https://www.facebook.com/$username/ </span> \n\n [GitHub] \t\t<span color='$existeG'>  https://github.com/$username/ </span> \n\n [Youtube] \t<span color='$existeY'>  https://youtube.com/c/$username/ </span> \n\n [Twitter] \t\t<span color='$existeT'>  https://twitter.com/$username/ </span>"




# Ventana que muestra esta informacion obtenida de cada red social (si existe o no el usuario consultado) ##
yad --title="FindTrack" --window-icon=images/icon.png \
    --width=500 --height=300 --justify=left \
    --text="\n  REDES SOCIALES ENCONTRADAS DEL USUARIO: $username\n\n--------------------------------------------------------------------------------- \n<span color='lime'> Verde: </span> Existe \n<span color='red'> Rojo:</span>\t  No existe \n--------------------------------------------------------------------------------- \n\n\n ${resultados} \n" \
    --button="Volver al menu:0" --button="Visualizar Fichero Resultados:1"



respuesta=$? # Variable que recoge lo que pulsa el usuario


if [ $respuesta -eq 1 ] # Si se elige visualizar el fichero de resultados
then
	xterm -geometry 200x100 -e "cat $rutaFichero; $SHELL" # Abre terminal y muestra el fichero
fi




echo -e "\n\n" >> $rutaFichero
