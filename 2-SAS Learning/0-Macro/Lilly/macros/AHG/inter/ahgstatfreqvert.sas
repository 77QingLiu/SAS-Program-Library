%macro AHGstatfreqvert(dsn,var,out=
,stats=
,varfmt=
,missing=0
,print=1
/* macro not done*/

);   
%local tempstats mycol myby mydsn i stat_n stat_percent;
%local tempdsn myrandom;
%let myrandom=%AHGrandom;
%AHGgettempname(tempdsn);

%if %AHGblank(&varfmt) %then 
%do;
%let mycol=&var;
%let myby=&var;
%let mydsn=&dsn;
%end;
%else %if %index(&varfmt,\) %then
%do;
%let mycol=&var.fmt&myrandom;
%let myby=by&var&myrandom;
%let mydsn=&tempdsn;
%end;
%else %if not %index(&varfmt,\) and not %AHGblank(&varfmt) %then
%do;
%let mycol=&var.fmt&myrandom;
%let myby=&var;
%let mydsn=&tempdsn;

data &tempdsn;
	set &dsn;
	&var.fmt&myrandom=&varfmt;
run;
%end;


%if %index(&varfmt,\) %then
%do;
/*when it is a var then do nothing*/
/**/
/*when it is a couple of rules*/

data &mydsn;
  set &dsn;
  format &var.fmt&myrandom $50.;
  %do i=1 %to %AHGcount(&varfmt,dlm=#);
  if &var=%AHGscan2(&varfmt,&i,1,dlm=#,dlm2=\) then 
  do;
  &var.fmt&myrandom=%AHGscan2(&varfmt,&i,2,dlm=#,dlm2=\);;
  by&var&myrandom=&i;
  end;
  %end;
run;

%end;


%if %AHGblank(&out)  %then %let out=&sysmacroname.out; 


%local total;
%local missingSign;
%let total=0;
%let missingSign=;
%if &missing %then 
%do;
%let missingSign=%str(*);
proc sql noprint;
  select count(*) into :total
  from &mydsn
  ;quit;

%end;
%else  
%do;
%let missingSign=&var;
proc sql noprint;
  select count(&var) into :total
  from &mydsn
  ;quit;
%end;
%if &total=0 %then %goto Quit;
%let stat_n=count(&missingSign);
%let stat_percent=count(&missingSign)/&total;
%let tempstats=&stats;
%let stats=;
%local single;
%do i=1 %to %AHGcount(&tempstats);
%let single=%scan(&tempstats,&i,%str( ));
%if not  (%index(&single,%str(%")) or %index(&single,%str(%'))) %then %let stats=&stats , &&stat_&single;
%else %let stats=&stats ,&single;
%end;
%AHGpm(stats);
proc sql;
  %if not &print %then create table &out as;
  select distinct &mycol as ahuigebycol &stats
  from &mydsn
  %if not &missing %then  where not missing(&var) ;
  group by &var
  order by &myby
  ;quit;

%quit:

%mend;

