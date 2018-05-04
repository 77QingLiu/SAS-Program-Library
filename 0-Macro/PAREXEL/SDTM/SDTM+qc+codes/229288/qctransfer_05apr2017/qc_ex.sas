/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 61610588LUC1001
  PXL Study Code:        227857

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Pengfei Lu $LastChangedBy: wangfu $
  Creation Date:         29Jun2016 / $LastChangedDate: 2016-12-27 22:33:35 -0500 (Tue, 27 Dec 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_ex.sas $

  Files Created:         qc_ex.log
                         qc_ex.txt
                         /projects/janss229288/stats/transfer/data/qtransfer/ex.sas7bdat
                         /projects/janss229288/stats/transfer/data/qtransfer/suppex.sas7bdat

  Program Purpose:       To QC Exposure Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 103 $
-----------------------------------------------------------------------------*/
%jjqcclean;

*------------------- Get meta data --------------------;
%let domain=EX;
%jjqcvaratt(domain=EX,flag=1);
%jjqcdata_type;

proc format;
    invalue TPTNUM 'Day 1'   = 1
                    'Day 2'  = 2
                    'Day 4'  = 3
                    'Day 5'  = 4
                    'Day 8'  = 5 
                    'Day 9'  = 6
                    'Day 11' = 7
                    'Day 12' = 8;
run;
*------------------- Read raw data --------------------;
%let dropvar=projectid studyid environmentname subjectid studysiteid sdvtier sitegroup instanceid 
             instancerepeatnumber folderid folder targetdays datapageid recorddate recordid 
             mincreated maxupdated savets ;
data EX_ONC_001B_2; /* Form: Dexamethasone Administration */
    set raw.EX_ONC_001B_2(where=(&raw_sub));
    drop &dropvar;
run;

data EX_ONC_001B; /* Form: Velcade Administration SC */
    set raw.EX_ONC_001B(where=(&raw_sub));
    drop &dropvar;
run;

data EX_ONC_001B_1; /* Form: Velcade Administration IV */
    set raw.EX_ONC_001B_1(where=(&raw_sub));
    drop &dropvar;
run;

*------------------- Mapping --------------------;

data ex0(drop=VISIT VISITNUM VISITDY EPOCH EXSTDY EXENDY);
    attrib &&&domain._varatt_;
	set ex_onc_001b_2(where=(&raw_sub) rename=(EXCAT = EXCAT_) drop=exdosfrq exroute extpt exdospru in=b2)
	    ex_onc_001b(where=(&raw_sub) rename=(EXCAT = EXCAT_) drop=exdosfrq exroute exloc exdospru in=b)
	    ex_onc_001b_1(where=(&raw_sub) rename=(EXCAT = EXCAT_) drop=exdosfrq exroute exdospru in=b1);

	call missing(EXDOSFRM,EXLOC,EXTPT,VISIT,VISITNUM,VISITDY,EPOCH,EXSTDY,EXTPT,EXENDY);

    STUDYID  = strip(PROJECT);
    DOMAIN   = "&domain";
    USUBJID  = catx("-",PROJECT,SUBJECT);
    EXSPID   = upcase(catx("-","RAVE",INSTANCENAME,DATAPAGENAME,cats(PAGEREPEATNUMBER),cats(RECORDPOSITION)));

    if b2 then EXTRT='DEXAMETHASONE';
    else if b then EXTRT='VELCADE SC';
    else if b1 then EXTRT='VELCADE IV';

	EXCAT = upcase(EXCAT_);
	if b or b1 then do;
	  EXDOSE = EXDOSAD;
	  EXDOSU = 'mg';
	end;
	else if b2 then do;
	  EXDOSE = .;
	  EXDOSU = '';
	end;
    EXDOSFRQ = cats(EXDOSFRQ_STD);
    EXROUTE  = cats(EXROUTE_STD);
    EXLOC    = cats(EXLOC_STD);
    %jjqcdate2iso(in_date=exstdat, in_time=exsttim, out_date=EXSTDTC);
    EXENDTC = '';
	EXTPT = upcase(cats(DAY));
	if ^missing(compress(EXTPT,,'kd')) then EXTPTNUM = input(DAY,TPTNUM.);

    /*to keep supp variables*/
		length EXACTDU1 EXACTDU2 EXACTDU3 EXACTDU4 EXACTDU5 EXACTDU6 EXACTDU7 EXACTDU8 EXADJ EXAMONT EXAMONTU $200;
		if EXACT1=1 then EXACTDU1 = 'FULL DOSE ADMINISTERED';
		if EXACT2=1 then EXACTDU2 = 'SAME DOSE AS PRIOR ADMINISTRATION';
		if EXACT3=1 then EXACTDU3 = 'DOSE SKIPPED (AND NOT MADE UP)';
		if EXACT4=1 then EXACTDU4 = 'DOSE REDUCED COMPARED TO PRIOR ADMINISTRATION';
		if EXACT5=1 then EXACTDU5 = 'DOSE RE-ESCALATED AS PER PROTOCOL';
		if EXACT6=1 then EXACTDU6 = 'DOSE DELAYED WITHIN THE CYCLE';
		if EXACT7=1 then EXACTDU7 = 'SCHEDULE CHANGE (REDUCED FREQUENCY)';
		if EXACT8=1 then EXACTDU8 = 'STUDY DRUG PERMANENTLY DISCONTINUED';

		EXADJ = upcase(cats(EXADJ_ACT));
		EXADJOTH = upcase(EXADJOTH);

        if upcase(EXDOSPR) = 'OTHER' and ^missing(EXDOSPROTH) then EXDOSPR = cats(EXDOSPROTH);
        else if upcase(EXDOSPR_VEL) = 'OTHER' and ^missing(EXDOSPROTH) then EXDOSPR = cats(EXDOSPROTH);
		else if ^missing(EXDOSPR) and upcase(EXDOSPR) ^= 'OTHER' then EXDOSPR = EXDOSPR;
		else if ^missing(EXDOSPR_VEL) and upcase(EXDOSPR_VEL) ^= 'OTHER' then EXDOSPR = EXDOSPR_VEL;
		else if (upcase(EXDOSPR_VEL) = 'OTHER' or upcase(EXDOSPR) = 'OTHER') and missing(EXDOSPROTH) then
          put 'WAR' ' NING:[PXL] other and not filled specified value '
           sitenumber= subject= foldername= instancename= DATAPAGENAME= recordposition= EXDOSPR_VEL= EXDOSPR= EXDOSPROTH=;

		EXDOSPRU = EXDOSPRU_STD;
/* 		if missing(EXDOSPR) and ^missing(EXDOSPRU) then do;
		   put 'WAR' ' NING:[PXL] mis sing EXDOSPR when EXDOSPRU is not null ' 
		      sitenumber= subject= foldername= instancename= DATAPAGENAME= recordposition= EXDOSPR= EXDOSPRU_STD=;
           EXDOSPRU = '';
		end; */

		EXAMONT = cats(EXAMONT_ADA);
		EXAMONTU = cats(EXAMONT_ADAU_std);

   keep &&&domain._varlst_ 
        EXDOSPR EXDOSPRU EXACTDU1 EXACTDU2 EXACTDU3 EXACTDU4 EXACTDU5 EXACTDU6 EXACTDU7 EXACTDU8 EXADJ EXADJOTH EXAMONT EXAMONTU
        sitenumber subject foldername instancename;

run;
proc sort; by sitenumber subject foldername instancename; run;

proc sort data=qtrans.sv out=sv(keep=sitenumber subject foldername instancename visit visitnum visitdy);
  by sitenumber subject foldername instancename;
run;

data ex1;
    merge ex0(in=a) sv;
    by sitenumber subject foldername instancename;
    if a;
    format _all_;
    informat _all_;
run;


/*calculate exstdy and exendy*/
%jjqccomdy(in_data=EX1, out_data=EX2, in_var=exstdtc, out_var=exstdy);
%jjqccomdy(in_data=EX2, out_data=EX3, in_var=exendtc, out_var=exendy);
/*add epoch*/
%jjqcmepoch(in_data=EX3, out_data=EX,in_date=exstdtc);

/*add seqnum*/
%let EX_keyvar_ = &&&domain._keyvar_ EXSPID;
%put &&&domain._keyvar_;

%jjqcseq(out_data=qtrans.ex,retainvar_=STUDYID DOMAIN USUBJID &domain.SEQ &&&domain._varlst_);

proc sort data=qtrans.ex; by &&&domain._keyvar_ EXSPID;run;

**SUPPEX**;
%jjqcvaratt(domain=SUPPEX, flag=1);

data supp;
    set qtrans.&domain;
    keep STUDYID USUBJID EXSEQ EXDOSPR EXDOSPRU EXACTDU1 EXACTDU2 EXACTDU3 EXACTDU4 EXACTDU5 EXACTDU6 EXACTDU7 EXACTDU8 
         EXADJ EXADJOTH EXAMONT EXAMONTU;
run;

%macro supp(i=,QNAM=);
data supp&domain.&i(keep = &&supp&domain._varlst_ label = &&supp&domain._dlabel_);
    attrib &&supp&domain._varatt_;;
    set supp;
	where ^missing(&qnam);
    RDOMAIN  = "&domain";
    IDVAR    = "EXSEQ";
    IDVARVAL = STRIP(put(EXSEQ,best.));
    QORIG    = "CRF";
    QEVAL    = "";
    QNAM     = "%sysfunc(prxchange(s/DU(\d)/$1/o,-1,&QNAM))";
    QLABEL   = put(QNAM,$&domain._QL.);
    QVAL     = cats(compbl(&QNAM));
run;
%mend supp;
          
%supp(i=1,QNAM=EXDOSPR);
%supp(i=2,QNAM=EXDOSPRU);
%supp(i=3,QNAM=EXACTDU1);
%supp(i=4,QNAM=EXACTDU2);
%supp(i=5,QNAM=EXACTDU3);
%supp(i=6,QNAM=EXACTDU4);
%supp(i=7,QNAM=EXACTDU5);
%supp(i=8,QNAM=EXACTDU6);
%supp(i=9,QNAM=EXACTDU7);
%supp(i=10,QNAM=EXACTDU8);
%supp(i=11,QNAM=EXADJ);
%supp(i=12,QNAM=EXADJOTH);
%supp(i=13,QNAM=EXAMONT);
%supp(i=14,QNAM=EXAMONTU);

data qtrans.supp&domain (keep = &&supp&domain._varlst_ label = &&supp&domain._dlabel_);
    attrib &&supp&domain._varatt_;;
    set supp&domain:;
    if ^missing(QVAL);
run;

proc sort data = qtrans.&domain (&keep_sub keep = &&&domain._varlst_ &domain.SEQ);
by &&&domain._keyvar_; run;

proc sort nodupkey data = qtrans.supp&domain(&keep_sub keep = &&supp&domain._varlst_);
by &&supp&domain._keyvar_; run;

************************************************************
*  Compare Main domain and QC domain                       *
************************************************************;


%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.ex
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );

%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.SUPPEX
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );

