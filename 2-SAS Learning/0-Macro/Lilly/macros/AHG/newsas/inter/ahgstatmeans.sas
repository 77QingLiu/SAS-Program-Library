%macro AHGstatmeans(dsn,var,out=stats,print=0,alpha=0.05
,stats=n mean median  min max
,split=\
,split2=#
,orie=hori
,random=
);
%if not %AHGblank(&random) %then %let random=stat_&random._;
%else %let random=stat_;
%local statN single %AHGwords(mystat,20)
 %AHGwords(myformat,20) %AHGwords(IsStat,20);
%local i sortdsn mystats;
%AHGgettempname(sortdsn);
data &sortdsn;
  set &dsn;
run;
%do i =1 %to %AHGcount(&stats);
 %let single=%scan(&stats,&i,%str( ));
 %let isStat&i=0;
 %if not %index(&single,%str(%")) %then
 %do;
 %let isStat&i=1;
 %let mystats=&mystats &single ;
 %end;
%end;
%AHGsetstatfmt(statfmt=&mystats);
%let statN=%AHGcount(&stats);
%do i=1 %to &statN;
 %let single=%scan(&stats,&i,%str( ));
 %let mystat&i=%scan(&single,1,&split);
 %let myformat&i=%scan(&single,2,&split);
 %if %AHGblank(&&myformat&i) and %str(&&isStat&i) %then %let myformat&i=&&&&formatof&&mystat&i;
 %if &&isStat&i %then 
    %do;
    %AHGpm(mystat&i myformat&i);
    %put ahuige=&random&&mystat&i;
    %global &random&&mystat&i;;
    %end;

%end;
%put I am fine 2;
 proc means data=&sortdsn noprint alpha=&alpha;;
  var &var;
  output out=&out 
  %do i=1 %to  &statN;
  %if &&isStat&i %then &&mystat&i%str(=)&&mystat&i;
  %end;
  ;
 run;
 
%if &orie=hori %then
 %do;
 proc sql noprint;

  select '' 
  %do i=1 %to  %AHGcount(&stats);
   %if &&isStat&i %then ,%AHGmyput(&&mystat&i, &&myformat&i) ;
  %end;
  into :temp
  %do i=1 %to  %AHGcount(&stats);
   %if &&isStat&i %then  ,:&random&&mystat&i ;
  %end;
  from &out
  ;

  %if not &print %then create table &out as ;
  select ''
  %do i=1 %to  %AHGcount(&stats);
   %if &&isStat&i %then ,put(&&mystat&i, &&myformat&i) as  &&mystat&i ;
   %else  ,&&mystat&i;
  %end;
  from &out
  ;quit;
 %end;
%if &orie=vert %then 
 %do;
 data &out;
  set  &out ;
    format ahuigeby $50.;
  %do i=1 %to  %AHGcount(&stats);
   %if &&isStat&i %then ahuigeby=put(&&mystat&i, &&myformat&i); 
   %else  ahuigeby=&&mystat&i;;
      output;
  %end;
    keep ahuigeby;
 run;
 %end;
%AHGpmlike(stat);
%mend;
