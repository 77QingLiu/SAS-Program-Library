*m203d04c;

%macro where(state);
   %if %str(&state)=NC %then %put Southeast;
   %else %if %str(&state)=%str(OR) %then %put Northwest;
   %else %put Unknown;
%mend where;

%where(OR)
