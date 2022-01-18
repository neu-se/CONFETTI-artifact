#!/bin/bash

if [ -z "$JAVA_HOME" ]; then
    echo "Error: Please set \$JAVA_HOME";
    exit 1
fi

mkdir -p $INSTALL_DIR

$ROOT/scripts/build/jvm.sh
$ROOT/scripts/build/knarr.sh
$ROOT/scripts/build/jqf.sh
$ROOT/scripts/build/closure.sh
$ROOT/scripts/build/ant.sh
$ROOT/scripts/build/maven.sh
$ROOT/scripts/build/rhino.sh
$ROOT/scripts/build/bcel.sh
$ROOT/scripts/build/batik.sh
$ROOT/scripts/build/instrument-experiments.sh
$ROOT/scripts/build/z3.sh
