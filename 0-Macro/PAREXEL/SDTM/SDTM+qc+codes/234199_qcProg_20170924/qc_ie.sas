/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   Janssen Research & Development / CNTO1959PSA3002
  PAREXEL Study Code:    234200

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Owner:                 Hyland Zhang $LastChangedBy: xiaz $
  Last Modified:         2017-06-07 $LastChangedDate: 2017-07-26 03:22:19 -0400 (Wed, 26 Jul 2017) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/qc_ie.sas $
  SVN Revision No:       $Rev: 3 $

  Files Created:         /project39/janss234200/stats/tabulate/qcprog/transfer/qc_ie.sas
                         /project39/janss234200/stats/tabulate/qcprog/transfer/qc_ie.log
                         /project39/janss234200/stats/tabulate/qcprog/transfer/qc_ie.txt
                         /project39/janss234200/stats/tabulate/data/qtransfer/ie.sas7dat

  Program Purpose:       to qc ie domain
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
***Domain name:IE;
%let domain=IE;
***To create attributes for SDTM datasets;
%jjqcvaratt(domain=&domain);
%jjqcdata_type;



************************************************************
*  COPY RAW DATASETS
************************************************************;
proc sql;
    create table &domain._raw_1 as
        select a.*,strip(put(input(scan(strip(put(b.SPRTDAT,datetime22.3)),1,':'),date9.),yymmdd10.)) as SPRTDTC length=19
        from raw.IE_GL_900(where=(&raw_sub)) as a 
        left join raw.dm_gl_900 as b on a.SITEID=b.SITEID and a.SUBJECT=b.SUBJECT;
quit;

************************************************************
*  DOMAIN SPECIFIC MACROS
************************************************************;
***assign_1;
%macro assign_1;
    *length STUDYID $40. DOMAIN $2. USUBJID $40.;
    STUDYID=strip(PROJECT);
    DOMAIN="&domain.";
    USUBJID=catx("-",PROJECT,SUBJECT);
%mend assign_1;

************************************************************
*  PREPERATION FOR FINAL
************************************************************;
*****RAW DATA 1******
*********************;
data &domain._pre_1_;
    attrib &&&domain._varatt_;
    set &domain._raw_1(drop=STUDYID rename=(IETESTCD=IETESTCD_));
    %assign_1;
    SOURCE=1;

    if IEYN_STD = 'Y' and cmiss(IECAT_STD, IETESTCD_) = 0 then
    put "WAR" "NING[PXL]: IEYN=Y but has value in category or IETESTCD " usubjid= iecat= ietestcd= ;

    if IEYN_STD = 'N' and cmiss(IECAT_STD, IETESTCD_) = 0 then do;
        STUDYID=strip(PROJECT);
        DOMAIN="&domain";
        USUBJID=catx("-",PROJECT,SUBJECT);
        IESPID=catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),
                put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
/*        if strip(IETESTCD_) ne "" and length(IETESTCD_) ge 2 then do;*/
		if strip(IETESTCD_) ne "" and length(IETESTCD_) ge 2 then do;
            if input(compress(IETESTCD_,,"kd"),best.) lt 10
                and prxmatch("[a-eA-E]",substr(IETESTCD_,length(IETESTCD_)-1,1)) gt 0 then
                IETESTCD=strip(substr(IECAT_STD,1,2))||put(input(compress(IETESTCD_,,"kd"),best.),Z2.)
                    ||substr(IETESTCD_,length(IETESTCD_)-1,1);
            else if input(compress(IETESTCD_,,"kd"),best.) lt 10
                and prxmatch("[a-eA-E]",substr(IETESTCD_,length(IETESTCD_)-1,1)) le 0 then
                IETESTCD=strip(substr(IECAT_STD,1,2))||put(input(compress(IETESTCD_,,"kd"),best.),Z2.);
            else IETESTCD=strip(substr(IECAT_STD,1,2))||substr(IETESTCD_,2);
        end;
		else IETESTCD=strip(substr(IECAT_STD,1,2))||put(input(compress(IETESTCD_,,"kd"),best.),Z2.);
        /* if SPRTDTC='2017-03-08' and IETESTCD in("IN01", "IN03B", "IN13B", "IN13C", "IN13D") then IETESTCD=cats(IETESTCD,'_1'); */
        IECAT=cats(IECAT_STD);
        IEORRES=cats(ifc(substrn(IECAT_STD, 1, 2) = "IN", "N", "Y"));
        IESTRESC=cats(IEORRES);
        output;
    end;
    format _all_; informat _all_;
    call missing(IESEQ, VISITNUM, VISIT, VISITDY, EPOCH, IEDTC, IEDY, IETEST);
    drop IESEQ VISITNUM VISIT VISITDY EPOCH IEDTC IEDY IETEST;
run;

proc sql;
    create table &domain._pre_1 as
        select a.*,b.IETEST
        from &domain._pre_1_ as a
        left join qtrans.TI as b
        on a.IETESTCD=b.IETESTCD;
quit;

************************************************************
*  PILE UP ALL THE DATASETS ABOVE
************************************************************;
data &domain._base(&keep_sub);
    set &domain._pre_1
    ;
run;

************************************************************
*  ADD VISIT EPOCH DTC DY AND SEQ ETC.
************************************************************;
%jjqcvisit(in_data=&domain._base, out_data=&domain._1, date=IEDTC, time=);
%jjqcmepoch(in_data=&domain._1,in_date=&domain.DTC);
%jjqccomdy(in_data=&domain._1, in_var=&domain.DTC, out_var=&domain.DY);
data &domain.; set &domain._1; run;
proc sort data=&domain. nodup; by USUBJID; run;
%jjqcseq(in=&domain, out=&domain, idvar_=USUBJID, retainvar_=STUDYID DOMAIN USUBJID);

************************************************************
*  FOR FINAL DATASETS OUTPUT AND COMPARATION,
   AS WELL AS CREATE PREREQUISITE DATASET FOR SUPP DOMAIN
************************************************************;
data &domain(Label = "&&&domain._dlabel_") qtrans.&domain.(Label = "&&&domain._dlabel_");
    retain &&&domain._varlst_;
    attrib &&&domain._varatt_;
    set &domain;
    keep &&&domain._varlst_;
    format _all_;
    informat _all_;
run;

%gmcompare( pathOut         =  &_qtransfer.
          , dataMain        =  transfer.&domain.
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          , allowWorkLibrary=  1
          , debug           =  0
          )
