#!/bin/sh

# parse-lexc.sh 1: LEXC-FILE 2: MULTICHAR-SYMBOLS-FILE

cat $1 |

gawk -v MULTICHARS=$2 'BEGIN { multichars=MULTICHARS;
  while((getline < multichars)!=0)
    {
      sub("[ ]*!.*$", "");
      gsub("\\+", "\\+");
      gsub("\\^", "\\^");
      gsub("[-]", "[-]");

      if($0!="")
        mcs[$0]=length($0);
    }

  PROCINFO["sorted_in"]="@val_num_desc";
  for(s in mcs)
     regex=regex "|" s;
  sub("|$", "", regex); # print regex;
}
{
  sub("[ ]*!.*$", "");
  if(index($0, ";")!=0)
    {
      sub("[ ]*;.*$", "");
      gsub("% ", "%_");

      n=split($0, f);
      if(n>=2)
        {
          m=split(f[1], ff, ":");
          for(j=1; j<=m; j++)
             {
               printf "%i-%i: ", NR, j;
               p=split(ff[j], fff, regex, seps);
               for(k=1; k<=p; k++)
                  {
                    str="";
                    if(fff[k]!="")
                      {
                        q=split(fff[k], c, "");
                        for(kk=1; kk<=q; kk++)
                           str=str c[kk] " ";
                        sub(" $", "", str);
                        if(str=="")
                          str="[]";
                        printf "%s %s ", str, seps[k];
                      }
                    else
                      printf "%s ", seps[k];
;

                  }
               printf "\n";
	     }
	}
    }
}'
