#!/bin/bash
cd /home/icse22ae/confetti-artifact


source scripts/env.sh
LOCALOUT=forensics_results.csv
ZIP=$4
FILENAME=$(basename $ZIP)
TEMPDIR="${FILENAME%.*}"


tar xzf $ZIP
bash software/jqf/scripts/evaluate_extended_dict.sh $1 $2 $LOCALOUT $TEMPDIR/corpus

mv $LOCALOUT $3
rm -rf $TEMPDIR
