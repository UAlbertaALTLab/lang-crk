#!/bin/sh

# compile-foma-fsts.sh

# Script to compile core FSTs from LEXC and XFSCRIPT source code
# Output: FOMA

echo 'Concatenating LEXC source files into: lexicon.lexc.' ;

cat \
./defs/multichars.lexc \
./defs/root.lexc \
./affixes/verb_prefixes.lexc \
./stems/verb_stems.lexc \
./affixes/verb_suffixes.lexc \
./affixes/noun_prefixes.lexc \
./affixes/prenouns.lexc \
./stems/noun_stems.lexc \
./affixes/noun_suffixes.lexc \
> lexicon.lexc

echo 'Compiling FOMA FSTs.' ;

foma -f scripts/foma_compile.xfscript

echo 'Finished.';

