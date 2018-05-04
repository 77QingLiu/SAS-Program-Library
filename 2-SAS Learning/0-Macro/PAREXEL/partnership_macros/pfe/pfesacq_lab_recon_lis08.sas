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
 
  Program Purpose:       Creates the LIS08 dataset for results with carriage return
						 in the Vendor lab dataset.
 
						 Note: Part of program: pfesacq_lab_recon 

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:
 


  Macro Output:          LIS08 dataset in WORK library


-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev:  $
  
-----------------------------------------------------------------------------*/


%macro pfesacq_lab_recon_lis08();


    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_LAB_RECON_LIS08: Start of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

	%if %sysfunc(exist(outdir.lbedata)) %then %do;

	****************************;
	*** Create LIS08 dataset ***;
	****************************;

	data lis08;
		length flag $40;
		set outdir.lbedata;

		if index(labvalue,'0D'x)>0 OR index(labvalue,'0A'x)>0;

		flagn=8;
		flag='Invalid Carriage Return';

	run;


	%end;

	%else %do;
    			%put %str(ERR)OR:[PXL]----------------------------------------------------------------;
    			%put %str(ERR)OR:[PXL] PFESACQ_LAB_RECON_LIS08: alert: Dataset LBEDATA does not exist.;
    			%put %str(ERR)OR:[PXL]----------------------------------------------------------------;
		  %end;

    %macend:;
    %put ;
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_LAB_RECON_LIS08: End of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_lab_recon_lis08;

