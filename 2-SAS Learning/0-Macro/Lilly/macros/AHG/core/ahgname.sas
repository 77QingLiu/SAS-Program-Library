%macro AHGname(stats,but=);
%local out final;
%let out=%sysfunc(translate(%bquote(&stats),__,%str(%')%str(%")));
%let out=%sysfunc(compress(&out));
%local i one rank;
%do i=1 %to %length(&out);
%let one=%bquote(%substr(&out,&i,1));
%if %SYSFUNC(NOTALNUM(%bquote(&one))) and not %index(&but,%bquote(&one)) %then %let final=&final._;
%else %let final=&final.%bquote(&one);
%end;
&final
%mend; 
