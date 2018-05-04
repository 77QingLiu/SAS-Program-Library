/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   Janssen Research and Development LLC / CNTO1959PSA3002
  PAREXEL Study Code:    234200

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Owner:         Cony Geng        $LastChangedBy: xiaz $
  Creation Date:         12Jun2017 / $LastChangedDate: 2017-07-27 02:40:47 -0400 (Thu, 27 Jul 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/qc_fa.sas $

  Files Created:         fa.sas7bdat, suppfa.sas7bdat
                         qc_fa.txt

  Program Purpose:       Produce and QC FA and SUPPFA domains

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 17 $
-----------------------------------------------------------------------------*/

/*clean work dataset*/
%jjqcclean;

/*read attrib from spec*/
%let domain=FA;
%jjqcvaratt(domain=FA, flag=1);
%jjqcdata_type;

proc sort data = raw.FA_PSA_001 out = date_1;
    by SITENUMBER SUBJECT DATAPAGENAME INSTANCENAME RECORDPOSITION;
run;

proc sort nodupkey data = date_1 out = date_1;
    by SITENUMBER SUBJECT DATAPAGENAME INSTANCENAME;
run;

proc sort data = raw.FA_PS_003 out = date_2;
    by SITENUMBER SUBJECT DATAPAGENAME INSTANCENAME RECORDPOSITION;
run;

proc sort nodupkey data = date_2 out = date_2;
    by SITENUMBER SUBJECT DATAPAGENAME INSTANCENAME;
run;


/*start to create*/
%macro fa(i=,in=);


proc sort data=qtrans.sv(where=(folder^='DE'))
          out=sv(keep=sitenumber subject folder instancename visit visitnum visitdy svstdtc);
  by sitenumber subject folder instancename;
run;

proc sort data=&in.(where=(&raw_sub)) out=fa&i; by sitenumber subject folder instancename; run;

data fa&i;
    merge fa&i(in=a) sv;
    by sitenumber subject folder instancename;
    if a;
run;




data fa&i.;
    set fa&i(drop=studyid

             %if &i=1 or &i=6 or &i=13 %then %do;rename=(facat=facat_) %end;
			 %if &i=4 %then %do;rename=(facat=facat_ faobj=faobj_) %end;
             %if &i=2 or &i=14 %then %do;  rename=(faobj=faobj_ facat=facat_ faorres=faorres_) %end;);

    attrib &&&domain._varatt_;
	call missing(fagrpid,fatest,faevlint,faorresu,fastresu);
    fastresn=.;
    studyid=strip(PROJECT);
    DOMAIN   = "&domain";
    usubjid=catx("-",PROJECT,SUBJECT);
    DATAPAGENAME=translate(DATAPAGENAME,repeat('',161),compress(collate(0),,'w'));
    DATAPAGENAME=strip(compbl(DATAPAGENAME));
    faspid=catx('-', 'RAVE', upcase(INSTANCENAME), upcase(DATAPAGENAME), put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));

    %if &i^=8 or &i^=9 or &i^=11 or &i^=12 %then %do;
      fadtc=svstdtc;
    %end;

    
	%if &i=13 %then %do; 
      if ^missing(DIAGDTC) then do;
        facat=facat_;
        faobj='Psoriatic Arthritis';
        fatestcd='DIAGDTC';
        %jjqcdate2iso(in_date=DIAGDTC, in_time=, out_date=FAORRES);
        FASTRESC=FAORRES;
        output;
      end;
    %end;
    %if &i=1 %then %do;
      if not missing(FAOBJ_SUB) then do;
	    facat=facat_;
        fatestcd='OCCUR';
		faobj=strip(FAOBJ_SUB);
        faorres='Y';
        fastresc=FAORRES;
        output;
      end;

	  if not missing(FAIMGYN_STD) then do;
	    facat=facat_;
		faobj='Imaging confirmation';
        fatestcd='OCCUR';
        faorres=strip(FAIMGYN_STD);
        fastresc=FAORRES;
        output;
      end;

