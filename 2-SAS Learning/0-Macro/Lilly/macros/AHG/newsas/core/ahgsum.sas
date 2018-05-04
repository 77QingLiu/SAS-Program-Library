%macro AHGsum(dsn,var,by,out=stats,print=0,alpha=
,stats=n mean median  min max
,orie=
,labels=
,left=left
,statord=
);


%if %index(&stats,@)=0 %then %let stats=%AHGaddcomma(&stats,comma=@);

/*%if &orie=vert and %index(&stats,@)=0 %then %let stats=%AHGaddcomma(&stats,comma=@);*/

%macro dosomething;
%local i j one;
%do i=1 %to %AHGcount(&stats,dlm=@);
  %let one=%scan(&stats,&i,@);
  %let labels=&labels@;
  %do j=1 %to %AHGcount(&one);
    %let labels=&labels %AHGscan2(&one,&j,1,dlm=%str( ),dlm2=\);
  %end;
%end;
%let labels=%substr(&labels,2);
%mend;
%if %AHGblank(&labels) %then %doSomething ;
%if not %AHGblank(&labels) and not %index(&labels,@) %then %let labels=%AHGaddcomma(&labels,comma=@);

/*if no explicit definition of orientation then use @ as criteria*/
%if   %AHGblank(&orie)  %then   %if %index(&stats,@) %then %let orie=vert ;%else  %let orie=hori;
%local localstats;
%let localstats=&stats;
%let stats=%sysfunc(tranwrd(&stats,@,%str( )));
%local statN single %AHGwords(mystat,20)
  %AHGwords(myformat,20) %AHGwords(IsStat,20);
%local i sortdsn mystats;

%let sortdsn=&dsn;


%do i =1 %to %AHGcount(&stats);
  %let single=%scan(&stats,&i,%str( ));
  %let isStat&i=0;
  %if not  (%index(&single,%str(%")) or %index(&single,%str(%'))) %then
  %do;
  %let isStat&i=1;
  %let mystats=&mystats &single ; /*mystats are real stats*/
  %end;
%end;


%AHGsetstatfmt(statfmt=&mystats);
%let statN=%AHGcount(&stats);

%do i=1 %to &statN;
  %let single=%scan(&stats,&i,%str( ));
  %let mystat&i=%scan(&single,1,\);
  %let myformat&i=%scan(&single,2,\);

  %if %AHGblank(&&myformat&i) and %str(&&isStat&i) %then 
  %do;
  %global formatof&&mystat&i;
  %let myformat&i=&&&&formatof&&mystat&i;
  %if %AHGblank(&&myformat&i) %then %let myformat&i=7.2;
  %end;
  %if &&isStat&i %then %AHGpm(mystat&i myformat&i);
%end;


  proc means data=&sortdsn noprint %AHG1(&alpha,%str(alpha=&alpha));  ;
    var &var;
    by &by;
    output out=&out 
    %do i=1 %to  &statN;
    %if &&isStat&i %then &&mystat&i%str(=)&&mystat&i;
    %end;
    ;
  run;




  proc sql noprint;
    create table old&out as
    select
    
    %do i=1 %to  %AHGcount(&stats);
      %if &&isStat&i %then %AHGd &left(put(&&mystat&i, &&myformat&i)) as  &&mystat&i ;
      %else  %AHGd &&mystat&i;
    %end;
    %if not %AHGblank(&by) %then ,%AHGaddcomma(&by);
    
    from &out
    ;quit;

%local labeln labelmodi labelfinal;
%let labelmodi=%sysfunc(tranwrd(&labels,@,%str( )));
%let labeln=%AHGqcount(&labelmodi);
%do i=1 %to &labeln;
%let labelfinal=&labelfinal@%AHGqscan(&labelmodi,&i);
%end;
%AHGrelabel(old&out,out=&out,pos=,labels=&labelfinal %if not %AHGblank(&by) %then @%AHGaddcomma(&by,comma=@););
%if %AHGequalmactext(&orie,hori)=1 and (not %AHGblank(&by)) %then 
%do;
%local varlist;
%AHGvarlist(&out,Into=varlist);
%let varlist=&by %AHGremoveWords(&varlist,&by,dlm=%str( ));
%AHGordvar(&out,&varlist,out=,keepall=0);
%end;

%if %AHGequalmactext(&orie,vert) %then  
%do;

%local varlist varN bigsingle statement;
%AHGvarlist(&out,Into=varlist,dlm=%str( ),global=0);
%local  num indx  ;
%let indx=0;
%let varN=%AHGcount(&localstats,dlm=@);
%AHGpm(varN);
%do i=1 %to &varN;
  %let bigsingle=%scan(&localstats,&i,@);
  %do num=1 %to %AHGcount(&bigsingle);
  %let indx=%eval(&indx+1);
  %if &num=1 %then %let statement= &statement   %str(theVerticalvar&i=) %scan(&varlist,&indx);
  %else  %let statement= &statement ||'  '|| %scan(&varlist,&indx);
  %if &num=%AHGcount(&bigsingle) %then  %let  statement= &statement %str(;);
  %end;
%end;

%local vertdsn;
%AHGgettempname(vertdsn);

data &vertdsn;
  set &out;
  keep &BY %do i=1 %to  &varN; theVerticalvar&i  %end;  ;
    %unquote(&statement);
run;

data hori&out;
  set &out;
run;

data &out;
  set &vertdsn;
  keep &BY  
  %if not %AHGblank(&labels) %then label; 
  %if not %AHGblank(&statord) %then &statord;
  stat;
  array allvar(1:&varN) theVerticalvar1-theVerticalvar&varN;
  do i=1 to dim(allvar);
  %if not %AHGblank(&labels) %then label=left(scan("%sysfunc(compress(&labels,%str(%'%")))",i,'@'));;
  %if not %AHGblank(&statord) %then &statord=i; ;
  stat=input(allvar(i),$50.);

  output;
  end;

  
run;

/*%AHGdatadelete(data=&vertdsn);*/




%end;

%if &print %then
%do;
%AHGprt;
%end;
%theexit:
%mend;
