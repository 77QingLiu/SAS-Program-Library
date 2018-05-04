/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / CNTO1959PSA3001
  PXL Study Code:        234199

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Deborah Liu $LastChangedBy: xiaz $
  Creation Date:         03JUL2017 / $LastChangedDate: 2017-09-18 07:49:22 -0400 (Mon, 18 Sep 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/qc_lb.sas $

  Files Created:         qc_lb.log
                         lb.sas7bdat


  Program Purpose:       To QC  Laboratory Test Results Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 35 $
-----------------------------------------------------------------------------*/
title;footnote;
dm "log; clear; out; clear;";
options nomprint;

************************************************************
*  GENERAL MACROS
************************************************************;
***macro used to change the length of specific character variables;
%macro changelen(varname=,tarlen=,type=);
  **varname: variable name;
  **tarlen:  target length;
  %IF &type.=char %THEN %DO; length &varname._ $&tarlen.; %END;
  %IF &type.=num %THEN %DO; length &varname._ &tarlen.; %END;
  &varname._=&varname;
  drop &varname;
  rename &varname._=&varname;
%mend changelen;

************************************************************
*  BASIC SETTINGS
************************************************************;
***Cleaning WORK library ;
%jjqcclean;
***Do not use threaded processing;
options nothreads;
***Domain name:LB;
%let domain=LB;
***To create attributes for SDTM datasets;
%jjqcvaratt(domain=&domain);
%jjqcdata_type;

************************************************************
*  IMPORT SPEC ("0A0D00"x)
************************************************************;
%jjqcgfname(fname=Mapping Specification, type=xlsx);
%put &fname;
%let specname=%str(&fname);


proc import out=work.VALDEF
     datafile="&specpath.&specname..xlsx" dbms=xlsx replace;
     getnames=YES;
     sheet="VALDEF";
run;

proc import out=work.LABDICT
     datafile="&specpath.&specname..xlsx" dbms=xlsx replace;
     getnames=YES;
     sheet="SRC2ORG";
run;

data SRC2ORG;
   set LABDICT;
   SRCU=strip(SRCU);
   LBORRESU=strip(LBORRESU);
run;

************************************************************
*  COPY RAW DATASETS
************************************************************;
data &domain._raw_1;
    set rawlb.covance_lb;
/*    %changelen(varname=STUDYID,tarlen=40,type=char);*/
/*    %changelen(varname=LBGRPID,tarlen=30,type=char);*/
/*    %changelen(varname=LBREFID,tarlen=25,type=char);*/
/*    %changelen(varname=LBTESTCD,tarlen=8,type=char);*/
/*    %changelen(varname=LBCAT,tarlen=200,type=char);*/
/*    %changelen(varname=LBORRES,tarlen=200,type=char);*/
/*    %changelen(varname=LBORRESU,tarlen=50,type=char);*/
/*    %changelen(varname=LBORNRLO,tarlen=20,type=char);*/
/*    %changelen(varname=LBSTAT,tarlen=8,type=char);*/
/*    %changelen(varname=LBREASND,tarlen=200,type=char);*/
/*    %changelen(varname=LBNAM,tarlen=200,type=char);*/
/*    %changelen(varname=LBSPEC,tarlen=100,type=char);*/
/*    %changelen(varname=LBSPCCND,tarlen=100,type=char);*/
/*    %changelen(varname=LBMETHOD,tarlen=200,type=char);*/
/*    %changelen(varname=LBFAST,tarlen=2,type=char);*/
/*    %changelen(varname=LBDTC,tarlen=19,type=char);*/
/*    %changelen(varname=LBENDTC,tarlen=19,type=char);*/
/*    %changelen(varname=LBTPT,tarlen=40,type=char);*/

    %changelen(varname=USUBJID,tarlen=40,type=char);
    %changelen(varname=LBCAT,tarlen=200,type=char);
    %changelen(varname=LBORRESU,tarlen=50,type=char);
    %changelen(varname=LBSTRESU,tarlen=50,type=char);
    %changelen(varname=LBNAM,tarlen=200,type=char);
    %changelen(varname=LBMETHOD,tarlen=200,type=char);
    %changelen(varname=LBFAST,tarlen=2,type=char);

run; 

proc sql;
   create table &domain._raw_2 as
   select a.*, b.lborresu as orresu
   from &domain._raw_1 as a left join SRC2ORG as b 
   on a.LBORRESU=b.SRCU
   ;
quit;
************************************************************
*  DOMAIN SPECIFIC MACROS
************************************************************;
***assign_1;
%macro assign_1;
    *length STUDYID $40. DOMAIN $2. USUBJID $40.;

    DOMAIN="&domain.";
/*    USUBJID=catx("-",STUDYID,SUBJID);*/
%mend assign_1;

***assign_2;
%macro assign_2(QNAM=,QVAL=);
    QNAM="&QNAM.";
    QVAL=&QVAL.;
    output;
%mend assign_2;

***assign_STD;
%macro assign_STD(VAL=);
    &VAL.=strip(&VAL._STD);
%mend assign_STD;

************************************************************
*  PREPERATION FOR FINAL
************************************************************;
*****RAW DATA 1******
*********************;
data &domain._pre_1;
    attrib &&&domain._varatt_;
    %put &&&domain._varatt_;
    set &domain._raw_1;
    %assign_1;
    SOURCE=1;

/*        LBSPID="";*/
        LBTEST=put(LBTESTCD,$LB_TESTCD.);
/*        LBSTRESN=input(strip(LBSTRESC),best.);*/
/*        length YY_ $200.;*/
/*    LBORRESU=ORRESU;*/
/****derive LBNRIND *****/
    if LBORNRLO^="" then do; 
	  if input(LBORNRLO,??best.)>.z then LBORNRLO_N = input(LBORNRLO,??best.);
	  else if substr(LBORNRLO,1,2) in (">=", "<=") then do; 
	    LBORNRLQ=substr(LBORNRLO,1,2);
        LBORNRLO_N=input(substr(LBORNRLO,3),??best.);
      end;
	  else if substr(LBORNRLO,1,1) in (">", "<") then do; 
	    LBORNRLQ=substr(LBORNRLO,1,1);
        LBORNRLO_N=input(substr(LBORNRLO,2),??best.);
      end;
    end;
    if LBORNRHI^="" then do; 
	  if input(LBORNRHI,??best.)>.z then LBORNRHI_N = input(LBORNRHI,??best.);
	  else if substr(LBORNRHI,1,2) in (">=", "<=") then do; 
	    LBORNRHQ=substr(LBORNRHI,1,2);
        LBORNRHI_N=input(substr(LBORNRHI,3),??best.);
      end;
	  else if substr(LBORNRHI,1,1) in (">", "<") then do; 
	    LBORNRHQ=substr(LBORNRHI,1,1);
        LBORNRHI_N=input(substr(LBORNRHI,2),??best.);
      end;
    end;

    if LBORRES^="" then do; 
	  if input(LBORRES,??best.)>.z then LBORRES_N = input(LBORRES,??best.);
	  else if substr(LBORRES,1,2) in (">=", "<=") then do; 
	    LBORRESQ=substr(LBORRES,1,2);
        LBORRES_N=input(substr(LBORRES,3),??best.);
      end;
	  else if substr(LBORRES,1,1) in (">", "<") then do; 
	    LBORRESQ=substr(LBORRES,1,1);
        LBORRES_N=input(substr(LBORRES,2),??best.);
      end;
    end;    

	if cmiss(LBORNRLO, LBORNRHI)^=2 and LBORRES_N>.z then do; 
	  if LBORRESQ= "" then do;
		  if LBORNRLQ in ("", ">=") and LBORRES_N<LBORNRLO_N then LBNRIND="LOW";
		  else if LBORNRLQ in (">") and LBORRES_N<=LBORNRLO_N then LBNRIND="LOW";
	      else if LBORNRHQ in ("", "<=") and LBORRES_N>LBORNRHI_N then LBNRIND="HIGH";
	      else if LBORNRHQ in ("<") and LBORRES_N>=LBORNRHI_N then LBNRIND="HIGH";
		  else if LBORNRLQ in ("<", "<=") or LBORNRHQ in (">", ">=") then LBNRIND="";
		  else LBNRIND="NORMAL";
      end;
	  else if LBORRESQ^="" then do;
	    if LBORNRLQ in (">") and LBORRESQ in ("<", "<=") and LBORRES_N <= LBORNRLO_N then LBNRIND="LOW";
	    if LBORNRLQ in (">") and LBORRESQ in ("<", "<=") and LBORRES_N > LBORNRLO_N then LBNRIND=" ";
        else if LBORNRLQ in (">=", "") and LBORRESQ in ("<") and LBORRES_N <= LBORNRLO_N then LBNRIND="LOW";
        else if LBORNRLQ in (">=", "") and LBORRESQ in ("<=") and LBORRES_N < LBORNRLO_N then LBNRIND="LOW";
        else if LBORNRLQ in (">=", "") and LBORRESQ in ("<=") and LBORRES_N >= LBORNRLO_N then LBNRIND=" ";
        else if LBORNRLQ in (">=", "") and LBORRESQ in ("<") and LBORRES_N > LBORNRLO_N then LBNRIND=" ";
	    else if LBORNRLQ in (">") and LBORRESQ in (">=") and LBORRES_N <= LBORNRLO_N then LBNRIND=" ";
	    else if LBORNRLQ in (">") and LBORRESQ in (">") and LBORRES_N < LBORNRLO_N then LBNRIND=" ";
        else if LBORNRLQ in (">=", "") and LBORRESQ in (">",">=") and LBORRES_N < LBORNRLO_N then LBNRIND=" ";
	    else if LBORNRHQ in ("<") and LBORRESQ in (">",">=") and LBORRES_N>=LBORNRHI_N then LBNRIND="HIGH";
	    else if LBORNRHQ in ("<") and LBORRESQ in (">",">=") and LBORRES_N<LBORNRHI_N then LBNRIND=" ";
	    else if LBORNRHQ in ("<=", "") and LBORRESQ in (">") and LBORRES_N>=LBORNRHI_N then LBNRIND="HIGH";
	    else if LBORNRHQ in ("<=", "") and LBORRESQ in (">=") and LBORRES_N>LBORNRHI_N then LBNRIND="HIGH";
	    else if LBORNRHQ in ("<=", "") and LBORRESQ in (">=") and LBORRES_N<=LBORNRHI_N then LBNRIND=" ";
	    else if LBORNRHQ in ("<=", "") and LBORRESQ in (">") and LBORRES_N<LBORNRHI_N then LBNRIND=" ";
	    else if LBORNRHQ in ("<") and LBORRESQ in ("<=") and LBORRES_N >= LBORNRHI_N then LBNRIND=" ";
	    else if LBORNRHQ in ("<") and LBORRESQ in ("<") and LBORRES_N > LBORNRHI_N then LBNRIND=" ";
        else if LBORNRHQ in ("<=", "") and LBORRESQ in ("<","<=") and LBORRES_N > LBORNRHI_N then LBNRIND=" ";
		else LBNRIND="NORMAL";
      end;
    end;

    else if LBORRES^="" and LBSTNRC^="" then do;
	    if LBORRES = LBSTNRC then LBNRIND="NORMAL";
		else LBNRIND="ABNORMAL";
	end;






	
	  


    call missing(&domain.SEQ,EPOCH,&domain.DY, &domain.BLFL, &domain.ENDY, visitdy);
    drop &domain.SEQ  EPOCH &domain.BLFL &domain.ENDY VISITDY;
/*    call missing(of _all_);*/
run;






************************************************************
*  PILE UP ALL THE DATASETS ABOVE
************************************************************;
data &domain(&keep_sub);
    set &domain._pre_1
    ;
run;

************************************************************
*  ADD VISIT EPOCH DTC DY AND SEQ ETC.
************************************************************;
%jjqcvisit(in_data=&domain, out_data=&domain, date=LBDTC, time=);


%jjqcmepoch(in_data=&domain,in_date=&domain.DTC);

%jjqcblfl( sortvar = %str(STUDYID, USUBJID, LBCAT, LBSPEC, LBMETHOD, LBTESTCD, LBDTC, VISITNUM, LBORRES));
*ADD DY;
%jjqccomdy(in_data=&domain, in_var=&domain.DTC, out_var=&domain.DY);
%jjqccomdy(in_data=&domain, in_var=&domain.ENDTC, out_var=&domain.ENDY);


data &domain.; set &domain; run;

*add seqnum;
%jjqcseq(in=&domain, out=&domain, idvar_=USUBJID, retainvar_=STUDYID DOMAIN USUBJID); 

************************************************************
*  FOR FINAL DATASETS OUTPUT AND COMPARATION,
   AS WELL AS CREATE PREREQUISITE DATASET FOR SUPP DOMAIN
************************************************************;
data supp&domain._raw; set &domain; if usubjid="" then delete;run;

data &domain(Label = "&&&domain._dlabel_") qtrans.&domain.(Label = "&&&domain._dlabel_");
    retain &&&domain._varlst_;
    attrib &&&domain._varatt_;
    set &domain;
    keep &&&domain._varlst_;
    format _all_;
    informat _all_;
    if usubjid="" then delete;
run;

data main_&domain.; set transfer.&domain.; run;
%let gmpxlerr=0;
%gmcompare( pathOut         =  &_qtransfer.
          , dataMain        =  transfer.&domain.
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          , allowWorkLibrary=  1
          , debug           =  0
          )

/************************************************************
*  PREPARE FOR SUPP DOMAIN.
************************************************************/

%let domain=SUPP&domain.;
%let rdomain=%substr(&domain.,5,2);
***To create attributes for SDTM datasets;
%jjqcvaratt(domain=&domain);
%jjqcdata_type;

data &domain._pre;
    attrib &&&domain._varatt_;
    /*set &domain._raw;
    RDOMAIN="&rdomain.";
    IDVAR="&rdomain.SEQ";
    IDVARVAL=strip(put(&rdomain.SEQ,best.));
    QORIG="EDT";
    QEVAL="";
    call missing(QLABEL);
    drop QLABEL;

    *VARIABLE lb_01_01;
    if ^missing(MKREASNE) then do; %assign_2(QNAM=MKREASNE,QVAL=MKREASNE); end; */

     call missing(of _all_);
     drop QLABEL;
run;

proc sql;
    create table &domain._base as
        select a.*,b.QLABEL
        from &domain._pre as a
        left join  (select VALUEOID,VALVAL,strip(compress(VALLABEL,"0A0D00"x)) as QLABEL length=40
                    from VALDEF
                    where strip(compress(VALUEOID,"0A0D00"x))="&domain..QNAM") as b
        on a.QNAM=strip(compress(b.VALVAL,"0A0D00"x));
quit;

proc sort data=&domain._base nodupkey;
    by &&&domain._keyvar_ QVAL;
    %put &&&domain._keyvar_;
run;

************************************************************
*  FOR OUTPUTING SUPP DATASET AND COMPARATION.
************************************************************;
data &domain(Label = "&&&domain._dlabel_") qtrans.&domain.(Label = "&&&domain._dlabel_");
    retain &&&domain._varlst_;
    attrib &&&domain._varatt_;
    /*set &domain._base; */
    keep &&&domain._varlst_;
    format _all_;
    informat _all_;
    if usubjid="" then delete;
    call missing(of _all_);
run;

data main_&domain.; set transfer.&domain.; run;
%let gmpxlerr=0;
%gmcompare( pathOut         =  &_qtransfer.
          , dataMain        =  transfer.&domain.
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          , allowWorkLibrary=  1
          , debug           =  0
          )
