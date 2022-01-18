#!/bin/bash

RES=$RESULTS_DIR/closure-jqf
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export EXP_CP="`$CLOSURE_DIR/classpath.sh`"
export EXP_CMD="edu.berkeley.cs.jqf.examples.closure.CompilerTest testWithGenerator $RES"

source $ROOT/experiments/run-jqf.sh
