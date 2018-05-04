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
 
  Program Purpose:       Creates the LIS04 dataset for non-protocol tests
                         in the Vendor lab dataset.
 
						 Note: Part of program: pfesacq_lab_recon 

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:
 


  Macro Output:          LIS04 dataset in WORK library


-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev:  $
  
-----------------------------------------------------------------------------*/


%macro pfesacq_lab_recon_lis04();


    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_LAB_RECON_LIS04: Start of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

	libname outdir "&path_listings./current";

	%if %sysfunc(exist(outdir.lbedata)) %then %do;

	*** Sort the dataset by Test ID, Subject, Test and Visit ***;

	proc sort data=outdir.lbedata out=edata nodupkey;
		by lbtstid pxcode lbtest subjid colldate;
	run;

	data edata;
		set edata;
		lbtest=strip(upcase(lbtest));
		lbtstid=strip(upcase(lbtstid));
	run;

	proc sort data=edata;
		by lbtstid pxcode lbtest subjid colldate;
	run;

	*** Import the protocol tests document ***;

	proc import datafile = "&path_dm/documents/lab_recon/current/%lowcase(&protocol.) lab recon specs.xls"
	            out      = prottest 
				dbms     = xls replace;
				sheet    = "Lab Tests";
				getnames = no;
				startrow = 2;
	run;

	data prottest;
		length LBTSTID $20 lbtest $100 pxcode $30;
		set prottest;
		lbtstid=strip(upcase(compress(d, ,'kw')));
		lbtest=upcase(strip(compress(b, ,'kw')));
		pxcode=strip(upcase(compress(put(c,best.), ,'kw')));
		keep pxcode lbtstid lbtest;
	run;

	proc sort data=prottest nodupkey;
		by lbtstid pxcode lbtest;
		where lbtstid ne '';
	run;


	****************************;
	*** Create LIS04 dataset ***;
	****************************;

	data lis04;
		length flag $40;
		merge prottest(in=a) edata(in=b);
		by lbtstid pxcode lbtest;

		if a=0 and upcase(labvalue) not in ('NR', 'NA', 'ND', 'NOT DONE','CANCELLED');

		flagn=4;
		flag='Invalid Test';

	run;


	proc datasets lib=work;
		delete edata prottest;
	quit;
	run;

	%end;

	%else %do;
    			%put %str(ERR)OR:[PXL]----------------------------------------------------------------;
    			%put %str(ERR)OR:[PXL] PFESACQ_LAB_RECON_LIS04: alert: Dataset LBEDATA does not exist.;
    			%put %str(ERR)OR:[PXL]----------------------------------------------------------------;
		  %end;

    %macend:;
    %put ;
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_LAB_RECON_LIS04: End of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_lab_recon_lis04;





