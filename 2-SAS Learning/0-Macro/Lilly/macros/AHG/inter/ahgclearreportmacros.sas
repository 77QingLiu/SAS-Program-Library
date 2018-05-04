%macro AHGclearReportMacros(startwith=AHGRPT);
  %local i macs;
  %AHGreportmacros(startwith=&startwith,into=macs);
  %do i=1 %to %AHGcount(&macs);
  %symdel %scan(&macs,&i);
  %end;
%mend;
