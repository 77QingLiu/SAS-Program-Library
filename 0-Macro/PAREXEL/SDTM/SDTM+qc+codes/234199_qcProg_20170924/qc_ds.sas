/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   Janssen Research & Development / CNTO1959PSA3002
  PAREXEL Study Code:    234200

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Owner:                 Hyland Zhang $LastChangedBy: xiaz $
  Last Modified:         2017-06-07 $LastChangedDate: 2017-07-26 03:22:19 -0400 (Wed, 26 Jul 2017) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/qc_ds.sas $
  SVN Revision No:       $Rev: 3 $

  Files Created:         /project39/janss234200/stats/tabulate/qcprog/transfer/qc_ds.sas
                         /project39/janss234200/stats/tabulate/qcprog/transfer/qc_ds.log
                         /project39/janss234200/stats/tabulate/qcprog/transfer/qc_ds.txt
                         /project39/janss234200/stats/tabulate/data/qtransfer/ds.sas7dat
                         /project39/janss234200/stats/tabulate/data/qtransfer/suppds.sas7dat

  Program Purpose:       to qc ds & suppds domains
-----------------------------------------------------------------------------*/


/*Cleaning WORK library */
proc datasets nolist lib=work memtype=data kill;
run;

/*Do not use threaded processing*/
options NOTHREADS;

*----------------------------------------------------------------------------*;
* Program body
*----------------------------------------------------------------------------*;
%jjqcdata_type;


/*DS*/
%let domain=DS;

*---Variable Attributes;
%jjqcvaratt(domain=&domain., flag=1);


data &domain;
    attrib &&&domain._varatt_;
    set raw.DM_GL_900  (drop = STUDYID  where=(&raw_sub and ^missing(rficdat)) in = DM_900_IC)/*INFORM CONSENT*/
        raw.DS_GL_902  (drop = STUDYID DSCAT DSCAT_STD where=(&raw_sub and ^missing(DSSTDAT)) in = DS_902)
        raw.DS_GL_900  (drop = STUDYID DSCAT DSCAT_STD  where=(&raw_sub) rename=(DSDECOD=DSDECOD_ DSTERM=DSTERM_ dsscat=dsscat_) in = DS_900)
        raw.DS_GL_904  (drop = STUDYID DSCAT DSCAT_STD where=(&raw_sub) rename=(DSDECOD=DSDECOD1) in = DS_904)
        raw.DS_GL_903  (drop = STUDYID DSCAT DSCAT_STD where=(&raw_sub ) in = DS_903)
        raw.DS_GL_908_W24  (drop = STUDYID DSCAT DSCAT_STD  where=(&raw_sub) rename=(DSDECOD=DSDECOD_) in = DS_908_W24)
        raw.DS_GL_908_W48  (drop = STUDYID DSCAT DSCAT_STD  where=(&raw_sub) rename=(DSDECOD=DSDECOD_) in = DS_908_W48);
    format _all_; informat _all_;

    STUDYID  = STRIP(PROJECT);
    DOMAIN   = "&domain";
    USUBJID  = catx("-", PROJECT, SUBJECT);
    DSSPID   = catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME), put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));


    if DM_900_IC then do;
            DSTERM   = "INFORMED CONSENT OBTAINED";
            DSDECOD  = "INFORMED CONSENT OBTAINED";
            DSCAT    = 'PROTOCOL MILESTONE';
            DSSCAT   = "";
            VISITNUM = .;
            VISIT    = "";
            VISITDY  = .;
            EPOCH    = "";
            DSDTC    = "";
            DSDY     = .;
            DSSTDY   = .;
            %jjqcdate2iso(in_date=RFICDAT, out_date=DSSTDTC)
            output;
    end;

    if DS_902 then do;
            DSTERM   = "RANDOMIZED";
            DSDECOD  = "RANDOMIZED";
            DSCAT    = "PROTOCOL MILESTONE";
            DSSCAT   = "";
            VISITNUM = .;
            VISIT    = "";
            VISITDY  = .;
            EPOCH    = "";
            DSDTC    = "";
            DSDY     = .;
            DSSTDY   = .;
            %jjqcdate2iso(in_date=DSSTDAT, out_date=DSSTDTC);
            output;
    end;

    if DS_900 then do;
       if ^missing(DSDECOD_STD) or ^missing(DSDECOD_REAS_STD) then do;
            if DSDECOD_STD="COMPLETED" then do;
              DSTERM = "COMPLETED";
              DSDECOD = "COMPLETED";
            end;
            if DSDECOD_STD='DISCONTINUED' and DSDECOD_REAS_STD='OTHER' and not missing(DSTERM_) then do;
              DSTERM=strip(upcase(compbl(DSTERM_)));
              DSDECOD="OTHER";
            end;
            if DSDECOD_STD='DISCONTINUED' and DSDECOD_REAS_STD not in ("",'OTHER') then do;
              DSTERM=upcase(DSDECOD_REAS);
              DSDECOD=upcase(DSDECOD_REAS_STD);
            end;
            DSCAT    = "DISPOSITION EVENT";
            DSSCAT   = "TRIAL";
            VISITNUM = .;
            VISIT    = "";
            VISITDY  = .;
            EPOCH    = "";
            DSDTC    = "";
            DSDY     = .;
            DSSTDY   = .;
            %jjqcdate2iso(in_date=DSSTDAT, out_date=DSSTDTC);
            output;
        end;
    end;

    if DS_904 then do;
        if SITESWYN_STD="Y" then do;
            DSTERM   = "SUBJECT SITE SWITCH";
            DSDECOD  = "SUBJECT SITE SWITCH";
            DSCAT    = "OTHER EVENT";
            DSSCAT   = "";
            VISITNUM = .;
            VISIT    = "";
            VISITDY  = .;
            EPOCH    = "";
            DSDTC    = "";
            DSDY     = .;
            DSSTDY   = .;
            %jjqcdate2iso(in_date=SITE2DAT, out_date=DSSTDTC)
            output;
        end;
    end;

    if DS_903 then do;
           if UPCASE(STRIP(dsunblnd))='YES' then do;
            if UPCASE(STRIP(DSTERM_UNRS))="OTHER" then dsterm= UPCASE(STRIP(DSTERM_oth));
            else DSTERM   = UPCASE(STRIP(DSTERM_UNRS));
            DSDECOD  = "TREATMENT UNBLINDED";
            DSCAT    = 'OTHER EVENT';
            DSSCAT   = "";
            VISITNUM = .;
            VISIT    = "";
            VISITDY  = .;
            EPOCH    = "";
            DSDTC    = "";
            DSDY     = .;
            DSSTDY   = .;
            %jjqcdate2iso(in_date=DSSTDAT, out_date=DSSTDTC)
            output;
          end;
    end;

    if DS_908_W24 or DS_908_W48 then do;
          if ^missing(DSDECOD_STD) or ^missing(DSDECOD_REAS2_STD) then do;
            if DSDECOD_STD="COMPLETED" then do;
                  DSTERM = "COMPLETED";
                  DSDECOD = "COMPLETED";
            end;
            if DSDECOD_STD='DISCONTINUED' and DSDECOD_REAS2_STD='OTHER' and not missing(DSTERM_OTH) then do;
                  DSDECOD="OTHER";
                  DSTERM=strip(upcase(compbl(DSTERM_OTH)));
            end;
            if DSDECOD_STD='DISCONTINUED' and DSDECOD_REAS2_STD ne'OTHER' and DSDECOD_REAS2_STD^='' then do;
                  DSTERM=upcase(DSDECOD_REAS2);
            end;
            if DSDECOD_STD='DISCONTINUED' and index(upcase(DSDECOD_REAS2),'ADVERSE') then do;
                  DSDECOD='ADVERSE EVENT';
            end;
            if DSDECOD_STD='DISCONTINUED' and not index(upcase(DSDECOD_REAS2),'ADVERSE') and DSDECOD_REAS2_STD not in ("","OTHER") then do;
                  DSDECOD=upcase(DSDECOD_REAS2_STD);
            end;
            DSCAT    = "DISPOSITION EVENT";
            if DS_908_w24  then DSSCAT   = upcase('Treatment Disposition Week 24');
            if DS_908_w48  then DSSCAT   = upcase('Treatment Disposition Week 48');
            VISITNUM = .;
            VISIT    = "";
            VISITDY  = .;
            EPOCH    = "";
            DSDTC    = "";
            DSDY     = .;
            DSSTDY   = .;
            %jjqcdate2iso(in_date=DSSTDAT_TDD, out_date=DSSTDTC);
            output;
          end;
    end;

    drop VISITNUM VISIT VISITDY EPOCH DSDTC DSDY DSSTDY;
