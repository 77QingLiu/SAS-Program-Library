

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
  if kindex(line,'��') and  kindex(line,'��') AND  kindex(line,'��')
  and not kindex(line,'����ֹ') and length(line)<20  THEN 
    do;
    start=1;
    datestr=ktranslate(line,'// ','������');
    date=input(datestr,??yymmdd10.);
    end;
  if start=1 then 
  do; 
  output;
  if missing(date) then put _all_;
  end;

  if kindex(line,'��һƪ') THEN 
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
