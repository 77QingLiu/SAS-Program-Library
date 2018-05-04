
%macro ah_message_js(dsn,flag=flag,file=) ; 
%local alink %AHGwords(html,5);
%let html1=<!DOCTYPE html>;
%let html2=<html>;
%let html3=<body>;
%let html4=</body>;
%let html5=</html> ;

%local rdm tempdir varlist;
%let rdm=%AHGrdm;
%let tempdir=%AHGtempdir;
%AHGpm(rdm);


data new&rdm;
  format ahgflag&rdm 2.;
  set &dsn;
  ahgflag&rdm=&flag ;
  drop &flag;
run;
%AHGtrimdsn(new&rdm);


%if %AHGblank(&file) %then %let file=&tempdir%str(\)&rdm..html;
proc printto print="&tempdir\&rdm..txt";run;
option ls=200;
%AHGreportby( new&rdm,0,which=,whichlength=,sort=0,groupby=0,groupto=0,topline=,showby=0,option=nowd,labelopt=%str(option label;));
proc printto;run;


%macro AHGreadline(file=,out=readlineout);
data &out;
  filename inf   "&file" ;
  infile inf truncover;;
  format  line $char300.;
  input    line $CHAR300.;
run;
%mend;

x "start call &tempdir%str(\)&rdm..txt";

%AHGreadline(file=&tempdir%str(\)&rdm..txt,out=text&rdm);

data null ; 
  format  line $char300.;
  file "&file"; 
  put "&html1";
  put "&html2";
  put "&html3";
  do i=1 to last;
  set text&rdm nobs=last;
  line=translate(line,'``','"''');
  if input(substr(line,1,7),??best.)>. then &flag=input(substr(line,1,7),best.);
  if &flag=9 then put '<h5 style=''color:red;''><pre>';
  else if &flag=3 then put '<h5 style=''color:purple;''><pre>';
  else if &flag=2 then put '<h5 style=''color:orange;''><pre>';
  else if &flag=1 then put '<h5 style=''color:Navy;''><pre>';
  else put '<h5 style=''color:black''><pre> ';
  put line $char300.;;
  put '</pre></h5> ';
  end;

  put "&html4";
  put "&html5";
run ; 
x "start call ""&file""";

%mend  ; 
/*%ah_message_js(sasuser.allfile,flag=flag,file=) ; */

/*%AHGkill;*/
/*%AHGclearlog;*/
/*option mprint;run;*/
/**/
/*data test;*/
/*  set sasuser.Allfile;*/
/*  flag=max(flag,0);*/
/*run;*/
/**/
/*%ah_message_js(test,flag=flag,file=) ; */
