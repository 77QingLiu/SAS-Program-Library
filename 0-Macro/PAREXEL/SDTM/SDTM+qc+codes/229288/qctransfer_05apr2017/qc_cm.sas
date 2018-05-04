/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 61610588LUC1001
  PXL Study Code:        227857

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Pengfei Lu $LastChangedBy: wangfu $
  Creation Date:         30Jun2016 / $LastChangedDate: 2017-04-05 05:00:26 -0400 (Wed, 05 Apr 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_cm.sas $

  Files Created:         qc_cm.log
                         qc_cm.txt
                         /projects/janss229288/stats/transfer/data/qtransfer/cm.sas7bdat
                         /projects/janss229288/stats/transfer/data/qtransfer/suppcm.sas7bdat

  Program Purpose:       To QC Concomitant Therapy

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 152 $
-----------------------------------------------------------------------------*/
%jjqcclean;

*------------------- Get meta data --------------------;
%let domain=CM;
%jjqcvaratt(domain=CM, flag=1);
%jjqcdata_type;

*------------------- Read raw data --------------------;
%let dropvar=projectid studyid environmentname subjectid studysiteid sdvtier sitegroup instanceid 
             instancerepeatnumber folderid folder targetdays datapageid recorddate recordid 
             mincreated maxupdated savets ;
%let kepvar =sitenumber project subject INSTANCENAME DATAPAGENAME PAGEREPEATNUMBER RECORDPOSITION foldername;

data CM_ONC_001; /* Form: Prior Systemic Therapy */
    set raw.CM_ONC_001(where=(&raw_sub));
    %jjqccmcoding(PRETXT_=CMTRT);        
    keep &kepvar CMCAT CMINDC CMGRPID_LT CMSTDAT: CMENDAT: CMGRPID_LT1 CMTRT CMDOSE CMDOSU CMDOSU_STD CMDOSFRQ 
    CMDOSFRQ_STD CMNUMCYC CMROUTE CMROUTE_STD CMTRT_ATC2 CMTRT_ATC_CODE_ CMLVL1 CMLVL1CD CMLVL2 CMLVL2CD CMLVL3 
    CMLVL3CD CMLVL4 CMLVL4CD CMGRPID CMDECOD CMDSFRQO;
run;

data CM_GL_900; /* Form: Concomitant Therapy */
    set raw.CM_GL_900(where=(&raw_sub));
    %jjqccmcoding(PRETXT_=CMTRT);      
    drop &dropvar;
run;

data CM_ONC_003; /* Form: Subsequent Systemic Therapy*/
    set raw.CM_ONC_003(where=(&raw_sub));
    %jjqccmcoding(PRETXT_=CMTRT);          
    keep &kepvar CMCAT CMGRPID_LT CMSTDAT: CMENDAT: CMGRPID_LT1 CMTRT CMTRT_ATC2 CMTRT_ATC_CODE_ CMLVL1 CMLVL1CD 
    CMLVL2 CMLVL2CD CMLVL3 CMLVL3CD CMLVL4 CMLVL4CD CMGRPID CMDECOD;
run;

*------------------- Mapping --------------------;

%macro cm(i=,raw=);
data cm&i;
  attrib &&&domain._varatt_;
  set &raw.(rename=(CMTRT = CMTRT_
                   CMCAT = CMCAT_
				   CMDECOD = CMDECOD_
				   %if &i=1 %then CMDOSE = CMDOSE_ CMINDC = CMINDC_ CMDOSFRQ = CMDOSFRQ_ CMGRPID = CMGRPID_;
				   %if &i=2 %then CMDOSTOT = CMDOSTOT_ CMINDC = CMINDC_;
                   %if &i=3 %then CMGRPID = CMGRPID_;)
           %if &i=1 or &i=2 %then drop = CMDOSU CMROUTE;);
  
   call missing(CMGRPID,CMINDC,CMDOSE,CMDOSTOT,CMDOSU,CMDOSFRQ,CMROUTE,CMSTDY,CMENDY,CMENRF,EPOCH);

   STUDYID  = strip(PROJECT);
   DOMAIN   = "&domain";
   USUBJID  = catx("-",PROJECT,SUBJECT);
   CMSPID   = upcase(catx("-","RAVE",INSTANCENAME,DATAPAGENAME,cats(PAGEREPEATNUMBER),cats(RECORDPOSITION)));

   CMTRT = compbl(cats(CMTRT_));
   CMDECOD = cats(CMDECOD_);
   CMCLAS = CMTRT_ATC2;
   CMCLASCD = CMTRT_ATC_CODE_;
   CMCAT =cats(upcase(CMCAT_));

   %if &i=1 %then %do;
     if missing(compress(cats(CMDOSE_),'.','d')) then CMDOSE = input(cats(CMDOSE_),best.);;
     CMDOSFRQ =cats(CMDOSFRQ_STD);
   %end;
   
   %if &i=1 or &i=2 %then %do;
    CMINDC =cats(upcase(CMINDC_));
    CMDOSU =cats(CMDOSU_STD);
    CMROUTE =cats(CMROUTE_STD);
   %end;

   %jjqcdate2iso(in_date=cmstdat, in_time=, out_date=CMSTDTC);
   %jjqcdate2iso(in_date=cmendat, in_time=, out_date=CMENDTC);

   %if &i=2 %then %do;
     if missing(compress(cats(CMDOSTOT_),'.','d')) then CMDOSTOT = input(cats(CMDOSTOT_),best.);
     if upcase(CMONGO) = 'YES' then CMENRF = 'AFTER';
   %end;

   %if &i=1 or &i=3 %then CMGRPID = cats(CMGRPID_LT);;

    /*to keep supp variables*/
   keep &&&domain._varlst_ 
        %if &i=1 %then CMNUMCYC CMDSFRQO; %if &i=2 %then CMINDDSC; 
        CMLVL1 CMLVL1CD CMLVL2 CMLVL2CD CMLVL3 CMLVL3CD CMLVL4 CMLVL4CD 
        sitenumber subject foldername instancename DATAPAGENAME RECORDPOSITION;
run;
%mend cm;

%cm(i=1,raw=CM_ONC_001);
%cm(i=2,raw=CM_GL_900);
%cm(i=3,raw=CM_ONC_003);

data cm_(drop=CMSTDY CMENDY EPOCH);
  set cm1 cm2 cm3;

  *adjust per codelist;
  if CMDOSFRQ = '1 TIME PER WEEK' then CMDOSFRQ = 'QS';
  else if CMDOSFRQ = '2 TIMES PER WEEK' then CMDOSFRQ = 'BIS';
  else if CMDOSFRQ = '3 TIMES PER WEEK' then CMDOSFRQ = 'TIS';
  else if CMDOSFRQ = '4 TIMES PER WEEK' then CMDOSFRQ = 'QIS';
  else if CMDOSFRQ = 'EVERY 2 WEEKS' then CMDOSFRQ = 'Q2S';
  else if CMDOSFRQ = 'EVERY 3 WEEKS' then CMDOSFRQ = 'Q3S';
  else if CMDOSFRQ = 'EVERY 4 WEEKS' then CMDOSFRQ = 'Q4S';

  if missing(CMTRT) then do;
    delete;
	put 'WAR' 'NING:[PXL] mis sing EXDOSPR when EXDOSPRU is not null ' 
		      sitenumber= subject= foldername= instancename= DATAPAGENAME= RECORDPOSITION= CMTRT= ;
  end;

    format _all_;
    informat _all_;
run;

/*calculate CMSTDY and CMENDY*/
%jjqccomdy(in_data=cm_, out_data=cm_1, in_var=CMSTDTC, out_var=CMSTDY);
%jjqccomdy(in_data=cm_1, out_data=cm_, in_var=CMENDTC, out_var=CMENDY);

/*add epoch*/
%jjqcmepoch(in_data=cm_, out_data=cm,in_date=CMSTDTC);

/*add seqnum*/
%jjqcseq(out_data=qtrans.cm,retainvar_=STUDYID DOMAIN USUBJID &domain.SEQ &&&domain._varlst_);

**SUPPCM**;
%jjqcvaratt(domain=SUPPCM);

data supp;
    set qtrans.&domain;
    keep STUDYID USUBJID CMSEQ CMNUMCYC CMINDDSC CMLVL1 CMLVL1CD 
    CMLVL2 CMLVL2CD CMLVL3 CMLVL3CD CMLVL4 CMLVL4CD CMDSFRQO;
run;

%macro supp(i=,QNAM=);
data supp&domain.&i(keep = &&supp&domain._varlst_ label = &&supp&domain._dlabel_);
    attrib &&supp&domain._varatt_;;
    set supp;
	where ^missing(&qnam);
    QNAM     = "&QNAM";
    QLABEL   = put(QNAM,$&domain._QL.);
    QVAL     = cats(&QNAM);

    RDOMAIN  = "&domain";
    IDVAR    = "CMSEQ";
    IDVARVAL = STRIP(put(CMSEQ,best.));
    if index(QNAM,'CMLVL') then QORIG = "ASSIGNED";
    else QORIG = "CRF";
    QEVAL    = "";
run;
%mend supp;
          
%supp(i=1,QNAM=CMNUMCYC);
%supp(i=2,QNAM=CMINDDSC);
%supp(i=3,QNAM=CMLVL1);
%supp(i=4,QNAM=CMLVL1CD);
%supp(i=5,QNAM=CMLVL2);
%supp(i=6,QNAM=CMLVL2CD);
%supp(i=7,QNAM=CMLVL3);
%supp(i=8,QNAM=CMLVL3CD);
%supp(i=9,QNAM=CMLVL4);
%supp(i=10,QNAM=CMLVL4CD);
%supp(i=11,QNAM=CMDSFRQO);/* FW Updated on 20Mar2017 due to migration */


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
          , dataMain        =  transfer.CM
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );

%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.SUPPCM
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );
