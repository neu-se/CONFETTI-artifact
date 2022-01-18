#!/bin/bash

if [ -z "$JAVA_HOME" ]; then
    echo "Error: Please set \$JAVA_HOME";
    exit 1
fi

which mvn &> /dev/null || { echo "Please install maven" ; exit 1 ; }

# get Rhino from Maven
pushd $RHINO_DIR
{
    # Get all dependencies from Maven
    ./getDeps.sh
}
popd
