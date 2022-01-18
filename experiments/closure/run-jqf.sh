#!/bin/bash

if [ -z "$JAVA_HOME" ]; then
    echo "Error: Please set \$JAVA_HOME";
    exit 1
fi

# How long to run the experiment (seconds)
#DURATION=28800 #8h
#DURATION=$((60*60*8 ))
DURATION=$((60*60*24 ))
echo $DURATION

# Use a known port
if [ -z "$2" ] ; then
    PORT=$((5000 + (RANDOM % 1000)))
else
    PORT=$2
fi

echo $PORT

RES=$RESULTS_DIR/closure-jqf

JQF_SENSITIVITY=3
JQF_DEBUG=""
JQF_OPTS="-Xmx3G"
JQF_CMD="JVM_OPTS=\"-DcentralPort=$PORT -Dtime=$DURATION -Djqf.ei.UNIQUE_SENSITIVITY=$JQF_SENSITIVITY $JQF_OPTS $JQF_DEBUG\" $JQF_DIR/bin/jqf-ei -c $JQF_DIR/closure/target/test-classes:`$JQF_DIR/closure/classpath.sh`:`$JQF_DIR/scripts/classpath.sh` examples.CompilerTest testWithString $RES"


# Launch program driver
echo "$JQF_CMD"
exec bash -c "$JQF_CMD"
