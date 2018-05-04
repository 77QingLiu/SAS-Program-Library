%macro populate(sasfile,out=,indent=);
%local shell inside myN;
%AHGgettempname(shell);
%AHGgettempname(inside);
%AHGreadline(file=&sasfile,out=&shell);
%AHGreadline(file=&indent,out=&inside);

x "del &out";


%AHGnobs(&inside,into=myN);
%AHGpm(myn);

data test;
  file "&out"  ;
  set &shell;
  retain flag 0;
  if (not index(line,'%macro themacrotoreplace')) 
    and (not index(line,'option nomprint'))
    and (not index(line,'%themacrotoreplace')) 
    and (flag ne 1) then 
    put line;
  if index(line,'%macro themacrotoreplace') then
    do;
    flag=1;
    do point=1 to &myN;
    set &inside point=point;
    if (not index(line,'option nomprint')) then put line;
    end;flag=1;
    end;
  
  if index(line,'%themacrotoreplace') then flag=0;
      
run;

%AHGindent(&out);

%mend;


%populate(z:\downloads\newsas\program\ori.sas
,out=z:\downloads\newsas\program\oricode.sas
,indent=c:\temp\mfile1.sas);
