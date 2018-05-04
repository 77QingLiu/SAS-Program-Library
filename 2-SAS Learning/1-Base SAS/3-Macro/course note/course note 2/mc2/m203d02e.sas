*m203d02e;

%macro name(fullname);
   %let first=%qscan(&fullname,2);
   %let last=%qscan(&fullname,1);
   %let newname=&first &last;
   %put      &newname;
%mend name;

%name(%str(Taylor, Jenna))
