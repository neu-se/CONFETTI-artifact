#!/bin/bash

mkdir -p $PLOTS_DIR/closure
pushd $PLOTS_DIR/closure
{
    cp $RESULTS_DIR/closure-jqf/plot_data jqf.csv
    cp $RESULTS_DIR/closure-knarr/plot_data knarr.csv
    $JQF_DIR/scripts/plot.py jqf.csv knarr.csv
}
popd
