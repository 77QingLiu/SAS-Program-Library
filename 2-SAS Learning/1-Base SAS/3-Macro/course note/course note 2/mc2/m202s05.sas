*m202s05;

%macro try;
   %put *** third try ***;
%mend try;

%try

%sysmacdelete try;

options mrecall sasautos=("&path\my autocall macros", sasautos);
*options mrecall sasautos=("S:\workshop\my autocall macros", sasautos);

%try

options nomrecall;

%put %datatyp(abc);