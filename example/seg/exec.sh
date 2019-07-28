#!/bin/sh

BIN_PATH="${1:-../..}"

$BIN_PATH/crf_learn -f 3 -c 4.0 template train.data model
$BIN_PATH/crf_test -m model test.data

$BIN_PATH/crf_learn -a MIRA -f 3 template train.data model
$BIN_PATH/crf_test -m model test.data
rm -f model
