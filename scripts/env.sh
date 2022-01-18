#!/bin/bash

#export GIT_SSH_COMMAND="/usr/bin/ssh -i /vagrant/knarr.pem"

# wget command to download programs/data
export WGET="$(which wget) -nc"

# Root dir
export ROOT=/home/icse22ae/confetti-artifact

# Location of fuzz_output
export FUZZ_OUTPUT=/home/icse22ae/icse_22_fuzz_output


if [ -z "$ROOT" ]; then
    echo "Please set project ROOT on file scripts/env.sh";
    exit 1
fi

# Where everything is downloaded
export DOWNLOAD_DIR=$ROOT/downloads

# Where everything is installed
export INSTALL_DIR=$ROOT/software

#export JAVA_HOME=$INSTALL_DIR/jvm

if [ -z "$JAVA_HOME" ]; then
    echo "Please export JAVA_HOME (or set it on file scripts/env.sh)";
    exit 1
fi

export PATH=$JAVA_HOME/bin:$PATH

# Results directory
export RESULTS_DIR=$ROOT/results

# Plots directory
export PLOTS_DIR=$ROOT/plots

# Reports directory
export REPORTS_DIR=$ROOT/reports

# Data directory
export DATA_DIR=$ROOT/data

# Patch directory
export PATCH_DIR=$ROOT/patches

# Cloned repos dir
export REPOS_DIR=$ROOT/repos

export GREEN_REPO_URL=https://github.com/gmu-swe/green-solver.git
export GREEN_BRANCH=master
export GREEN_DIR=$INSTALL_DIR/green


export KNARR_REPO_URL="https://github.com/gmu-swe/knarr.git" ;
export KNARR_BRANCH=icse-22-confetti-evaluation
export KNARR_DIR=$INSTALL_DIR/knarr

export Z3_DIR=$INSTALL_DIR/z3

export CLOSURE_REPO_URL=git@github.com:google/closure-compiler.git
export CLOSURE_VERSION=v20190415
export CLOSURE_BRANCH=closure-compiler-parent-$CLOSURE_VERSION
export CLOSURE_DIR=$INSTALL_DIR/closure

export RHINO_DIR=$INSTALL_DIR/rhino

export MAVEN_DIR=$INSTALL_DIR/maven

export ANT_DIR=$INSTALL_DIR/ant

export BCEL_DIR=$INSTALL_DIR/bcel

export BATIK_DIR=$INSTALL_DIR/batik

export JQF_REPO_URL=https://github.com/neu-se/confetti
export JQF_BRANCH=icse-22-evaluation
export JQF_DIR=$INSTALL_DIR/jqf

export JQF_VANILLA_REPO_URL=https://github.com/neu-se/jqf-non-colliding-coverage.git
export JQF_VANILLA_BRANCH=jqf-1.1-with-non-colliding-coverage
export JQF_VANILLA_DIR=$INSTALL_DIR/jqf-vanilla
