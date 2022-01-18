#!/bin/bash
cd /home/ubuntu
if [ ! -d "/home/ubuntu/jqf-artifact" ]
then
	cp -r /experiment/confetti/jqf-artifact.tgz .
	tar xzf jqf-artifact.tgz
fi

source jqf-artifact/scripts/env.sh
LOCALOUT=forensics_results.csv
ZIP=$4
FILENAME=$(basename $ZIP)
TEMPDIR="${FILENAME%.*}"


tar xzf $ZIP
bash jqf-artifact/software/jqf//scripts/evaluate_extended_dict.sh $1 $2 $LOCALOUT $TEMPDIR/corpus

mv $LOCALOUT $3
rm -rf $TEMPDIR
