%macro AHGcodeCompletion(thedsn,tofile=,cleanWork=0,
metadir= ,n=200,);

%if %AHGequalmactext(&sysuserid,ahuige) %then %let metadir=c:\temp\meta;
%if (not %AHGequalmactext(&sysuserid,c187781) and %AHGblank(&metadir)) 
or %AHGequalmactext(&metadir,study)  %then %let metadir=&studypath\replica_programs_nonsdd\replication_output\temp\meta;
%if %AHGequalmactext(&sysuserid,c187781) and %AHGblank(&metadir) %then %let metadir=%AHGtempdir\meta;

%if %AHGnonblank(&metadir) %then
%do;
%let metadir=%AHGremoveslash(&metadir);
%if  not %sysfunc(fileexist(&metadir)) %then x mkdir "&metadir";
%end;

%local metadsn;
%AHGgettempname(metadsn);
data &metadsn;
  format dir $250.;
run;

%if %sysfunc(fileexist(%AHGuserdir)) %then 
%do;

data _null_;
  file "%AHGuserdir\metadir.last.txt";
  put "&metadir";
run;

%if %sysfunc(fileexist(%AHGuserdir\metadir.txt)) %then %AHGreadline(file=%AHGuserdir\metadir.txt,out=&metadsn);
data &metadsn(keep=dir);
  format dir $250.;
  if _n_=1 then do;dir=put("&metadir",$250.);output;end;
  set &metadsn;
  if line NE '' then dir=line;
  output;
run;

proc sort data=&metadsn nodup;
  by dir;
run;

data _null_;
  file "%AHGuserdir\metadir.txt";
  set &metadsn;
  if  dir ne '' then put dir;
run;
%end;

%if not %index(&thedsn,.) %then %let thedsn=Work.&thedsn;

%if %AHGblank(&tofile) %then
%if not %index(&THEdsn,.) %then %let tofile=&thedsn;
%else %let tofile=%ahgdsnfilename(&thedsn,ext=);
%let tofile=%sysfunc(translate(&tofile,+#,:\));
%let tofile=&metaDIR\&tofile..meta.txt;
%AHGpm(tofile);
/*%goto Exit;*/
%if &cleanWork %then %AHGkill;
%local rdm ;
%let rdm=%AHGrdm;
%AHGtime(&rdm);
%local uniqdsn theone thetwo line lookinto trtM byM numM trtnumM;
%let line=zsdafjljioqjkewqrlq;
%AHGgettempname(uniqdsn);
%AHGgettempname(lookinto);
/*%AHGDataView(dsin=&thedsn,dsout=&uniqdsn,order=original,SameVal=noDelete,open=0);*/
%AHGlookinto(&thedsn,out=&lookinto, uniq=&uniqdsn,n=&n);

%AHGgettempname(theone);
%AHGgettempname(thetwo);
data &theone(keep=&line);
    set &uniqdsn;
    array allnum _numeric_;
    array allchar _char_;
    array nullchar(1) $500 _temporary_;
    format &line $32555.;
    do over allnum;
      if index(vformat(allnum),'DATE') and not index(vformat(allnum),'DATET') then nullchar(1)= '.'||vname(allnum)||'    '''||put( allnum,date9.)||'''d';
      else nullchar(1)= '.'||vname(allnum)||'    '||put( allnum,best.);
      if not missing(allnum) then 
      do;
      &line=nullchar(1);
      output;
      end;
    end;
    do over allchar;
      nullchar(1)='.'||vname(allchar)||'      "'||trim(allchar)||'"';
      if not missing(allchar) then 
      do;
      &line=compress(nullchar(1),'0D0A'x);
      output;
      end;
    end;
    ;
  run;


%macro AHGdsntofile(dsn,file,var=);
%local i myallchar myallnum allvar;
%if %AHGblank(&var) %then %AHGvarlist(&dsn,Into=var,dlm=%str( ),global=0);

%AHGallchar(&dsn,into=myallchar);
%AHGallnum(&dsn,into=myallnum);

  data &thetwo(keep=&line);
    set &dsn;
    array zen(2) $200. _temporary_; 
    array all(1) $32555. _temporary_; 
    format &line $32555.;
    %do i=1 %to %AHGcount(&var);
    zen(1)="..%scan(&var,&i)  "||vformat(%scan(&var,&i));
    &line=zen(1);
    output;
    zen(2)="%scan(&var,&i)  /*"||vlabel(%scan(&var,&i))||'*/';
    &line=zen(2);
    output;
    all(1)=catx(' ',all(1),zen(2));
    %end;
    ;
    &line="...allvarlabel "||all(1);
    output;

    &line= "...allchar    &myallchar";
    output;
    &line= "...allnum     &myallnum";
    output;
    &line= "...allvar     %sysfunc(trim(&var))";
    output;
    %macro dosomething;
    %local i str;
    %let str=data  proc set run merge put ;
    %do i=1 %to %AHGcount(%str(&str));
    put "%scan(&str,&i)"  ;
    %end;

    %mend;
/*    %doSomething*/
    stop;
  run;
%mend;



%AHGdsntofile(&thedsn,&tofile ,var=);

%AHGvarinfo(&uniqdsn,out=&uniqdsn.info,info= 
name length superfmt label);

%macro AHGmask(var,tovar,mod=0);
%local i;
%let i=%AHGrdm;
&tovar=&var;
do &i=1 to Length(&var);
if (65<=rank(substr(&var,&i,1))<=90) then substr(&tovar,&i,1)=byte(155-rank(substr(&var,&i,1)));
else if (48<=rank(substr(&var,&i,1))<=57) then substr(&tovar,&i,1)=byte(105-rank(substr(&var,&i,1)));
else if (97<=rank(substr(&var,&i,1))<=122) then substr(&tovar,&i,1)=byte(219-rank(substr(&var,&i,1)));
end;
%mend;


%local libpath;
%AHGlibpath(&thedsn,libpath);

data &uniqdsn.info;
  set &uniqdsn.info;
  &line=catx(' ','/',name,length,superfmt,label);
  output;
  if _n_=1 then 
  do;
  &line="@&thedsn";
  output;
  &line="#libname:%scan(&thedsn,1)";
  output;
  &line="#libpath`&libpath";
  output;
  &line="#trt:&trtm";
  output;
  &line="#by:&bym";
  output;
  &line="#num:&NUMm";
  output;
  &line="#trtnum:&trtnumm";
  output;
/*  &line="#libname:&libpath";*/
/*  output;*/

  end;

run;

data &uniqdsn.out;
  set &theone &thetwo &uniqdsn.info;
run;


data _null_;
  file "&tofile" lrecl=32555;
  set &uniqdsn.out(where=(not missing(&line)));
  %AHGmask(&line,new&line);
  put new&line;
run;

%if  %upcase(&sysuserid)=C187781 or %upcase(&sysuserid)=AHUIGE   %then 
%do;

data _null_;
  file "&tofile.sas.txt" lrecl=32555;
  set &uniqdsn.out;
  put &line;
run;
%end;

%if 0 and %sysfunc(fileexist(H:\meta)) %then 
%do;
data _null_;
  file "H:\meta\%AHGfilename(&tofile)" lrecl=32555;
  set &uniqdsn.out(where=(not missing(&line)));
  %AHGmask(&line,new&line);
  put new&line;
run;
%end;
%AHGtime(&rdm.2);

%AHGinterval(&rdm,&rdm.2);

/*x "&tofile";*/
/*x "&tofile.sas.txt";*/
%AHGwt(&metadir\SAS_session_%substr(&SYSPROCESSID,6,20).sas.txt,
str=reloadlist);
%exit:
%mend;

