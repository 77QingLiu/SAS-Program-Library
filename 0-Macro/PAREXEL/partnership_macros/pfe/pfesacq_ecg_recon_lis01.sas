/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Allwyn Dsouza, $LastChangedBy: dsouzaal $
  Creation Date:         20APR2016      $LastChangedDate: 2016-06-10 06:24:47 -0400 (Fri, 10 Jun 2016) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfesacq_ecg_recon_lis01.sas $
 
  Files Created:         None
 
  Program Purpose:       Creates the LIS01 dataset by comparing the gender and DOB between
                         the EDC ECG dataset and the Vendor ECG dataset.
 
						 Note: Part of program: pfesacq_ecg_recon

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:
 


  Macro Output:          LIS01 dataset is created in the WORK Folder


-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2296 $
  
-----------------------------------------------------------------------------*/

%macro pfesacq_ecg_recon_lis01;

    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put NOTE:[PXL] &sysmacroname.: Start of Submacro;
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put ;
	
	%if %sysfunc(exist(outdir.eg_crf)) and %sysfunc(exist(outdir.egedata)) %then %do;

		proc sort data=outdir.eg_crf  out=_lis01_edc(keep=study subjid sex dob status1) nodupkey;
			by study subjid sex dob;
		run;

		proc sort data=outdir.egedata out=_lis01_edata(keep=study subjid sex dob status2) nodupkey;
			by study subjid sex dob;
		run;

		****************************;
		*** Create LIS01 dataset ***;
		****************************;
					
		data lis01;
			length status $40;
			length flag $40;
			merge _lis01_edc  (in=a rename=(sex=clinsex dob=clindob) ) 
				  _lis01_edata(in=b rename=(sex=vendsex dob=venddob) );
			by study subjid;

			if a=1 then clinstdy=study;
			if b=1 then vendstdy=study;

			if a=1 then clinsubj=subjid;
			if b=1 then vendsubj=subjid;

			if a=1 and b=1 and clinsex ne '' and vendsex ne '' and clinsex ne vendsex then do; flagn=1.1; flag = 'Gender Mismatch';  end;

			if a=1 and b=1 and clindob ne '' and venddob ne '' and clindob ne venddob then do; flagn=1.2; flag = 'Date of Birth Mismatch';  end;

			if      status1 =  ''                                then status=status2;
			else if status2 =  ''                                then status=status1;
			else if status1 =  'New'     or status2 =  'New'     then status='New';
			else if status1 =  'Changed' or status2 =  'Changed' then status='Changed';
			else if status1 =  'Old'     or status2 =  'Old'     then status='Old';
			
			keep flag flagn study subjid clinsex vendsex clindob venddob status status1 status2;

			if flagn ne .;

		run;

		proc datasets lib=work nolist;
			delete _lis01: ;
		quit;
		run;

	%end;
	%else %do;
	    %put NOTE:[PXL] --------------------------------------------------------------------------;
	    %put %str(ERR)OR:[PXL] &sysmacroname.: alert: Dataset EG_CRF or EGEDATA does not exist.;
	    %put NOTE:[PXL] --------------------------------------------------------------------------;
	%end;

    %macend:;
    %put ;
    %put NOTE:[PXL] ----------------------------------------------------------;
    %put NOTE:[PXL] &sysmacroname.: End of Submacro;
    %put NOTE:[PXL] ----------------------------------------------------------;
    %put ;

%mend pfesacq_ecg_recon_lis01;