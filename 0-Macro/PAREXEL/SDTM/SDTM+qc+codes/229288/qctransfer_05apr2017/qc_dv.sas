/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor /Protocol No:  Janssen Research Development / R033812DYP1002
  PXL Study Code:        228775

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Ran Liu  / $LastChangedBy: wangfu $
  Creation Date:         06May2016 / $LastChangedDate: 2017-03-20 22:59:51 -0400 (Mon, 20 Mar 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_dv.sas $

  Files Created:         dv.log
                         dv.sas7bdat

  Program Purpose:       To create QC SDTM dataset DV

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 147 $
-----------------------------------------------------------------------------*/
/* options mprint mlogic; */

/*clean work dataset*/
%jjqcclean;

/*read attrib*/
%let domain=DV;
%jjqcvaratt(domain=DV);
%jjqcdata_type;

data _null_;
  set raw.dm_gl_901 end=last;
  if last then call symput('envr',strip(upcase(environmentName)));
run;

%put &envr;

/* %macro gfname();

filename fname pipe "ls /project26/jjprd221689/stats/transfer/data/rawctms/*.csv";

data fname;
    infile fname truncover;
    input;
    fname=prxchange('s/(.+)\/(.+)(\.xlsx)/\2/',-1,_infile_);
    if not prxmatch('/\$/',fname) and prxmatch('/(filename)/',fname);
    ord=input(prxchange('s/(.+)\_(\d+)/\2/',-1,fname),best.);
    proc sort;
    by ord fname;
run;

data _null_;
    set fname end=eof;
    if eof then call symputx("fname",fname,'g');
run;
%mend gfname;
 */

 %macro gfname(loc=_rawspec,type=MAPPING SPECIFICATION,ext=xlsx);
filename fname pipe "ls &&&loc../*.&ext";

data fname;
    infile fname truncover;
    input;
  length fname $200;
    fname=prxchange("s/(.+)\/(.+)(\.&ext)/\2/",-1,_infile_);
    if not prxmatch('/\$/',fname) and prxmatch("/(%upcase(&type))/",upcase(fname));
  ord=strip(upcase(fname));
    proc sort;
    by ord fname;
run;

data _null_;
    set fname end=eof;
    if eof then call symputx("fname",fname,'g');
run;
%mend gfname;
%let _rawctms=/projects/janss229288/stats/transfer/data/rawmctms/;

%gfname(loc=_rawctms,type=filename,ext=csv);


/* %let fname = filename; */
%put &fname;

%macro envr;

%if &envr ne /* UAT */ %then %do;/* For migration purporse, remove the annotation for production data */
%let domain=DV;
%jjqcvaratt(domain=DV);

  

  %let saswork=%sysfunc(pathname(work));

  data _null_;
    call system("cp &_rawctms.&fname..csv &saswork.temp.csv");
  run;



  data _null_;
    infile "&saswork.temp.csv" recfm=n sharebuffers;
    file   "&saswork.temp.csv" recfm=n;
    retain mark 0;
    input word $char1.;
    if word='"' then mark=^(mark);

    if mark then do;
       if word='0A'x then put ' ';
     else if word='0D'x then put ;
    end;
  run;


  PROC IMPORT DATAFILE="&saswork.temp.csv"
    OUT=mctms  REPLACE ;
    GETNAMES=YES;     
    GUESSINGROWS=2000;        
  quit;

  %macro dv;
  proc sql;
    create table chk as
      select *
    from dictionary.columns
    where libname='WORK' and upcase(memname)='MCTMS' and upcase(name) in('END_DATE', 'START_DATE')
    ;
  quit;
  data _null_;
   set chk;
   call symput(name,strip(type));
   call symput(catx('_',name,'f'),strip(format));
  run;

  data dv(drop=EPOCH DVSTDY DVENDY DVSEQ);
    attrib &&&domain._varatt_;
/*     set mctms(where=(Lock_Deviation='N' and Active='Y')); */
    set mctms(where=(Active='Y'));
    STUDYID = upcase(study_name);
    DOMAIN  = "&domain";
    length subject $20;
    subject = cats(subject_number);
    USUBJID = strip(STUDYID) ||"-"||strip(SUBJECT);
    /* USUBJID = catx("-", STUDYID, SUBJECT); */
    DVSEQ   = .;
    DVREFID = cats(reference);
/* 2015-12-17:mCTMS use introduce for SP:DVSPID => Concatenate "SUBJECT DEVIATION" and (Reference) by "-"*/
    DVSPID  = upcase(catx("-",'SUBJECT DEVIATION',reference));
    temp=description__1_;
    %gmmodifysplit(var=temp,width=200);
    length DVTERM1-DVTERM9 $200;
    array suppdv DVTERM DVTERM1-DVTERM9;
    call missing(DVTERM1,DVTERM2,DVTERM3,DVTERM4, DVTERM5, DVTERM6, DVTERM7, DVTERM8,DVTERM9);
    n=length(strip(COMPRESS(temp,'~','k')))+1;
    do i=1 to n;
       suppdv(i)=scan(temp,i,'~');
    end;

    DVDECOD = upcase(category);
    DVCAT   = upcase(Severity);
    DVSCAT  = "";
    EPOCH   = "";
    visit = '';

    %if &start_date=num %then %do;
     %if %index(&start_date_f,TIME) %then if missing(start_date)=0 then start= datepart(start_date);
     %else if missing(start_date)=0 then start= start_date;;
    %end;
    %else %do;
     if missing(start_date)=0 then start= input(compress(start_date),date9.);
    %end;
    %if &end_date=num %then %do;
     %if %index(&end_date_f,TIME) %then if missing(end_date)=0 then end= datepart(end_date);
     %else if missing(end_date)=0 then end= end_date;;
    %end;
    %else %do;
     if missing(end_date)=0 then end= input(compress(end_date),date9.);
    %end;
     if missing(start)=0 then DVSTDTC = strip(put(start,yymmdd10.));
     if missing(end)  =0 then DVENDTC = strip(put(end,yymmdd10.));
    DVSTDY  = .;
    DVENDY  = .;
      DVTERM=compress(DVTERM,,'kw');/*2016-01-14: only keep printable character*/
      DVTERM1=compress(DVTERM1,,'kw');
/*       dvterm1 = scan(compress(DVTERM,,'kw'),201,400); */
    if ^missing(DVTERM) and DVCAT='MAJOR';
    array char _character_;
    do over char;
      char=upcase(char);
    end;
  run;
  %mend dv;
  %dv;

%jjqccomdy(in_data=dv, out_data=dv_1, in_var=DVSTDTC, out_var=DVSTDY);
%jjqccomdy(in_data=DV_1, out_data=DV_2, in_var=DVENDTC, out_var=DVENDY);

/*add epoch*/
%jjqcmepoch(in_data=DV_2, out_data=DV,in_date=DVSTDTC);


 /*  %seq(retainvar_=STUDYID DOMAIN USUBJID &domain.SEQ &&&domain._varlst_); */
%jjqcseq(out_data=DV,retainvar_=STUDYID DOMAIN USUBJID &domain.SEQ &&&domain._varlst_);

%qcoutput(in_data = dv);

%qcsupp(in_data = dv); 

%end;

%else %do;
   data dv;
attrib &&&domain._varatt_;
STUDYID='';
DOMAIN='';
USUBJID='';
DVSEQ=.;
DVREFID='';
DVSPID='';
DVTERM='';
DVDECOD='';
DVCAT='';
EPOCH='';
DVSTDTC='';
DVENDTC='';
DVSTDY=.;
DVENDY=.;
run;

/*DVSEQ*/
proc sort data=dv;
    by STUDYID USUBJID DVTERM;
run;

data dv;
    set dv;
    by STUDYID USUBJID DVTERM;
    *if first.usubjid then &domain.SEQ=1;
    *else &domain.SEQ+1;
    &domain.SEQ=.;
run;

proc sort data=dv;
    by &&&domain._keyvar_;
run;

data qtrans.&domain(label="&&&domain._dlabel_");
    retain &&&domain._varlst_;
    attrib &&&domain._varatt_;
    set qtrans.&domain.;
    keep &&&domain._varlst_;
run;

proc sort data=qtrans.&domain (&keep_sub keep=&&&domain._varlst_ label="&&&domain._dlabel_");
    by &&&domain._keyvar_;
run;

%let sdomain = supp&domain;
%jjqcvaratt(domain = &sdomain);

data suppdv;
attrib &&supp&domain._varatt_;
STUDYID='';
RDOMAIN='';
USUBJID='';
IDVAR='';
IDVARVAL='';
QNAM='';
QLABEL='';
QVAL='';
QORIG='';
QEVAL='';
run;

data qtrans.supp&domain(label="&&supp&domain._dlabel_");
    retain &&supp&domain._varlst_;
    attrib &&supp&domain._varatt_;
    set suppdv;
    if STUDYID='' then delete;
    keep &&supp&domain._varlst_;
run;

%end;
%mend;

%envr;


*----------------------------------------------------------------------------*;
* end of programs
*----------------------------------------------------------------------------*;

************************************************************
*  Compare Main domain and QC domain                       *
************************************************************;

%GMCOMPARE( pathOut         =  &_qtransfer.
          , dataMain        =  transfer.&domain.
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );

%GMCOMPARE( pathOut         =  &_qtransfer.
          , dataMain        =  transfer.supp&domain.
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );
