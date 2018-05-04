%macro AHGin(sub,str,case=0);
  %if not &case %then index(left(trim(upcase(&str))),left(trim(upcase(&sub))));
  %else index(left(trim(&str)),left(trim(&sub)))
%mend;
