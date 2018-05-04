%macro AHGcount(line,dlm=%str( ));
  %local i AHG66TheEnd;
  %let i=1;
  %do %until(&AHG66TheEnd=yes);
      %if  %qscan(%bquote(&line),&i,&dlm) eq %str() %then
      %do;
      %let AHG66TheEnd=yes;
      %eval(&i-1)
      %end;
    %else %let i=%eval(&i+1);
  %end;

%mend;