/*	   if not missing(FARAYYN_STD) then do;*/
/*	    facat=facat_;*/
/*        fatestcd='OCCUR';*/
/*		faobj='Screening xray with confirmation of sacroiliitis';*/
/*        faorres=strip(FARAYYN_STD);*/
/*        fastresc=FAORRES;*/
/*        output;*/
/*      end;*/

	   if not missing(FASPONYN_STD) then do;
	    facat=facat_;
        fatestcd='OCCUR';
		faobj='Rheumatologist confirmed the diagnosis of spondylitis';
        faorres=strip(FASPONYN_STD);
        fastresc=FAORRES;
        output;
      end;
    %end;

     
    %if &i=14 %then %do;
      if not missing(DIAGDTC) then do;
        facat=facat_;
		faobj='Psoriasis';
        fatestcd='DIAGDTC';
        %jjqcdate2iso(in_date=DIAGDTC, in_time=, out_date=FAORRES);
        FASTRESC=FAORRES;
        output;
      end;
    %end;
 
    %if &i=2 %then %do;
      if ^missing(FAOBJ_) then do;
	    facat=facat_;
		faobj=strip(FAOBJ_);
        fatestcd='OCCUR';
        faorres=FAORRES_STD;
        FASTRESC=FAORRES;
        output;
      end;

    %end;

    %if &i=3 %then %do;
      if not missing(DURCUM_STD) then do;
        fatestcd='DURCUM';
        facat=CMCAT;
	    faobj=CMTRT;
        faorres=DURCUM_STD;
        FASTRESC=faorres;
        output;
      end;

    %end;

    %if &i=4 %then %do;

      faobj=faobj_;
      facat=facat_;

      if not missing(DURCUM_STD) then do;
	    fatestcd="DURCUM";
        faorres=strip(DURCUM_STD);
        FASTRESC=faorres;
        output;
      end;

      if not missing(DOSCUM_STD) then do;
        fatestcd='DOSCUM';
        faorres=strip(DOSCUM_STD);
        FASTRESC=faorres;
		faorresu=strip(DOSCUMU_STD);
		fastresu=faorresu;
        output;
      end;

      if not missing(DOSLMAX) then do;
	    fatestcd='DOSLMAX';
        faorres=strip(put(DOSLMAX,best.));
        FASTRESC=faorres;
		faorresu=strip(DOSLMAXU_STD);
		fastresu=faorresu;
		fastresn=input(faorres,??best.);
		faevlint='-P3M';
        output;
      end;

      if not missing(FAEXYN_STD) then do;
        fatestcd='DSCCTIND';
        faorres=strip(FAEXYN_STD);
        FASTRESC=faorres;
		fastresn=.;
		faorresu='';
		fastresu='';
		faevlint='';
        output;
      end;

      if not missing(FAEXYN_1_STD) then do;
        fatestcd='DSCIRSP';
        faorres=strip(FAEXYN_1_STD);
        FASTRESC=faorres;
		fastresn=.;
		fastresn=.;
		faorresu='';
		fastresu='';
		faevlint='';
        output;
      end;

      if not missing(FAEXYN_2_STD) then do;
        fatestcd='DSCAE';
        faorres=strip(FAEXYN_2_STD);
        FASTRESC=faorres;
		fastresn=.;
		faorresu='';
		fastresu='';
		faevlint='';
        output;
      end;

      if not missing(DSOTHYN_STD) then do;
        fatestcd='DSOTHYN';
        faorres=strip(DSOTHYN_STD);
        FASTRESC=faorres;
		fastresn=.;
		faorresu='';
		fastresu='';
		faevlint='';
        output;
      end;

      if not missing(FAEXREA_STD) then do;
        fatestcd='DSCOTH';
        faorres=strip(FAEXREA_STD);
        FASTRESC=faorres;
		fastresn=.;
		faorresu='';
		fastresu='';
		faevlint='';
        output;
      end;
    %end;

    %if &i=5 %then %do;
      faobj=cmtrt;
	  facat=cmcat;

      if not missing(DURCUM_STD) then do;
        fatestcd='DURCUM';
        faorres=DURCUM_STD;
        FASTRESC=faorres;
        output;
      end;

      if not missing(DSCCTIND_STD) then do;
        fatestcd='DSCCTIND';
        faorres=DSCCTIND_STD;
        FASTRESC=faorres;
        output;
      end;

      if ^missing(DSCIRSP_STD) then do;
        fatestcd='DSCIRSP';
        faorres=DSCIRSP_STD;
        FASTRESC=faorres;
        output;
      end;

      if not missing(DSCAE_STD) then do;
        fatestcd='DSCAE';
        faorres=DSCAE_STD;
        FASTRESC=faorres;
        output;
      end;

      if not missing(DSOTHYN_STD) then do;
        fatestcd='DSOTHYN';
        faorres=DSOTHYN_STD;
        FASTRESC=faorres;
        output;
      end;

      if not missing(DSCOTH_STD) then do;
        fatestcd='DSCOTH';
        faorres=DSCOTH_STD;
        FASTRESC=faorres;
        output;
      end;
    %end;

    %if &i=6 %then %do;
      facat="MEDICATION REVIEW";
      m=6;
      if not missing(TRTINI_STD) then do;
        fatestcd='TRTINI';
        faorres=TRTINI_STD;
        FASTRESC=faorres;
		faobj='Methotrexate';
        output;
      end;

	  if not missing(TRTDINC_STD) then do;
        fatestcd='DOSINCB';
        faorres=TRTDINC_STD;
        FASTRESC=faorres;
		faobj='Methotrexate';
        output;
      end;

	  if not missing(TRTINI1_STD) then do;
        fatestcd='TRTINI';
        faorres=TRTINI1_STD;
        FASTRESC=faorres;
		faobj='Oral Corticosteroids';
        output;
      end;

	  if not missing(TRTDINC1_STD) then do;
        fatestcd='DOSINCB';
        faorres=TRTDINC1_STD;
        FASTRESC=faorres;
		faobj='Oral Corticosteroids';
        output;
      end;

	  if not missing(TRTDINC2_STD) then do;
        fatestcd='TRTINI';
        faorres=TRTDINC2_STD;
        FASTRESC=faorres;
		faobj='Protocol prohibited medications/therapies';
        output;
      end;


	  if not missing(TRTDINC2A_STD) then do;
        fatestcd='TRTINI';
        faorres=TRTDINC2A_STD;
        FASTRESC=faorres;
		faobj='DMARDS';
        output;
      end;

	  if not missing(TRTDINC2B_STD) then do;
        fatestcd='TRTINI';
        faorres=TRTDINC2B_STD;
        FASTRESC=faorres;
		faobj='Systemic Immunosuppressive Agents';
        output;
      end;

	  if not missing(TRTDINC2C_STD) then do;
        fatestcd='TRTINI';
        faorres=TRTDINC2C_STD;
        FASTRESC=faorres;
		faobj='Intravenous, intramuscular, or epidural administration of corticosteroids';
        output;
      end;

	  if not missing(TRTDINC2D_STD) then do;
        fatestcd='TRTINI';
        faorres=TRTDINC2D_STD;
        FASTRESC=faorres;
		faobj='Biologic Agents, Cytotoxic Drugs, JAK Inhibitors, or Investigational Agents';
        output;
      end;

	  if not missing(TRTDINC2E_STD) then do;
        fatestcd='TRTINI';
        faorres=TRTDINC2E_STD;
        FASTRESC=faorres;
		faobj='Complementary Therapies';
        output;
      end;
      if not missing(TRTDINC2F_STD) then do;
        fatestcd='TRTINI';
        faorres=TRTDINC2F_STD;
        FASTRESC=faorres;
		faobj='Other therapies';
        output;
      end;

	  if not missing(TRTDINC3_STD) then do;
        fatestcd='TRTINI';
        faorres=TRTDINC3_STD;
        FASTRESC=faorres;
		faobj='Protocol permitted concomitant medications other than MTX/oral Corticosteroid';
        output;
      end;


	  if not missing(TRTDINC3A_STD) then do;
        fatestcd='TRTINI';
        faorres=TRTDINC3A_STD;
        FASTRESC=faorres;
		faobj='SSZ, HCQ, or LEF';
        output;
      end;

	  if not missing(TRTDINC3B_STD) then do;
        fatestcd='TRTINI';
        faorres=TRTDINC3B_STD;
        FASTRESC=faorres;
		faobj='NSAIDs';
        output;
      end;

	  if not missing(TRTDINC3C_STD) then do;
        fatestcd='TRTINI';
        faorres=TRTDINC3C_STD;
        FASTRESC=faorres;
		faobj='Other analgesics';
        output;
      end;

	  if not missing(TRTDINC4_STD) then do;
        fatestcd='DOSINCB';
        faorres=TRTDINC4_STD;
        FASTRESC=faorres;
		faobj='Protocol permitted concomitant medications other than MTX/oral Corticosteroid';
        output;
      end;

	  if not missing(TRTDINC4A_STD) then do;
        fatestcd='DOSINCB';
        faorres=TRTDINC4A_STD;
        FASTRESC=faorres;
		faobj='SSZ, HCQ, or LEF';
        output;
      end;

	  if not missing(TRTDINC4B_STD) then do;
        fatestcd='DOSINCB';
        faorres=TRTDINC4B_STD;
        FASTRESC=faorres;
		faobj='NSAIDs';
        output;
      end;

	  if not missing(TRTDINC4C_STD) then do;
        fatestcd='DOSINCB';
        faorres=TRTDINC4C_STD;
        FASTRESC=faorres;
		faobj='Other analgesics';
        output;
      end;
    %end;

    %if &i=7 %then %do;
	  facat='SCREENING FOR TUBERCULOSIS';
      if not missing(TBSSATB_STD) then do;
        fatestcd='OCCUR';
        faorres=TBSSATB_STD;
        FASTRESC=faorres;
		faobj='Signs or Symptoms of Active TB';
        output;
      end;

	   if not missing(TBAGENT_STD) then do;
        fatestcd='TRTREC';
        faorres=TBAGENT_STD;
        FASTRESC=faorres;
		faobj='Receive treatment for latent TB';
        output;
      end;

	   if not missing(TBFIVE_STD) then do;
        fatestcd='TRTCOMP';
        faorres=TBFIVE_STD;
        FASTRESC=faorres;
		faobj='Complete treatment for latent TB in the last 5 years';
        output;
      end;

	   if not missing(TBRCATB_STD) then do;
        fatestcd='OCCUR';
        faorres=TBRCATB_STD;
        FASTRESC=faorres;
		faobj='Contact with individual with active TB';
        output;
      end;

	   if not missing(TBTRTRQ_STD) then do;
        fatestcd='TRTREQ';
        faorres=TBTRTRQ_STD;
        FASTRESC=faorres;
		faobj='Require treatment for latent TB';
        output;
      end;

	
    %end;

	%if &i=8 %then %do;
	  facat='PELVIC X-RAY';
      if not missing(PELVICYN_STD) then do;
	    FADTC='';
        fatestcd='OCCUR';
        faorres=PELVICYN_STD;
        FASTRESC=faorres;
		faobj='Pelvic X-ray';
	    %jjqcdate2iso(in_date=PELVICDAT, in_time=, out_date=FADTC);
        output;
      end;
	%end;

    %if &i=9 %then %do;
	  facat='TUBERCULOSIS TESTING';
      if not missing(TTYN_STD) then do;
	    FADTC='';
        fatestcd='OCCUR';
        faorres=TTYN_STD;
        FASTRESC=faorres;
		faobj='Repeat chest radiograph';
	    %jjqcdate2iso(in_date=TTDY, in_time=, out_date=FADTC);
        output;
      end;

	   if not missing(TTCDR_STD) then do;
	    FADTC='';
        fatestcd='RESULT';
        faorres=TTCDR_STD;
        FASTRESC=faorres;
		faobj='Repeat chest radiograph';
	    %jjqcdate2iso(in_date=TTDY, in_time=, out_date=FADTC);
        output;
      end;

	   if not missing(TTYD_STD) then do;
	     FADTC='';
        fatestcd='OCCUR';
        faorres=TTYD_STD;
        FASTRESC=faorres;
		faobj='Repeat QuantiFERON TB Gold test';
        %jjqcdate2iso(in_date=TTDD, in_time=, out_date=FADTC);
        output;
      end;

	   if not missing(TTNSD_STD) then do;
	    FADTC='';
        fatestcd='TRTREQ';
        faorres=TTNSD_STD;
        FASTRESC=faorres;
		faobj='Require treatment for latent TB';
        output;
      end;
    %end;

	%if &i=10 %then %do;
	  facat='EARLY ESCAPE MEDICATIONS';
      if not missing(EEM) then do;
        fatestcd='ACT';
        faorres=EEM_STD;
        FASTRESC=faorres;
		faobj='Early Escape Medications';
        output;
      end;
	%end;

	%if &i=11 %then %do;
	  facat='TB FOLLOW-UP CALL';
      if not missing(TBFUCALLYN_STD) then do;
	    FADTC='';
        fatestcd='OCCUR';
        faorres=TBFUCALLYN_STD;
        FASTRESC=faorres;
		faobj='TB Follow-Up Call';
		%jjqcdate2iso(in_date=TBDAT, in_time=, out_date=FADTC);
        output;
      end;
	%end;

	%if &i=12 %then %do;
	  facat='RADIOGRAPHS OF HANDS AND FEET';
      if not missing(RADIOHFYN_STD) then do;
	    FADTC='';
        fatestcd='OCCUR';
        faorres=RADIOHFYN_STD;
        FASTRESC=faorres;
		faobj='Radiographs of Hands and Feet';
		%jjqcdate2iso(in_date=RADIODAT, in_time=, out_date=FADTC);
        output;
      end;
	%end;

    %if &i=15 or  &i=16  %then %do;

      faobj=cmtrt;
      facat=cmcat;

      if not missing(DURCUM_STD) then do;
	    fatestcd="DURCUM";
        faorres=strip(DURCUM_STD);
        FASTRESC=faorres;
        output;
      end;

      if not missing(DOSMAX) then do;
	    fatestcd='DOSMAX';
        faorres=strip(put(DOSMAX,best.));
        FASTRESC=faorres;
		faorresu=strip(DOSMAXU_STD);
		fastresu=faorresu;
		fastresn=input(faorres,??best.);
		faevlint=' ';
        output;
      end;

      if not missing(DSMAXFRQ_STD) then do;
        fatestcd='DSMAXFRQ';
        faorres=strip(DSMAXFRQ_STD);
        FASTRESC=faorres;
		fastresn=.;
		faorresu='';
		fastresu='';
		faevlint='';
        output;
      end;

      if not missing(DSCDCTD_STD) then do;
        fatestcd='DSCCTIND';
        faorres=strip(DSCDCTD_STD);
        FASTRESC=faorres;
		fastresn=.;
		faorresu='';
		fastresu='';
		faevlint='';
        output;
      end;

      if not missing(DSCIADR_STD) then do;
        fatestcd='DSCIRSP';
        faorres=strip(DSCIADR_STD);
        FASTRESC=faorres;
		fastresn=.;
		fastresn=.;
		faorresu='';
		fastresu='';
		faevlint='';
        output;
      end;

      if not missing(DSCADE_STD) then do;
        fatestcd='DSCAE';
        faorres=strip(DSCADE_STD);
        FASTRESC=faorres;
		fastresn=.;
		faorresu='';
		fastresu='';
		faevlint='';
        output;
      end;

      if not missing(DSCANR_STD) then do;
        fatestcd='DSOTHYN';
        faorres=strip(DSCANR_STD);
        FASTRESC=faorres;
		fastresn=.;
		faorresu='';
		fastresu='';
		faevlint='';
        output;
      end;

      if not missing(DSCORS_STD) then do;
        fatestcd='DSCOTH';
        faorres=strip(DSCORS_STD);
        FASTRESC=faorres;
		fastresn=.;
		faorresu='';
		fastresu='';
		faevlint='';
        output;
      end;
    %end;
    
    fablfl='';
    epoch='';
    fady=.;
    keep &&&domain._varlst_ %if &i=6 %then %do;  m %end;;
 run;

