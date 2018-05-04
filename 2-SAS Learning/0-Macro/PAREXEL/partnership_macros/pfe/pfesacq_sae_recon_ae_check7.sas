/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX
  Example Call:          Note: Part of program: pfesacq_sae_recon 
               
                         Call from parent submacro pfesacq_sae_recon.sas:
                         %pfesacq_sae_recon_ae_check7();

-------------------------------------------------------------------------------
 
  Author:                Shiva Bhimreddy, $LastChangedBy: bhimres $
  Creation Date:         01JUN2015                       $LastChangedDate: 2015-10-01 17:22:10 -0400 (Thu, 01 Oct 2015) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfesacq_sae_recon_ae_check7.sas $
 
  Files Created:         None
 
  Program Purpose:       Merge the EDC AE dataset with the safety (CSV/XLS) AE dataset
                         and see if there are any mismatches for the AE outcome.                      
 
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
MODIFICATION HISTORY: Subversion $Rev: 2284 $
  
-----------------------------------------------------------------------------*/

%macro pfesacq_sae_recon_ae_check7();
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_SAE_RECON_AE_CHECK7: Start of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

	*** Sort the 2 datasets by Study and Merge them to check if AE outcome mismatches exist ***;

	*** EDC ***;

	proc sort data=outdir.ae_crf out=edc;
		by subjid aedecd2 fromdate aepres;
		where subjid ne '' and aeser in ('YES','Y');
	run;

	data edc;
		length aepres $40;
		set edc(rename=(aepres=aepres1));
		if aepres1='NOT REC/NOT RES' then aepres='NOT RECOVERED/NOT RESOLVED';
		else aepres=aepres1;
	run;

	proc sort data=edc;
		by subjid aedecd2 fromdate aepres;
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
		by study subjid dob sex aeser aeterm aedecd2 fromdate todate aecaseid aercaus aestdrg deathdt;
	run;

	*** Safety ***;

	proc sort data=outdir.aesafety out=safe;
		by subjid aedecd2 fromdate aepres;
		where subjid ne '';
	run;

	data safe;
		length aepres $40;
		set safe(rename=(aepres=aepres1));
		if aepres1='NOT REC/NOT RES' then aepres='NOT RECOVERED/NOT RESOLVED';
		else aepres=aepres1;
	run;

	proc sort data=safe;
		by subjid aedecd2 fromdate aepres;
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
		by study subjid dob sex aeser aeterm aedecd2 fromdate todate aecaseid aercaus aestdrg deathdt;
	run;

	*** Create a dataset with AE outcome mismatches ***;

	data check1;
		length flag $40;
		merge edc(in=a  rename=(aepres=clinout)) 
			  safe(in=b rename=(aepres=safeout));
		by study subjid dob sex aeser aeterm aedecd2 fromdate todate aecaseid aercaus aestdrg deathdt;

		if a and b and clinout ne safeout then flag = 'Outcome mismatch';
		if flag ne '';

		if a=1 then do;
                      clinstudy=study;
					  clinsubj=subjid;
					  clindob=dob;
					  clinsex=sex;
					  clincase=aecaseid;
					  clinterm=aeterm;
					  clindecd=aedecd2;
					  clinst=fromdate;
					  clinen=todate;
					  clinrel=aercaus;
					  clinacn=aestdrg;
					  clindth=deathdt;
					  clinser=aeser;
					end;

		if b=1 then do;
                      safestudy=study;
					  safesubj=subjid;
					  safedob=dob;
					  safesex=sex;
					  safecase=aecaseid;
					  safeterm=aeterm;
					  safedecd=aedecd2;
					  safest=fromdate;
					  safeen=todate;
					  saferel=aercaus;
					  safeacn=aestdrg;
					  safedth=deathdt;
					  safeser=aeser;
					end;
	run;


	data aecheck7;
		set check1;
	run;

	proc datasets lib=work;
		delete edc dmedc safe dmsafe check1;
	run;

    %macend:;
    %put ;
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_SAE_RECON_AE_CHECK7: End of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_sae_recon_ae_check7;

*** Example macro call ***;

*%pfesacq_sae_recon_ae_check7();