#!/bin/bash

if [ -z "$JAVA_HOME" ]; then
    echo "Error: Please set \$JAVA_HOME";
    exit 1
fi

while getopts ":d:h" opt; do
  case $opt in
    /?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    d)
      JQF_DEBUG="-Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=5555,suspend=y"
      ;;
    h)
      CLOSURE_DIR="$CLOSURE_DIR-HEAD"
      ;;
  esac
done
shift $((OPTIND-1))

JQF_CMD="$JAVA_HOME/bin/java $JQF_DEBUG -cp $JQF_DIR/examples/target/test-classes:`$CLOSURE_DIR/classpath.sh`:`$JQF_DIR/scripts/classpath.sh` edu.berkeley.cs.jqf.examples.closure.CompilerTest $@"

echo "$JQF_CMD"
exec bash -c "$JQF_CMD"
