*m203d02c;

%macro name(fullname);
   %let first=%scan(&fullname,2);
   %let last=%scan(&fullname,1);
   %let newname=&first &last;
   %put &newname;
%mend name;

%name(%str(O%'Malley, George))
