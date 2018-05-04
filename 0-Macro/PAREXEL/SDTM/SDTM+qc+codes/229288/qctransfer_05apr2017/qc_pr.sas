/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 61610588LUC1001
  PXL Study Code:        227857

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Pengfei Lu $LastChangedBy: liuc5 $
  Creation Date:         01Jul2016 / $LastChangedDate: 2016-07-17 08:57:45 -0400 (Sun, 17 Jul 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_pr.sas $

  Files Created:         qc_pr.log
                         qc_pr.txt
                         /projects/janss229288/stats/transfer/data/qtransfer/pr.sas7bdat
                         /projects/janss229288/stats/transfer/data/qtransfer/supppr.sas7bdat

  Program Purpose:       To QC Exposure Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 14 $
-----------------------------------------------------------------------------*/
/*clean work dataset*/
proc datasets nolist lib = work memtype = data kill;
quit;

/*read attrib*/
%let domain=PR;
%jjqcvaratt(domain=PR, flag=1);
%jjqcdata_type;

/*start to create*/

proc sort data=raw.PR_ONC_004 out=RPR_ONC_004;
  by sitenumber subject instancename;
run;
proc sort data=raw.PR_ONC_004YN out=RPR_ONC_004YN;
  by sitenumber subject instancename;
run;
data RPR_ONC_004;
  merge RPR_ONC_004(in=a) RPR_ONC_004YN(in=b keep=sitenumber subject instancename PROCCUR_STD);
  by sitenumber subject instancename;
  if a;
run;

%macro pr(i=,raw=);
data pr&i;
  attrib &&&domain._varatt_;
  set &raw(rename=(%if &i=1 %then PRTRT = PRTRT_ PRCAT=PRCAT_ PRINDC=PRINDC_;
				           %if &i=2 %then PRTRT = PRTRT_ PRCAT=PRCAT_ PRINDC=PRINDC_ PRLOC = PRLOC_;
                   %if &i=3 %then PRTRT = PRTRT_ PRCAT=PRCAT_ PRSCAT=PRSCAT_ PRINDC=PRINDC_;
                   %if &i=4 %then PRCAT=PRCAT_ PRDOSE = PRDOSE_ PRDOSEU = PRDOSEU_ PRINDC=PRINDC_;)
           drop = STUDYID);
  
   call missing(PRGRPID,PRSCAT,PRPRESP,PROCCUR,PRINDC,PRDOSE,PRDOSU,PRLOC,EPOCH
                ,VISIT,VISITNUM,VISITDY,PRSTDY,PRENDY,PRENDTC);

   STUDYID  = strip(PROJECT);
   DOMAIN   = "&domain";
   USUBJID  = catx("-",PROJECT,SUBJECT);
   PRSPID   = upcase(catx("-","RAVE",INSTANCENAME,DATAPAGENAME,cats(PAGEREPEATNUMBER),cats(RECORDPOSITION)));

   %if &i=5 %then PRGRPID = cats(CMGRPID_LT);;

   %if &i>=1 and &i<=3 %then PRTRT = cats(PRTRT_);
   %else %if &i=4 %then %do;
     if upcase(cats(PRTRT2)) = 'OTHER TRANSFUSION' and ^missing(upcase(cats(PRTRT3))) then PRTRT = upcase(cats(PRTRT3));
	 else if upcase(cats(PRTRT2)) = 'OTHER TRANSFUSION' and missing(upcase(cats(PRTRT3))) then 
	   put 'WAR' 'NING:[PXL] Type of Transfusion is Other Transfusion but do not specified '
	   sitenumber= subject= foldername= instancename= DATAPAGENAME= PAGEREPEATNUMBER= RECORDPOSITION=
       PRTRT2= PRTRT3=;
	 else if upcase(cats(PRTRT2)) ^= 'OTHER TRANSFUSION' then PRTRT = upcase(cats(PRTRT2));
   %end;
   %else %if &i=5 %then if TRANREL^='No' then PRTRT = upcase(cats(TRANREL));;

   %if &i>=1 and &i<=4 %then PRCAT = upcase(cats(PRCAT_));
   %else %if &i=5 %then PRCAT = upcase(cats(CMCAT));;

   %if &i=3 %then PRSCAT = upcase(cats(PRSCAT_));;

   %if &i=2 %then %do;
      PRPRESP = "Y";
      PROCCUR = PROCCUR_STD;
   %end;

   %if &i=1 %then PRINDC = 'MULTIPLE MYELOMA';
   %else %if &i>=2 and &i<=4 %then PRINDC = upcase(PRINDC_);;

   %if &i=4 %then %do;
      if prxmatch('/\D|\s/',cats(PRDOSE_))=0 then PRDOSE = PRDOSE_;
      if ^missing(PRDOSE) then PRDOSU = cats(PRDOSEU_);
   %end;

   %if &i=2 %then PRLOC = PRLOC_STD;;

   %if &i>=1 and &i<=4 %then %jjqcdate2iso(in_date=PRSTDAT, in_time=, out_date=&domain.STDTC);
   %else %if &i=5 %then %jjqcdate2iso(in_date=PRSTDAT_TR, in_time=, out_date=&domain.STDTC);

   %if &i=2 or &i=3 %then %jjqcdate2iso(in_date=PRENDAT, in_time=, out_date=&domain.ENDTC);

    /*to keep supp variables*/
     %if &i=1 %then PRDOSCUMU = 'Gy';;
	 %if &i=3 %then %jjqcdate2iso(in_date=PRPLNDAT, in_time=, out_date=PRPLNDTC);

   keep &&&domain._varlst_ 
        %if &i=2 %then PRLOCO PRDOSCUM PRDOSCUMU PRINDCO;
        %if &i=3 %then PRINDDSC PRPLNDTC; 
        %if &i=4 %then PRINDCO; 
        sitenumber subject foldername instancename;
run;
%mend pr;

%pr(i=1,raw=raw.PR_ONC_001);
%pr(i=2,raw=RPR_ONC_004);
%pr(i=3,raw=raw.PR_GL_900);
%pr(i=4,raw=raw.PR_GL_901);
%pr(i=5,raw=raw.CM_ONC_003);


data pr_(drop=PRSTDY PRENDY EPOCH VISIT VISITNUM VISITDY);
  set pr:;
  if ^missing(PRTRT);
    format _all_;
    informat _all_;
run;
/*visit visitnum visitdy*/
proc sort; by sitenumber subject foldername instancename; run;
proc sort data=qtrans.sv out=sv(keep=sitenumber subject foldername instancename VISIT VISITNUM VISITDY);
  where index(upcase(instancename),'FOLLOW UP')=0;
  by sitenumber subject foldername instancename;
run;
data pr_;
  merge pr_(in=a) sv;
  by sitenumber subject foldername instancename;
  if a;
run;

/*calculate CMSTDY and CMENDY*/
%jjqccomdy(in_data=pr_, out_data=pr_1, in_var=PRSTDTC, out_var=PRSTDY);
%jjqccomdy(in_data=pr_1, out_data=pr_, in_var=PRENDTC, out_var=PRENDY);

/*add epoch*/
%jjqcmepoch(in_data=pr_, out_data=pr,in_date=PRSTDTC);

/*add seqnum*/
%jjqcseq(out_data=qtrans.pr,retainvar_=STUDYID DOMAIN USUBJID &domain.SEQ &&&domain._varlst_);

**SUPPPR**;
%jjqcvaratt(domain=SUPPPR);

data supp;
    set qtrans.&domain;
    keep STUDYID USUBJID PRSEQ PRLOCO PRDOSCUM PRDOSCUMU PRINDCO PRINDDSC PRPLNDTC;
run;

%macro supp(i=,QNAM=);
data supp&domain.&i(keep = &&supp&domain._varlst_ label = &&supp&domain._dlabel_);
    attrib &&supp&domain._varatt_;;
    set supp;
	where ^missing(&qnam);
    RDOMAIN  = "&domain";
    IDVAR    = "PRSEQ";
    IDVARVAL = STRIP(put(PRSEQ,best.));
    QORIG    = "CRF";
    QEVAL    = "";
    QNAM     = "&QNAM";
    QLABEL   = put(QNAM,$&domain._QL.);
    QVAL     = cats(&QNAM);
run;
%mend supp;
          
%supp(i=1,QNAM=PRLOCO);
%supp(i=2,QNAM=PRDOSCUM);
%supp(i=3,QNAM=PRDOSCUMU);
%supp(i=4,QNAM=PRINDCO);
%supp(i=5,QNAM=PRINDDSC);
%supp(i=6,QNAM=PRPLNDTC);

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
          , dataMain        =  transfer.pr
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );

%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.SUPPPR
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );
