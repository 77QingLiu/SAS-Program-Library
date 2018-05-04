/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX
  Example Call:          Note: Part of program: pfesacq_sae_recon 
               
                         Call from parent submacro pfesacq_sae_recon.sas:
                         %pfesacq_sae_recon_ae_check12();

-------------------------------------------------------------------------------
 
  Author:                Shiva Bhimreddy, $LastChangedBy: bhimres $
  Creation Date:         01JUN2015                       $LastChangedDate: 2015-10-01 17:22:10 -0400 (Thu, 01 Oct 2015) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/unittesting/testing_area/macros/partnership_macros/pfe/pfesacq_sae_recon_ae_check12.sas $
 
  Files Created:         None
 
  Program Purpose:       Merge the EDC AE dataset with the safety (CSV/XLS) AE dataset
                         and see if there are any mismatches for the AE Death Date.                      
 
                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:
 
  Macro Output:  

  Macro Dependencies:    Note: Part of program: pfesacq_sae_recon 

                         This is a submacro dependant on calling parent macro: 
                         pfesacq_sae_recon.sas

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 1170 $
  
-----------------------------------------------------------------------------*/

%macro pfesacq_sae_recon_ae_check12();
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_SAE_RECON_AE_CHECK12: Start of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

	*** Sort the 2 datasets by Study and Merge them to check if AE Death Date mismatches exist ***;

	*** EDC ***;

	proc sort data=outdir.ae_crf out=edc;
		by subjid aedecd2 fromdate deathdt;
		where subjid ne '' and aeser in ('YES','Y');
	run;

	proc sort data=outdir.dm_crf out=dmedc nodupkey;
		by subjid;
	run;

	data edc;
		merge edc(in=a) dmedc(in=b);
		by subjid;
		if a;
	run;

	proc sort data=edc;
		by study subjid aeterm aecaseid;
	run;

	*** Safety ***;

	proc sort data=outdir.aesafety out=safe;
		by subjid aedecd2 fromdate deathdt;
		where subjid ne '';
	run;

	proc sort data=outdir.dmsafety out=dmsafe nodupkey;
		by subjid;
	run;

	data safe;
		merge safe(in=a) dmsafe(in=b);
		by subjid;
		if a;
	run;

	proc sort data=safe;
		by study subjid aeterm aecaseid;
	run;

	*** Create a dataset with AE Death Date mismatches ***;

	data check1;
		length flag $40;
		merge edc(in=a  rename=(dob=clindob sex=clinsex aeser=clinser aedecd2=clindecd fromdate=clinst todate=clinen aepres=clinpres aercaus=clinrel aestdrg=clinacn deathdt=clindth)) 
			  safe(in=b rename=(dob=safedob sex=safesex aeser=safeser aedecd2=safedecd fromdate=safest todate=safeen aepres=safepres aercaus=saferel aestdrg=safeacn deathdt=safedth));
		by study subjid aeterm aecaseid;

		if a=1 then do;
                      clinstudy=study;
					  clinsubj=subjid;
					  clincase=aecaseid;
					  clinterm=aeterm;
					end;

		if b=1 then do;
                      safestudy=study;
					  safesubj=subjid;
					  safecase=aecaseid;
					  safeterm=aeterm;
					end;	

		if a and b and clindob   ne safedob   then ae1=1;
		if a and b and clinsex   ne safesex   then ae2=1;
		if a and b and clinser   ne safeser   then ae3=1;
		if a and b and clindecd  ne safedecd  then ae4=1;
		if a and b and clinst    ne safest    then ae5=1;
		if a and b and clinen    ne safeen    then ae6=1;
		if a and b and clinpres  ne safepres  then ae7=1;
		if a and b and clinrel   ne saferel   then ae8=1;
		if a and b and clinacn   ne safeacn   then ae9=1;
		if a and b and clindth   ne safedth   then ae10=1;

		count=sum(ae1,ae2,ae3,ae4,ae5,ae6,ae7,ae8,ae9,ae10);

		if ae1=1  then ae1c='DOB';
		if ae2=1  then ae2c='Sex';
		if ae3=1  then ae3c='Serious';
		if ae4=1  then ae4c='Preferred Term';
		if ae5=1  then ae5c='Start Date';
		if ae6=1  then ae6c='End Date';
		if ae7=1  then ae7c='Outcome';
		if ae8=1  then ae8c='Causality';
		if ae9=1  then ae9c='Action';
		if ae10=1 then ae10c='Death Date';

		category=catx(', ',ae1c,ae2c,ae3c,ae4c,ae5c,ae6c,ae7c,ae8c,ae9c,ae10c);


		if count>1 then flag = 'Multiple mismatches';


		if a=1 and b=0 then flag = 'CRF/eCRF only';
		if a=0 and b=1 then flag = 'Safety data only';

		if flag ne '';

	run;


	data aecheck12;
		set check1;
	run;

