*m203d02h;

*specify a blank delimiter;
%macro name(fullname);
   %let first=%qscan(&fullname,2,%str( ));
   %let last=%qscan(&fullname,1,%str( ));
   %let newname=&first &last;
   %put %str(     &newname);
%mend name;

%name(%str(Taylor, Jenna))

*specify a comma delimiter;
%macro name(fullname);
   %let first=%qscan(&fullname,2,%str( ));
   %let last=%qscan(&fullname,1,%str(,));
   %let newname=&first &last;
   %put %str(     &newname);
%mend name;

%name(%str(Taylor, Jenna))
