#!/bin/sh

# compile-foma-fsts.sh

# Script to compile core FSTs from LEXC and XFSCRIPT source code
# Output: FOMA

echo 'Concatenating LEXC source files into: lexicon.lexc.' ;

rm lexicon.lexc

while read line; do
    cat "$line" >> lexicon.lexc
done < defs/lexc.list

echo 'Compiling FOMA FSTs.' ;

foma -f scripts/foma_compile.xfscript

echo 'Finished.';

