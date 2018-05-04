/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / CNTO1275CRD1001
  PXL Study Code:        234200

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Deborah Liu $LastChangedBy: xiaz $
  Creation Date:         19JUN2017 / $LastChangedDate: 2017-07-26 03:22:19 -0400 (Wed, 26 Jul 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/qc_xz.sas $

  Files Created:         qc_xz.log
                         qc_xz.txt
                         qc_xz.sas7bdat


  Program Purpose:       To QC  Sample Handling

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 3 $
-----------------------------------------------------------------------------*/

/*Cleaning WORK library */
proc datasets nolist lib=work memtype=data kill;
run;

/*Do not use threaded processing*/
options NOTHREADS;

/*Variable Attributes*/;
%jjqcdata_type;

%let domain=XZ;
%jjqcvaratt(domain=&domain);
%jjqcdata_type;

/*Deriving variables*/
data XZ;
    attrib &&&domain._varatt_;
    set raw.XZ_GL_901(drop=STUDYID RENAME=(XZCAT=XZCAT_) in=GL_901)
        raw.BE_GL_902(drop=STUDYID in=GL_902);
    format _all_; informat _all_;
        if &raw_sub;
    STUDYID=strip(PROJECT);
    DOMAIN="&domain";
    USUBJID=catx("-", PROJECT, SUBJECT);
    XZSPID=catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME), put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
    if  ^missing(XZSLYN) and GL_901 then do;
        XZTESTCD= 'STORLIMT';
        XZTEST='Limit on Length of Storage of Samples';
        XZCAT='LIMITATION ON RETENTION OF SAMPLES FOR FUTURE RESEARCH';
        XZORRES=substr(XZSLYN,1,1);
        XZSTRESC =XZORRES;
        XZORRESU = '';
        XZSTRESN =.;
        XZSTRESU=XZORRESU;
        EPOCH  = '';
        XZDTC  = '';
        XZDY   = .;
        output;
    end;
    if (^missing(XZSLNUM) or  ^missing(XZSLOTH)) and GL_901 then do;
        XZTESTCD=  'STORLEN';
        XZTEST='Length of Storage of Samples';
        XZCAT='LIMITATION ON RETENTION OF SAMPLES FOR FUTURE RESEARCH';
        IF ^MISSING(XZSLNUM) and  XZSLNUM ne "Other" then XZORRES =cats(XZSLNUM);
        if XZSLNUM = "Other"  and not missing(XZSLOTH) then XZORRES =cats(put(XZSLOTH, best.));
        XZSTRESC =XZORRES;
        XZORRESU = 'YEARS';
        XZSTRESN =input(XZORRES,??best.);
        XZSTRESU=XZORRESU;
        EPOCH  = '';
        XZDTC  = '';
        XZDY   = .;
        output;
    end;
    if ^missing(BELMTLENYN) and GL_902 then do;
        XZTESTCD= 'STORLIMT';
        XZTEST='Limit on Length of Storage of Samples';
        XZCAT=BECAT_STD;
        XZORRES =substr(BELMTLENYN,1,1);
        XZSTRESC =XZORRES;
        XZORRESU = '';
        XZSTRESN =.;
        XZSTRESU=XZORRESU;
        EPOCH  = '';
        %jjqcdate2iso(in_date=BESTDAT, in_time=, out_date=XZDTC);
        XZDY   = .;
        output;
    end;
    if ^missing(BELMT) and GL_902 then do;
        XZTESTCD=  'STORLEN';
        XZTEST='Length of Storage of Samples';
        XZCAT=BECAT_STD;
        if BELMT ne "Other" then XZORRES=scan(BELMT,1,'');
        else if BELMT = "Other" and ^missing(BELMTOTH) then XZORRES=scan(BELMTOTH,1,'');
        XZSTRESC =XZORRES;
        XZORRESU = 'YEARS';
        XZSTRESN =input(XZORRES,??best.);
        XZSTRESU=XZORRESU;
        EPOCH  = '';
        %jjqcdate2iso(in_date=BESTDAT, in_time=, out_date=XZDTC);
        XZDY   = .;
        output;
    end;

    call missing(XZSEQ, EPOCH, VISITNUM, VISIT, VISITDY);
    drop XZSEQ EPOCH VISIT VISITNUM VISITDY ;
run;


*--Add VISIT VISITNUM VISITDY;
%jjqcvisit(in_data=&domain., out_data=&domain., date=);

*---Add EPOCH;
%jjqcmepoch(in_data=&domain., in_date=XZDTC);

*---Add XZDY;
%jjqccomdy(in_data=XZ, in_var=XZDTC, out_var=XZDY);

/*---Baseline flag;
%jjqcblfl(sortvar=%str(STUDYID, USUBJID, XZTESTCD, XZDTC, XZORRES));*/

/*Adding XZSEQ*/
%jjqcseq(retainvar_=STUDYID DOMAIN USUBJID &domain.SEQ &&&domain._varlst_);

/*Sort*/
proc sort data =qtrans.&domain  (&keep_sub keep = &&&domain._varlst_ &domain.SEQ);
    by &&&domain._keyvar_;
run;


************************************************************
*  Compare Main domain and QC domain                       *
************************************************************;
%let GMPXLERR=0;
%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.xz
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );
