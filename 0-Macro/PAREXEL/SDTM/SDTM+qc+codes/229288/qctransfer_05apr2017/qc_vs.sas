/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 26866138MMY3037
  PXL Study Code:        229288

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Chase Liu $LastChangedBy: liuc5 $
  Creation Date:         04Jul2016 / $LastChangedDate: 2016-08-29 03:51:21 -0400 (Mon, 29 Aug 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_vs.sas $

  Files Created:         qc_VS.log
                         VS.sas7bdat

  Program Purpose:       To QC Vital Signs Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 39 $
-----------------------------------------------------------------------------*/
%jjqcclean;
*------------------- Get meta data --------------------;
%let domain=VS;
%jjqcvaratt(domain=VS);
%jjqcdata_type;

*------------------- Read raw data --------------------;
%let dropvar=projectid studyid environmentname subjectid studysiteid sdvtier site sitegroup instanceid 
             instancerepeatnumber folderid folder targetdays datapageid recorddate recordid 
             mincreated maxupdated savets ;
data VS_GL_900;
    set raw.VS_GL_900(where=(&raw_sub));
    drop &dropvar;
run;

data VS_GL_900_1;
    set raw.VS_GL_900_1(where=(&raw_sub));
    drop &dropvar;
run;

*------------------- Mapping --------------------;
data VS_1;
    set VS_GL_900 VS_GL_900_1;
    attrib &&&domain._varatt_;
    STUDYID =strip(PROJECT);
    DOMAIN  ="&domain";
    USUBJID =catx("-",PROJECT,SUBJECT);
    VSSPID  =catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
    %jjqcdate2iso(in_date =VSDAT, in_time=, out_date=VSDTC);
    array VSTESTCD_(7)$ _temporary_ ('HEIGHT','WEIGHT','BSA','TEMP','PULSE','SYSBP','DIABP') ; 
    array VSORRES_(*)  HEIGHT  WEIGHT BSA TEMP  PULSE  SYSBP  DIABP  ;       
    array VSORRESU_(*)  HEIGHT_UN WEIGHT_UN BSAU TEMP_UN PULSEU SYSBPU DIABPU ;
    array VSSTRES_(*)  HEIGHT_STD WEIGHT_STD BSA TEMP_STD PULSE  SYSBP  DIABP ;
    array VSSTRESU_(*)  HEIGHT_STD_UN WEIGHT_STD_UN BSAU TEMP_STD_UN PULSEU SYSBPU DIABPU;


    do i = 1 to 7;
        VSTESTCD = VSTESTCD_(i);
        VSTEST   = put(VSTESTCD,$VS_TESTCD.);
        VSORRES  = put(VSORRES_(i),best. -l);
        if VSORRESU_(i) in ('in','lb') then  VSORRESU = upcase(VSORRESU_(i));
        else if VSORRESU_(i) = 'M2' then VSORRESU ='m2';
        else if VSORRESU_(i) = 'Beats/Min' then VSORRESU = "BEATS/MIN";
        else VSORRESU = VSORRESU_(i);
        VSSTRESC = put(VSSTRES_(i),best. -l);
        VSSTRESN = VSSTRES_(i);
        if VSSTRESU_(i) ='Beats/Min' then VSSTRESU = upcase(VSSTRESU_(i));
        if VSSTRESU_(i) = 'M2' then VSSTRESU = 'm2';
        else VSSTRESU = VSSTRESU_(i);
        if VSSTRESU ='Beats/Min' then VSSTRESU ='BEATS/MIN';
        if ^missing(VSORRES) then output;
    end;
    call missing(of VSSEQ VSBLFL VISITNUM VISIT VISITDY EPOCH VSDY);
    drop VSSEQ VSBLFL VISITNUM VISIT VISITDY EPOCH VSDY;
run;

*------------------- Visit --------------------;
%jjqcvisit(in_data=VS_1, out_data=VS_2, date=, time=);

*------------------- DY --------------------;
%jjqccomdy(in_data=VS_2,out_data=VS_3, in_var=VSDTC, out_var=VSDY);

*------------------- Epoch --------------------;
%jjqcmepoch(in_data=VS_3,out_data=VS_4, in_date=VSDTC);

*------------------- BLFL --------------------;
%jjqcblfl(in_data=VS_4,out_data=VS_5,dtc=VSDTC,ExtraVar=VISITNUM);

*------------------- VSSEQ --------------------;
%jjqcseq(in_data=VS_5, out_data=VS_6, idvar_=USUBJID, retainvar_=STUDYID DOMAIN USUBJID);

*------------------- Output --------------------;
%qcoutput(in_data =VS_6 );

*------------------- Compare --------------------;
%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );
