%macro AHGsumtrt(dsn,var,by,trt,out=stats,print=0,alpha=0.05
,stats=n mean median  min max
 /* min\4. median\5.1 max\4. */
 /*n @ min '-' max*/
,orie=
,labels=
,left=left
,statord=
);
%macro ahgD(d=%str(,));
%if &i ne 1 %then &d; 
%MEND;
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

/*if no explicit definition of orientation then use @ as criteria*/
%if   %AHGblank(&orie)  %then   %if %index(&stats,@) %then %let orie=vert ;%else  %let orie=hori;
%if %AHGequalmactext(&orie,hori) and  %AHGblank(&statord) %then %let statord=statord34325435;


%local localstats;
%let localstats=&stats;
%let stats=%sysfunc(tranwrd(&stats,@,%str( )));
%local statN single %AHGwords(mystat,20)
  %AHGwords(myformat,20) %AHGwords(IsStat,20);
%local i sortdsn mystats;

%AHGgettempname(sortdsn);

%if not %AHGblank(&by) %then %AHGdatasort(data =&dsn , out =&sortdsn , by = &by &trt );
%else %let sortout=&dsn;


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

  proc means data=&sortdsn noprint alpha=&alpha;;
    var &var;
    by &by &trt;
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
      %if &&isStat&i %then %ahgd &left(put(&&mystat&i, &&myformat&i)) as  &&mystat&i ;
      %else  %ahgd &&mystat&i as mystat&i;
    %end;
    ,%AHGaddcomma(&by &trt)
    from &out
    ;quit;

%local labeln labelmodi labelfinal;
%let labelmodi=%sysfunc(tranwrd(&labels,@,%str( )));
%let labeln=%AHGqcount(&labelmodi);
%do i=1 %to &labeln;
%let labelfinal=&labelfinal%ahgd(d=@)%AHGqscan(&labelmodi,&i);
%end;
%AHGrelabel(old&out,out=&out,pos=,labels=&labelfinal@%AHGaddcomma(&by &trt,comma=@));

%if &orie=hori %then  
%do;
/*%local someVars;*/
/*%do i=1 %to %AHGcount(&stats);*/
/*    %if &&isStat&i %then %let someVars=&somevars  &&mystat&i ;*/
/*    %else %let someVars=&somevars mystat&i;*/
/*%end;*/
/**/
/*data &out test;*/
/*  set &out;*/
/*  format ahgid3457843 $100.;*/
/*  ahgid3457843=catx('_',&trt,&statord);*/
/*run;*/
/**/
/*proc transpose data=&out out=&out;*/
/*  var &someVars;*/
/*  by &by;*/
/*  id ahgid3457843;*/
/*run;*/

%AHGfreeloop(&out,&trt
,cmd=put
,in=ahuige
,out=ahuige
,url=stat_
,addloopvar=0);


%macro dosomething(dsn);
  data &dsn;
    set &dsn(drop=&trt);
  run;
%mend;

%AHGfuncloop(%nrbquote(dosomething(ahuige) ) ,loopvar=ahuige,loops=%AHGwords(stat_AHUIGE,&stat_n));



/*%AHGpm(stat_n);*/
/*%AHGdsnInLib(lib=work,list=dsnlist,mask='stat_%%');*/
/*%put %AHGwords(stat_,&stat_n);*/

%AHGmergePrintex(%AHGwords(stat_AHUIGE,&stat_n)
,by=&by,drop=,out=&out,print=0,prefix=ahuigecol);

%local varlist;
%AHGvarlist(&out,Into=varlist);
%let varlist=&by %AHGremoveWords(&varlist,&by,dlm=%str( ));
%AHGordvar(&out,&varlist,out=,keepall=0);
%end;

%if &orie=vert %then  
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
  keep &BY &trt %do i=1 %to  &varN; theVerticalvar&i  %end;  ;
    %unquote(&statement);
run;

data hori&out;
  set &out;
run;

data new&out;
  set &vertdsn;
  keep &BY &trt  
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

%AHGdatasort(data =new&out , out = sort&out, by =&by &statord  label &trt );

proc transpose data=sort&out out=&out(drop=&statord _name_);
  var stat;
  by &BY  
  &statord
  %if not %AHGblank(&labels) %then label;   
  ;
  id &trt;
run;

%local myvars  entrys IDs;
%AHGvarlist(&out,Into=myvars );
%let IDs=%AHGremoveWords(&myvars,&BY &statord label );
%let entrys=%AHGremoveWords(&myvars,&ids);
%AHGsortwords(&IDS,into=ids);
%AHGordvar(&out,&entrys &ids,out=,keepall=0);

/*%AHGdatadelete(data=&vertdsn);*/

%end;

%if &print %then
%do;
%AHGprt;
%end;
%theexit:
%mend;
