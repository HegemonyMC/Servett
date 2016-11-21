#!/usr/bin/env bash

(
set -e
PS1="$"
basedir="$(cd "$1" && pwd -P)"
workdir="$basedir/work"
minecraftversion=$(cat "$workdir/BuildData/info.json"  | grep minecraftVersion | cut -d '"' -f 4)

decompiledir="$2"
if [[ -z ${decompiledir} ]] ; then
    decompiledir="$workdir/$minecraftversion"
fi

sourcejar="$3"
if [[ -z ${sourcejar} ]] ; then
    sourcejar="$decompiledir/$minecraftversion-mapped.jar"
fi

justextract="$4"

classdir="$decompiledir/classes"

echo "Extracting NMS classes..."
if [ ! -d "$classdir" ]; then
    mkdir -p "$classdir"
    cd "$classdir"
    jar xf "$sourcejar" net/minecraft
    if [ "$?" != "0" ]; then
        cd "$basedir"
        echo "Failed to extract NMS classes."
        exit 1
    fi
fi

if [[ ! -z "$justextract" ]] ; then
    exit 0
fi

echo "Decompiling classes..."
if [ ! -d "$decompiledir/net/minecraft/server" ]; then
    cd "$basedir"
    java -jar "$workdir/BuildData/bin/fernflower.jar" -dgs=1 -hdc=0 -asc=1 -udv=0 "$classdir" "$decompiledir"
    if [ "$?" != "0" ]; then
        echo "Failed to decompile classes."
        exit 1
    fi
fi
)
