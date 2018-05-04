/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Shiva Bhimreddy, $LastChangedBy:  $
  Creation Date:         08SEP2015                       $LastChangedDate:  $
 
  Program Location/Name: $HeadURL: $
 
  Files Created:         None
 
  Program Purpose:       Reports the Lab Checks results in an excel file.   
 
						 Note: Part of program: pfesacq_lab_recon  

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:
 
  Macro Output:  

  Macro Dependencies:    Note: Part of program: pfesacq_lab_recon

                         This is a submacro dependant on calling parent macro: 
                         pfesacq_lab_recon.sas

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev:  $
  
-----------------------------------------------------------------------------*/

%macro pfesacq_lab_recon_checks_report();
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_LAB_RECON_CHECKS_REPORT: Start of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

	options ls=256 ps=64 nocenter; 

	%if %sysfunc(exist(outdir.labcheck)) %then %do;


	********************;
	*** REPORT LIS01 ***;
	********************;

	proc sql noprint;
		select count(*) into:nobs1
		from outdir.labcheck
		where flagn in (1.1 1.2);
	quit;


	*title1    j=l "&protocol." j=c "SAS &sysver." j=r"Lab Checks";

	*footnote1 j=l "&sysdate9.";

	ODS TAGSETS.EXCELXP
	file="&path_listings./current/&protocol._Lab Checks_&rundate..xls"
	STYLE=Printer
	OPTIONS ( 
			Orientation = 'landscape'
			FitToPage = 'yes'
			Pages_FitWidth = '1'
			Pages_FitHeight = '100' 
			autofit_height='YES'
			Autofilter = 'All'
			embedded_titles = 'yes'
			embedded_footnotes = 'yes'
			print_header = "%nrstr(&L) &protocol.  %nrstr(&C) SAS &sysver.  %nrstr(&R)  Lab Checks"
			print_footer = "%nrstr(&L) &sysdate9.  %nrstr(&R) Page %nrstr(&P) of %nrstr(&N) "
			Frozen_Headers='3'
			Absolute_Column_Width='10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10'
  			sheet_name='LIS01'
			);


	title1 j=l "LIS01: Gender/Date of Birth Mismatch &sysdate9. &systime.";

	%if %eval(&nobs1) > 0 %then %do; 


	proc report data=outdir.labcheck nowd style(header)=[background=lightskyblue foreground=black fontweight=bold fontsize=11pt]	;

		column  status flag study subjid cpevent clinsex clindob vendsex venddob;
		where flagn in (1.1 1.2);

		define	status    / "Data State"            display flow style(header) = {background=grey  foreground=black}; 
		define	flag      / "Flag"                  display flow style(header) = {background=grey  foreground=black}; 
		define	study     / "Study"                 display flow style(header) = {background=grey  foreground=black};
		define	subjid    / "Subject"               display flow style(header) = {background=grey  foreground=black}; 
		define	cpevent   / "Visit"                 display flow style(header) = {background=grey  foreground=black};
		define	clinsex   / "EDC Gender"            display flow style(header) = {background=grey  foreground=black}; 
		define	clindob   / "EDC Date of Birth"     display flow style(header) = {background=grey  foreground=black}; 
		define	vendsex   / "Vendor Gender"         display flow style(header) = {background=grey  foreground=black}; 
		define	venddob   / "Vendor Date of Birth"  display flow style(header) = {background=grey  foreground=black};

	run;



						       %end;

	%else %if %eval(&nobs1) = 0 %then %do; 


	data zero_obs_ds;

		status='No output for this listing'; flag='Gender/Date of Birth Mismatch'; study=''; subjid=''; cpevent=''; clinsex=''; clindob=''; vendsex=''; venddob='';
		label status='Data State' flag='Flag' study='Study' subjid='Subject' cpevent='Visit' clinsex='EDC Gender'
              clindob='EDC Date of Birth' vendsex='Vendor Gender' venddob='Vendor Date of Birth';

	run;

	title1 j=l "LIS01: Gender/Date of Birth Mismatch &sysdate9. &systime.";

	proc print data=zero_obs_ds LABEL noobs;
	run;

	proc datasets lib=work nolist nodetails;
		delete zero_obs_ds;
	run;
	quit;
							     	%end;



	********************;
	*** REPORT LIS02 ***;
	********************;

	proc sql noprint;
		select count(*) into:nobs2
		from outdir.labcheck
		where flagn=2;
	quit;

	ODS TAGSETS.EXCELXP
	OPTIONS ( 
			Orientation = 'landscape'
			FitToPage = 'yes'
			Pages_FitWidth = '1'
			Pages_FitHeight = '100' 
			autofit_height='YES'
			embedded_titles = 'yes'
			embedded_footnotes = 'yes'
			print_header = "%nrstr(&L) &protocol.  %nrstr(&C) SAS &sysver.  %nrstr(&R)  Lab Checks"
			print_footer = "%nrstr(&L) &sysdate9.  %nrstr(&R) Page %nrstr(&P) of %nrstr(&N) "
			Autofilter = 'All'
			Frozen_Headers='3'
			Absolute_Column_Width='10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10'
  			sheet_name='LIS02'
			);


	title1 j=l "LIS02: Invalid Study ID &sysdate9. &systime.";

	%if %eval(&nobs2) > 0 %then %do; 

	proc report data=outdir.labcheck nowd style(header)=[background=lightskyblue foreground=black fontweight=bold fontsize=11pt]	;

		column  status2 flag study subjid cpevent;
		where flagn=2;

		define	status2   / "Data State"            display flow style(header) = {background=grey  foreground=black}; 
		define	flag      / "Flag"                  display flow style(header) = {background=grey  foreground=black}; 
		define	study     / "Study"                 display flow style(header) = {background=grey  foreground=black};
		define	subjid    / "Subject"               display flow style(header) = {background=grey  foreground=black}; 
		define	cpevent   / "Visit"                 display flow style(header) = {background=grey  foreground=black};

	run;



						       %end;

	%else %if %eval(&nobs2) = 0 %then %do; 

	data zero_obs_ds;

		status='No output for this listing'; flag='Invalid Study ID'; study=''; subjid=''; cpevent='';
		label status='Data State' flag='Flag' study='Study' subjid='Subject' cpevent='Visit';

	run;

	title1 j=l "LIS02: Invalid Study ID &sysdate9. &systime.";

	proc print data=zero_obs_ds LABEL noobs;
	run;

	proc datasets lib=work nolist nodetails;
		delete zero_obs_ds;
	run;
	quit;
							     	%end;


	********************;
	*** REPORT LIS03 ***;
	********************;

	proc sql noprint;
		select count(*) into:nobs3
		from outdir.labcheck
		where flagn=3;
	quit;

	ODS TAGSETS.EXCELXP
	OPTIONS ( 
			Orientation = 'landscape'
			FitToPage = 'yes'
			Pages_FitWidth = '1'
			Pages_FitHeight = '100' 
			autofit_height='YES'
			embedded_titles = 'yes'
			embedded_footnotes = 'yes'
			print_header = "%nrstr(&L) &protocol.  %nrstr(&C) SAS &sysver.  %nrstr(&R)  Lab Checks"
			print_footer = "%nrstr(&L) &sysdate9.  %nrstr(&R) Page %nrstr(&P) of %nrstr(&N) "
			Autofilter = 'All'
			Frozen_Headers='3'
			Absolute_Column_Width='10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10'
  			sheet_name='LIS03'
			);


	title1 j=l "LIS03: Invalid Visit &sysdate9. &systime.";

	%if %eval(&nobs3) > 0 %then %do; 

	proc report data=outdir.labcheck nowd style(header)=[background=lightskyblue foreground=black fontweight=bold fontsize=11pt]	;

		column  status2 flag study subjid cpevent lbcat lbtpt colldate testtime labsmpid invcom;
		where flagn=3;

		define	status2   / "Data State"               display flow style(header) = {background=grey  foreground=black}; 
		define	flag      / "Flag"                     display flow style(header) = {background=grey  foreground=black}; 
		define	study     / "Study"                    display flow style(header) = {background=grey  foreground=black};
		define	subjid    / "Subject"                  display flow style(header) = {background=grey  foreground=black}; 
		define	cpevent   / "Visit"                    display flow style(header) = {background=grey  foreground=black};
		define	lbcat     / "Lab Classification"       display flow style(header) = {background=grey  foreground=black}; 
		define	lbtpt     / "Lab Time Point"           display flow style(header) = {background=grey  foreground=black};
		define	colldate  / "Lab Collection Date"      display flow style(header) = {background=grey  foreground=black}; 
		define	testtime  / "Lab Collection Time"      display flow style(header) = {background=grey  foreground=black}; 
		define	labsmpid  / "Lab Sample ID"            display flow style(header) = {background=grey  foreground=black}; 
		define	invcom    / "Lab Comment"              display flow style(header) = {background=grey  foreground=black}; 

	run;



						       %end;

	%else %if %eval(&nobs3) = 0 %then %do; 

	data zero_obs_ds;

		status='No output for this listing'; flag='Invalid Visit'; study=''; subjid=''; cpevent='';lbcat=''; lbtpt=''; colldate=''; testtime=''; labsmpid=''; invcom='';
		label status='Data State' flag='Flag' study='Study' subjid='Subject' cpevent='Visit' lbcat='Lab Classification' lbtpt='Lab Time Point'
              colldate='Lab Collection Date' testtime='Lab Collection Time' labsmpid='Lab Sample ID' invcom='Lab Comment';

	run;

	title1 j=l "LIS03: Invalid Visit &sysdate9. &systime.";

	proc print data=zero_obs_ds LABEL noobs;
	run;

	proc datasets lib=work nolist nodetails;
		delete zero_obs_ds;
	run;
	quit;

							     	%end;

	********************;
	*** REPORT LIS04 ***;
	********************;

	proc sql noprint;
		select count(*) into:nobs4
		from outdir.labcheck
		where flagn=4;
	quit;


	ODS TAGSETS.EXCELXP 
	OPTIONS ( 
			Orientation = 'landscape'
			FitToPage = 'yes'
			Pages_FitWidth = '1'
			Pages_FitHeight = '100' 
			autofit_height='YES'
			embedded_titles = 'yes'
			embedded_footnotes = 'yes'
			print_header = "%nrstr(&L) &protocol.  %nrstr(&C) SAS &sysver.  %nrstr(&R)  Lab Checks"
			print_footer = "%nrstr(&L) &sysdate9.  %nrstr(&R) Page %nrstr(&P) of %nrstr(&N) "
			Autofilter = 'All'
			Frozen_Headers='3'
			Absolute_Column_Width='10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10'
  			sheet_name='LIS04'
			) ;

	title1 j=l "LIS04: Invalid Test &sysdate9. &systime.";

	%if %eval(&nobs4) > 0 %then %do; 

	proc report data=outdir.labcheck nowd style(header)=[background=lightskyblue foreground=black fontweight=bold fontsize=11pt]	;

		column  status2 flag study subjid cpevent lbcat lbtest pxcode labvalue lbtpt colldate testtime labsmpid invcom;
		where flagn=4;



		define	status2   / "Data State"               display flow style(header) = {background=grey  foreground=black}; 
		define	flag      / "Flag"                     display flow style(header) = {background=grey  foreground=black}; 
		define	study     / "Study"                    display flow style(header) = {background=grey  foreground=black};
		define	subjid    / "Subject"                  display flow style(header) = {background=grey  foreground=black}; 
		define	cpevent   / "Visit"                    display flow style(header) = {background=grey  foreground=black};
		define	lbcat     / "Vendor Classification"    display flow style(header) = {background=grey  foreground=black}; 
		define	lbtest    / "Lab test name"            display flow style(header) = {background=grey  foreground=black}; 
		define	pxcode    / "Lab test ID"              display flow style(header) = {background=grey  foreground=black}; 
		define	labvalue  / "Lab Test Result"          display flow style(header) = {background=grey  foreground=black}; 
		define	lbtpt     / "Lab Time Point"           display flow style(header) = {background=grey  foreground=black};
		define	colldate  / "Lab Collection Date"      display flow style(header) = {background=grey  foreground=black}; 
		define	testtime  / "Lab Collection Time"      display flow style(header) = {background=grey  foreground=black}; 
		define	labsmpid  / "Lab Sample ID"            display flow style(header) = {background=grey  foreground=black}; 
		define	invcom    / "Lab Comment"              display flow style(header) = {background=grey  foreground=black}; 

	run;



						       %end;

	%else %if %eval(&nobs4) = 0 %then %do; 

	data zero_obs_ds;

		status='No output for this listing'; flag='Invalid Test'; study=''; subjid=''; cpevent='';lbcat=''; lbtest=''; lbtstid=''; labvalue=''; lbtpt=''; colldate=''; testtime=''; labsmpid=''; invcom='';
		label status='Data State' flag='Flag' study='Study' subjid='Subject' cpevent='Visit' lbcat='Lab Classification' lbtpt='Lab Time Point'
              colldate='Lab Collection Date' testtime='Lab Collection Time' labsmpid='Lab Sample ID' invcom='Lab Comment' lbtest='Lab test name'
              pxcode='Lab test ID (PX Code)' labvalue='Lab Test Result';

	run;

	proc print data=zero_obs_ds LABEL noobs;
	run;

	title1 j=l "LIS04: Invalid Test &sysdate9. &systime.";

	proc datasets lib=work nolist nodetails;
		delete zero_obs_ds;
	run;
	quit;

							     	%end;


	********************;
	*** REPORT LIS05 ***;
	********************;

	proc sql noprint;
		select count(*) into:nobs5
		from outdir.labcheck
		where flagn=5;
	quit;

	ODS TAGSETS.EXCELXP
	OPTIONS ( 
			Orientation = 'landscape'
			FitToPage = 'yes'
			Pages_FitWidth = '1'
			Pages_FitHeight = '10000' 
			autofit_height='YES'
			embedded_titles = 'yes'
			embedded_footnotes = 'yes'
			print_header = "%nrstr(&L) &protocol.  %nrstr(&C) SAS &sysver.  %nrstr(&R)  Lab Checks"
			print_footer = "%nrstr(&L) &sysdate9.  %nrstr(&R) Page %nrstr(&P) of %nrstr(&N) "
			Autofilter = 'All'
			Frozen_Headers='3'
			Absolute_Column_Width='10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10'
  			sheet_name='LIS05'
			);


	title1 j=l "LIS05: Missing Test &sysdate9. &systime.";

	%if %eval(&nobs5) > 0 %then %do; 

	proc report data=outdir.labcheck nowd style(header)=[background=lightskyblue foreground=black fontweight=bold fontsize=11pt]	;

		column  status2 flag study subjid cpevent lbcat lbtpt colldate testtime labsmpid invcom lbtest;
		where flagn=5;

		define	status2   / "Data State"               display flow style(header) = {background=grey  foreground=black}; 
		define	flag      / "Flag"                     display flow style(header) = {background=grey  foreground=black}; 
		define	study     / "Study"                    display flow style(header) = {background=grey  foreground=black};
		define	subjid    / "Subject"                  display flow style(header) = {background=grey  foreground=black}; 
		define	cpevent   / "Visit"                    display flow style(header) = {background=grey  foreground=black};
		define	lbcat     / "Vendor Classification"    display flow style(header) = {background=grey  foreground=black}; 
		define	lbtpt     / "Lab Time Point"           display flow style(header) = {background=grey  foreground=black};
		define	colldate  / "Lab Collection Date"      display flow style(header) = {background=grey  foreground=black}; 
		define	testtime  / "Lab Collection Time"      display flow style(header) = {background=grey  foreground=black}; 
		define	labsmpid  / "Lab Sample ID"            display flow style(header) = {background=grey  foreground=black}; 
		define	invcom    / "Lab Comment"              display flow style(header) = {background=grey  foreground=black}; 
		define	lbtest    / "Missing test name"        display flow style(header) = {background=grey  foreground=black}; 

	run;



						       %end;

	%else %if %eval(&nobs5) = 0 %then %do; 

	data zero_obs_ds;

		status='No output for this listing'; flag='Missing Test'; study=''; subjid=''; cpevent='';lbcat=''; lbtest=''; lbtpt=''; colldate=''; testtime=''; labsmpid=''; invcom='';
		label status='Data State' flag='Flag' study='Study' subjid='Subject' cpevent='Visit' lbcat='Lab Classification' lbtpt='Lab Time Point'
              colldate='Lab Collection Date' testtime='Lab Collection Time' labsmpid='Lab Sample ID' invcom='Lab Comment' lbtest='Lab test name';

	run;

	title1 j=l "LIS05: Missing Test &sysdate9. &systime.";

	proc print data=zero_obs_ds LABEL noobs;
	run;

	proc datasets lib=work nolist nodetails;
		delete zero_obs_ds;
	run;
	quit;
							     	%end;

	********************;
	*** REPORT LIS06 ***;
	********************;

	proc sql noprint;
		select count(*) into:nobs6
		from outdir.labcheck
		where flagn=6;
	quit;

	ODS TAGSETS.EXCELXP
	OPTIONS ( 
			Orientation = 'landscape'
			FitToPage = 'yes'
			Pages_FitWidth = '1'
			Pages_FitHeight = '100' 
			autofit_height='YES'
			embedded_titles = 'yes'
			embedded_footnotes = 'yes'
			print_header = "%nrstr(&L) &protocol.  %nrstr(&C) SAS &sysver.  %nrstr(&R)  Lab Checks"
			print_footer = "%nrstr(&L) &sysdate9.  %nrstr(&R) Page %nrstr(&P) of %nrstr(&N) "
			Autofilter = 'All'
			Frozen_Headers='3'
			Absolute_Column_Width='10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10'
  			sheet_name='LIS06'
			);


	title1 j=l "LIS06: Missing Result &sysdate9. &systime.";

	%if %eval(&nobs6) > 0 %then %do; 

	proc report data=outdir.labcheck nowd style(header)=[background=lightskyblue foreground=black fontweight=bold fontsize=11pt]	;

		column  status2 flag study subjid cpevent lbcat lbtest pxcode labvalue lbtpt colldate testtime labsmpid invcom;
		where flagn=6;

		define	status2   / "Data State"               display flow style(header) = {background=grey  foreground=black}; 
		define	flag      / "Flag"                     display flow style(header) = {background=grey  foreground=black}; 
		define	study     / "Study"                    display flow style(header) = {background=grey  foreground=black};
		define	subjid    / "Subject"                  display flow style(header) = {background=grey  foreground=black}; 
		define	cpevent   / "Visit"                    display flow style(header) = {background=grey  foreground=black};
		define	lbcat     / "Vendor Classification"    display flow style(header) = {background=grey  foreground=black}; 
		define	lbtest    / "Lab test name"            display flow style(header) = {background=grey  foreground=black}; 
		define	pxcode    / "Lab test ID (PX Code)"    display flow style(header) = {background=grey  foreground=black}; 
		define	labvalue  / "Lab Test Result"          display flow style(header) = {background=grey  foreground=black}; 
		define	lbtpt     / "Lab Time Point"           display flow style(header) = {background=grey  foreground=black};
		define	colldate  / "Lab Collection Date"      display flow style(header) = {background=grey  foreground=black}; 
		define	testtime  / "Lab Collection Time"      display flow style(header) = {background=grey  foreground=black}; 
		define	labsmpid  / "Lab Sample ID"            display flow style(header) = {background=grey  foreground=black}; 
		define	invcom    / "Lab Comment"              display flow style(header) = {background=grey  foreground=black}; 

	run;



						       %end;

	%else %if %eval(&nobs6) = 0 %then %do; 

	data zero_obs_ds;

		status='No output for this listing'; flag='Missing Result'; study=''; subjid=''; cpevent='';lbcat=''; lbtest=''; pxcode=''; labvalue=''; lbtpt=''; colldate=''; testtime=''; labsmpid=''; invcom='';
		label status='Data State' flag='Flag' study='Study' subjid='Subject' cpevent='Visit' lbcat='Lab Classification' lbtpt='Lab Time Point'
              colldate='Lab Collection Date' testtime='Lab Collection Time' labsmpid='Lab Sample ID' invcom='Lab Comment' lbtest='Lab test name'
              pxcode='Lab test ID (PX Code)' labvalue='Lab Test Result';

	run;

	title1 j=l "LIS06: Missing Result &sysdate9. &systime.";

	proc print data=zero_obs_ds LABEL noobs;
	run;

	proc datasets lib=work nolist nodetails;
		delete zero_obs_ds;
	run;
	quit;
							     	%end;

	********************;
	*** REPORT LIS07 ***;
	********************;

	proc sql noprint;
		select count(*) into:nobs7
		from outdir.labcheck
		where flagn=7;
	quit;

	ODS TAGSETS.EXCELXP
	OPTIONS ( 
			Orientation = 'landscape'
			FitToPage = 'yes'
			Pages_FitWidth = '1'
			Pages_FitHeight = '100' 
			autofit_height='YES'
			embedded_titles = 'yes'
			embedded_footnotes = 'yes'
			print_header = "%nrstr(&L) &protocol.  %nrstr(&C) SAS &sysver.  %nrstr(&R)  Lab Checks"
			print_footer = "%nrstr(&L) &sysdate9.  %nrstr(&R) Page %nrstr(&P) of %nrstr(&N) "
			Autofilter = 'All'
			Frozen_Headers='3'
			Absolute_Column_Width='10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10'
  			sheet_name='LIS07'
			);


	title1 j=l "LIS07: Invalid Result Comma &sysdate9. &systime.";

	%if %eval(&nobs7) > 0 %then %do; 

	proc report data=outdir.labcheck nowd style(header)=[background=lightskyblue foreground=black fontweight=bold fontsize=11pt]	;

		column  status2 flag study subjid cpevent lbcat lbtest pxcode labvalue lbtpt colldate testtime labsmpid invcom;
		where flagn=7;

		define	status2   / "Data State"               display flow style(header) = {background=grey  foreground=black}; 
		define	flag      / "Flag"                     display flow style(header) = {background=grey  foreground=black}; 
		define	study     / "Study"                    display flow style(header) = {background=grey  foreground=black};
		define	subjid    / "Subject"                  display flow style(header) = {background=grey  foreground=black}; 
		define	cpevent   / "Visit"                    display flow style(header) = {background=grey  foreground=black};
		define	lbcat     / "Vendor Classification"    display flow style(header) = {background=grey  foreground=black}; 
		define	lbtest    / "Lab test name"            display flow style(header) = {background=grey  foreground=black}; 
		define	pxcode    / "Lab test ID (PX Code)"    display flow style(header) = {background=grey  foreground=black}; 
		define	labvalue  / "Lab Test Result"          display flow style(header) = {background=grey  foreground=black}; 
		define	lbtpt     / "Lab Time Point"           display flow style(header) = {background=grey  foreground=black};
		define	colldate  / "Lab Collection Date"      display flow style(header) = {background=grey  foreground=black}; 
		define	testtime  / "Lab Collection Time"      display flow style(header) = {background=grey  foreground=black}; 
		define	labsmpid  / "Lab Sample ID"            display flow style(header) = {background=grey  foreground=black}; 
		define	invcom    / "Lab Comment"              display flow style(header) = {background=grey  foreground=black}; 

	run;



						       %end;

	%else %if %eval(&nobs7) = 0 %then %do; 

	data zero_obs_ds;

		status='No output for this listing'; flag='Invalid Result Comma'; study=''; subjid=''; cpevent='';lbcat=''; lbtest=''; pxcode=''; labvalue=''; lbtpt=''; colldate=''; testtime=''; labsmpid=''; invcom='';
		label status='Data State' flag='Flag' study='Study' subjid='Subject' cpevent='Visit' lbcat='Lab Classification' lbtpt='Lab Time Point'
              colldate='Lab Collection Date' testtime='Lab Collection Time' labsmpid='Lab Sample ID' invcom='Lab Comment' lbtest='Lab test name'
              pxcode='Lab test ID (PX Code)' labvalue='Lab Test Result';

	run;

	title1 j=l "LIS07: Invalid Result Comma &sysdate9. &systime.";

	proc print data=zero_obs_ds LABEL noobs;
	run;

	proc datasets lib=work nolist nodetails;
		delete zero_obs_ds;
	run;
	quit;

							     	%end;

	********************;
	*** REPORT LIS08 ***;
	********************;

	proc sql noprint;
		select count(*) into:nobs8
		from outdir.labcheck
		where flagn=8;
	quit;

	ODS TAGSETS.EXCELXP
	OPTIONS ( 
			Orientation = 'landscape'
			FitToPage = 'yes'
			Pages_FitWidth = '1'
			Pages_FitHeight = '100' 
			autofit_height='YES'
			embedded_titles = 'yes'
			embedded_footnotes = 'yes'
			print_header = "%nrstr(&L) &protocol.  %nrstr(&C) SAS &sysver.  %nrstr(&R)  Lab Checks"
			print_footer = "%nrstr(&L) &sysdate9.  %nrstr(&R) Page %nrstr(&P) of %nrstr(&N) "
			Autofilter = 'All'
			Frozen_Headers='3'
			Absolute_Column_Width='10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10'
  			sheet_name='LIS08'
			);


	title1 j=l "LIS08: Invalid Carriage Return &sysdate9. &systime.";

	%if %eval(&nobs8) > 0 %then %do; 

	proc report data=outdir.labcheck nowd style(header)=[background=lightskyblue foreground=black fontweight=bold fontsize=11pt]	;

		column  status2 flag study subjid cpevent lbcat lbtest pxcode labvalue lbtpt colldate testtime labsmpid invcom;
		where flagn=8;

		define	status2   / "Data State"               display flow style(header) = {background=grey  foreground=black}; 
		define	flag      / "Flag"                     display flow style(header) = {background=grey  foreground=black}; 
		define	study     / "Study"                    display flow style(header) = {background=grey  foreground=black};
		define	subjid    / "Subject"                  display flow style(header) = {background=grey  foreground=black}; 
		define	cpevent   / "Visit"                    display flow style(header) = {background=grey  foreground=black};
		define	lbcat     / "Vendor Classification"    display flow style(header) = {background=grey  foreground=black}; 
		define	lbtest    / "Lab test name"            display flow style(header) = {background=grey  foreground=black}; 
		define	pxcode    / "Lab test ID (PX Code)"    display flow style(header) = {background=grey  foreground=black}; 
		define	labvalue  / "Lab Test Result"          display flow style(header) = {background=grey  foreground=black}; 
		define	lbtpt     / "Lab Time Point"           display flow style(header) = {background=grey  foreground=black};
		define	colldate  / "Lab Collection Date"      display flow style(header) = {background=grey  foreground=black}; 
		define	testtime  / "Lab Collection Time"      display flow style(header) = {background=grey  foreground=black}; 
		define	labsmpid  / "Lab Sample ID"            display flow style(header) = {background=grey  foreground=black}; 
		define	invcom    / "Lab Comment"              display flow style(header) = {background=grey  foreground=black}; 

	run;



						       %end;

	%else %if %eval(&nobs8) = 0 %then %do; 

	data zero_obs_ds;

		status='No output for this listing'; flag='Invalid Carriage Return'; study=''; subjid=''; cpevent='';lbcat=''; lbtest=''; pxcode=''; labvalue=''; lbtpt=''; colldate=''; testtime=''; labsmpid=''; invcom='';
		label status='Data State' flag='Flag' study='Study' subjid='Subject' cpevent='Visit' lbcat='Lab Classification' lbtpt='Lab Time Point'
              colldate='Lab Collection Date' testtime='Lab Collection Time' labsmpid='Lab Sample ID' invcom='Lab Comment' lbtest='Lab test name'
              pxcode='Lab test ID (PX Code)' labvalue='Lab Test Result';

	run;

	title1 j=l "LIS08: Invalid Carriage Return &sysdate9. &systime.";

	proc print data=zero_obs_ds LABEL noobs;
	run;

	proc datasets lib=work nolist nodetails;
		delete zero_obs_ds;
	run;
	quit;

							     	%end;

	********************;
	*** REPORT LIS09 ***;
	********************;


	proc sql noprint;
		select count(*) into:nobs9
		from outdir.labcheck
		where flagn=9;
	quit;

	ODS TAGSETS.EXCELXP
	OPTIONS ( 
			Orientation = 'landscape'
			FitToPage = 'yes'
			Pages_FitWidth = '1'
			Pages_FitHeight = '100' 
			autofit_height='YES'
			embedded_titles = 'yes'
			embedded_footnotes = 'yes'
			print_header = "%nrstr(&L) &protocol.  %nrstr(&C) SAS &sysver.  %nrstr(&R)  Lab Checks"
			print_footer = "%nrstr(&L) &sysdate9.  %nrstr(&R) Page %nrstr(&P) of %nrstr(&N) "
			Autofilter = 'All'
			Frozen_Headers='3'
			Absolute_Column_Width='10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10'
  			sheet_name='LIS09'
			);


	title1 j=l "LIS09: Lab code with more than 1 test name &sysdate9. &systime.";

	%if %eval(&nobs9) > 0 %then %do; 

	proc report data=outdir.labcheck nowd style(header)=[background=lightskyblue foreground=black fontweight=bold fontsize=11pt]	;

		column  status2 flag study subjid cpevent lbcat lbtest pxcode lbtstid labvalue lbtpt colldate testtime labsmpid invcom;
		where flagn=9;

		define	status2   / "Data State"               display flow style(header) = {background=grey  foreground=black}; 
		define	flag      / "Flag"                     display flow style(header) = {background=grey  foreground=black}; 
		define	study     / "Study"                    display flow style(header) = {background=grey  foreground=black};
		define	subjid    / "Subject"                  display flow style(header) = {background=grey  foreground=black}; 
		define	cpevent   / "Visit"                    display flow style(header) = {background=grey  foreground=black};
		define	lbcat     / "Vendor Classification"    display flow style(header) = {background=grey  foreground=black}; 
		define	lbtest    / "Lab test name"            display flow style(header) = {background=grey  foreground=black}; 
		define	pxcode    / "Lab test ID (PX Code)"    display flow style(header) = {background=grey  foreground=black}; 
		define	lbtstid   / "Vendor Test ID"           display flow style(header) = {background=grey  foreground=black}; 
		define	labvalue  / "Lab Test Result"          display flow style(header) = {background=grey  foreground=black}; 
		define	lbtpt     / "Lab Time Point"           display flow style(header) = {background=grey  foreground=black};
		define	colldate  / "Lab Collection Date"      display flow style(header) = {background=grey  foreground=black}; 
		define	testtime  / "Lab Collection Time"      display flow style(header) = {background=grey  foreground=black}; 
		define	labsmpid  / "Lab Sample ID"            display flow style(header) = {background=grey  foreground=black}; 
		define	invcom    / "Lab Comment"              display flow style(header) = {background=grey  foreground=black}; 

	run;



						       %end;

	%else %if %eval(&nobs9) = 0 %then %do; 

	data zero_obs_ds;

		status='No output for this listing'; flag='Lab code with more than 1 test name'; study=''; subjid=''; cpevent='';lbcat=''; lbtest=''; pxcode='';lbtstid=''; labvalue=''; lbtpt=''; colldate=''; testtime=''; labsmpid=''; invcom='';
		label status='Data State' flag='Flag' study='Study' subjid='Subject' cpevent='Visit' lbcat='Lab Classification' lbtpt='Lab Time Point'
              colldate='Lab Collection Date' testtime='Lab Collection Time' labsmpid='Lab Sample ID' invcom='Lab Comment' lbtest='Lab test name'
              pxcode='Lab test ID (PX Code)' lbtstid='Vendor Test ID' labvalue='Lab Test Result';

	run;

	title1 j=l "LIS09: Lab code with more than 1 test name &sysdate9. &systime.";

	proc print data=zero_obs_ds LABEL noobs;
	run;

	proc datasets lib=work nolist nodetails;
		delete zero_obs_ds;
	run;
	quit;


							     	%end;


	********************;
	*** REPORT LIS10 ***;
	********************;

	%if &estdunit= %then %do; %end;
	%else %do;

	proc sql noprint;
		select count(*) into:nobs10
		from outdir.labcheck
		where flagn=10;
	quit;

	ODS TAGSETS.EXCELXP
	OPTIONS ( 
			Orientation = 'landscape'
			FitToPage = 'yes'
			Pages_FitWidth = '1'
			Pages_FitHeight = '100' 
			autofit_height='YES'
			embedded_titles = 'yes'
			embedded_footnotes = 'yes'
			print_header = "%nrstr(&L) &protocol.  %nrstr(&C) SAS &sysver.  %nrstr(&R)  Lab Checks"
			print_footer = "%nrstr(&L) &sysdate9.  %nrstr(&R) Page %nrstr(&P) of %nrstr(&N) "
			Autofilter = 'All'
			Frozen_Headers='3'
			Absolute_Column_Width='10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10'
  			sheet_name='LIS10'
			);


	title1 j=l "LIS10: Standard unit missing &sysdate9. &systime.";

	%if %eval(&nobs10) > 0 %then %do; 

	proc report data=outdir.labcheck nowd style(header)=[background=lightskyblue foreground=black fontweight=bold fontsize=11pt]	;

		column  status2 flag study subjid cpevent lbcat lbtest pxcode labvalue stdunit lbtpt colldate testtime labsmpid invcom;
		where flagn=10;

		define	status2   / "Data State"               display flow style(header) = {background=grey  foreground=black}; 
		define	flag      / "Flag"                     display flow style(header) = {background=grey  foreground=black}; 
		define	study     / "Study"                    display flow style(header) = {background=grey  foreground=black};
		define	subjid    / "Subject"                  display flow style(header) = {background=grey  foreground=black}; 
		define	cpevent   / "Visit"                    display flow style(header) = {background=grey  foreground=black};
		define	lbcat     / "Vendor Classification"    display flow style(header) = {background=grey  foreground=black}; 
		define	lbtest    / "Lab test name"            display flow style(header) = {background=grey  foreground=black}; 
		define	pxcode    / "Lab test ID (PX Code)"    display flow style(header) = {background=grey  foreground=black}; 
		define	labvalue  / "Lab Test Result"          display flow style(header) = {background=grey  foreground=black}; 
		define	stdunit   / "Standard Unit"            display flow style(header) = {background=grey  foreground=black}; 
		define	lbtpt     / "Lab Time Point"           display flow style(header) = {background=grey  foreground=black};
		define	colldate  / "Lab Collection Date"      display flow style(header) = {background=grey  foreground=black}; 
		define	testtime  / "Lab Collection Time"      display flow style(header) = {background=grey  foreground=black}; 
		define	labsmpid  / "Lab Sample ID"            display flow style(header) = {background=grey  foreground=black}; 
		define	invcom    / "Lab Comment"              display flow style(header) = {background=grey  foreground=black}; 

	run;



						       %end;

	%else %if %eval(&nobs10) = 0 %then %do; 

	data zero_obs_ds;

		status='No output for this listing'; flag='Standard unit missing'; study=''; subjid=''; cpevent='';lbcat=''; lbtest=''; pxcode=''; labvalue=''; lbtpt=''; colldate=''; testtime=''; labsmpid=''; invcom=''; stdunit='';
		label status='Data State' flag='Flag' study='Study' subjid='Subject' cpevent='Visit' lbcat='Lab Classification' lbtpt='Lab Time Point'
              colldate='Lab Collection Date' testtime='Lab Collection Time' labsmpid='Lab Sample ID' invcom='Lab Comment' lbtest='Lab test name'
              pxcode='Lab test ID (PX Code)' labvalue='Lab Test Result' stdunit='Standard Unit';

	run;

	title1 j=l "LIS10: Standard unit missing &sysdate9. &systime.";

	proc print data=zero_obs_ds LABEL noobs;
	run;

	proc datasets lib=work nolist nodetails;
		delete zero_obs_ds;
	run;
	quit;

							     	%end;

	%end;

	********************;
	*** REPORT LIS11 ***;
	********************;

	%if &estdunit= %then %do; %end;
	%else %do;

	proc sql noprint;
		select count(*) into:nobs11
		from outdir.labcheck
		where flagn=11;
	quit;

	ODS TAGSETS.EXCELXP
	OPTIONS ( 
			Orientation = 'landscape'
			FitToPage = 'yes'
			Pages_FitWidth = '1'
			Pages_FitHeight = '100' 
			autofit_height='YES'
			embedded_titles = 'yes'
			embedded_footnotes = 'yes'
			print_header = "%nrstr(&L) &protocol.  %nrstr(&C) SAS &sysver.  %nrstr(&R)  Lab Checks"
			print_footer = "%nrstr(&L) &sysdate9.  %nrstr(&R) Page %nrstr(&P) of %nrstr(&N) "
			Autofilter = 'All'
			Frozen_Headers='3'
			Absolute_Column_Width='10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10'
  			sheet_name='LIS11'
			);


	title1 j=l "LIS11: Inconsistent Standard unit &sysdate9. &systime.";

	%if %eval(&nobs11) > 0 %then %do; 

	proc report data=outdir.labcheck nowd style(header)=[background=lightskyblue foreground=black fontweight=bold fontsize=11pt]	;

		column  status2 flag study subjid cpevent lbcat lbtest pxcode labvalue labunitr stdunit lbtpt colldate testtime labsmpid invcom;
		where flagn=11;

		define	status2   / "Data State"               display flow style(header) = {background=grey  foreground=black}; 
		define	flag      / "Flag"                     display flow style(header) = {background=grey  foreground=black}; 
		define	study     / "Study"                    display flow style(header) = {background=grey  foreground=black};
		define	subjid    / "Subject"                  display flow style(header) = {background=grey  foreground=black}; 
		define	cpevent   / "Visit"                    display flow style(header) = {background=grey  foreground=black};
		define	lbcat     / "Vendor Classification"    display flow style(header) = {background=grey  foreground=black}; 
		define	lbtest    / "Lab test name"            display flow style(header) = {background=grey  foreground=black}; 
		define	pxcode    / "Lab test ID (PX Code)"    display flow style(header) = {background=grey  foreground=black}; 
		define	labvalue  / "Lab Test Result"          display flow style(header) = {background=grey  foreground=black}; 
		define	labunitr  / "Lab Test Unit"            display flow style(header) = {background=grey  foreground=black}; 
		define	stdunit   / "Standard Unit"            display flow style(header) = {background=grey  foreground=black}; 
		define	lbtpt     / "Lab Time Point"           display flow style(header) = {background=grey  foreground=black};
		define	colldate  / "Lab Collection Date"      display flow style(header) = {background=grey  foreground=black}; 
		define	testtime  / "Lab Collection Time"      display flow style(header) = {background=grey  foreground=black}; 
		define	labsmpid  / "Lab Sample ID"            display flow style(header) = {background=grey  foreground=black}; 
		define	invcom    / "Lab Comment"              display flow style(header) = {background=grey  foreground=black}; 

	run;



						       %end;

	%else %if %eval(&nobs11) = 0 %then %do; 

	data zero_obs_ds;

		status='No output for this listing'; flag='Inconsistent Standard unit '; study=''; subjid=''; cpevent='';lbcat=''; lbtest=''; pxcode=''; labvalue=''; lbtpt=''; colldate=''; testtime=''; labsmpid=''; invcom='';
		stdunit=''; labunitr='';
		label status='Data State' flag='Flag' study='Study' subjid='Subject' cpevent='Visit' lbcat='Lab Classification' lbtpt='Lab Time Point'
              colldate='Lab Collection Date' testtime='Lab Collection Time' labsmpid='Lab Sample ID' invcom='Lab Comment' lbtest='Lab test name'
              pxcode='Lab test ID (PX Code)' labvalue='Lab Test Result' labunitr='Lab Test Unit' stdunit='Standard Unit';

	run;

	title1 j=l "LIS11: Inconsistent Standard unit  &sysdate9. &systime.";

	proc print data=zero_obs_ds LABEL noobs;
	run;

	proc datasets lib=work nolist nodetails;
		delete zero_obs_ds;
	run;
	quit;

							     	%end;

	%end;





	ods tagsets.excelxp close;

	ods listing; 

	title;
	footnote;

	%end;

	%else %do;
    			%put %str(ERR)OR:[PXL]-------------------------------------------------------------------------;
    			%put %str(ERR)OR:[PXL] PFESACQ_LAB_RECON_CHECKS_REPORT: alert: Dataset LABCHECK does not exist.;
    			%put %str(ERR)OR:[PXL]-------------------------------------------------------------------------;
		  %end;




    %macend:;
    %put ;
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_LAB_RECON_CHECKS_REPORT: End of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_lab_recon_checks_report;

*%pfesacq_lab_recon_checks_report;


