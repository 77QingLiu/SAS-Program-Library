*m203d04b;

%macro where(state);
   %if &state=NC %then %put Southeast;
   %else %if &state=%str(OR) %then %put Northwest;
   %else %put Unknown;
%mend where;

%where(NY)
%where(OR)
