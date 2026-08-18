#!/bin/sh

# compile-hfst-fsts.sh

# Script to compile core FSTs from LEXC and XFSCRIPT source code
# Output: HFST

HFST_BIN=../../../hfst-rs/target/debug/hfst

echo 'Concatenating LEXC source files.' ;

rm lexicon.lexc

while read line; do
    cat "$line" >> lexicon.lexc
done < defs/lexc.list

echo 'Concatenated LEXC source files into: lexicon.lexc.' ;

echo 'Compiling HFSTs.' ;

$HFST_BIN xfst -F scripts/hfst_compile.xfscript

echo 'Compiled HFSTs.' ;

echo 'Creating HFSTOLs.' ;

$HFST_BIN fst2fst -w -i fst/analyser-gt-norm.hfst -o fst/analyser-gt-norm.hfstol
$HFST_BIN fst2fst -w -i fst/analyser-gt-desc.hfst -o fst/analyser-gt-desc.hfstol
$HFST_BIN fst2fst -w -i fst/generator-gt-norm.hfst -o fst/generator-gt-norm.hfstol
$HFST_BIN fst2fst -w -i fst/generator-gt-norm-bound.hfst -o fst/generator-gt-norm-bound.hfstol

echo 'Created HFSTOLs.' ;

echo 'Finished.';

