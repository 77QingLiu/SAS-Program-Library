%macro postPrint;

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

%local lstls lstps ttpage ttRec n_of_title n_ft;
%let lstls=%sysfunc(getoption(ls));
%let lstps=%sysfunc(getoption(ps));
%AHGnobs(___tb___,into=ttRec);
%let ttPage=%sysfunc(ceil(%sysevalf(&ttRec/&lstps)));

proc sql noprint;
  select count(*) into :n_ft
  from sashelp.vtitle
  where type='F'
;quit;

 
DATA _null_;
	SET ___tb___;
  format theline $200. PG1 $50. ;
  retain theline '';

  IF  theline='' and index(string,repeat('_',80)) then theline=string;
  file NEWTB;
  array pg(1) $&LSTLS.. _temporary_;
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
  PG1=prxchange('s/([^:]+):([^:]+):([^:]+):([^:]+)/\2:\3 \1/',1,pg1);
/*  )                        08DEC2015:01:19:11 */
  substr(string,&lstls-length(pg1),length(pg1))=pg1;
  end;

  IF mod(_n_-1,input(getoption('ps'),best.))=2 then
  do;
  pg1=prxchange('s/(.*)\(dmpm:\s+(\S+)\)/\2/i',1,string);
  string=prxchange('s/\(dmpm:\s+(\S+)\)//i',1,string);
  substr(string,&lstls-length(pg1),length(pg1))=pg1;
  end;

  IF mod(_n_+&n_ft-1,input(getoption('ps'),best.))=0 then string=theline;
	put string $char&lstls..;
RUN;


proc printto; run;

 
%tableout2rtf(in =NEWTB , out=outfile);
/**/
/*proc printto;run;*/
/*%postreport(inds=lstfi_,outds=_txpfile_b_,suf=);*/
/*proc printto; run;*/
/*filename lstfi_ clear;*/
/*filename outfile clear;*/

 
%mend;
