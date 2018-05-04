%macro postPrint();

proc printto;run;

  data ___tb___;
    infile lstfi_  lrecl = %SYSFUNC(GETOPTION(LS)) pad missover print;  
    length string $%SYSFUNC(GETOPTION(LS));
    input string $char%SYSFUNC(GETOPTION(LS)).;  
    length text $%SYSFUNC(GETOPTION(LS)); 
    text=string; 
	  seq=_n_;
    IF substr(string,1,2)='  ' then indent=1;
  run;

%local lstls lstps ttpage ttRec realftn;
%let lstls=%sysfunc(getoption(ls));
%let lstps=%sysfunc(getoption(ps));
%macro AHGnobs(dsn,into=);
  %if %sysfunc(exist(&dsn))  %then
  %do;
  proc sql noprint;
  select strip(put(count(*),best.)) into :&into
  from &dsn
  ;quit;
  %end; 
  %else  %let &into=0;

%mend;

%AHGnobs(___tb___,into=ttRec);
%AHGnobs(footnote,into=realftn);

%let ttPage=%sysfunc(ceil(%sysevalf(&ttRec/%sysfunc(getoption(ps)))));



 
DATA _null_;
	SET ___tb___;
  format theline $200. ;
  retain theline '';

  if missing(theline) and index(STRING,'_________________________________') then theline=string;
  file NEWTB;
  array pg(1) $%sysfunc(getoption(ps)).  _temporary_;
	REtain pagecnt 0;
	if mod(_n_-1,input(getoption('ps'),best.))=0  then 
  do;
  string=prxchange('s/\(page\s+xxx\)//i',1,string);
  pagecnt=pagecnt+1;
  pg1='Page '||strip(put(pagecnt,best.))||" of &ttpage";
  substr(string,&lstls-length(pg1),length(pg1))=pg1;
 
  end;

  IF  mod(_n_-1,input(getoption('ps'),best.))=1 then
  do;
  string=prxchange('s/\(date\s+xxx\)//i',1,string);
  pg1=strip(put(DATEtime(),datetime20.));
  pg1=trim(scan(pg1,2,':'))||':'||trim(scan(pg1,3,':'))||' '||trim(scan(pg1,1,':'));
/*  28FEB2016:23:19:40*/
  substr(string,&lstls-length(pg1),length(pg1))=pg1;
  end;

  IF mod(_n_-1,input(getoption('ps'),best.))=2 then
  do;
  pg1=prxchange('s/(.*)\(dmpm:\s+(\S+)\)/\2/i',1,string);
  string=prxchange('s/\(dmpm:\s+(\S+)\)//i',1,string);
  substr(string,&lstls-length(pg1),length(pg1))=pg1;
  end;
  if string="ahuige_BeginingOfFootnote_" then 
  do;
  put theline $char%SYSFUNC(GETOPTION(LS)).;
  do point=1 to &realftn;
    set footnote point=point;
    put realft;
  end;
  put " ";
  put "Program Location: %str(&prg)&pgmname..sas"; 
  put "Output Location: %str(&rptfile)&outfile..rtf"; 
  put "Data Set Location: &rptindat"; 
/*  put '\par \pard\plain \b\f11\fs16\page ';*/
  end;
  else	put string $char%SYSFUNC(GETOPTION(LS)).;
RUN;


proc printto; run;

 
%tableout2rtf(in =NEWTB , out=outfile);

%mend;
