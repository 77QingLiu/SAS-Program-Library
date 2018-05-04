%macro AHGsumextrt(dsn,var,by=,trt=,out=stats,print=0,alpha=0.05
,stats=n mean median  min max
 /* min\4. median\5.1 max\4. */
 /*n @ min '-' max*/
,orie=vert
,labels=
,left=left
,statord=
);
%local thedsn byflag;
%if %AHGblank(&statord) %then %let statord=ahgdummy%AHGrdm(10);
%AHGgettempname(thedsn);
%if %AHGblank(&by) %then 
%do;
%let byflag=missing;
%let by=%AHGrdm(10);
%end;
data &thedsn;
  set &dsn;
 %if &byflag=missing %then  &by=1; ;
run;



%local fn;
%let fn=ahgxxxyyyzzz;
%macro ahgxxxyyyzzz(one);
  %IF not  (%index(&one,%str(%")) or %index(&one,%str(%'))) %THEN 1;
  %ELSE 0;
%mend;
/*%local finallabel;*/
/*%let finallabel=%AHGname(&stats,but=@);*/

%if %index(&stats,@)=0 %then %let stats=%AHGaddcomma(&stats,comma=@);
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
%local finallabel;
%let finallabel=%AHGname(&labels,but=@);
%AHGpm(finallabel);
%let finallabel=%sysfunc(tranwrd(&finallabel,@,%str( )));
%AHGpm(finallabel);

/*if no explicit definition of orientation then use @ as criteria*/
%if   %AHGblank(&orie)  %then   %if %index(&stats,@) %then %let orie=vert ;%else  %let orie=hori;
%local localstats;
%let localstats=&stats;
%let stats=%sysfunc(tranwrd(&stats,@,%str( )));
%local statN single %AHGwords(mystat,20)
  %AHGwords(myformat,20) %AHGwords(ISstat,20);
%local i sortdsn mystats;
%AHGgettempname(sortdsn);


%do i =1 %to %AHGcount(&stats);
  %let single=%scan(&stats,&i,%str( ));
  %if %&fn(&single) %then %let mystats=&mystats &single ; /*mystats are real stats*/
%end;

%AHGsetstatfmt(statfmt=&mystats);
%let statN=%AHGcount(&stats);

%do i=1 %to &statN;
  %let single=%scan(&stats,&i,%str( ));
  %let mystat&i=%scan(&single,1,\);
  %let myformat&i=%scan(&single,2,\);
  %if %AHGblank(&&myformat&i) and %&fn(&&mystat&i) %then 
  %do;
  %global formatof&&mystat&i;
  %let myformat&i=&&&&formatof&&mystat&i;
  %if %AHGblank(&&myformat&i) %then %let myformat&i=7.2;
  %end;
  %if %&fn(&&mystat&i)  %then %AHGpm(mystat&i myformat&i);
%end;

%AHGdatasort(data =&thedsn , out = , by = &by &trt);

  proc means data=&thedsn noprint %if %AHGnonblank(&alpha) %then alpha=&alpha;;
    var &var;
    by &by &trt;
    output 
    /**/
    %local everyone;
    %let everyone= %str(out=&out ) ;
    %do i=1 %to  &statN;
    %if %&fn(&&mystat&i) %then  %let everyone=&everyone &&mystat&i  %bquote(=)  &&mystat&i;
    %end;
    &everyone
    ;
  run;

%macro ahgD(d=%str(,));
%if &i ne 1 %then &d; 
%MEND;

  proc sql noprint;
    create table temp&out as
    select
    %do i=1 %to  %AHGcount(&stats);
      %if %&fn(&&mystat&i) %then %AHGd &left(put(&&mystat&i, &&myformat&i)) as  &&mystat&i ;
      %else  %AHGd &&mystat&i;
    %end;
    %AHG1(&by,%bquote(,%AHGaddcomma(&by)))
    %AHG1(&trt,%str(,&trt))
    from &out
    ;
    create table &out as
    select *
    from temp&out

    ;quit;

%if %substr(&sysmacroname,1,3)=AHG %then  
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
  %if &num=1 %then %let statement= &statement   %str(theVerticalvar&i=compbl%() %scan(&varlist,&indx);
  %else  %let statement= &statement ||'  '|| %scan(&varlist,&indx);
  %if &num=%AHGcount(&bigsingle) %then  %let  statement= &statement %str(%););
  %end;
%end;

%local vertdsn;
%AHGgettempname(vertdsn);

data &vertdsn;
  set &out;
  keep   %AHG1(&trt,&trt) &BY %do i=1 %to  &varN; theVerticalvar&i  %end;  ;
    %unquote(&statement);
run;

data hori&out;
  set &out;
run;

data &out;
  set &vertdsn;
  keep &BY  
  %AHG1(&labels,label) 
  %AHG1(&statord,&statord) 
  %AHG1(&trt,&trt)
  stat;
  array allvar(1:&varN) theVerticalvar1-theVerticalvar&varN;
  do i=1 to dim(allvar);
  %if not %AHGblank(&labels) %then label=left(scan("%sysfunc(compress(&labels,%str(%'%")))",i,'@'));;
  %if not %AHGblank(&statord) %then &statord=i; ;
  stat=input(allvar(i),$50.);

  output;
  end;  
run;
%if not %AHGblank(&trt) %then
  %do;
  %AHGdatasort(data =&out , out = sort&out, by =&by &statord  label &trt );

  proc transpose data=sort&out out=&out(drop=_name_);
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
  %end;
%end;

%IF %AHGequalmactext(&orie,hori) %then
%do;
data &out;set &vertdsn;run;
%local rdm;
%let rdm=%AHGrdm()_;
%if %AHGblank(&trt) %then %let &rdm.n=1;
%else 
  %do;
  %AHGfreeloop(&out,&trt
  ,cmd=put
  ,in=ahuige
  ,out=ahuige
  ,url=&rdm
  ,addloopvar=0);


  %macro dosomething(dsn);
    data &dsn;
      set &dsn(drop=&trt);
    run;
  %mend;

  %AHGfuncloop(%nrbquote(dosomething(ahuige) ) ,loopvar=ahuige,loops=%AHGwords(&rdm.AHUIGE,&&&rdm.n));


  %AHGmergePrintex(%AHGwords(&rdm.AHUIGE,&&&rdm.n)
  ,by=&by,drop=,out=&out,print=0,prefix=ahuigecol);

  %local varlist;
  %AHGvarlist(&out,Into=varlist);
  %let varlist=&by %AHGremoveWords(&varlist,&by,dlm=%str( ));
  %AHGordvar(&out,&varlist,out=,keepall=0);
  %end;


  %local longlabel;
  %AHGuniq(%do i=1 %to &&&rdm.n;  &finallabel   %end;,longlabel);
    
  %AHGrenamekeep(&out,names=&by &longlabel,out=&out);
%end; 

data &out;
  set &out(drop=%if &byflag=missing %then &by;  
    %if %AHGequalmactext(&orie,vert) and %substr(&statord,1,8)=ahgdummy %then &statord;
);
run;


%if &print %then
%do;
%AHGprt;
%end;
%theexit:
%mend;
