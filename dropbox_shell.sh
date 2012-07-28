#!/bin/bash

REMOTEFOLD="${HOME}/Dropbox/remote"
[ -n "$1" ] && REMOTEFOLD="${HOME}/Dropbox/remote_$1"
COMFOLD="${REMOTEFOLD}/commands"
OUTFOLD="${REMOTEFOLD}/output"
OLDFOLD="${REMOTEFOLD}/old"
PRINTFOLD="${REMOTEFOLD}/toprint"
PRINTEDFOLD="${REMOTEFOLD}/printed"

pushd "$COMFOLD" >/dev/null
for i in *
do
    if [ -f "$i" -a ! -e "$i.lock" -a "${i%%.lock}" == "$i" ]
    then
        chmod +x "$i"
        touch "$i.lock"
        echo "==== Start: `date` ====" >> "${OUTFOLD}/${i}.log"
		if [ `expr index "$i" "at-"` -eq 1 ]
		then 
			at -f "$i" "${i#at-}" >> "${OUTFOLD}/${i}.log.txt"
		else
			"./${i}" 2>&1 >> "${OUTFOLD}/${i}.log"
		fi
        echo "===== End: `date` =====" >> "${OUTFOLD}/${i}.log"
        echo >> "${OUTFOLD}/${i}.log"
		mv -t "${OLDFOLD}" "$i"
        rm "$i.lock"
    fi
done
popd >/dev/null

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
