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
 
  Program Purpose:       Creates the LIS09 dataset for Lab code with more than 1 test name
						 in the Vendor lab dataset.
 
						 Note: Part of program: pfesacq_lab_recon 

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:
 


  Macro Output:          LIS09 dataset in WORK library


-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev:  $
  
-----------------------------------------------------------------------------*/


%macro pfesacq_lab_recon_lis09();


    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_LAB_RECON_LIS09: Start of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

	%if %sysfunc(exist(outdir.lbedata)) %then %do;

	****************************;
	*** Create LIS09 dataset ***;
	****************************;

	proc sort data=outdir.lbedata out=lis09 nodupkey;
		by subjid lbtstid pxcode lbtest;
	run;

	proc sort data=outdir.lbedata out=select nodupkey;
		by lbtstid pxcode lbtest;
	run;

	data select;
		set select;
		by lbtstid pxcode lbtest;

		if first.pxcode then count=1;
		else count+1;

		if count>1;

	run;

	proc sort data=select nodupkey;
		by lbtstid pxcode;
	run;

	proc sort data=lis09;
		by lbtstid pxcode;
	run;

	*** All Subject records with the code with duplicate tests ***;

	data lis09;
		length flag $40;
		merge lis09(in=a) select(in=b keep=lbtstid pxcode);
		by lbtstid pxcode;

		if a and b;

		flagn=9;
		flag='Lab code with more than 1 test name';

	run;


	proc sort data=lis09 nodupkey;
		by subjid lbtstid pxcode lbtest;
	run;

	proc datasets lib=work;
		delete select;
	quit;
	run;

	%end;

	%else %do;
    			%put %str(ERR)OR:[PXL]----------------------------------------------------------------;
    			%put %str(ERR)OR:[PXL] PFESACQ_LAB_RECON_LIS09: alert: Dataset LBEDATA does not exist.;
    			%put %str(ERR)OR:[PXL]----------------------------------------------------------------;
		  %end;

    %macend:;
    %put ;
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_LAB_RECON_LIS09: End of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_lab_recon_lis09;




