/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 26866138MMY3037
  PXL Study Code:        229288

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Chase Liu $LastChangedBy: liuc5 $
  Creation Date:         27Jun2016 / $LastChangedDate: 2016-08-24 04:46:14 -0400 (Wed, 24 Aug 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_zr.sas $

  Files Created:         qc_ZR.log
                         ZR.sas7bdat

  Program Purpose:       To QC Immunogenicity Specimen Assessments Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 25 $
-----------------------------------------------------------------------------*/
%jjqcclean;
*------------------- Get meta data --------------------;
%let domain=ZR;
%jjqcvaratt(domain=ZR);
%jjqcdata_type;

*------------------- Get raw data --------------------;
%let dropvar=projectid studyid environmentname subjectid studysiteid sdvtier sitegroup instanceid 
             instancerepeatnumber folderid folder targetdays datapageid recorddate recordid 
             mincreated maxupdated savets ;
data DS_GL_902;
    set raw.DS_GL_902(where=(&raw_sub));
    drop &dropvar DSCAT DSRANDYN;
run;

*------------------- Mapping --------------------;
data ZR_1;
    attrib &&&domain._varatt_;
    set DS_GL_902;
    STUDYID               =strip(PROJECT);
    DOMAIN                ="&domain";
    USUBJID               =catx("-",PROJECT,SUBJECT);
    ZRSPID                =catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
    %jjqcdate2iso(in_date =RANDOMIZED_AT, in_time=, out_date=ZRDTC);
    ZRCAT='TREATMENT ASSIGNMENT RESULT';
    ZRNAM = "BLANCE";
    if ^missing(RAND_ID) then do;
        ZRTESTCD              = 'RANUM';
        ZRTEST                = put(ZRTESTCD,$ZR_TESTCD.);
        ZRORRES               = strip(RAND_ID);
        ZRSTRESC              = ZRORRES;
        ZRSTRESN              = input(ZRSTRESC,best.);
        Output;
    end;
    if ^missing(RANDFA1) then do;
        ZRTESTCD              = 'RANSTRF1';
        ZRTEST                = put(ZRTESTCD,$ZR_TESTCD.);
        ZRCAT                 = "TREATMENT ASSIGNMENT INPUT";
        ZRSCAT                = "STRATIFICATION FACTOR";
        ZRORRES               = strip(RANDFA1);
        ZRSTRESC              = ZRORRES;
        ZRSTRESN              = .;        
        Output;
    end;
    if ^missing(RANDFA2) then do;
        ZRTESTCD              = 'RANSTRF2';
        ZRTEST                = put(ZRTESTCD,$ZR_TESTCD.);
        ZRCAT                 = "TREATMENT ASSIGNMENT INPUT";
        ZRSCAT                = "STRATIFICATION FACTOR";
        ZRORRES               = strip(RANDFA2);
        ZRSTRESC              = ZRORRES;
        ZRSTRESN              = .;        
        Output;
    end;
    if ^missing(REGIME_NAME) then do;
        ZRTESTCD              = 'TXPCD';
        ZRCAT                 = "TREATMENT ASSIGNMENT RESULT";
        ZRSCAT                = "";
        ZRTEST                = put(ZRTESTCD,$ZR_TESTCD.);
        ZRORRES               = strip(REGIME_NAME);
        ZRSTRESC              = ZRORRES;
        ZRSTRESN              = .;        
        Output;
    end;
    if ^missing(REGIME_DESCRIPTION) then do;
        ZRTESTCD              = 'TXP';
        ZRCAT                 = "TREATMENT ASSIGNMENT RESULT";
        ZRSCAT                = "";       
        ZRTEST                = put(ZRTESTCD,$ZR_TESTCD.);
        ZRORRES               = strip(REGIME_DESCRIPTION);
        ZRSTRESC              = ZRORRES;
        ZRSTRESN              = .;        
        Output;
    end;
    if ^missing(STRATUM_NAME) then do;
        ZRTESTCD              = 'STRNAM';
        ZRCAT                 = "TREATMENT ASSIGNMENT RESULT";
        ZRSCAT                = "";     
        ZRTEST                = put(ZRTESTCD,$ZR_TESTCD.);
        ZRORRES               = strip(STRATUM_NAME);
        ZRSTRESC              = ZRORRES;
        ZRSTRESN              = .;        
        Output;
    end;      
    call missing(of ZRSEQ ZRORRESU ZRSTRESN ZRSTRESU ZRNAM VISITNUM VISIT VISITDY EPOCH ZRDY);
    drop ZRSEQ VISITNUM VISIT VISITDY EPOCH ZRDY;
run;

*------------------- Visit --------------------;
%jjqcvisit(in_data=ZR_1, out_data=ZR_2, date=, time=);

*------------------- DY --------------------;
%jjqccomdy(in_data=ZR_2,out_data=ZR_3, in_var=ZRDTC, out_var=ZRDY);

*------------------- Epoch --------------------;
%jjqcmepoch(in_data=ZR_3,out_data=ZR_4, in_date=ZRDTC);

*------------------- ZRSEQ --------------------;
%jjqcseq(in_data=ZR_4, out_data=ZR_5, idvar_=USUBJID, retainvar_=STUDYID DOMAIN USUBJID);

*------------------- Output --------------------;
%qcoutput(in_data =ZR_5 );

*------------------- Compare --------------------;
%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );