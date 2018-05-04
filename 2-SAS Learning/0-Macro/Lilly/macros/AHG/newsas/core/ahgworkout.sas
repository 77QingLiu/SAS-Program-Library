%macro AHGworkout(fromlib,dsns,tolib=work,pre=,where=%str(where 1));
  %if %AHGblank(&dsns) %then %AHGdsnInLib(lib=&fromlib,list=dsns,lv=1);;
/*  data &tolib..*/
  %local i;
  %do i=1 %to %AHGcount(&dsns);
    data &tolib..&pre%scan(&dsns,&i);
      set &fromlib..%scan(&dsns,&i);
      &where ;
    run;
  %end;

%mend;
