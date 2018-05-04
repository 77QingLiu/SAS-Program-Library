/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Shiva Bhimreddy, $LastChangedBy:  $
  Creation Date:         03SEP2015                       $LastChangedDate:  $
 
  Program Location/Name: $HeadURL: $
 
  Files Created:         None
 
  Program Purpose:       Creates the LIS03 dataset for non-protocol visits
                         in the Vendor lab dataset.
 
						 Note: Part of program: pfesacq_lab_recon 

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:
 


  Macro Output:          LIS03 dataset in WORK library


-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev:  $
  
-----------------------------------------------------------------------------*/


%macro pfesacq_lab_recon_lis03();


    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_LAB_RECON_LIS03: Start of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

	libname outdir "&path_listings./current";

	%if %sysfunc(exist(outdir.lbedata)) %then %do;

	*** Sort the dataset by Study, Subject and Visit ***;

	proc sort data=outdir.lbedata out=edata nodupkey;
		by cpevent subjid lbtest;
	run;

	data edata;
		set edata;
		cpevent=upcase(cpevent);
	run;

	proc sort data=edata;
		by cpevent subjid lbtest;
	run;

	*** Import the protocol visits document ***;

	proc import datafile = "&path_dm/documents/lab_recon/current/%lowcase(&protocol.) lab recon specs.xls"
	            out      = protvis 
				dbms     = xls replace;
				sheet    = "Expected Visits";
				getnames = no;
				startrow = 2;
	run;

	data protvis;
		length CPEVENT $20;
		set protvis;
		cpevent=upcase(compress(a, ,'kw'));
		keep cpevent;
	run;

	proc sort data=protvis nodupkey;
		by cpevent;
		where cpevent ne '';
	run;


	****************************;
	*** Create LIS03 dataset ***;
	****************************;

	data lis03;
		length flag $40;
		merge protvis(in=a) edata(in=b);
		by cpevent;

		if a=0 and b=1;

		flagn=3;
		flag='Invalid Visit';

	run;


	proc datasets lib=work;
		delete edata protvis;
	quit;
	run;

	%end;

	%else %do;
    			%put %str(ERR)OR:[PXL]----------------------------------------------------------------;
    			%put %str(ERR)OR:[PXL] PFESACQ_LAB_RECON_LIS03: alert: Dataset LBEDATA does not exist.;
    			%put %str(ERR)OR:[PXL]----------------------------------------------------------------;
		  %end;



    %macend:;
    %put ;
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_LAB_RECON_LIS03: End of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_lab_recon_lis03;






