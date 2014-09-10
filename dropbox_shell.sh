#!/bin/bash

REMOTEFOLD="${HOME}/Dropbox/remote"
[ -n "$1" -a -d "$1" ] && REMOTEFOLD="$1"
[ -n "$1" -a ! -d "$1" ] && REMOTEFOLD="${HOME}/Dropbox/remote_$1"
COMFOLD="${REMOTEFOLD}/commands"
OUTFOLD="${REMOTEFOLD}/output"
OLDFOLD="${REMOTEFOLD}/old"
PRINTFOLD="${REMOTEFOLD}/toprint"
PRINTEDFOLD="${REMOTEFOLD}/printed"

## Add functions to process special types, check README for instructions
function run_application_octetstream_n() {
	neko "$1"
}
function run_application_xjavaapplet_class() {
	java "${1%.class}"
}
function run_application_jar_jar() {
	java -jar "$1"
}

## Default run function. Do not modify
function run_default() {
	chmod +x "$1"
	"./${1}"
}

if [ -d "$COMFOLD" ]
then
	pushd "$COMFOLD" >/dev/null
	for i in *
	do
		if [ -f "$i" -a ! -e "$i.lock" -a "${i%%.lock}" == "$i" ]
		then
			mime="$(file -bi "$i")"
			mime="${mime%;*}"
			minmime=$(echo "$mime" | sed -e 's@/@_@g' -e 's/[^a-z_]//')
			ext="${i##*.}"

			if declare -f "run_${minmime}_${ext}" >/dev/null
			then dorun="run_${minmime}_${ext}"
			else dorun="run_default"
			fi 

			touch "$i.lock"

			echo "==== Start: `date` ====" >> "${OUTFOLD}/${i}.log"
			if [ "${i#at-}" != "$i" ]
			then 
				at -f "$i" "${i#at-}" >> "${OUTFOLD}/${i}.log" 2>&1
			else
				$dorun "$i" >> "${OUTFOLD}/${i}.log" 2>&1
			fi
			echo "===== End: `date` =====" >> "${OUTFOLD}/${i}.log"
			echo >> "${OUTFOLD}/${i}.log"
			mv -t "${OLDFOLD}" "$i"
			rm "$i.lock"
		fi
	done
	popd >/dev/null
fi

if [ -d "$PRINTFOLD" ]
then
	pushd "$PRINTFOLD" >/dev/null
	for i in *.pdf
	do
		if [ -f "$i" -a ! -e "$i.lock" -a "${i%%.lock}" == "$i" ]
		then
			touch "$i.lock"
			echo "=== Printing: `date` ==" >> "${OUTFOLD}/${i}.log"
			ps2pdf "$i" - | lp >> "${OUTFOLD}/${i}.log" 2>&1
			echo "= Print done: `date` ==" >> "${OUTFOLD}/${i}.log"
			mv -t "${PRINTEDFOLD}" "$i"
			rm "$i.lock"
		fi
	done
	for i in *.ps
	do
		if [ -f "$i" -a ! -e "$i.lock" -a "${i%%.lock}" == "$i" ]
		then
			touch "$i.lock"
			echo "=== Printing: `date` ==" >> "${OUTFOLD}/${i}.log"
			lp "$i" >> "${OUTFOLD}/${i}.log" 2>&1
			echo "= Print done: `date` ==" >> "${OUTFOLD}/${i}.log"
			mv -t "${PRINTEDFOLD}" "$i"
			rm "$i.lock"
		fi
	done
	for i in *.jpg *.gif *.png *.bmp *.tif *.tiff
	do
		if [ -f "$i" -a ! -e "$i.lock" -a "${i%%.lock}" == "$i" ]
		then
			touch "$i.lock"
			echo "=== Printing: `date` ==" >> "${OUTFOLD}/${i}.log"
			convert "$i" pdf:- | pdf2ps - - | lp >> "${OUTFOLD}/${i}.log" 2>&1
			echo "= Print done: `date` ==" >> "${OUTFOLD}/${i}.log"
			mv -t "${PRINTEDFOLD}" "$i"
			rm "$i.lock"
		fi
	done
	popd >/dev/null
fi

if [ -d "${REMOTEFOLD}/books" ]
then
    pushd "${REMOTEFOLD}/books" >/dev/null
    for i in *
    do
		if [ -f "$i" -a ! -e "$i.lock" -a "${i%%.lock}" == "$i" ]
		then
            touch "$i.lock"
            echo "=== Adding book: `date` ==" >> "${OUTFOLD}/${i}.log"
            calibredb add "$i" >> "${OUTFOLD}/${i}.log" 2>&1
            echo "==== Added book: `date` ==" >> "${OUTFOLD}/${i}.log"
			mv -t "${OLDFOLD}" "$i"
            rm "$i.lock"
		fi
    done
    popd >/dev/null
fi
