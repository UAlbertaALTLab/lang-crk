#!/bin/sh

# compile-hfst-weighted-fsts.sh

# Script to compile core FSTs from LEXC and XFSCRIPT source code
# Output: HFST

echo 'Concatenating LEXC source files.' ;

rm lexicon.lexc

while read line; do
    cat "$line" >> lexicon.lexc
done < defs/lexc.list

echo 'Concatenated LEXC source files into: lexicon.lexc.' ;

# Max: 119400 (Ipc) + 90831 (V) + 61599 (N) + 21906 (Pron) + 106523 (CLB) +30372 (Punct) = 430631

echo 'Adding feature weights into LEXC file: lexicon.lexc.' ;

scripts/insert-weights-to-lexc.sh lexicon.lexc scripts/crk_a_w_b_s_m.tags_freq.txt log '*2' '=430631' yes > lexicon_weighted.lexc

echo 'Added feature weights into LEXC file: lexicon_weighted.lexc.' ;

echo 'Compiling HFSTs.' ;

hfst-xfst -F scripts/hfst_weighted_compile.xfscript

echo 'Compiled HFSTs.' ;

echo 'Creating HFSTOLs.' ;

hfst-fst2fst -w -i fst/analyser-gt-norm.hfst -o fst/analyser-gt-norm.hfstol
hfst-fst2fst -w -i fst/analyser-gt-desc.hfst -o fst/analyser-gt-desc.hfstol
hfst-fst2fst -w -i fst/generator-gt-norm.hfst -o fst/generator-gt-norm.hfstol
hfst-fst2fst -w -i fst/generator-gt-norm-bound.hfst -o fst/generator-gt-norm-bound.hfstol

echo 'Created HFSTOLs.' ;

echo 'Finished.';

