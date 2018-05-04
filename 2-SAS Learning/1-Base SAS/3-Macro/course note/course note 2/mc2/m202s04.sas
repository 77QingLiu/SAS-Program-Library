*m202s04;

%macro try;
   %put *** second try ***;
%mend try;

%sysmacdelete try;

%try