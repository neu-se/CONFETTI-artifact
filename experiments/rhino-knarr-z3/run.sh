#!/bin/bash

RES=$RESULTS_DIR/rhino-knarr-z3
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export EXP_CP="`$RHINO_DIR/classpath.sh`"
export EXP_CMD="edu.berkeley.cs.jqf.examples.rhino.CompilerTest testWithGenerator $RES"
export EXP_KNARR_CP="`$RHINO_DIR/../rhino-inst/classpath.sh`"
export EXP_CENTRAL_PROPS="$DIR/properties"
export EXP_EXTRA_OPTS="-DhintCombinations=0"

source $ROOT/experiments/run-knarr.sh
