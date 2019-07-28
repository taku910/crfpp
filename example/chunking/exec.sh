#!/bin/sh

BIN_PATH="${1:-../..}"

$BIN_PATH/crf_learn -c 4.0 template train.data model
$BIN_PATH/crf_test -m model test.data

$BIN_PATH/crf_learn -a MIRA template train.data model
$BIN_PATH/crf_test -m model test.data

# $BIN_PATH/crf_learn -a CRF-L1 template train.data model
# $BIN_PATH/crf_test -m model test.data

rm -f model
