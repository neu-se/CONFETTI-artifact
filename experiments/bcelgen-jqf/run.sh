#!/bin/bash

RES=$RESULTS_DIR/bcelgen-jqf
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export EXP_CP="`$BCEL_DIR/classpath.sh`"
export EXP_CMD="edu.berkeley.cs.jqf.examples.bcel.ParserTest testWithGenerator $RES"
export EXP_KNARR_CP="not-used"
export EXP_CENTRAL_PROPS="not-used"

source $ROOT/experiments/run-jqf.sh
