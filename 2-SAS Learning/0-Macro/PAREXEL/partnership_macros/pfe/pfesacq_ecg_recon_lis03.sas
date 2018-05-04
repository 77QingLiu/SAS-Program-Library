/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Allwyn Dsouza $LastChangedBy: dsouzaal $
  Creation Date:         03SEP2015     $LastChangedDate: 2016-06-10 06:24:47 -0400 (Fri, 10 Jun 2016) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfesacq_ecg_recon_lis03.sas $
 
  Files Created:         None
 
  Program Purpose:       Creates the LIS03 dataset for non-protocol visits
                         in the Vendor ECG dataset.
 
						 Note: Part of program: pfesacq_ecg_recon 

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:      N/A

  Macro Output:          LIS03 dataset in WORK library

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2296 $
  
-----------------------------------------------------------------------------*/

%macro pfesacq_ecg_recon_lis03;

    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put NOTE:[PXL] &sysmacroname.: Start of Submacro;
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put ;

	%if not %sysfunc(fileexist("&path_dm./documents/ecg_recon/current/%lowcase(&protocol.) ecg recon specs.xls")) %then %do;
		
	    %put NOTE:[PXL] ---------------------------------------------------------------------;
	    %put NOTE:[PXL] &sysmacroname.: Listing skipped as Study Level spec was not present ;
	    %put NOTE:[PXL] ---------------------------------------------------------------------;
	    %put ;
	%end;
	%else %if %sysfunc(exist(outdir.egedata)) %then %do;
	
	data lis03;
		set outdir.egedata ;
		cpevent=upcase(strip(cpevent));
	run;

	proc sort data=lis03 ;
		by cpevent siteid subjid ;
	run;

	*** Import the specs for visits mapping ***;

	proc import datafile = "&path_dm./documents/ecg_recon/current/%lowcase(&protocol.) ecg recon specs.xls"
	            out      = _lis03_vis 
				dbms     = xls replace;
				sheet    = "Expected Visits";
				getnames = no;
				startrow = 2;
	run;

	data _lis03_vis (keep=cpevent);
		set _lis03_vis;
		where not missing(a);

		length cpevent $20;
		cpevent=strip(upcase(a));

		if cpevent ne "" ;
	run;

	proc sort data=_lis03_vis nodupkey;
		by cpevent;
	run;
	
	data lis03 (rename = (cpevent = vend_cpevent colldate = vend_colldate egtpd = vend_egtpd egacttmf = vend_egacttmf egintp = vend_egintp egcom = vend_egcom));
		length status flag $40;
		merge _lis03_vis(in=a) lis03(in=b);
		by cpevent;

		if a=0 and b=1;

		flagn=3;
		flag='Invalid Visit';

		status = status2;

	run;

	proc sort data = lis03 ;
		by siteid subjid vend_cpevent vend_colldate ;
	run ;

	proc datasets lib=work nolist;
		delete _lis:;
	quit;

	%end;
	%else %do;
	    %put NOTE:[PXL]----------------------------------------------------------------;
	    %put %str(ERR)OR:[PXL] &sysmacroname.: alert: Dataset EGEDATA does not exist.;
	    %put NOTE:[PXL]----------------------------------------------------------------;
		%put ;
	%end;
	
    %put NOTE:[PXL]---------------------------------------------------------------------;
    %put NOTE:[PXL] &sysmacroname.: End of Submacro;
    %put NOTE:[PXL]---------------------------------------------------------------------;
    %put ;

%mend pfesacq_ecg_recon_lis03;