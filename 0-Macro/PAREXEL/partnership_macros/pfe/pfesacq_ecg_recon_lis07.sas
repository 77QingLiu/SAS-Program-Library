/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Allwyn Dsouza, $LastChangedBy: dsouzaal $
  Creation Date:         05MAY2016      $LastChangedDate: 2016-06-10 06:24:47 -0400 (Fri, 10 Jun 2016) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfesacq_ecg_recon_lis07.sas $
 
  Files Created:         None
 
  Program Purpose:       Creates the LIS07 dataset by checking for same dates across 
                         visits in the EDC ECG dataset.
 
						 Note: Part of program: pfesacq_ecg_recon

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:
 


  Macro Output:          LIS07 dataset is created in the WORK Folder


-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2296 $
  
-----------------------------------------------------------------------------*/

%macro pfesacq_ecg_recon_lis07;

    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put NOTE:[PXL] &sysmacroname.: Start of Submacro;
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put ;
	
	%if %sysfunc(exist(outdir.eg_crf)) %then %do;

		proc sort data=outdir.eg_crf out=_lis07_dup (keep = study siteid subjid colldate cpevent) nodupkey;
			by study siteid subjid colldate cpevent ;
			where not missing(colldate) ;
		run;
		
		data _lis07_dup;
			set _lis07_dup ;
			by study siteid subjid colldate cpevent;
			if not (first.colldate and last.colldate);
		run;

		proc sort data=outdir.eg_crf out=lis07 ;
			by study siteid subjid colldate cpevent ;
		run;

		data lis07 (keep = flag flagn study siteid subjid cpevent colldate visitdt egnd egacttmf egtpd egcom egintp status);
			merge lis07 (in=a) _lis07_dup (in=b);
			by study siteid subjid colldate cpevent ;
			if a and b ;

			length status flag $40;
			flagn=7;
			flag = 'Same Collection Date across Visits CRF';
			
			status=status1;
		run;

		proc sort data=lis07;
			by study siteid subjid colldate cpevent egacttmf egtpd;
		run;

		proc datasets lib=work nolist;
			delete _lis: ;
		quit;
		run;
		
	%end;
	%else %do;
	    %put NOTE:[PXL] --------------------------------------------------------------------------;
	    %put %str(ERR)OR:[PXL] &sysmacroname.: alert: Dataset EG_CRF does not exist.;
	    %put NOTE:[PXL] --------------------------------------------------------------------------;
	%end;

    %macend:;
    %put ;
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put NOTE:[PXL] &sysmacroname.: End of Submacro;
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_ecg_recon_lis07;