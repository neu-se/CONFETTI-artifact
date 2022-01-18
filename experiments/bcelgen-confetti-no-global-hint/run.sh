#!/bin/bash

RES=$RESULTS_DIR/bcelgen-confetti-no-global-hint
export NO_GLOBAL_DICT=TRUE
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export EXP_CP="`$BCEL_DIR/classpath.sh`"
export EXP_CMD="edu.berkeley.cs.jqf.examples.bcel.ParserTest testWithGenerator $RES"
export EXP_KNARR_CP="`$BCEL_DIR/../bcel-inst/classpath.sh`"
export EXP_CENTRAL_PROPS="$DIR/properties"
export EXP_EXTRA_OPTS="-DhintCombinations=0 -DextraZeroesForZ3=10000"

source $ROOT/experiments/run-knarr.sh
