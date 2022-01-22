#!/bin/bash

# Figure out script absolute path
pushd `dirname $0` > /dev/null
SCRIPT_DIR=`pwd`
popd > /dev/null

# The root dir is one up
ROOT_DIR=`dirname $SCRIPT_DIR`

# Create classpath
cp=""

# Ensure BCEL is first on the CP
cp="$SCRIPT_DIR/deps/bcel-6.2.jar"

for jar in $SCRIPT_DIR/deps/*.jar; do
  cp="$cp:$jar"
done

echo $cp