/*
	*** Remove CRF only records from AECHECK10 if AECHECK12 has them ***;

	proc sort data=aecheck10 out=aecheck10crf;
		by study subjid aeterm aecaseid;
		where flag='CRF/eCRF only';
	run;

	proc sort data=aecheck12 out=aecheck12crf nodupkey;
		by study subjid aeterm aecaseid;
		where flag in ('CRF/eCRF only','Multiple mismatches');
	run;

	data aecheck10crf;
		merge aecheck10crf(in=a) aecheck12crf(in=b);
		by study subjid aeterm aecaseid;
		if a=1 and b=1 then delete;
	run;

	*** Remove Safe only records from AECHECK10 if AECHECK12 has them ***;

	proc sort data=aecheck10 out=aecheck10safe;
		by study subjid aeterm aecaseid;
		where flag='Safety data only';
	run;

	proc sort data=aecheck12 out=aecheck12safe nodupkey;
		by study subjid aeterm aecaseid;
		where flag in ('Safety data only','Multiple mismatches');
	run;

	data aecheck10safe;
		merge aecheck10safe(in=a) aecheck12safe(in=b);
		by study subjid aeterm aecaseid;
		if a=1 and b=1 then delete;
		if a;
	run;

	*** Create final AECHECK10 Dataset ***;

	data aecheck10;
		set aecheck10 (where=(flag not in ('CRF/eCRF only','Safety data only') ))
            aecheck10crf
            aecheck10safe;
	run;

*/
	*** Remove records from DMCHECK3 if AECHECK12 has them ***;

	proc sort data=dmcheck3;
		by study subjid aeterm aecaseid;
	run;

	proc sort data=aecheck12 out=aecheck12_d3 nodupkey;
		by study subjid aeterm aecaseid;
		where flag in ('Multiple mismatches') and ae1c='DOB';
	run;

	data dmcheck3;
		merge dmcheck3(in=a) aecheck12_d3(in=b);
		by study subjid aeterm aecaseid;
		if a=1 and b=1 then delete;
		if a;
	run;

	*** Remove records from DMCHECK4 if AECHECK12 has them ***;

	proc sort data=dmcheck4;
		by study subjid aeterm aecaseid;
	run;

	proc sort data=aecheck12 out=aecheck12_d4 nodupkey;
		by study subjid aeterm aecaseid;
		where flag in ('Multiple mismatches') and ae2c='Sex';
	run;

	data dmcheck4;
		merge dmcheck4(in=a) aecheck12_d4(in=b);
		by study subjid aeterm aecaseid;
		if a=1 and b=1 then delete;
		if a;
	run;

	*** Remove records from AECHECK1 if AECHECK12 has them ***;

	proc sort data=aecheck1;
		by study subjid aeterm aecaseid;
	run;

	proc sort data=aecheck12 out=aecheck12_1 nodupkey;
		by study subjid aeterm aecaseid;
		where flag in ('Multiple mismatches') and ae3c='Serious';
	run;

	data aecheck1;
		merge aecheck1(in=a) aecheck12_1(in=b);
		by study subjid aeterm aecaseid;
		if a=1 and b=1 then delete;
		if a;
	run;

	*** Remove records from AECHECK4 if AECHECK12 has them ***;

	proc sort data=aecheck4;
		by study subjid aeterm aecaseid;
	run;

	proc sort data=aecheck12 out=aecheck12_4 nodupkey;
		by study subjid aeterm aecaseid;
		where flag in ('Multiple mismatches') and ae4c='Preferred Term';
	run;

	data aecheck4;
		merge aecheck4(in=a) aecheck12_4(in=b);
		by study subjid aeterm aecaseid;
		if a=1 and b=1 then delete;
		if a;
	run;

	*** Remove records from AECHECK5 if AECHECK12 has them ***;

	proc sort data=aecheck5;
		by study subjid aeterm aecaseid;
	run;

	proc sort data=aecheck12 out=aecheck12_5 nodupkey;
		by study subjid aeterm aecaseid;
		where flag in ('Multiple mismatches') and ae5c='Start Date';
	run;

	data aecheck5;
		merge aecheck5(in=a) aecheck12_5(in=b);
		by study subjid aeterm aecaseid;
		if a=1 and b=1 then delete;
		if a;
	run;

	*** Remove records from AECHECK6 if AECHECK12 has them ***;

	proc sort data=aecheck6;
		by study subjid aeterm aecaseid;
	run;

	proc sort data=aecheck12 out=aecheck12_6 nodupkey;
		by study subjid aeterm aecaseid;
		where flag in ('Multiple mismatches') and ae6c='End Date';
	run;

	data aecheck6;
		merge aecheck6(in=a) aecheck12_6(in=b);
		by study subjid aeterm aecaseid;
		if a=1 and b=1 then delete;
		if a;
	run;

	*** Remove records from AECHECK7 if AECHECK12 has them ***;

	proc sort data=aecheck7;
		by study subjid aeterm aecaseid;
	run;

	proc sort data=aecheck12 out=aecheck12_7 nodupkey;
		by study subjid aeterm aecaseid;
		where flag in ('Multiple mismatches') and ae7c='Outcome';
	run;

	data aecheck7;
		merge aecheck7(in=a) aecheck12_7(in=b);
		by study subjid aeterm aecaseid;
		if a=1 and b=1 then delete;
		if a;
	run;

	*** Remove records from AECHECK8 if AECHECK12 has them ***;

	proc sort data=aecheck8;
		by study subjid aeterm aecaseid;
	run;

	proc sort data=aecheck12 out=aecheck12_8 nodupkey;
		by study subjid aeterm aecaseid;
		where flag in ('Multiple mismatches') and ae8c='Causality';
	run;

	data aecheck8;
		merge aecheck8(in=a) aecheck12_8(in=b);
		by study subjid aeterm aecaseid;
		if a=1 and b=1 then delete;
		if a;
	run;

	*** Remove records from AECHECK9 if AECHECK12 has them ***;

	proc sort data=aecheck9;
		by study subjid aeterm aecaseid;
	run;

	proc sort data=aecheck12 out=aecheck12_9 nodupkey;
		by study subjid aeterm aecaseid;
		where flag in ('Multiple mismatches') and ae9c='Action';
	run;

	data aecheck9;
		merge aecheck9(in=a) aecheck12_9(in=b);
		by study subjid aeterm aecaseid;
		if a=1 and b=1 then delete;
		if a;
	run;

	*** Remove records from AECHECK11 if AECHECK12 has them ***;

	proc sort data=aecheck11;
		by study subjid aeterm aecaseid;
	run;

	proc sort data=aecheck12 out=aecheck12_11 nodupkey;
		by study subjid aeterm aecaseid;
		where flag in ('Multiple mismatches') and ae10c='Death Date';
	run;

	data aecheck11;
		merge aecheck11(in=a) aecheck12_11(in=b);
		by study subjid aeterm aecaseid;
		if a=1 and b=1 then delete;
		if a;
	run;


	*** Remove records from AECHECK12 (SUBSET AECHECK12T) if AECHECK2 has them ***;

	data aecheck12t;
		set aecheck12;
		where flag in ('CRF/eCRF only','Safety data only');
		if flag='CRF/eCRF only'    then do;aeterm=clinterm;aecaseid=clincase;end;
		if flag='Safety data only' then do;aeterm=safeterm;aecaseid=safecase;end;
	run;

	proc sort data=aecheck12t;
		by study subjid aeterm;
	run;

	data aecheck2_1;
		set aecheck2;
		if clincase ne '' then aecaseid=clincase;
		if safecase ne '' then aecaseid=safecase;
	run;

	proc sort data=aecheck2_1 nodupkey;
		by study subjid aeterm;
	run;

	data aecheck12t;
		merge aecheck12t(in=a) aecheck2_1(in=b);
		by study subjid aeterm;
		if a=1 and b=1 then delete;
		if a;
	run;

	*** Remove records from AECHECK12T if AECHECK3 has them ***;

	data aecheck3_1;
		set aecheck3;
		if clinterm ne '' then aeterm=clinterm;
		if safeterm ne '' then aeterm=safeterm;
	run;

	proc sort data=aecheck3_1 nodupkey;
		by study subjid aecaseid;
	run;

	proc sort data=aecheck12t;
		by study subjid aecaseid;
	run;

	data aecheck12t;
		merge aecheck12t(in=a) aecheck3_1(in=b);
		by study subjid aecaseid;
		if a=1 and b=1 then delete;
		if a;
	run;

	*** Remove records from AECHECK12T if DMCHECK1 has them ***;

	proc sort data=dmcheck1 out=dmcheck1_1(rename=(clinstdy=study)) nodupkey;
		by clinstdy;
		where clinstdy ne '';
	run;

	proc sort data=aecheck12t;
		by study;
	run;

	data aecheck12t;
		merge aecheck12t(in=a) dmcheck1_1(in=b);
		by study;
		if a=1 and b=1 then delete;
		if a;
	run;

	proc sort data=dmcheck1 out=dmcheck1_1(rename=(safestdy=study)) nodupkey;
		by safestdy;
		where safestdy ne '';
	run;

	proc sort data=aecheck12t;
		by study;
	run;

	data aecheck12t;
		merge aecheck12t(in=a) dmcheck1_1(in=b);
		by study;
		if a=1 and b=1 then delete;
		if a;
	run;

	*** Remove records from AECHECK12T if DMCHECK2 has them ***;

	proc sort data=dmcheck2 out=dmcheck2_1(rename=(clinsubj=subjid)) nodupkey;
		by clinsubj;
		where clinsubj ne '';
	run;

	proc sort data=aecheck12t;
		by subjid;
	run;

	data aecheck12t;
		merge aecheck12t(in=a) dmcheck2_1(in=b);
		by subjid;
		if a=1 and b=1 then delete;
		if a;
	run;


	proc sort data=dmcheck2 out=dmcheck2_1(rename=(safesubj=subjid)) nodupkey;
		by safesubj;
		where safesubj ne '';
	run;

	proc sort data=aecheck12t;
		by subjid;
	run;

	data aecheck12t;
		merge aecheck12t(in=a) dmcheck2_1(in=b);
		by subjid;
		if a=1 and b=1 then delete;
		if a;
	run;

	*** Add remaining records to AECHECK12 ***;

	data aecheck12;
		set aecheck12 (where =(flag not in ('CRF/eCRF only','Safety data only') ) )
		    aecheck12t;
	run;


	*** Check if DOCNUM exists in this study ***;
	proc contents data=aecheck1 noprint out=aecont;
	run;

	proc sql noprint;
		select count(*) into:datalabs
		from aecont
		where upcase(name)='DOCNUM';
	quit;

	*** Concatenate all 15 checks datasets ***;

	data allchecks;
		set dmcheck1 dmcheck2 dmcheck3 dmcheck4 
		    aecheck1 aecheck2 aecheck3 aecheck4
		    aecheck5 aecheck6 aecheck7 aecheck8
		    aecheck9 aecheck10 aecheck11 aecheck12;

		%if &datalabs ne 1 %then %do;
								  if docnum = '' then docnum = 'N/A';
							  %end;

	run;

	proc sort data=allchecks out=outdir.allchecks;
		by study clinstdy safestdy subjid clinsubj safesubj;
	run;


	proc datasets lib=work;
		delete dmcheck1 dmcheck2 dmcheck3 dmcheck4 aecheck1 aecheck2 aecheck3 aecheck4 aecheck5 aecheck6 
	       	   aecheck7 aecheck8 aecheck9 aecheck10 aecheck11 aecheck12 aecheck10crf aecheck12crf aecheck10safe
           	   aecheck12safe allchecks edc dmedc safe dmsafe check1 aecont aecheck12_1 aecheck12_4 aecheck12_5 aecheck12_6 aecheck12_7 
               aecheck12_8 aecheck12_9 aecheck12_11 aecheck12_d3 aecheck12_d4 dmcheck1_1 dmcheck2_1 aecheck12t aecheck2_1 aecheck3_1;
	run;
	quit;




    %macend:;
    %put ;
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_SAE_RECON_AE_CHECK12: End of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_sae_recon_ae_check12;

*** Example macro call ***;

*%pfesacq_sae_recon_ae_check12();