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
 
  Program Purpose:       Creates the LIS02 dataset by comparing the gender and DOB between
                         the EDC lab dataset and the Vendor lab dataset.
 
						 Note: Part of program: pfesacq_lab_recon 

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:
 


  Macro Output:          LIS02 dataset in WORK library


-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev:  $
  
-----------------------------------------------------------------------------*/



%macro pfesacq_lab_recon_lis02();

    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_LAB_RECON_LIS02: Start of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

	%if %sysfunc(exist(outdir.lbedata)) %then %do;


	*** Sort the dataset by Study, Subject and Visit ***;

	proc sort data=outdir.lbedata out=edata(keep=study subjid cpevent status2) nodupkey;
		by study subjid cpevent;
	run;


	****************************;
	*** Create LIS02 dataset ***;
	****************************;

	data lis02;
		length flag $40;
		set edata;

		if study ne "&protocol.";

		flagn=2;
		flag='Invalid Study ID';

	run;


	proc datasets lib=work;
		delete edata;
	quit;
	run;

	%end;

	%else %do;
    			%put %str(ERR)OR:[PXL]----------------------------------------------------------------;
    			%put %str(ERR)OR:[PXL] PFESACQ_LAB_RECON_LIS02: alert: Dataset LBEDATA does not exist.;
    			%put %str(ERR)OR:[PXL]----------------------------------------------------------------;
		  %end;


    %macend:;
    %put ;
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_LAB_RECON_LIS02: End of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_lab_recon_lis02;





