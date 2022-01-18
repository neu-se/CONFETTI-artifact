#!/bin/bash

unzip `find $DOWNLOAD_DIR -name *z3*zip` -d $INSTALL_DIR
mv `find $INSTALL_DIR -maxdepth 1 -name *z3-*`/bin $Z3_DIR
rm -rf `find $INSTALL_DIR -name *z3-*`
