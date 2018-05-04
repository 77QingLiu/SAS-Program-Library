/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Allwyn Dsouza, $LastChangedBy: dsouzaal $
  Creation Date:         05MAY2016      $LastChangedDate: 2016-06-10 06:24:47 -0400 (Fri, 10 Jun 2016) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfesacq_ecg_recon_lis06.sas $
 
  Files Created:         None
 
  Program Purpose:       Creates the LIS06 dataset by checking for invalid carriage return 
                         in the Vendor ECG dataset.
 
						 Note: Part of program: pfesacq_ecg_recon

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:
 


  Macro Output:          LIS06 dataset is created in the WORK Folder


-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2296 $
  
-----------------------------------------------------------------------------*/

%macro pfesacq_ecg_recon_lis06;

    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put NOTE:[PXL] &sysmacroname.: Start of Submacro;
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put ;
	
	%if %sysfunc(exist(outdir.egedata)) %then %do;

		proc sort data=outdir.egedata out=lis06 ;
			by study siteid subjid cpevent colldate egacttmf egtpd egcom egintp;
		run;
		
		data lis06 (keep = flag flagn study siteid subjid cpevent colldate egacttmf egtpd egcom egintp status vend_: status2);
			length status flag $40;
			set lis06 ;
			by study siteid subjid cpevent colldate egacttmf egtpd ;
			
			if index(study,   '0D'x) or index(study,   '0A'x) 
			or index(siteid,  '0D'x) or index(siteid,  '0A'x)
			or index(subjid,  '0D'x) or index(subjid,  '0A'x)  
			or index(cpevent, '0D'x) or index(cpevent, '0A'x)
			or index(colldate,'0D'x) or index(colldate,'0A'x)
			or index(egacttmf,'0D'x) or index(egacttmf,'0A'x)
			or index(egintp,  '0D'x) or index(egintp,  '0A'x)
			or index(egtpd,   '0D'x) or index(egtpd,   '0A'x) ;
			
			vend_egtpd = egtpd;
			vend_colldate = colldate;
			vend_cpevent = cpevent;
			vend_egacttmf = egacttmf;
			vend_egintp = egintp;
			vend_egcom = egcom;

			flagn=6;
			flag = 'Invalid Carriage Return';
			
			status=status2;
		run;

	%end;
	%else %do;
	    %put NOTE:[PXL] --------------------------------------------------------------------------;
	    %put %str(ERR)OR:[PXL] &sysmacroname.: alert: Dataset EGEDATA does not exist.;
	    %put NOTE:[PXL] --------------------------------------------------------------------------;
	%end;
	
    %put ;
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put NOTE:[PXL] &sysmacroname.: End of Submacro;
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_ecg_recon_lis06;