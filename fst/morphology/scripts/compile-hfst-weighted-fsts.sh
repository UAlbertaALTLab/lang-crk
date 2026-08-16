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

# bin/generate-a-w-b-s-m-wordform-lemma-anl-frequency-list.sh corpora ~/gt/lang-crk/ " -b 2 /Users/arppe/altdev/lang-crk/fst/morphology/fst/analyser-gt-norm.hfstol" > generated/ahenakew_wolfart_bloomfield_supplements_mason.fst+cg.freq-sorted.txt3
# cat generated/ahenakew_wolfart_bloomfield_supplements_mason.fst+cg.freq-sorted.txt3 | bin/extract-individual-tag-frequencies-from-full-analysis-list.sh > generated/crk_aw_b_s_m.tags_freq.txt
# bin/extract-tag-frequencies-from-cw-entry-lexicalized-derivations.sh dicts/Wolvengrey_altlab.toolbox /Users/arppe/altdev/lang-crk/fst/morphology/fst/analyser-gt-norm.hfstol '(N|V)' '^(P[VN]/|Der/).+' 0 > generated/crk_cw_pvn_der.tags_freq.txt
# bin/aggregate-corpus+dictionary-feature-tag-weights.sh generated/crk_aw_b_s_m.tags_freq.txt generated/crk_cw_pvn_der.tags_freq.txt '1+1' > generated/crk_aw_b_s_m_corp+cw_dict.tags_freq.txt

scripts/insert-weights-to-lexc.sh lexicon.lexc scripts/crk_aw_b_s_m_corp+cw_dict.tags_freq.txt log '*2' '=430631' no 0 > lexicon_weighted.lexc

echo 'Added feature weights into LEXC file: lexicon_weighted.lexc.' ;

echo 'Compiling HFSTs.' ;

hfst-xfst -F scripts/hfst_weighted_compile.xfscript

echo 'Compiled HFSTs.' ;

echo 'Creating HFSTOLs.' ;

hfst-fst2fst -w -i fst/analyser-gt-norm.hfst -o fst/analyser-gt-norm.hfstol
hfst-fst2fst -w -i fst/analyser-gt-desc.hfst -o fst/analyser-gt-desc.hfstol
hfst-fst2fst -w -i fst/generator-gt-norm.hfst -o fst/generator-gt-norm.hfstol
hfst-fst2fst -w -i fst/lexicon.hfst -o fst/lexicon.hfstol
hfst-fst2fst -w -i fst/generator-gt-norm-bound.hfst -o fst/generator-gt-norm-bound.hfstol

echo 'Created HFSTOLs.' ;

echo 'Finished.';

