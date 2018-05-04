/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Allwyn Dsouza, $LastChangedBy: dsouzaal $
  Creation Date:         05MAY2016      $LastChangedDate: 2016-06-10 06:24:47 -0400 (Fri, 10 Jun 2016) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfesacq_ecg_recon_lis08.sas $
 
  Files Created:         None
 
  Program Purpose:       Creates the LIS08 dataset by checking for duplicates 
                         in the Vendor ECG dataset.
 
						 Note: Part of program: pfesacq_ecg_recon

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:
 


  Macro Output:          LIS08 dataset is created in the WORK Folder


-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2296 $
  
-----------------------------------------------------------------------------*/

%macro pfesacq_ecg_recon_lis08;

    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put NOTE:[PXL] &sysmacroname.: Start of Submacro;
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put ;
	
	%if %sysfunc(exist(work.lis08_raw)) %then %do;

		proc sort data=lis08_raw out=lis08;
			by study siteid subjid cpevent colldate egacttmf egtpd egtest egcom egintp sex dob status2;
		run;

		data lis08;
			set lis08;
			by study siteid subjid cpevent colldate egacttmf egtpd egtest egcom egintp sex dob status2;
			if not (first.egintp and last.egintp);
			
			length status flag $40;
			rename
				egtpd = vend_egtpd
				colldate = vend_colldate
				cpevent = vend_cpevent
				egacttmf = vend_egacttmf
				egintp = vend_egintp
				egcom = vend_egcom
				egtest = vend_egtest
			;

			flagn=8;
			flag = 'Duplicate Record Vendor';
			
			status=status2;
		run;

		proc datasets lib=work nolist;
			delete lis08_:;
		quit;
		
	%end;
	%else %do;
	    %put NOTE:[PXL] --------------------------------------------------------------------------;
	    %put %str(ERR)OR:[PXL] &sysmacroname.: alert: Dataset LIS08_RAW does not exist.;
	    %put NOTE:[PXL] --------------------------------------------------------------------------;
	%end;

    %macend:;
    %put ;
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put NOTE:[PXL] &sysmacroname.: End of Submacro;
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_ecg_recon_lis08;