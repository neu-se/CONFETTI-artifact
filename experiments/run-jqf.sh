#!/bin/bash

if [ -z "$JAVA_HOME" ]; then
    echo "Error: Please set \$JAVA_HOME";
    exit 1
fi

if [ -z "$EXP_CP" ]; then
    echo "Error: Please set the experiment classpath \$EXP_CP";
    exit 1
fi

if [ -z "$EXP_CMD" ]; then
    echo "Error: Please set the experiment command \$EXP_CMD";
    exit 1
fi

source $ROOT/experiments/jvm.sh

# How long to run the experiment (seconds)
#DURATION=$((60*2 ))
if [ -z "$DURATION" ]; then
    DURATION=$((60*60*24))
fi

JQF_SENSITIVITY=3
#JQF_DEBUG="-Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=5555,suspend=n"
JQF_OPTS="$JQF_JVM_OPTS -Dtime=$(($DURATION))" #-Djanala.verbose=true"
JQF_CMD="JVM_OPTS=\"-Djqf.ei.UNIQUE_SENSITIVITY=$JQF_SENSITIVITY $JQF_OPTS $JQF_DEBUG\" timeout $(($DURATION)) $JQF_VANILLA_DIR/bin/jqf-ei -c $JQF_VANILLA_DIR/examples/target/classes:$JQF_VANILLA_DIR/examples/target/test-classes:`$JQF_VANILLA_DIR/scripts/classpath.sh`:$EXP_CP $EXP_CMD"


# Launch program driver
#echo "$JQF_CMD"
#exec bash -c "$JQF_CMD"

screen -S "jqf" -d -m bash -c "$JQF_CMD"

# Re-attach JQF screen to wait for it to exit
screen -r "jqf" 