run;


*--Add VISIT VISITNUM VISITDY;
%jjqcvisit(in_data=&domain., out_data=&domain., date=DSDTC);


*---Add EPOCH;
%jjqcmepoch(in_data=&domain., in_date=DSSTDTC);

*---Add DSDY;
%jjqccomdy(in_data=&domain., in_var=DSSTDTC, out_var=DSSTDY);
%jjqccomdy(in_data=&domain., in_var=DSDTC, out_var=DSDY);

*---Add seqnum;
%jjqcseq(retainvar_=STUDYID DOMAIN USUBJID &domain.SEQ &&&domain._varlst_)


/* Set the EPOCH to blank for DSCAT="PROTOCOL MILESTONE"
   SET visitnum to blank for DSDECOD='RANDOMIZED'*/
data qtrans.&domain;
    set qtrans.&domain;
run;



/*SUPPDS*/

%jjqcvaratt(domain=supp&domain.);

data qtrans.supp&domain;
    attrib &&supp&domain._varatt_;
    set qtrans.&domain;
    RDOMAIN  = DOMAIN;
    IDVAR    = "DSSEQ";
    IDVARVAL = STRIP(put(DSSEQ,best.));
    QORIG    = "CRF";
    QEVAL    = "";

    if ^missing(SPRTDAT) then do;
        QNAM   = "SPRTDTC";
        QLABEL = put(QNAM,$&domain._QL.);
        %jjqcdate2iso(in_date=SPRTDAT, out_date=QVAL); 
        output;
    end;

    if ^missing(DSDMSITE) then do;
        QNAM   = "DSDMSITE";
        QLABEL = put(QNAM,$&domain._QL.);
        QVAL   = strip(upcase(DSDMSITE)); 
        output;
    end;

run;



proc sort data =qtrans.&domain  (&keep_sub keep = &&&domain._varlst_ &domain.SEQ Label = "&&&domain._dlabel_"); 
  by &&&domain._keyvar_; 
run;

proc sort nodupkey data = qtrans.supp&domain(&keep_sub keep = &&supp&domain._varlst_ Label = "&&supp&domain._dlabel_"); by &&supp&domain._keyvar_; 
run;


************************************************************
*  Compare Main domain and QC domain                       *
************************************************************;

%GMCOMPARE( pathOut         =  &_qtransfer.
          , dataMain        =  transfer.&domain.
    /*    , VarsId          =  &&&domain._varid_;*/
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          , allowWorkLibrary=  1
          , debug           =  0
          );

%GMCOMPARE( pathOut         =  &_qtransfer.
          , dataMain        =  transfer.supp&domain
    /*    , VarsId          =  &&&domain._varid_;*/
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          , allowWorkLibrary=  1
          , debug           =  0
          );

*%qc_clean;
