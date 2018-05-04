/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Allwyn Dsouza, $LastChangedBy: dsouzaal $
  Creation Date:         05MAY2016      $LastChangedDate: 2016-06-10 06:24:47 -0400 (Fri, 10 Jun 2016) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfesacq_ecg_recon_lis04.sas $
 
  Files Created:         None
 
  Program Purpose:       Creates the LIS04 dataset by comparing the EGINTP between
                         the EDC ECG dataset and the Vendor ECG dataset.
 
						 Note: Part of program: pfesacq_ecg_recon

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:
 


  Macro Output:          LIS04 dataset is created in the WORK Folder


-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2296 $
  
-----------------------------------------------------------------------------*/

%macro pfesacq_ecg_recon_lis04;

    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put NOTE:[PXL] &sysmacroname.: Start of Submacro;
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put ;

	%if &egintp. = or &eegintp. = %then %do;
	    %put NOTE:[PXL] ---------------------------------------------------------------------;
	    %put NOTE:[PXL] &sysmacroname.: Listing skipped as EGINTP parameter was missing either;
		%put NOTE:[PXL] in EDC Macro or in Vendor Macro;
	    %put NOTE:[PXL] ---------------------------------------------------------------------;
	    %put ;
	%end;
	%else %if %sysfunc(exist(outdir.eg_crf)) and %sysfunc(exist(outdir.egedata)) %then %do;
		
		data _lis04_crf ;
			set outdir.eg_crf ;
			crf_egacttmf = egacttmf ;
			crf_egtpd = egtpd;
			
			if not missing(egacttmf) then egacttmf = put(input(egacttmf,time5.),time5.);
		run;

		proc sort data = _lis04_crf ;
			by study siteid subjid cpevent colldate egacttmf egtpd ;
		run;
		
		data _lis04_ven ;
			set outdir.egedata ;
			vend_egacttmf = egacttmf ;
			vend_egtpd = egtpd;
			vend_colldate = colldate;
			vend_cpevent = cpevent;
			
			if not missing(egacttmf) then egacttmf = put(input(egacttmf,time5.),time5.);

			rename egintp = vend_egintp ;
			rename egcom = vend_egcom ;
		run;

		proc sort data =_lis04_ven ;
			by study siteid subjid cpevent colldate egacttmf egtpd ;
		run;

		****************************;
		*** Create LIS04 dataset ***;
		****************************;
					
		data lis04 (keep = flag flagn study siteid subjid cpevent visitdt colldate egnd egcom egintp crf_: vend_: status);
			length status flag $40;
			merge _lis04_crf (in=a) 
				  _lis04_ven (in=b);
			by study siteid subjid cpevent colldate 
				%if &egacttmf. ne %then %do ; egacttmf %end;
				%if &egtpd. ne %then %do ; egtpd %end;
				;
			if a and b ;

			if strip(upcase(egintp)) ne strip(upcase(vend_egintp)) ;
			
			flagn=4;
			flag = 'Mismatch of Result Interpretation';
			
			if      status1 =  ''        or  status2 =  ''        then status=coalescec(status1,status2);
			else if status1 =  'New'     or  status2 =  'New'     then status='New';			
			else if status1 =  'Changed' or  status2 =  'Changed' then status='Changed';
			else if status1 =  'Old'     or  status2 =  'Old'     then status='Old';
		run;

		data lis04 ;
			set lis04;
			rename crf_egacttmf = egacttmf ;
			rename crf_egtpd = egtpd;
		run;

		proc datasets lib=work nolist;
			delete _lis: ;
		quit;

	%end;
	%else %do;
	    %put NOTE:[PXL] --------------------------------------------------------------------------;
	    %put %str(ERR)OR:[PXL] &sysmacroname.: alert: Dataset EG_CRF or EGEDATA does not exist.;
	    %put NOTE:[PXL] --------------------------------------------------------------------------;
		%put ;
	%end;
	
    %put ;
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put NOTE:[PXL] &sysmacroname.: End of Submacro;
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_ecg_recon_lis04;