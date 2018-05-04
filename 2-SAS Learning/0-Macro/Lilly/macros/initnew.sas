%let statdrive=\\gh3nas01\gh3nas_sales.grp\LCDDMAC\STATS;
libname AHGcat "&STATDRIVE\SA\Macro library\Macro learning tool\sas7bcat\mac";
options mstored sasmstore=AHGCAT;
%AHGaddsasautos(&statdrive\sa\Macro library\Macro learning tool\macros);
option mrecall MPRINT;



