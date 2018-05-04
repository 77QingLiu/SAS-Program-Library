
%macro AHGcolor(dsn,flag=flag,file=,label=,show=label) ; 
%local alink %AHGwords(html,5);
%let html1=<!DOCTYPE html>;
%let html2=<html>;
%let html3=<body>;
%let html4=</body>;
%let html5=</html> ;

%local rdm tempdir varlist;
%let rdm=%AHGrdm;
%let tempdir=%AHGtempdir;

%AHGtrimdsn(&dsn,out=new&rdm);


data new&rdm;
  format ahgflag&rdm $2.;
  set new&rdm;
  ahgflag&rdm=&flag ;
  drop &flag;
  label ahgflag&rdm='Status' &label ;
run;


%if %AHGblank(&file) %then %let file=&tempdir%str(\)&rdm..html;
proc printto print="&tempdir\&rdm..txt";run;
option ls=200;
option label;
%AHGreportby( new&rdm,0,which=,whichlength=,sort=0,groupby=0,groupto=0,topline=,showby=0,option=nowd,labelopt=%str(option label;));
proc printto;run;



/*x "start call &tempdir%str(\)&rdm..txt";*/

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
  if &flag = 9 then put '<h5 style=''color:red;''><pre>';
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

option noxwait;
x "start call ""&file""";

%mend  ; 
