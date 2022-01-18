#!/bin/bash

if [ -z "$JAVA_HOME" ]; then
    echo "Error: Please set \$JAVA_HOME";
    exit 1
fi

# How long to run the experiment (seconds)
#DURATION=$((60*60*8))
DURATION=$((60*60*24))

# Use a known port
if [ -z "$2" ] ; then
    PORT=$((5000 + (RANDOM % 1000)))
else
    PORT=$2
fi

echo $PORT

RES=$RESULTS_DIR/closure-knarr

#JQF_SENSITIVITY=3
#JQF_DEBUG=""
#JQF_OPTS="-Xmx1G"
#JQF_CMD="JVM_OPTS=\"-DcentralPort=$PORT -Dtime=$(($DURATION + 60)) -Djqf.ei.UNIQUE_SENSITIVITY=$JQF_SENSITIVITY $JQF_OPTS $JQF_DEBUG\" $JQF_DIR/bin/jqf-ei -c $JQF_DIR/closure/target/test-classes:`$JQF_DIR/closure/classpath.sh`:`$JQF_DIR/scripts/classpath.sh` examples.CompilerTest testWithString $RES"
JQF_SENSITIVITY=3
#JQF_DEBUG="-Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=5555,suspend=n"
#JQF_OPTS="-Xmx12G -Xss1G" #-DusePriorityQueue=true"
JQF_CMD="JVM_OPTS=\"-DcentralPort=$PORT -Dtime=$(($DURATION + 60)) -Djqf.ei.UNIQUE_SENSITIVITY=$JQF_SENSITIVITY $JQF_OPTS $JQF_DEBUG\" $JQF_DIR/bin/jqf-ei -c $JQF_DIR/examples/target/classes:$JQF_DIR/examples/target/test-classes:`$JQF_DIR/scripts/classpath.sh`:`$CLOSURE_DIR/classpath.sh` edu.berkeley.cs.jqf.examples.closure.CompilerTest testWithString $RES"

#Z3_OUTPUT_DIR="-DZ3_OUTPUT_DIR=/home/lganchin/repos/swe/jqf-artifact/results/ant-knarr/"
CENTRAL_DEBUG="-Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=5554,suspend=n"
#CENTRAL_OPTS="-Xmx12G -Xss1G"
CENTRAL_CMD="LD_LIBRARY_PATH=$Z3_DIR $JAVA_HOME/bin/java $CENTRAL_DEBUG $CENTRAL_OPTS -Djava.library.path=$Z3_DIR $Z3_OUTPUT_DIR -cp $GREEN_DIR/green/green.jar:`$JQF_DIR/scripts/classpath.sh` -DcentralPort=$PORT edu.berkeley.cs.jqf.fuzz.central.Central $ROOT/experiments/closure/properties"

#KNARR_DEBUG=""
#KNARR_OPTS="-Xmx20G"
#KNARR_CMD="KNARR_DIR=\"$INSTALL_DIR/knarr\" JVM_OPTS=\"-DcentralPort=$PORT -Dsize=15 $KNARR_OPTS $KNARR_DEBUG\" $JQF_DIR/bin/jqf-knarr -c $JQF_DIR/closure-inst/target/test-classes:`$JQF_DIR/closure/classpath.sh`:`$JQF_DIR/scripts/classpath.sh` examples.CompilerTest testWithString"

KNARR_DEBUG="-Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=5556,suspend=n"
#KNARR_OPTS="-Xmx20G -Xss1G"
KNARR_CMD="JVM_OPTS=\"-DcentralPort=$PORT -Dsize=15 $KNARR_OPTS $KNARR_DEBUG\" $JQF_DIR/bin/jqf-knarr -c $JQF_DIR/examples/target/classes-inst:$JQF_DIR/examples/target/test-classes-inst:`$CLOSURE_DIR/../closure-inst/classpath.sh`:`$JQF_DIR/scripts/classpath.sh` edu.berkeley.cs.jqf.examples.closure.CompilerTest testWithString"

# Launch program driver
if [ "$1" = central ] ; then
    echo $CENTRAL_CMD
    exec bash -c "$CENTRAL_CMD"
elif [ "$1" = knarr ] ; then
    echo "$KNARR_CMD"
    exec bash -c "$KNARR_CMD"
elif [ "$1" = jqf ] ; then
    echo "$JQF_CMD"
    exec bash -c "$JQF_CMD"
fi

# Launch central
screen -S "central-$PORT" -d -m bash -c "$CENTRAL_CMD"

sleep 5

# Launch JQF
screen -S "jqf-$PORT" -d -m bash -c "$JQF_CMD"

sleep 5

# Launch Knarr
screen -S "knarr-$PORT" -d -m bash -c "$KNARR_CMD"

# Re-attach JQF screen to wait for it to exit
screen -r "jqf-$PORT"

# Stop other screens
screen -r "knarr-$PORT" -X kill
screen -r "central-$PORT" -X kill
