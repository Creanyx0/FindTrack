#!/bin/bash


	#####################################################################################################
	#												    #
	# 		FindTrack - Herramienta con interfaz grafica que automatiza tareas OSINT    	    #
	#												    #
	# Autora: Elisa Alises Nuñez									    #
	#												    #
	#####################################################################################################


############################################# PROGRAMA PRINCIPAL ####################################################



## Variable que almacena la ruta donde esta instalada la herramienta ##
directorio=$(pwd)



## Exporta variable para que desde los demas scripts se pueda acceder a ella ##
export directorio



## Comprobacion/instalacion dependencias ##
echo "Comprobando/instalando las dependencias necesarias..."
sleep 2
./modulos/dependencias/instalador.sh # Ejecuta script auxiliar que contiene las dependencias



## Da permisos a los scripts auxiliares interconectados ##
echo "Dando permiso a los scripts auxiliares interconectados con el programa principal..."
sleep 2
./modulos/permisos/permisos.sh
echo "Iniciando..."




## Funcion bash para crear carpeta y fichero con los resultados ##
function crearFichero {

	# Crea carpeta (o comprueba que existe) para almacenar resultados
	mkdir $directorio/resultados

	# Crea ruta del fichero
	rutaFichero="$directorio/resultados/resultados.txt"

	## Crea fichero para almacenar las redes sociales de ese username
	touch $rutaFichero
	export rutaFichero


	# Ejecuta script que escribe cabecera dentro del fichero
	sh $directorio/cabecera/cabeceraFichero.sh

}





## Funcion para mostrar pantalla de error (warning) y evitar duplicar codigo (vuelve a menu principal cuando hay error o se dejan los campos vacios) ##
function ventanaError {

zenity --warning \
         --title="FindTrack" --window-icon=images/icon.png  \
         --width=300 \
         --text="\nNo se ha seleccionado ninguna de las opciones del menu o el campo esta vacio"

resp=$? # Recoge el boton que pulsa el usuario


if [ $resp -eq 0 ] # Si pulsa en Ok en la ventana de warning, vuelve al menu principal de opciones
then
    volver=1 # Para que vuelva a la ventana del menu de opciones

else # Si no pulsa en OK en el warning, no vuelve a mostrar la ventana de las opciones
    volver=0
fi

# Se vuelve al menu de opciones hasta que se pulsa en alguna opcion

}




## Pantalla principal de inicio del programa (pregunta si comenzar o salir) ##
yad --question \
	--image images/FindTrackElisa.jpg \
	--title "FindTrack" --window-icon=images/icon.png \
	--width=750 --height=300 --center \
	--button="SALIR:252" --button="COMENZAR:0" --center



respuesta=$? # Variable que recoge lo que pulsa el usuario




