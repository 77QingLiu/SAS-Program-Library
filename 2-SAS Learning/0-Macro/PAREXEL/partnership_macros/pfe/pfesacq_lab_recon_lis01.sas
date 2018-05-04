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
 
  Program Purpose:       Creates the LIS01 dataset by comparing the gender and DOB between
                         the EDC lab dataset and the Vendor lab dataset.
 
						 Note: Part of program: pfesacq_lab_recon 

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:
 


  Macro Output:          LIS01 dataset is created in the WORK Folder


-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev:  $
  
-----------------------------------------------------------------------------*/


%macro pfesacq_lab_recon_lis01();


    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_LAB_RECON_LIS01: Start of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

	libname outdir "&path_listings./current";

	%if %sysfunc(exist(outdir.lb_crf)) and %sysfunc(exist(outdir.lbedata)) %then %do;


	*** Sort the 2 datasets by Study, Subject and Visit ***;

	proc sort data=outdir.lb_crf  out=edc(keep=study subjid sex dob status1) nodupkey;
		by study subjid sex dob;
	run;


	proc sort data=outdir.lbedata out=edata(keep=study subjid sex dob status2) nodupkey;
		by study subjid sex dob;
	run;

	****************************;
	*** Create LIS01 dataset ***;
	****************************;

				
	data lis01;
		length status $8;
		length flag $40;
		merge edc  (in=a rename=(sex=clinsex dob=clindob) ) 
			  edata(in=b rename=(sex=vendsex dob=venddob) );
		by study subjid;

		if a=1 then clinstdy=study;
		if b=1 then vendstdy=study;

		if a=1 then clinsubj=subjid;
		if b=1 then vendsubj=subjid;

		if a=1 and b=1 and clinsex ne '' and vendsex ne '' /*and clindob=venddob*/ and clinsex ne vendsex then do; flagn=1.1; flag = 'Gender Mismatch';  end;

		if a=1 and b=1 and clindob ne '' and venddob ne '' /*and clinsex=vendsex*/ and clindob ne venddob then do; flagn=1.2; flag = 'Date of Birth Mismatch';  end;

		if      status1 =  ''        and status2 ne ''        then status=status2;
		else if status1 ne ''        and status2 =  ''        then status=status1;
		else if status1 =  'New'     and status2 =  'New'     then status='New';
		else if status1 =  'New'     and status2 =  'Old'     then status='New';
		else if status1 =  'New'     and status2 =  'Changed' then status='New';
		else if status1 =  'Old'     and status2 =  'New'     then status='New';
		else if status1 =  'Old'     and status2 =  'Old'     then status='Old';
		else if status1 =  'Old'     and status2 =  'Changed' then status='Changed';
		else if status1 =  'Changed' and status2 =  'New'     then status='New';
		else if status1 =  'Changed' and status2 =  'Old'     then status='Changed';
		else if status1 =  'Changed' and status2 =  'Changed' then status='Changed';

		keep flag flagn study subjid clinsex vendsex clindob venddob status status1 status2;

		if flagn ne .;

	run;


	proc datasets lib=work;
		delete edc edata;
	quit;
	run;

	%end;

	%else %do;
    			%put %str(ERR)OR:[PXL]--------------------------------------------------------------------------;
    			%put %str(ERR)OR:[PXL] PFESACQ_LAB_RECON_LIS01: alert: Dataset LB_CRF or LBEDATA does not exist.;
    			%put %str(ERR)OR:[PXL]--------------------------------------------------------------------------;
		  %end;


    %macend:;
    %put ;
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_LAB_RECON_LIS01: End of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_lab_recon_lis01;






