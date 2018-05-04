%macro AHGlabeldsn(dsn,labels,out=%AHGbasename(%AHGpurename(&dsn)));
  %local varlist labelloop varID;
  %if %index(&labels,\) %then
	  %do;
	  %AHGvarlist(&dsn,Into=varlist,dlm=%str( ),global=0);
	  data &out;
	    set &dsn;
	    %do labelloop=1 %to %AHGcount(&labels,dlm=#);
	    %let varID=%AHGscan2(&labels,&labelloop,1,dlm=#,dlm2=\);
	    label %scan(&varlist,&varid)=%AHGscan2(&labels,&labelloop,2,dlm=#,dlm2=\);
	    %end;
	  run;
	  %end;
  %else
	  %do;
	  %AHGvarlist(&dsn,Into=varlist,dlm=%str( ),global=0);
	  data &out;
	    set &dsn;
	    %do labelloop=1 %to %AHGcount(&labels,dlm=#);
	    %let varID=&labelloop;
	    label %scan(&varlist,&varid)="%scan(&labels,&labelloop,#)";
	    %end;
	  run;
  %end;

%mend;
