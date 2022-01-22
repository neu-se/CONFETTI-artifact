#!/bin/sh

mvn dependency:copy-dependencies -DoutputDirectory="deps"
rm deps/jqf-fuzz-* deps/jqf-instrument-*
