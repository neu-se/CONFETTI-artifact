#!/bin/bash

RES=$RESULTS_DIR/closure-confetti
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export EXP_CP="`$CLOSURE_DIR/classpath.sh`"
export EXP_CMD="edu.berkeley.cs.jqf.examples.closure.CompilerTest testWithGenerator $RES"
export EXP_KNARR_CP="`$CLOSURE_DIR/../closure-inst/classpath.sh`"
export EXP_CENTRAL_PROPS="$DIR/properties"
export EXP_EXTRA_OPTS="-DhintCombinations=0"

source $ROOT/experiments/run-knarr.sh
