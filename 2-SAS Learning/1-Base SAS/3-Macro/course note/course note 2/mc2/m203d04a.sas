*m203d04a;

%macro where(state);
   %if &state=NC %then %put Southeast;
   %else %if &state=OR %then %put Northwest;
   %else %put Unknown;
%mend where;

%where(NY)
