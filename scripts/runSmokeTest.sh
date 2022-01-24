#!/bin/bash
export FUZZ_OUTPUT=/home/icse22ae/confetti-artifact/local_eval_output

php scripts/runOneSmokeTest.php ant-jqf
php scripts/runOneSmokeTest.php bcelgen-jqf
php scripts/runOneSmokeTest.php closure-jqf
php scripts/runOneSmokeTest.php maven-jqf
php scripts/runOneSmokeTest.php rhino-jqf

php scripts/runOneSmokeTest.php ant-knarr-z3
php scripts/runOneSmokeTest.php bcelgen-knarr-z3
php scripts/runOneSmokeTest.php closure-knarr-z3
php scripts/runOneSmokeTest.php maven-knarr-z3
php scripts/runOneSmokeTest.php rhino-knarr-z3

php scripts/runOneSmokeTest.php ant-knarr-z3-no-global-hint
php scripts/runOneSmokeTest.php bcelgen-knarr-z3-no-global-hint
php scripts/runOneSmokeTest.php closure-knarr-z3-no-global-hint
php scripts/runOneSmokeTest.php maven-knarr-z3-no-global-hint
php scripts/runOneSmokeTest.php rhino-knarr-z3-no-global-hint