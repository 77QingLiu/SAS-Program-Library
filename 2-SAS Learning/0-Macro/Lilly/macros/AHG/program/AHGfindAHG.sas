
%AHGdatadelete;
dm "clear log";
%macro AHGfindAHG(file,into=);
%local sum;
%AHGgettempname(sum)
%AHGreadline( file=&file,out=&sum);

data newsum;
  set &sum;
run;

data &sum ;
  set &sum;
  line=lowcase(line);
  if index(line,'ahg') then OUTPUT;
run;

data &sum;
  set &sum;
  IF _N_ = 1 THEN PATTERN_NUM = PRXPARSE('/\%ahg[a-z\d]*/'); 
  *Exact match for the letters 'cat' anywhere in the string; 
  RETAIN PATTERN_NUM; 
  position=0;
  call prxsubstr(PATTERN_NUM, line, position, length);
  do while (position>0);
  ahg=substr(line,position+1,length-1);
  output;
  line=substr(line,position+length);
  call prxsubstr(PATTERN_NUM, line, position, length);
  end;

run;

proc sql noprint;
  select distinct(trim(ahg)||'.sas') into :&into separated by ' '
  from &sum

  ;
  quit;
  
%mend;

%let ok=;
%AHGfindAHG(D:\lillyce\qa\ly231514\h3e_cr_jmit\arjan2015\replica_programs\ir_jmit_dsur_summary.sas,INTO=ok);
%AHGpm(ok);
%let thefinal=;
%AHGfindallmeta(&ok,into=thefinal);
