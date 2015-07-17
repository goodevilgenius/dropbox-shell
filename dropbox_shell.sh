#!/bin/bash

REMOTEFOLD="${HOME}/Dropbox/remote"
[ -n "$1" -a -d "$1" ] && REMOTEFOLD="$1"
[ -n "$1" -a ! -d "$1" ] && REMOTEFOLD="${HOME}/Dropbox/remote_$1"
COMFOLD="${REMOTEFOLD}/commands"
OUTFOLD="${REMOTEFOLD}/output"
OLDFOLD="${REMOTEFOLD}/old"
PRINTFOLD="${REMOTEFOLD}/toprint"
PRINTEDFOLD="${REMOTEFOLD}/printed"

## Processing special folders here. Check README for instructions
OTHERFOLDERS=( books toprint )
function run_folder_books() {
	calibredb add "$1"
}
function run_folder_toprint() {
	ext="${1##*.}"
	case $ext in
		pdf)
			ps2pdf "$1" - | lp
			;;
		ps)
			lp "$i"
			;;
		jpg|gif|png|bmp|tif|tiff)
			convert "$1" pdf:- | pdf2ps - - | lp
			;;
		*)
			echo "Can't print $ext file"
			;;
	esac
}

## Add functions to process special types. Check README for instructions
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

# If `file` command isn't present (msys), declare a dummy function
# In this case, all commands will use the default run function
if ! which file >/dev/null
then
	function file() {
		echo "unknown/unknown"
	}
fi 

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
			mv --target-directory="${OLDFOLD}" "$i"
			rm "$i.lock"
		fi
	done
	popd >/dev/null
fi

for d in "${OTHERFOLDERS[@]}"
do
	if [ -d "${REMOTEFOLD}/${d}" ] && declare -f "run_folder_${d}" >/dev/null
	then
		pushd "${REMOTEFOLD}/${d}" >/dev/null
		for i in *
		do
			if [ -f "$i" -a ! -e "$i.lock" -a "${i%%.lock}" == "$i" ]
			then
				touch "$i.lock"
				echo "=== Processing from $d: `date` ==" >> "${OUTFOLD}/${d}.log"
				echo "Processing $(basename "$i")" >> "${OUTFOLD}/${d}.log"
				run_folder_${d} "$i" >> "${OUTFOLD}/${d}.log" 2>&1
				echo "==== Processed from $d: `date` ==" >> "${OUTFOLD}/${d}.log"
				echo >> "${OUTFOLD}/${d}.log"
				mv --target-directory="${OLDFOLD}" "$i"
				rm "$i.lock"
			fi
		done
		popd >/dev/null
	fi
done
