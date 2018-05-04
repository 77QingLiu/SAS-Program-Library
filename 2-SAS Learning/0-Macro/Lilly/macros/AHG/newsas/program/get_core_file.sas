%MACRO GETCORE(ALL);
%local i allsas;
%do i=1 %to %AHGcount(&all);
%if %sysfunc(fileexist(d:\newsas\core\%scan(&all,&i,%str( )))) %then %let allsas=&allsas  core\%scan(&all,&i,%str( )) ;
%if %sysfunc(fileexist(d:\newsas\inter\%scan(&all,&i,%str( )))) %then %let allsas=&allsas  inter\%scan(&all,&i,%str( )) ;
%if %sysfunc(fileexist(d:\newsas\adhoc\%scan(&all,&i,%str( )))) %then %let allsas=&allsas  adhoc\%scan(&all,&i,%str( )) ;

%end;
%let allsas=x copy %AHGaddcomma(&allsas,comma=+d:\newsas\draft\blank.sas+) d:\ahg_core.sas %str(;);

x "cd d:\newsas";
 &allsas;

%MEND;

