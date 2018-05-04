/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   Janssen Research and Development LLC / CNTO1959PSA3002
  PAREXEL Study Code:    234199

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Owner:         FU WANG        $LastChangedBy: wangfu $
  Last Modified:     2017-06-07    $LastChangedDate: 2017-07-20 03:52:22 -0400 (Thu, 20 Jul 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/qc_se.sas $

  Files Created:         qc_se.log
                         se.sas7bdat

  Program Purpose:       To qc Subject Elements Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 1 $
-----------------------------------------------------------------------------*/

/*Cleaning WORK library */
proc datasets nolist lib=work memtype=data kill;
run;

/*Do not use threaded processing*/
options NOTHREADS;

/*SE*/
%let domain=SE;
%jjqcvaratt(domain=&domain)
%jjqcdata_type;

/*Deriving variables*/
/*screening*/

%macro se (in=,date=,date1=);
data &in;
    set raw.&in(drop=STUDYID SITEID where=(&raw_sub));
    length STUDYID USUBJID $40 &date $19 SESPID $200;
    STUDYID=strip(PROJECT);
    DOMAIN="&domain";
    USUBJID=catx("-", PROJECT, SUBJECT);
    SESPID=catx("-","RAVE",upcase(INSTANCENAME),upcase(DATAPAGENAME),cats(RECORDPOSITION));
    %jjqcdate2iso(in_date=&date1, out_date=&date);
    proc sort;
    by STUDYID USUBJID;
run;

%if &in^=ds_gl_900 %then %do;
proc sort data=qtrans.dm out=dm(keep=studyid usubjid rficdtc rfxstdtc rfxendtc);by studyid usubjid;run;

data &in;
    merge &in(in=a) dm;
    by studyid usubjid;
    if a;
run;
%end;
%mend;

%se(in=ds_gl_900,date=seendtc,date1=dsstdat)
%se(in=ds_gl_908_w24,date=sestdtc,date1=dsstdat_tdd)

/*screening*/
/*merge dm when ds_gl_900 to get rficdtc and rfxstdtc*/
data ds_gl_9;
    merge ds_gl_900 dm(in=a);
    by studyid usubjid;
    if a;
run;

data se1;
    set ds_gl_9;
    length sestdtc $19 ETCD $8 ELEMENT $60 ;
    if not missing(rficdtc);
    sestdtc=rficdtc;
    if DSDECOD_REAS_STD^='SCREEN FAILURE' and not missing(rfxstdtc) then seendtc=rfxstdtc;
    etcd='SCR';
    element='Screening';
    taetord=1;
run;

data se2;
    merge ds_gl_908_w24(rename=(sestdtc=seendtc) drop=rfxstdtc rfxendtc rficdtc)  dm(in=a);
    by studyid usubjid;
    if a;
    length sestdtc $19;
    sestdtc=rfxstdtc;
    taetord=2;
    proc sort;
    by usubjid;
run;

data zr;
  set dummy.zr(keep=usubjid zrtestcd zrorres);
  if zrtestcd='TXPCD';
  proc sort nodupkey;by usubjid ;
run;

data se2;
    merge se2 zr;
	by usubjid;
    length ETCD $8 ELEMENT $60;
	if ZRORRES="GUSE_DUM" then do;
      etcd='GUS100R';
      element='Guselkumab 100 mg Randomized';
	  seendtc=rfxendtc;
	  output;
	end;
    if ZRORRES="GUSP_DUM" then do;
      etcd='GUSPBO';
      element='Guselkumab 100 mg and Placebo Alternate';
	  seendtc=rfxendtc;
	  output;
	end;
	if ZRORRES="PCBO_DUM" then do;
      etcd='PBOR';
      element='Placebo Randomized';
	  output;
	  etcd='GUS100CO';
      element='Placebo to Guselkumab 100 mg Crossover';
	  sestdtc=seendtc;
	  seendtc=rfxendtc;
	  output;
	end;
run;

/*follow up use end of treatment end of study pd*/
proc sort data=ds_gl_900;by usubjid;run;
/*proc sort data=ds_gl_908;by usubjid;run;*/



data se3;
    set ds_gl_9;
/*    if not missing(sestdtc_) then b=input(sestdtc_,yymmdd10.)+1;*/
	
    sestdtc=rfxendtc;
	
    length ETCD $8 ELEMENT $60;
    ETCD='FU';
    ELEMENT='Follow-Up';
    taetord=3;
run;

/*set all se datasets*/
data se;
    set se1 se2 se3;
    if not missing(etcd) and not missing(sestdtc);
    keep studyid domain usubjid etcd element sestdtc seendtc taetord;
    informat studyid;
run;

proc sort data=se;by usubjid;run;


/*SESTDY SEENDY*/
%jjqccomdy(in_data=se, in_var=SESTDTC, out_var=SESTDY)
%jjqccomdy(in_data=se, in_var=SEENDTC, out_var=SEENDY)

/*re generate the epoch*/
data se;
    set se;
    if TAETORD=1 then epoch='SCREENING';
    if TAETORD=2 then epoch='TREATMENT';
    if TAETORD=3 then epoch='FOLLOW-UP';
run;

/*SESEQ*/
proc sort data=se;
    by &&&domain._keyvar_;
run;

data se;
    set se;
    by &&&domain._keyvar_;
    if first.USUBJID then SESEQ=1;
    else SESEQ+1;
    DOMAIN='SE';
run;

/*Output dataset SE*/
data qtrans.&domain(&keep_sub label="&&&domain._dlabel_");
    retain &&&domain._varlst_;
    attrib &&&domain._varatt_;
    set se;
    keep &&&domain._varlst_;
run;

%GMCOMPARE( pathOut         =  &_qtransfer
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          , allowWorkLibrary=  1
          , debug           =  0
          );