## Bucle que ejecuta la siguiente pantalla si se quiere continuar o si se decide salir del programa ##
if [ $respuesta -eq 0 ] # Si se elige que se quiere iniciar la herramienta (pulsa en ok)
then
    #echo "Si que quiere continuar"

    volver=1 # Para que entre en el bucle al menos una vez

    while [ $volver -eq 1 ]
    do
    	# Ventana que contiene el menu principal de opciones del programa
    	opcion=$(zenity --list \
			--title="FindTrack" --window-icon=images/icon.png \
			--text="Selecciona una opcion: " \
			--radiolist \
			--column="" \
                	--column="Opcion" \
                 	1 "Redes sociales de un username conocido (nick)" 2 "Username de redes sociales de una persona" 3 "Rutas de Google relacionadas con una persona (nombre y apellidos)" 4 "URLs Google Imagenes relacionado con una persona" 5 "Informacion de un telefono movil" 6 "Correos electronicos de un dominio" 7 "Metadatos de una fotografia" 8 "Descargar imagenes de una cuenta de Instagram" \
			--width=700 --height=300 --hide-header)


    	resp=$? # Recoge el boton que pulsa el usuario

    	if [ $resp -eq 0 ] # Si se pulsa el boton ok
    	then
		#echo $opcion # Recoge la opcion del menu

    		if [ -z "$opcion" ] # Si se pulsa en ok sin pulsar ninguna opcion del menu
		then
    			# Llama a funcion que muestra ventana de warning (indicando que no se ha seleccionado ninguna opcion valida)
			ventanaError


		else # Si ha elegido una de las opciones del menu (valida)

			volver=0 # Para que deje de mostrar el menu de opciones

			# Si se ha elegido la primera opcion del menu o la opcion 8
			if [ "$opcion" = "Redes sociales de un username conocido (nick)" ] || [ "$opcion" = "Descargar imagenes de una cuenta de Instagram" ]
			then
				# Ventana formulario que solicita dato (nick) al usuario para comenzar la investigacion
				datos=$(yad --form \
            					--title="FindTrack" --window-icon=images/icon.png \
            					--text=" Introduzca el username que se va a analizar:\n" \
            					--center --width=400 \
            					--field="Nick (username): " )

				ans=$?

				if [ $ans -eq 0 ] # Si se pulsa en OK una vez se rellenan los datos que se conocen
				then
    					#echo "Se han introducido los siguientes datos:"
    					IFS="|" read -r -a array <<< "$datos"


					username="${array[0]}" # Se almacena en una variable lo que se recibe en el campo de texto
					export username # Exporta variable


					# Comprueba si se ha insertado algun username, si esta vacio muestra error
					if [ -z "$username" ]
					then
						echo "No se conoce username"
						ventanaError # Muestra ventana de warning y vuelve a menu principal


					else # Si se recibe un username
						if [ "$opcion" = "Redes sociales de un username conocido (nick)" ]
						then
							crearFichero # Llama a funcion que crea el fichero que almacenara resultados
							./modulos/buscarRedesSociales.sh # Llama script auxiliar que comprueba que redes sociales tiene ese username
							volver=1 # Para que vuelva al menu de opciones

						elif [ "$opcion" = "Descargar imagenes de una cuenta de Instagram" ]
						then
							crearFichero
							./modulos/descargarImgInstagram.sh
							volver=1
						fi

					fi


				else # Si se pulsa en cancelar, se vuelve al menu de opciones principal
    					echo "Volver al menu principal de opciones"
					volver=1
				fi



			# Si se elige la segunda, tercera o cuarta opcion del menu
			elif [ "$opcion" = "Username de redes sociales de una persona" ] || [ "$opcion" = "Rutas de Google relacionadas con una persona (nombre y apellidos)" ] || [ "$opcion" = "URLs Google Imagenes relacionado con una persona" ]
			then
				# Ventana formulario que pide al usuario el nombre y apellidos de la persona que quiere investigar
				datos=$(yad --form \
                                                --title="FindTrack" --window-icon=images/icon.png \
                                                --text=" Introduzca el nombre y apellidos de la persona a investigar:\n" \
                                                --center --width=400 \
                                                --field="Nombre: " \
						--field="Apellidos: " )
				ans=$?

				if [ $ans -eq 0 ]
				then
					IFS="|" read -r -a array <<< "$datos"

					# Almacena y exporta variables
					nombre="${array[0]}"
					export nombre

					apellidos="${array[1]}"
					export apellidos


					if [ -z "$nombre" ] && [ -z "$apellido" ]
					then
						echo "No se conocen ni nombre ni apellidos"
						ventanaError # Muestra ventana error para volver al menu principal
					else


						# Si se ha elegido la segunda opcion
                                                if [ "$opcion" = "Username de redes sociales de una persona" ]
                                                then
							crearFichero
							./modulos/obtenerNick.sh # Llama a script que obtiene el nick de redes sociales de una persona
							volver=1

						# Si se ha elegido la tercera opcion, llama script que obtiene rutas google relacionadas con la persona
						elif [ "$opcion" = "Rutas de Google relacionadas con una persona (nombre y apellidos)" ]
						then
							crearFichero # Llama a funcion que crea el fichero que va a tener los resultados
							./modulos/rutasGooglePersona.sh
							volver=1

						# Si se ha elegido la cuarta opcion, llama script que obtiene URL google imagenes relacionados con esa persona
						elif [ "$opcion" = "URLs Google Imagenes relacionado con una persona" ]
						then
							crearFichero
							./modulos/rutaImgGoogle.sh
							volver=1
						fi


					fi
				else # Si se pulsa en cancelar, se vuelve al menu de opciones principal
                                        echo "Volver al menu principal de opciones"
                                        volver=1
                                fi

			# Si se elige 5 opcion
			elif [ "$opcion" = "Informacion de un telefono movil" ]
			then
				# Ventana formulario que pide al usuario el nombre y apellidos de la persona que quiere investigar
                                datos=$(yad --form \
                                                --title="FindTrack" --window-icon=images/icon.png \
                                                --text=" Introduzca el numero de telefono movil a investigar (con prefijo):\n" \
                                                --center --width=400 \
                                                --field="Telefono: " )
				ans=$?

                                if [ $ans -eq 0 ]
                                then
                                        IFS="|" read -r -a array <<< "$datos"

                                        # Almacena y exporta variables
                                        telefono="${array[0]}"
                                        export telefono

					# Comprueba si se ha insertado algun telefono, si esta vacio muestra error
                                        if [ -z "$telefono" ]
                                        then
						echo "No se conoce ningun telefono"
						ventanaError
					else
						crearFichero
						./modulos/infoTelefono.sh # Ejecuta script que obtiene informacion del telefono dado
						volver=1
					fi


				else # Si se pulsa en cancelar, se vuelve al menu de opciones principal
                                        echo "Volver al menu principal de opciones"
                                        volver=1
				fi


			# Si se elige la opcion 6
			elif [ "$opcion" = "Correos electronicos de un dominio" ]
			then

				# Ventana formulario que pide al usuario el dominio que quiere investigar
                                datos=$(yad --form \
                                                --title="FindTrack" --window-icon=images/icon.png \
                                                --text=" Introduzca el dominio (con extension)  a investigar (ej: unir.net):\n" \
                                                --center --width=600 \
                                                --field="Dominio: " )
                                ans=$?

                                if [ $ans -eq 0 ]
                                then
                                        IFS="|" read -r -a array <<< "$datos"

                                        # Almacena y exporta variables
                                        dominio="${array[0]}"
                                        export dominio

					# Comprueba si se ha insertado algun dominio, si esta vacio muestra error
                                        if [ -z "$dominio" ]
                                        then
                                                echo "No se conoce ningun dominio"
                                                ventanaError
                                        else
						crearFichero
                                                ./modulos/infoDominio.sh # Ejecuta script que obtiene informacion del dominio dado
						volver=1
                                        fi


				else
					echo "Volver al menu principal de opciones"
					volver=1
				fi


			# Si se eliga la opcion 7
			elif [ "$opcion" = "Metadatos de una fotografia" ]
			then
				archivo=$(yad --file \
              					--title="FindTrack" --window-icon=images/icon.png \
              					--height=200 \
              					--width=100 \
              					--center \
              					--text="Seleccione un archivo:" \
              					--file-filter="imagen | *.jpg *png")
				ans=$?
				if [ $ans -eq 0 ]
				then
					# Variable $archivo contiene la ruta de la imagen elegida

					if [ -f "$archivo" ]
					then
						echo "El archivo elegido existe"
						export archivo

						crearFichero
						./modulos/metadatosImg.sh # Llamada a script que obtiene sus metadatos
						volver=1

					else
						echo "No se ha seleccionado ningun archivo"
						zenity --warning \
         						--title="FindTrack" --window-icon=images/icon.png  \
         						--width=300 \
         						--text="\nNo se ha seleccionado ningun archivo"

						resp=$? # Recoge el boton que pulsa el usuario


						if [ $resp -eq 0 ] # Si pulsa en Ok en la ventana de warning, vuelve al menu principal de opciones
						then
    							volver=1 # Para que vuelva a la ventana del menu de opciones

						else # Si no pulsa en OK en el warning, no vuelve a mostrar la ventana de las opciones
    							volver=0
						fi

						# Se vuelve al menu de opciones hasta que se pulsa en alguna opcion

					fi


				else # Si pulsa en cancelar, vuelve atras
    					echo "Volver al menu principal de opciones"
					volver=1
				fi

			fi
    		fi

     	else # Si se pulsa en cancel en ventana de opciones, termina el programa
		volver=0 # Para que deje de mostrar el menu de opciones
		echo "Se ha elegido finalizar el programa."

     	fi
    done


else # Si elige que no se quiere iniciar el programa, finaliza
    echo "Se ha elegido finalizar el programa."
fi



