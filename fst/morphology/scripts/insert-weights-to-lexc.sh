#!/bin/sh

# Usage:
#    insert-weights-to-lexc.sh 1:LEXC 2:WEIGHTS 3:WTYPE 4:WINFMULT 5:NMAX 6:RM_ALL_WEIGHTS

# Example:
#    ./insert-weights-to-lexc.sh lexicon.lexc crk_weights.txt log 2 yes '+0' | less

# Alternative ways to define default weights or maximum absolute feature count:
# =10 : exact default weight of 10
# +10 : maximum absolute weight plus 10
# *10 : maximum absolute weight times 10
# x10 : maximum absolute weight times 10
# X10 : maximum absolute weight times 10

cat $1 | gawk -v RM_ALL_WEIGHTS=$6 'BEGIN { rm_all_weights=RM_ALL_WEIGHTS;
  if(rm_all_weights=="yes") rm=1;
}
{
  if(rm)
    gsub("\"weight:[^\"]+\"", "");
  print;
}' |

gawk -v WEIGHTS=$2 -v WTYPE=$3 -v WINFMULT=$4 -v NMAX=$5 'BEGIN { weights=WEIGHTS;
  wtype=WTYPE; winfmult=WINFMULT; nmax=NMAX;

  if(winfmult=="")
    winfmult="*2";
  if(wtype!="log" && wtype!="abs")
    wtype="log";

  while((getline < weights)!=0)
    if(match($2, "(^\\+)|(\\+$)")!=0)
    {
      tag=$2;
      if($1*1>wmax)
        {
          wmax=$1;
          maxtag=tag;
        }
      # gsub("\\+|\\*|\\?|[-]", "\\\\&", tag);
      gsub("0","%0",tag);
      gsub("%+","%",tag);
      w[tag]=$1;
      tlen[tag]=length(tag);
    }
# Section for including lemmas in weighting, which slows down their insertion for now.
#  else
#    {
#      lex=$2;
#      split(lex,f,"+");
#      gsub("\\-","\\-",f[1]);
#      lex=f[1];
#      w[lex]=$1;
#      tlen[lex]=length(f[1]);
#    }

  if(match(nmax, "^=([[:digit:]]+)$", f)!=0)
    {
      if(f[1]<wmax)
        printf "WARNING: Assigned maximum absolute feature count (=%i) less than count for most common feature: %s (=%i).\n", f[1], maxtag, wmax > "/dev/stderr/";
      wmax=f[1];
    }

  if(match(nmax, "^\\+([[:digit:]]+)$", f)!=0)
    wmax=wmax+f[1];

  if(match(nmax, "^[\\*xX]([[:digit:]]+[\\.]?[[:digit:]]*)$", f)!=0)
    wmax=wmax*f[1];

  for(t in w)
    l[t]=-log(w[t]/wmax);

  if(match(winfmult, "^=([[:digit:]]+[\\.]?[[:digit:]]*)$", f)!=0)
    {
      wabsinf=f[1];
      wloginf=f[1];
    }

  if(match(winfmult, "^\\+([[:digit:]]+[\\.]?[[:digit:]]*)$", f)!=0)
    {
      wabsinf=wmax+f[1];
      wloginf=-log(1/wmax)+f[1];
    }

  if(match(winfmult, "^[\\*xX]([[:digit:]]+[\\.]?[[:digit:]]*)$", f)!=0)
    {
      wabsinf=1/f[1];
      wloginf=-log(wabsinf/wmax);
    }

  if(wloginf==0)
    {
      wabsinf=1/winfmult;
      wloginf=-log(wabsinf/wmax);
    }

  # Interim outputting of tags, their lengths, and weights
  # PROCINFO["sorted_in"]="@val_num_desc";
  # for(t in tlen)
  #    print tlen[t], w[t], l[t], t;

  file="\n";
}
{
  # Concatanating all the lines in the entire LEXC file into a single internal file record
  file=file sprintf("%s\n", $0);
}

END {
  nr=split(file, section, "\n(LEXICON |Multichar_Symbols)[^\\n]*\n", seps);
  # sub("^\n", "", seps[1]);

  for(i=1; i<=nr; i++)
     {
       # Reviewing all Multichar_Symbols sections, to assign a default weight for multi-char symbols without a corpus-based weight
       if(match(seps[i], "\nMultichar_Symbols")!=0)
         {
           nf=split(section[i+1], line, "\n");
           for(j=1; j<=nf; j++)
              {
                mc_line=line[j];
                sub("((!.*)|([ ]*))$", "", mc_line); # print "<" mc_line ">";
                if(!(mc_line in w) && mc_line!="")
                  {
                    # Ruling out flag-diacritics, carot+upper-case triggers (^XXX), lower-case+number special characters ([a-z][0-9]) and morpheme boundary markers (<, >, /):
                    if(match(mc_line, "^@[^@]+@")==0 && match(mc_line, "^\\^")==0 && match(mc_line, "^[[:lower:]]+[0-9]+")==0 && mc_line!="%<" && mc_line!="%>" && mc_line!="/")
                      {
                        tlen[mc_line]=length(mc_line)
                        w[mc_line]=wabsinf;
                        l[mc_line]=wloginf;
                        printf "Tag without corpus weight: %s - assigned default weight: %f\n", mc_line, wloginf > "/dev/stderr/";
                      }
                  }
              }
         }

       # Adding weights to LEXICON sections, based on multichar symbols occurring in these sections
       if(match(seps[i], "^\nLEXICON ")!=0)
         {
           new_section="";
           nf=split(section[i+1], line, "\n");
           for(j=1; j<=nf; j++)
              {
                if(match(line[j],"^[^!]+:[^!]+;")!=0)
                  {
                    lexc_line=line[j];
                    # Remove comments
                    sub("!.*", "", lexc_line);
                    # Remove flag-diacritics (to avoid finding tags embedded within the flags)
                    gsub("@[^@]+@", "", lexc_line); # print llexc
                    wlexc=0;

                    # Cycling through all tags with weights based on descending tag length
                    PROCINFO["sorted_in"]="@val_num_desc";
                    for(t in tlen)
                       if(t!="" && index(lexc_line, t)!=0)
                         {
                           # printf "MATCHED tag [%s] in: %s\n", t, lexc_line > "/dev/stderr/";
                           if(wtype=="abs")
                             wlexc+=w[t];
                           else
                             wlexc+=l[t];
                           # Modify tag into regexp for removal with sub()
                           gsub("\\+|\\*|\\?|[-]", "\\\\&", t);
                           sub(t, "", lexc_line);
                         }

                    # Removing previous weights/infostrings on the particular line within LEXC code
                    if(wlexc!=0 && match(line[j], "\"[^\"]*\"")!=0)
                      {
                        lexicon_name=seps[i]; gsub("(^[\\n]+)|([\\n]+$)", "", lexicon_name);
                        printf "Removing previous weight/infostring in LEXC code (line %i in: %s):\n--> %s\n", j, lexicon_name, line[j] > "/dev/stderr/";
                        sub("\"[^\"]*\"", "", line[j]);
                      }
                    # Assigning aggregate weight to LEXC line
                    if(wlexc!=0)
                      sub(";", "\"weight: " wlexc "\" ;", line[j]);
                  }
               new_section=new_section sprintf("%s\n", line[j]);
             }
           sub("\n$", "", new_section);
           section[i+1]=new_section;
         }
     }

  # Outputting entire weighted LEXC code
  sub("^\n", "", seps[1]);
  for(i=1; i<=nr; i++)
     {
       printf "%s", section[i];
       printf "%s", seps[i];
     }

}' | less; exit 0;
