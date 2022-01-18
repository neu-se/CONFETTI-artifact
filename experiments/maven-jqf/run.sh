#!/bin/bash

RES=$RESULTS_DIR/maven-jqf
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export EXP_CP="`$MAVEN_DIR/classpath.sh`"
export EXP_CMD="edu.berkeley.cs.jqf.examples.maven.ModelReaderTest testWithGenerator $RES"

source $ROOT/experiments/run-jqf.sh
