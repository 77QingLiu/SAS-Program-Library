

%AHGclearlog;
%macro AHGreadline(file=,out=readlineout);
data &out;
  filename inf   "&file" ;
  infile inf truncover;;
  format  line $4000.;
  input line 1-4000 ;
run;
%mend;


%AHGreadline(file=d:\text.txt,out=dsn);

option mprint;
data small;
  set dsn;
  format date yymmdd10.;
  id=_n_;
  retain start date 0;
  if kindex(line,'年') and  kindex(line,'月') AND  kindex(line,'日')
  and not kindex(line,'林行止') and length(line)<20  THEN 
    do;
    start=1;
    datestr=ktranslate(line,'// ','年月日');
    date=input(datestr,??yymmdd10.);
    end;
  if start=1 then 
  do; 
  output;
  if missing(date) then put _all_;
  end;

  if kindex(line,'下一篇') THEN 
  do;
  line='';
/*  output;*/
  start=0;
  end;

run;

proc sort data=small out=sort;
  by date id;
run;

data _null_;
  file "d:\temp.txt";
  set sort;
  put line;

run;

%AHGopenfile(d:\temp.txt);
