/*read perl output*/
%macro AHGreadperl(dsn=perlout,length=200,file=);

%local perlfile;
%if %substr(&sysscp,1,3) = WIN %then %let perlfile=&localtemp\perlout.tmp;
%else %let perlfile=/home/liu04/temp/perlout.tmp;

%if &file ne %then %let perlfile=&file;

  data &dsn;
    infile "&perlfile" truncover;
    length line $ &length;
    input line 1-&length ;
  run;
    
    

%mend;
