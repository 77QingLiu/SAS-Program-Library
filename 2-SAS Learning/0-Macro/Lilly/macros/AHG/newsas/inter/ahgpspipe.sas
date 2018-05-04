%macro AHGpspipe(cmd,path=,out=_null_);
%AHGpm(cmd);
%local outfile;
%let outfile=%AHGtempdir\%AHGrdm.txt;
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
  format line $300.;
  input line 1-300;
run;

%mend;


 
