#!/bin/bash

if [ -z "$JAVA_HOME" ]; then
    echo "Error: Please set \$JAVA_HOME";
    exit 1
fi

mkdir -p $REPORTS_DIR/closure-knarr
mkdir -p $REPORTS_DIR/closure-jqf

JQF_CMD="$JAVA_HOME/bin/java $JQF_DEBUG -cp $JQF_DIR/closure/target/test-classes:CLOSURE_DIR/target/classes:`$JQF_DIR/closure/classpath.sh`:`$JQF_DIR/scripts/classpath.sh` examples.CompilerTest"

for dir in knarr jqf
do
    FILES=$RESULTS_DIR/closure-$dir/failures/*input
    for f in $FILES
    do
        min="$RESULTS_DIR/closure-$dir/min-fails-by-hand/`basename $f`"
        if [ -f $min ]; then
           f=$min
        fi
        echo "Processing $f"
        ERR1=`mktemp`
        OUT1=`mktemp`
        CMD="${JQF_CMD/CLOSURE_DIR/$CLOSURE_DIR}"
        ff=`mktemp`
        cp $f $ff
        bash -c "$CMD $ff" > /dev/null 2> $ERR1
        bash -c "$CMD $ff" > /dev/null &> $OUT1

        OUT2=`mktemp`
        ERR2=`mktemp`
        CMD="${JQF_CMD/CLOSURE_DIR/$CLOSURE_DIR-HEAD}"
        bash -c "$CMD $ff" > /dev/null 2> $ERR2
        bash -c "$CMD $ff" > /dev/null &> $OUT2
        rm $ff

        if [ -s $ERR2 ]
        then
            VERSION="$CLOSURE_VERSION and current master (`git -C $CLOSURE_DIR-HEAD log --pretty=format:'%H' -n 1`)"
            OUT=$OUT2
        else
            VERSION="$CLOSURE_VERSION"
            OUT=$OUT1
        fi

        cat > $REPORTS_DIR/closure-$dir/`basename $f .input` << EOF
Input for \`SIMPLE_OPTIMIZATIONS\`:

\`\`\`
`cat $f`
\`\`\`

Error output:

\`\`\`
`cat $OUT`
\`\`\`

Affects: $VERSION

EOF
    rm $OUT1 $OUT2
    done
done
