/* 
http://www.w3schools.com/html/default.asp


*/


proc print data=sashelp.class;run;

%macro html(dsn );
%local html;
%let html=d:\temp\myrdm.HTML;
    ods html file="&html";  
    proc print data=&dsn;
    run;
    ods html close;   
    x "start &html";
%mend;



data one; drop age;
  set sashelp.class;
  format agestr $100.;
  agestr=put(age,best.);
  if age>13 then agestr='<font  color="red">' ||trim(agestr)||'</font>';
run;

%html(one);




%macro readline(file=,out=readlineout);
data &out;
  filename inf   "&file" ;
  infile inf truncover;;
  format  line $char800.;
  input line 1-800  ;
run;
%mend;

%readline(file=h:\test.txt,out=lst);

data one;  
  set lst;
  if index(lowcase(line),'unequal') then  line='<pre><font color="red">' ||trim(line)||'</font></pre>';  
  ELSE if index(lowcase(line),'note') then  line='<pre><font color="orange">' ||trim(line)||'</font></pre>';  
  else  line='<pre><font color="blue">' ||trim(line)||'</font></pre>';  

run;

%html(one);


run AHGcolorEx;

%chn_ut_status(showall=1);

