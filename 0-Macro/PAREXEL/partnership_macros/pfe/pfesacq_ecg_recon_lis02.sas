/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Allwyn Dsouza,   $LastChangedBy: dsouzaal $
  Creation Date:         05MAY2015        $LastChangedDate: 2016-06-10 06:24:47 -0400 (Fri, 10 Jun 2016) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfesacq_ecg_recon_lis02.sas $
 
  Files Created:         None
 
  Program Purpose:       Creates the LIS02 dataset with invalid PROTOCOL number in Vendor ECG dataset
 
						 Note: Part of program: pfesacq_ecg_recon 

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:      N/A

  Macro Output:          LIS02 dataset in WORK library

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2296 $
  
-----------------------------------------------------------------------------*/

%macro pfesacq_ecg_recon_lis02;

    %put NOTE:[PXL] -----------------------------------------------------------;
    %put NOTE:[PXL] &sysmacroname.: Start of Submacro;
    %put NOTE:[PXL] -----------------------------------------------------------;
    %put ;

	%if %sysfunc(exist(outdir.egedata)) %then %do;

		*** Sort the dataset by Study, Subject and Visit ***;

		proc sort data=outdir.egedata out=lis02 (keep=study subjid cpevent status2) nodupkey;
			by study subjid cpevent;
			where upcase(strip(study)) ne upcase(strip("&protocol.")) ;
		run;

		data lis02;
			set lis02;
			length status flag $40;
			flag='Invalid Study ID';
			status = status2;
		run;

	%end;
	%else %do;
	    %put NOTE:[PXL]----------------------------------------------------------------;
	    %put %str(ERR)OR:[PXL] &sysmacroname.: alert: Dataset EGEDATA does not exist.;
	    %put NOTE:[PXL]----------------------------------------------------------------;
	%end;
	
    %put ;
    %put NOTE:[PXL] -----------------------------------------------------------;
    %put NOTE:[PXL] &sysmacroname.: End of Submacro;
    %put NOTE:[PXL] -----------------------------------------------------------;
    %put ;

%mend pfesacq_ecg_recon_lis02;