%macro AHGclearlog(opt);
  %if %AHGblank(&opt) %then %let opt=log lst tree;
  %if %AHGonwin %then
  %do;
    %if %AHGpos(&opt,log) %then dm "clear log";;
    %if %AHGpos(&opt,lst) %then dm "clear lst";;
    %if %AHGpos(&opt,tree) %then dm 'odsresults; clear';;
  %end;
%mend;

