*m202s03;

%macro try;
   %put *** first try ***;
%mend try;

proc options option=(mautosource sasautos);
run;

options mautosource sasautos=("&path\my autocall macros", sasautos);
*options mautosource sasautos=("S:\workshop\my autocall macros", sasautos);

proc options option=(mautosource sasautos);
run;

%try

%put %datatyp(abc);