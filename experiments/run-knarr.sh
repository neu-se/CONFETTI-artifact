#!/bin/bash

if [ -z "$JAVA_HOME" ]; then
    echo "Error: Please set \$JAVA_HOME";
    exit 1
fi

if [ -z "$EXP_CP" ]; then
    echo "Error: Please set the experiment classpath \$EXP_CP";
    exit 1
fi

if [ -z "$EXP_PRI_FILE" ]; then
    export EXP_PRI_FILE="/dev/null"
fi

if [ -z "$EXP_KNARR_CP" ]; then
    echo "Error: Please set the experiment classpath for the Knarr instrumented classes \$EXP_KNARR_CP";
    exit 1
fi

if [ -z "$EXP_CMD" ]; then
    echo "Error: Please set the experiment command \$EXP_CMD";
    exit 1
fi

if [ -z "$EXP_CENTRAL_PROPS" ]; then
    echo "Error: Please set the experiment properties file \$EXP_CENTRAL_PROPS";
    exit 1
fi

# How long to run the experiment (seconds)
#DURATION=$((60*60*24))
if [ -z "$DURATION" ]; then
    DURATION=$((60*60*24))
fi
#DURATION=$((60*2))
echo $DURATION

# Z3 Timeout
Z3_TO=$((60*1000)) #10 sec
echo $Z3_TO

# Use a known port
if [ -z "$2" ] ; then
    PORT=$((5000 + (RANDOM % 1000)))
else
    PORT=$2
fi

echo $PORT

JQF_SENSITIVITY=3
#JQF_DEBUG="-Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=5555,suspend=n"
JQF_OPTS="-Xmx5G -Dpriority=$EXP_PRI_FILE $JQF_OPTS"
JQF_CMD="JVM_OPTS=\"-DcentralPort=$PORT -Dtime=$(($DURATION + 60)) -Djqf.ei.UNIQUE_SENSITIVITY=$JQF_SENSITIVITY $JQF_OPTS $JQF_DEBUG $EXP_EXTRA_OPTS\" timeout $(($DURATION + 60)) $JQF_DIR/bin/jqf-ei -c $JQF_DIR/examples/target/classes:$JQF_DIR/examples/target/test-classes:`$JQF_DIR/scripts/classpath.sh`:$EXP_CP $EXP_CMD"

Z3_OUTPUT_DIR=
#CENTRAL_DEBUG="-Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=5554,suspend=n"
CENTRAL_OPTS="-Xmx14G -Xss1G"
CENTRAL_CMD="LD_LIBRARY_PATH=$Z3_DIR $JAVA_HOME/bin/java $CENTRAL_DEBUG $CENTRAL_OPTS -Djava.library.path=$Z3_DIR $Z3_OUTPUT_DIR -DZ3_TIMEOUT=$Z3_TO $EXP_EXTRA_OPTS -cp $GREEN_DIR/green/green.jar:`$JQF_DIR/scripts/classpath.sh` -DcentralPort=$PORT -Dz3StatsLog=$RES/z3.log edu.berkeley.cs.jqf.fuzz.central.Central $EXP_CENTRAL_PROPS"

#KNARR_DEBUG="-Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=5556,suspend=n"
KNARR_OPTS="-Xmx8G -Xss1G"
KNARR_CMD="JVM_OPTS=\"-DcentralPort=$PORT -Dsize=15 $KNARR_OPTS $KNARR_DEBUG $EXP_EXTRA_OPTS\" $JQF_DIR/bin/jqf-knarr -c $JQF_DIR/examples/target/classes-inst:$JQF_DIR/examples/target/test-classes-inst:$EXP_KNARR_CP:`$JQF_DIR/scripts/classpath.sh` $EXP_CMD"

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
screen -S "central-$PORT" -d -m bash -c "$CENTRAL_CMD &> $RES/central.log"

sleep 5

# Launch JQF
screen -S "jqf-$PORT" -d -m bash -c "$JQF_CMD"

sleep 5

# Launch Knarr
screen -S "knarr-$PORT" -d -m bash -c "$KNARR_CMD &> $RES/knarr.log"

# Re-attach JQF screen to wait for it to exit
screen -r "jqf-$PORT"

# Stop other screens
screen -r "knarr-$PORT" -X kill
screen -r "central-$PORT" -X kill
