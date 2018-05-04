*m203d02g;

*attempt to use a blank delimiter;
%macro name(fullname);
   %let first=%qscan(&fullname,2, );
   %let last=%qscan(&fullname,1, );
   %let newname=&first &last;
   %put %str(     &newname);
%mend name;

%name(%str(Taylor, Jenna))

*use the %STR function;
%macro name(fullname);
   %let first=%qscan(&fullname,2,%str( ));
   %let last=%qscan(&fullname,1,%str( ));
   %let newname=&first &last;
   %put %str(     &newname);
%mend name;

%name(%str(Taylor, Jenna))

*additional %PUT statements added below to aid debugging;

*attempt to use a blank delimiter;
%macro name(fullname);
   %let first=%qscan(&fullname,2, );
   %put &=first;
   %let last=%qscan(&fullname,1, );
   %put &=last;
   %let newname=&first &last;
   %put %str(     &newname);
%mend name;

%name(%str(Taylor, Jenna))

*use the %STR function;
%macro name(fullname);
   %let first=%qscan(&fullname,2,%str( ));
   %put &=first;
   %let last=%qscan(&fullname,1,%str( ));
   %put &=last;
   %let newname=&first &last;
   %put %str(     &newname);
%mend name;

%name(%str(Taylor, Jenna))