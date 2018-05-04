*m203d02b;

%macro name(fullname);
   %let first=%scan(&fullname,2,%str(,));
   %let last=%scan(&fullname,1,%str(,));
   %let newname=&first &last;
   %put &newname;
%mend name;

%name(%str(Taylor, Jenna))