%mend;

%fa(i=1,in=raw.FA_PSA_001);
%fa(i=2,in=raw.FA_PS_003);
%fa(i=3,in=raw.CM_PS_002);
%fa(i=4,in=raw.FA_RA_006);
%fa(i=5,in=raw.CM_RA_005);
%fa(i=6,in=raw.FA_RA_007);
%fa(i=7,in=raw.TBINFO_1);
/*%fa(i=8,in=raw.PELVIC);*/
%fa(i=9,in=raw.TT);
%fa(i=10,in=raw.EEM);
%fa(i=11,in=raw.TB_FU);
/*%fa(i=12,in=raw.RADIO_HF);*/
%fa(i=13,in=date_1);
%fa(i=14,in=date_2);
%fa(i=15,in=raw.CM_RA_006);
%fa(i=16,in=raw.CM_RA_007);

data fa(drop=FABLFL);
    retain &&&domain._varlst_;
    set fa:;
    fatest=put(fatestcd,&domain._testcd.);
    faorres=strip(faorres);
    if fastresc='ADVERSE EVENT' then do;fastresc='AE';faorres='AE';end;
    if fastresc='In Situ' then do;fastresc='0';faorres='0';end;
    if fastresc='Not applicable' then do;fastresc='NOT APPLICABLE';faorres='NOT APPLICABLE';end;
    if fastresc='Unknown' then do;fastresc='UNKNOWN';faorres='UNKNOWN';end;
