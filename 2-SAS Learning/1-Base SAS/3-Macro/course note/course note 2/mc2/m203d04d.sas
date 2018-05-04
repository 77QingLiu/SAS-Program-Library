*m203d04d;

%macro where(state);
   %if %superq(state)=NC %then %put Southeast;
   %else %if %superq(state)=%str(OR) %then %put Northwest;
   %else %put Unknown;
%mend where;

%where(OR)
