#!/bin/bash

if [ -z "$JAVA_HOME" ]; then
    echo "Error: Please set \$JAVA_HOME";
    exit 1
fi

which mvn &> /dev/null || { echo "Please install maven" ; exit 1 ; }

# get Ant from Maven
pushd $ANT_DIR
{
    # Get all dependencies from Maven
    ./getDeps.sh
}
popd
