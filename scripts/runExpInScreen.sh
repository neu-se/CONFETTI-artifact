#!/bin/bash
source scripts/env.sh
mkdir -p $ROOT/results/$1
bash experiments/$1/run.sh