run;


/*calculate fady*/
%jjqccomdy(in_data=fa, in_var=fadtc, out_var=fady);

/*add epoch*/
%jjqcmepoch(in_data=FA, in_date=fadtc);

/*baseline flag*/
%jjqcBLFL (sortvar=%str(STUDYID,USUBJID,faobj,&domain.TESTCD,&domain.DTC));

proc sort data=fa; by &&&domain._keyvar_ faspid; run;

/*add seqnum*/
%jjqcseq(retainvar_=STUDYID DOMAIN USUBJID &domain.SEQ &&&domain._varlst_);



/*SUPPFA*/
%jjqcvaratt(domain=SUPPFA, flag=1);
%jjqcdata_type;

data qtrans.supp&domain (&keep_sub. keep = &&supp&domain._varlst_ label = &&supp&domain._dlabel_);
    attrib &&supp&domain._varatt_;
    set qtrans.&domain/*(where=(not missing(favirinf_std)  and fatestcd='PTHCAT' and upcase(faorres)='VIRAL' ))*/;
	if m=6 and ^missing(faorres) ;
    RDOMAIN  = "&domain";
    IDVAR    = "FASEQ";
    IDVARVAL = STRIP(put(FASEQ,best.));
    QORIG    = "ASSIGNED";
    QEVAL    = "";
    QNAM   = "FAEVINTX";
    QLABEL = put(QNAM,$&domain._QL.);
    QVAL   ='SINCE LAST REVIEW';
    output;
run;




proc sort data = qtrans.&domain (&keep_sub keep = &&&domain._varlst_ &domain.SEQ);
    by &&&domain._keyvar_;
run;

************************************************************
*  Compare Main domain and QC domain                       *
************************************************************;

%GMCOMPARE( pathOut = &_qtransfer, dataMain = transfer.&domain, libraryQC = qtrans);




proc sort nodupkey data = qtrans.supp&domain (&keep_sub keep = &&supp&domain._varlst_);
  by &&supp&domain._keyvar_;
run;

************************************************************
*  Compare Main domain and QC domain                       *
************************************************************;

%GMCOMPARE( pathOut = &_qtransfer, dataMain = transfer.supp&domain, libraryQC = qtrans);
