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

%let allcore=;
%let allinter=;
%AHGfilesindir(d:\newsas\core,into=allcore,dlm=%str( ));
%AHGfilesindir(d:\newsas\inter,into=allinter,dlm=%str( ));

%macro doit(where,file,mac);
%local &mac ;
%global &mac&i;
%let &mac=;
%AHGfindAHG(&where\&file,INTO=&mac&i);
%let &mac&i=&file &&&mac&i;
%let bigN=&i;

%mend;


%macro dosomething(dsn);

%local i;
data &dsn;
  format drvr $30. macros $500.;
  %do i=1 %to &bign;
  drvr=scan("&&&dsn&i",1,' ');
  macros=substr("&&&dsn&i",index("&&&dsn&i",' '));
  output;
  %end;
run;
%mend;

%let  bigN=;
%AHGdel(core,like=1);
%AHGfuncloop(%nrbquote( doit(d:\newsas\core, ahuige,core) ) ,loopvar=ahuige,loops=&allcore);

%doSomething(core);

%let  bigN=;
%AHGdel(inter,like=1);
%AHGfuncloop(%nrbquote( doit(d:\newsas\inter, ahuige,inter) ) ,loopvar=ahuige,loops=&allinter);

%doSomething(inter);



data sasuser.macmeta;
  set core inter;
  macros=left(macros);
run;
