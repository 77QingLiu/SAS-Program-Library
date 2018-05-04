%macro AHGfuncloop(func,loopvar=ahuige,loops=,execute=yes);
  %local i j cmd perccmd;
  %let j=%AHGcount(&loops);
  %do i=1 %to &j;
  %*put i=&i;
  %let cmd=%sysfunc(tranwrd(&func,&loopvar,%scan(&loops,&i,%str( ))));
  %*put this iteration of macro execution is.........;
/*  %put this iteration of macro execution is...No &i...... %nrstr(%%)&cmd%str(;);*/
  %let perccmd=%nrstr(%%)&cmd;
  %if &execute=yes %then %unquote(&perccmd);
  %end;
%mend;
