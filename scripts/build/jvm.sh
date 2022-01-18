#!/bin/bash

if [ -z "$JAVA_HOME" ]; then
    echo "Error: Please set \$JAVA_HOME";
    exit 1
fi

sudo apt-get install -y ant maven
which mvn &> /dev/null || { echo "Please install maven" ; exit 1 ; }

tar xf `ls $DOWNLOAD_DIR/jdk-*-linux-x64.tar.gz` -C $INSTALL_DIR
mv `echo $INSTALL_DIR/jdk*` $JAVA_HOME
