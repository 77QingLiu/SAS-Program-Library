%macro AHGps(cmd,path,out=_null_);
%let cmd=%sysfunc(tranwrd(&cmd,\\mango\sddext.grp,M:));
%let cmd=%sysfunc(tranwrd(&cmd,\\mango\awe.grp,N:));
%AHGpm(cmd);
%local outfile;
%let outfile=\\%scan(&__snapshot,1,\)\%scan(&__snapshot,2,\)\%scan(&__snapshot,3,\)\trash\&sysuserid..txt;
x "del &outfile /y";
%AHGpm(outfile);
%IF %AHGblank(&path) %then %let path=.;
filename ps pipe  "powershell.exe  "" cd &path; &cmd  |out-file &outfile -width 300 "" ";
data _null_;
  infile ps;
run;

/*|out-string -width 200*/
data &out;
  infile "&outfile" truncover;
  format text $300. lagfile $100.;
  retain lagfile;
  format line $300.;
  input line 1-300;
  sub=prxchange('s/([^:]+\\)([^:]+:)/\2/',1,line);
  file=scan(sub,1,':');
  if file ne lagfile then 
  do;
  text='';output;
  put;
  end;
  else 
  do;
  text=sub;output;
  put sub;
  end;
  lagfile=scan(sub,1,':');
run;

%mend;

