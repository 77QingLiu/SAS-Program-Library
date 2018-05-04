/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 61610588LUC1001
  PXL Study Code:        227857

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Pengfei Lu $LastChangedBy: liuc5 $
  Creation Date:         04Jul2016 / $LastChangedDate: 2016-10-28 04:04:26 -0400 (Fri, 28 Oct 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_ae.sas $

  Files Created:         qc_ae.log
                         qc_ae.txt
                         /projects/janss229288/stats/transfer/data/qtransfer/ae.sas7bdat
                         /projects/janss229288/stats/transfer/data/qtransfer/suppae.sas7bdat

  Program Purpose:       To QC Adverse Events Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 50 $
-----------------------------------------------------------------------------*/
/*clean work dataset*/
proc datasets nolist lib = work memtype = data kill;
quit;

/*read attrib*/
%let domain=AE;
%jjqcvaratt(domain=AE, flag=1);
%jjqcdata_type;

/*start to create*/

data ae_(drop=AESTDY AEENDY EPOCH);
  attrib &&&domain._varatt_;
  set raw.AE_GL_900(drop = STUDYID AESER AESCONG AESDISAB AESDTH AESHOSP AESLIFE AESMIE AECONTRT
                           AEACN AEREL AETRLPRC AESHOSPR AESHOSPP
                    rename=(AETERM = AETERM_ AEOUT = AEOUT_ AETOXGR = AETOXGR_));

   call missing(EPOCH,AESTDY,AEENDY);

   STUDYID  = strip(PROJECT);
   DOMAIN   = "&domain";
   USUBJID  = catx("-",PROJECT,SUBJECT);
   AESPID   = upcase(catx("-","RAVE",INSTANCENAME,DATAPAGENAME,cats(PAGEREPEATNUMBER),cats(RECORDPOSITION)));

   AETERM   = cats(AETERM_);

   array rchar AETERM_LLT AETERM_PT AETERM_HLT AETERM_HLGT AETERM_SOC AETERM_SOC;
   array rcode AETERM_LLT_CODE AETERM_PT_CODE AETERM_HLT_CODE AETERM_HLGT_CODE AETERM_SOC_CODE AETERM_SOC_CODE;
   array char AELLT AEDECOD AEHLT AEHLGT AEBODSYS AESOC;
   array code AELLTCD AEPTCD AEHLTCD AEHLGTCD AEBDSYCD AESOCCD;
   do over rchar;
     char = cats(rchar);
	 code = input(cats(rcode),best.);
   end;

   AESER    = cats(AESER_STD);

   AEACN    = 'MULTIPLE';
   AEREL    = 'MULTIPLE';

   AESCONG  = cats(AESCONG_STD);
   AESDISAB = cats(AESDISAB_STD);
   AESDTH   = cats(AESDTH_STD);
   AESHOSP  = cats(AESHOSP_STD);
   AESLIFE  = cats(AESLIFE_STD);
   AESMIE   = cats(AESMIE_STD);
   AECONTRT = cats(AECONTRT_STD);

   AEOUT    = upcase(cats(AEOUT_));
   AETOXGR  = upcase(cats(AETOXGR_));

   %jjqcdate2iso(in_date=AESTDAT, in_time=AESTTIM, out_date=&domain.STDTC, flag=1);
   %jjqcdate2iso(in_date=AEENDAT, in_time=AEENTIM, out_date=&domain.ENDTC, flag=1);

   if AEONGO = 1 then AEENRF = 'AFTER';

    /*to keep supp variables*/
     length AEDRGS1 AEDRGO1 AEACNS1 AEACNO1 AERELS1 AERELO1 AETRLPRC AESHOSPR AESHOSPP $200;
	 AEACNS1 = cats(AEACN_STD);
	 AEACNO1 = cats(AEACN1_STD);
	 AERELS1 = cats(AEREL_STD);
	 AERELO1 = cats(AEREL1_STD);
	 AESHOSPR = cats(AESHOSPR_STD);
     AESHOSPP = cats(AESHOSPP_STD);
	 AETRLPRC = cats(AETRLPRC_std);
	 AESOSP = upcase(cats(AESOSP));
	 if cmiss(AEACNS1,AERELS1)<2 then AEDRGS1 = 'VELCADE';
	 if cmiss(AEACNO1,AERELO1)<2 then AEDRGO1 = 'DEXAMETHASONE';

    format _all_;
    informat _all_;

   keep &&&domain._varlst_ 
        AEDRGS1 AEDRGO1 AEACNS1 AEACNO1 AERELS1 AERELO1 AETRLPRC AESHOSPR AESHOSPP AESOSP
        sitenumber subject foldername instancename;
run;
proc sort ; by USUBJID ; run;
proc sort data=transfer.DM out=DM ; by USUBJID ; run;

data ae_;
  merge ae_(in=a) dm(keep=USUBJID RFXSTDTC);
  by USUBJID;
  if a;
     length AETRTEM $200;
	 if AESTDTC >= RFXSTDTC > '' then AETRTEM = 'Y';
	 else if prxmatch('/\d{4}-\d{2}-\d{2}/',scan(AESTDTC,1,'T'))=0 
             and ^('-----' < AEENDTC <= RFXSTDTC) then AETRTEM = 'Y';
run;


/*calculate --STDY and --ENDY*/
%jjqccomdy(in_data=ae_, out_data=ae_1, in_var=AESTDTC, out_var=AESTDY);
%jjqccomdy(in_data=ae_1, out_data=ae_, in_var=AEENDTC, out_var=AEENDY);

/*add epoch*/
%jjqcmepoch(in_data=ae_, out_data=ae,in_date=AESTDTC);

/*add seqnum*/
%jjqcseq(out_data=qtrans.AE,retainvar_=STUDYID DOMAIN USUBJID &domain.SEQ &&&domain._varlst_);

**SUPPAE**;
%jjqcvaratt(domain=SUPPAE);

data supp;
    set qtrans.&domain;
    keep STUDYID USUBJID AESEQ AEDRGS1 AEDRGO1 AEACNS1 AEACNO1 AERELS1 AERELO1 AETRLPRC AESHOSPR AESHOSPP AESOSP AETRTEM;
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
    IDVAR    = "AESEQ";
    IDVARVAL = STRIP(put(AESEQ,best.));
    if qnam ^= 'AETRTEM' then QORIG    = "CRF";
	else QORIG    = "DERIVED";
    QEVAL    = "";
run;
%mend supp;
          
%supp(i=1,QNAM=AEDRGS1);
%supp(i=2,QNAM=AEDRGO1);
%supp(i=3,QNAM=AEACNS1);
%supp(i=4,QNAM=AEACNO1);
%supp(i=5,QNAM=AERELO1);
%supp(i=6,QNAM=AERELS1);
%supp(i=7,QNAM=AETRLPRC);
%supp(i=8,QNAM=AESHOSPR);
%supp(i=9,QNAM=AESHOSPP);
%supp(i=10,QNAM=AESOSP);
%supp(i=11,QNAM=AETRTEM);

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
          , dataMain        =  transfer.AE
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );

%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.SUPPAE
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );
