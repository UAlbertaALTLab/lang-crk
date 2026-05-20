#!/bin/sh

# compile-hfst-fsts.sh

# Script to compile core FSTs from LEXC and XFSCRIPT source code
# Output: HFST

echo 'Concatenating LEXC source files into: lexicon.lexc.' ;

cat \
./defs/multichars.lexc \
./defs/root.lexc \
./affixes/verb_prefixes.lexc \
./stems/verb_stems.lexc \
./affixes/verb_suffixes.lexc \
> lexicon.lexc

echo 'Compiling HFSTs.' ;

hfst-xfst -F scripts/hfst_compile.xfscript

echo 'Creating HFSTOLs.' ;

hfst-fst2fst -O -i fst/analyser-gt-norm.hfst -o fst/analyser-gt-norm.hfstol
hfst-fst2fst -O -i fst/analyser-gt-desc.hfst -o fst/analyser-gt-desc.hfstol
hfst-fst2fst -O -i fst/generator-gt-norm.hfst -o fst/generator-gt-norm.hfstol
hfst-fst2fst -O -i fst/generator-gt-norm-bound.hfst -o fst/generator-gt-norm-bound.hfstol

echo 'Finished.';

