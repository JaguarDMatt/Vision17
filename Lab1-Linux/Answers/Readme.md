Answers

1.What is the grep command?

Grep es un comando que busca un patrón de entrada dado en una lista de archivos o lineas, e imprime las lineas encontradas.

2.What does the -prune option of find do? Give an example

Sirve para indicarle al comando find que si el archivo buscado es un directorio, que no busque recursivamente dentro.

Ejemplo:
find . -name .snapshot -prune -o -name '*.foo' -print

En este caso si hay archivos con extensión foo en carpetas llamadas snapshot, no se buscara dentro de estos carpetas. Se utiliza name para mostrar en ambos pasos los patrones o nombres que se buscan, o en el caso de prune, los nombres de carpetas que no se deben entrar para buscar.[1]
 
3. What does the cut command do?

Busca secciones especificas de cada linea de un documento y las imprime en la terminal

5. what does the diff command do?

Compara documentos linea por linea para ver sus diferencias

6. What does the tail command do?

Imprime las ultimas 10 lineas de cada documento entrado como input

7. What does the tail -f command do?

Realiza la misma accion que tail, solo que ahora sigue los cambios del documento.

8. What does the link command do?

Crea un enlace duro (hard link) entre dos archivos, lo que hace que tengan un mismo nodo de indexación. [2]

9. What is the meaning of #! /bin/bash at the start of scripts?

Le permite saber al computador con que programa o interpretador de comandos correr el script. En este caso particular, significa que el script debe ser corrido por el bash Shell. [3]

10. How many users exist in the course server?

Utilizando el comando, que me permite imprimir al terminal solo los nombres de usuarios:

awk -F':' '{ print $1}' /etc/passwd

Me aparecieron alrededor de 39 usuarios.

vision@ing-542:~$ awk -F':' '{ print $1}' /etc/passwd|wc -l
39

Pero usando grep: 
grep -a "/bin/bash" /etc/passwd| wc -l

Solo aparecen 9 usuarios que usan /bin/bash [4]

11. What command will produce a table of Users and Shells sorted by shell (tip: using cut and sort)

Solo logre imprimir la lista de Usuarios y Shells, no ordenarla:

grep "/bin/" /etc/passwd | cut -d':' -f1,7

12. Create a script for finding duplicate images based on their content (tip: hash or checksum) You may look in the internet for ideas, Do not forget to include the source of any code you use. [5]

#! /bin/bash

# encontrar todas las imagenes .jpg
images=$(find . -name *.jpg)
#creo array para almacenar hash de cada imagen
declare -a hash=(" ")
#comienzo recorrido para almacenar hash y comparar
for im in ${images[*]}
do
#extraigo el hash de la imagen actual y lo almaceno
hashi=`identify -format "%#" $im`
#comparo este hash contra los existentes
	for ha in ${hash[*]}
	do 
	#Si el hash actual es igual al hash ha, es un duplicado
	if [ $hashi == $ha ]; then
	echo $im is duplicate
	fi
	done
#almaceno el hash para futuras comparaciones
hash=("${hash[@]}" $hashi
done

14. What is the disk size of the uncompressed dataset, How many images are in the directory 'BSR/BSDS500/data/images'?

Usando el comando du que sirve para conocer el uso del disco de archivos:

cristian@JaguarD:~/Descargas$ du -hs ./BSR/
245M	./BSR/

Usando el comando find, que permite encontrar archivos, y la extension .jpg encontre que eran 512.

find . -name "*.jpg"|wc -l
512

15. What is their resolution, what is their format?

La mayoria tienen una resolución de 72 ppp x 72 ppp, dos tienen de 180 x 180, pero todas las imágenes están con el formato JPEG.

Utilice el siguiente script para ver todas las resoluciones y formatos:

#! /bin/bash

# encontrar todas las imagenes .jpg
images=$(find . -name *.jpg)

#comienzo recorrido para extraer resolucion y formato
for im in ${images[*]}
do
#extraigo la informacion de formato y resolucion en la imagen actual
formato=`identify -format "%m" $im`
resi=`identify -format "%x %y" $im`

#imprimo a consola resoluciones y formatos
echo $formato
echo $resi

done


16. How many of them are in landscape orientation (opposed to portrait)?
Utilizando el siguiente script:

#! /bin/bash

# encontrar todas las imagenes .jpg
images=$(find . -name *.jpg)
#creo array para almacenar las imagenes en orientacion horizontal  
declare -a portrait
#comienzo recorrido para comparar
for im in ${images[*]}
do
#extraigo la informacion de altura y ancho en la imagen actual y la almaceno
ancho=`identify -format "%w" $im`
alto=`identify -format "%h" $im`

#guarda la imagen si esta en posicion horizontal
	if [ $ancho -ge $alto ]; then
	portrait=("${portrait[@]}" $im)
	fi
done

echo ${#portrait[@]}

Me dieron 355 imágenes horizontales


17. Crop all images to make them square (256x256).
Lo hice con el siguiente script:


#! /bin/bash

# encontrar todas las imagenes .jpg
images=$(find . -name *.jpg)

#comienzo recorrido para cortar
for im in ${images[*]}
do

#recorto y guardo con el mismo nombre
convert $im -crop 256x256! $im
#imprimo a consola un mensaje
echo $im has been cropped

done


Referencias

[1] "How To Use '-Prune' Option Of 'Find' In Sh?". Stackoverflow.com. N.p., 2009. Web. 10 Feb. 2017.

[2] Computerhope.com. (n.d.). Linux and UNIX link command help and examples. [online] Available at: http://www.computerhope.com/unix/link.htm [Accessed 8 Feb. 2017].

[3] Tldp.org. (n.d.). Starting Off With a Sha-Bang. [online] Available at: http://tldp.org/LDP/abs/html/sha-bang.html [Accessed 8 Feb. 2017].

[4] Gite, Vivek. "Linux Command: List All Users In The System". Cyberciti.biz. Web. 9 Feb. 2017.

[5]Arapidis, Charalampos. "How To Batch Identify Similar Images In Linux". Fuzz-box.blogspot.com.co. N.p., 2012. Web. 9 Feb. 2017.
