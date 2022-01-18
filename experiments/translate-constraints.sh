#!/bin/bash

if [ -z "$JAVA_HOME" ]; then
    echo "Error: Please set \$JAVA_HOME";
    exit 1
fi

DEBUG="-Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=5554,suspend=n"
OPTS="-Xmx10G -Xss1G"
#OPTS="-Xmx10G"
CMD="LD_LIBRARY_PATH=$Z3_DIR $JAVA_HOME/bin/java $DEBUG $OPTS -Djava.library.path=$Z3_DIR -cp $GREEN_DIR/green/green.jar:$Z3_DIR/com.microsoft.z3.jar:$KNARR_DIR/knarr/target/Knarr-0.0.2-SNAPSHOT.jar za.ac.sun.cs.green.service.z3.Z3JavaTranslator $@"
echo $CMD
exec bash -c "$CMD"
