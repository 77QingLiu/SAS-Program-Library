%macro onlylocalPC;
%if (&SYSSCP=WIN) OR (NOT %SYSFUNC(LIBREF(STORED)))  %then
%do;
%let statdrive=\\gh3nas01\gh3nas_sales.grp\LCDDMAC\STATS;
libname Myadam "&STATDRIVE\SA\Macro library\Macro learning tool\adam";
option sasautos=(sasautos "&statdrive\sa\Macro library\Macro learning tool\macros" "&statdrive\sa\Macro library\Macro learning tool\macros\ahg\core");
option mrecall MPRINT nosymbolgen;
option ls=124;
%end;
%mend;
%onlylocalPC;
/*
libname user 'd:\temp\work';

libname AHGcat 'S:\SA\Macro library\Macro learning tool\sas7bcat';
options mstored sasmstore=AHGCAT;

data  thebeginning;
*	format line $%sysfunc(getoption(ls)).;
	label line =' ';
	line=repeat('#',getoption('ls')-1);
run;

proc print data=thebeginning;run;
*/