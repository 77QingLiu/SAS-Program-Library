%macro AHGsetstatfmt(statfmt=);
%local i statement allstatfmt;
%let allstatfmt=n\5. std\6.2 mean\6.1 median\6.1 min\6.1 max\6.1 lclm\6.2 uclm\6.2 p25\6.2 p50\6.2 p75\6.2;
%do i=1 %to %AHGcount(&statfmt);
  %if %index(%scan(&statfmt,&i,%str( )),\) %then %let allstatfmt=&allstatfmt %scan(&statfmt,&i,%str( ));
%end;
%do i=1 %to %AHGcount(&allstatfmt);
%let statement=%nrstr(%global) formatof%scan(%scan(&allstatfmt,&i,%str( )),1,\);
%unquote(&statement);
%if %AHGblank(%scan(%scan(&allstatfmt,&i,%str( )),2,\)) %then %let formatof%scan(%scan(&allstatfmt,&i,%str( )),1,\)=6.2;
%else %let formatof%scan(%scan(&allstatfmt,&i,%str( )),1,\)=%scan(%scan(&allstatfmt,&i,%str( )),2,\);

%end;

%mend;
