/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Shiva Bhimreddy, $LastChangedBy:  $
  Creation Date:         27APR2016                       $LastChangedDate:  $
 
  Program Location/Name: $HeadURL: $
 
  Files Created:         None
 
  Program Purpose:       Reports the PK Checks results in an excel file.   
 
						 Note: Part of program: pfesacq_pk_recon  

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:
 
  Macro Output:  

  Macro Dependencies:    Note: Part of program: pfesacq_pk_recon

                         This is a submacro dependant on calling parent macro: 
                         pfesacq_pk_recon.sas

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev:  $
  
-----------------------------------------------------------------------------*/

%macro pfesacq_pk_recon_c_checks_report();
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_PK_RECON_C_CHECKS_REPORT: Start of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

	options ls=256 ps=64 nocenter; 

	%if %sysfunc(exist(unblind.pkcheckc)) %then %do;


	********************;
	*** REPORT LIS01 ***;
	********************;

	proc sql noprint;
		select count(*) into:nobs1
		from unblind.pkcheckc
		where flagn in (1);
	quit;


	*title1    j=l "&protocol." j=c "SAS &sysver." j=r"PK Checks";

	*footnote1 j=l "&sysdate9.";

	ODS TAGSETS.EXCELXP
	file="&path_listings./current/&protocol._Central PK Checks_&rundate..xls"
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
			print_header = "%nrstr(&L) &protocol.  %nrstr(&C) SAS &sysver.  %nrstr(&R)  PK Checks"
			print_footer = "%nrstr(&L) &sysdate9.  %nrstr(&R) Page %nrstr(&P) of %nrstr(&N) "
			Frozen_Headers='3'
			Absolute_Column_Width='10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10'
  			sheet_name='LIS01'
			);


	title1 j=l "LIS01: Invalid Study ID &sysdate9. &systime.";

	%if %eval(&nobs1) > 0 %then %do; 


	proc report data=unblind.pkcheckc nowd style(header)=[background=grey foreground=black fontweight=bold fontsize=8pt]
                                          style(column)=[fontsize=8pt];

		column  /*status*/ flag study siteid subjid visit;
		where flagn in (1);

		*define	status    / "Data State"           display flow style(header) = {background=grey  foreground=black}; 
		define	flag      / "Flag"                 display flow style(header) = {background=grey  foreground=black}; 
		define	study     / "Study"                display flow style(header) = {background=grey  foreground=black};
		define	siteid    / "Site"                 display flow style(header) = {background=grey  foreground=black}; 
		define	subjid    / "Subject"              display flow style(header) = {background=grey  foreground=black}; 
		define	visit     / "Visit"                display flow style(header) = {background=grey  foreground=black};

	run;



						       %end;

	%else %if %eval(&nobs1) = 0 %then %do; 


	data zero_obs_ds;

		/*status='No output for this listing';*/ flag='Invalid Study ID'; study=''; siteid='';subjid=''; visit='';
		label /*status='Data State'*/ flag='Flag' study='Study' subjid='Subject' siteid='Site'  visit='Visit' ;

	run;

	title1 j=l "LIS01: Invalid Study ID &sysdate9. &systime.";

	*proc print data=zero_obs_ds LABEL noobs;
	run;

	proc report data=zero_obs_ds nowd style(header)=[background=grey foreground=black fontweight=bold fontsize=8pt]
                                          style(column)=[fontsize=8pt];
		column  /*status*/ flag study siteid subjid visit;
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
		from unblind.pkcheckc
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
			print_header = "%nrstr(&L) &protocol.  %nrstr(&C) SAS &sysver.  %nrstr(&R)  PK Checks"
			print_footer = "%nrstr(&L) &sysdate9.  %nrstr(&R) Page %nrstr(&P) of %nrstr(&N) "
			Autofilter = 'All'
			Frozen_Headers='3'
			Absolute_Column_Width='10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10'
  			sheet_name='LIS02'
			);


	title1 j=l "LIS02: Missing Subject &sysdate9. &systime.";

	%if %eval(&nobs2) > 0 %then %do; 

	proc report data=unblind.pkcheckc nowd style(header)=[background=grey foreground=black fontweight=bold fontsize=8pt]
                                          style(column)=[fontsize=8pt];

		column  flag study siteid source subjid visit pktpt pksmpid;
		where flagn=2;

		define	flag      / "Flag"                 display flow style(header) = {background=grey  foreground=black}; 
		define	study     / "Study"                display flow style(header) = {background=grey  foreground=black};
		define	source    / "Source Data"          display flow style(header) = {background=grey  foreground=black};
		define	siteid    / "Site"                 display flow style(header) = {background=grey  foreground=black}; 
		define	subjid    / "Subject"              display flow style(header) = {background=grey  foreground=black}; 
		define	visit     / "Visit"                display flow style(header) = {background=grey  foreground=black};
		define	pktpt     / "Timepoint"            display flow style(header) = {background=grey  foreground=black}; 
		define	pksmpid   / "Unique Smaple ID"     display flow style(header) = {background=grey  foreground=black}; 

	run;



						       %end;

	%else %if %eval(&nobs2) = 0 %then %do; 

	data zero_obs_ds;

		flag='Missing Subject'; study=''; SITEID='';subjid='';source=''; visit='';pktpt='';pksmpid='';
		label flag='Flag' study='Study' siteid='Site' subjid='Subject' visit='Visit'  pktpt='Timepoint' pksmpid='Sample ID' 
              source='Source Data';

	run;

	title1 j=l "LIS02: Missing Subject &sysdate9. &systime.";

	*proc print data=zero_obs_ds LABEL noobs;
	run;

	proc report data=zero_obs_ds nowd style(header)=[background=grey foreground=black fontweight=bold fontsize=8pt]
                                          style(column)=[fontsize=8pt];
		column  flag study siteid source subjid visit pktpt pksmpid;
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
		select count(*) into:nobs2
		from unblind.pkcheckc
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
			print_header = "%nrstr(&L) &protocol.  %nrstr(&C) SAS &sysver.  %nrstr(&R)  PK Checks"
			print_footer = "%nrstr(&L) &sysdate9.  %nrstr(&R) Page %nrstr(&P) of %nrstr(&N) "
			Autofilter = 'All'
			Frozen_Headers='3'
			Absolute_Column_Width='10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10'
  			sheet_name='LIS03'
			);


	title1 j=l "LIS03: Invalid Visit &sysdate9. &systime.";

	%if %eval(&nobs2) > 0 %then %do; 

	proc report data=unblind.pkcheckc nowd style(header)=[background=grey foreground=black fontweight=bold fontsize=8pt]
                                          style(column)=[fontsize=8pt];

		column  flag study siteid subjid visit pktpt pksmpid;
		where flagn=3;

		define	flag      / "Flag"                 display flow style(header) = {background=grey  foreground=black}; 
		define	study     / "Study"                display flow style(header) = {background=grey  foreground=black};
		define	siteid    / "Site"                 display flow style(header) = {background=grey  foreground=black}; 
		define	subjid    / "Subject"              display flow style(header) = {background=grey  foreground=black}; 
		define	visit     / "Visit"                display flow style(header) = {background=grey  foreground=black};
		define	pktpt     / "Timepoint"            display flow style(header) = {background=grey  foreground=black}; 
		define	pksmpid   / "Unique Smaple ID"     display flow style(header) = {background=grey  foreground=black}; 

	run;



						       %end;

	%else %if %eval(&nobs2) = 0 %then %do; 

	data zero_obs_ds;

		flag='Invalid Visit'; study=''; SITEID='';subjid=''; visit='';pktpt='';pksmpid='';
		label  flag='Flag' study='Study' siteid='Site' subjid='Subject' visit='Visit'  pktpt='Timepoint' pksmpid='Sample ID' 
              ;

	run;

	title1 j=l "LIS03: Invalid Visit &sysdate9. &systime.";

	proc report data=zero_obs_ds nowd style(header)=[background=grey foreground=black fontweight=bold fontsize=8pt]
                                          style(column)=[fontsize=8pt];
		column  flag study siteid subjid visit pktpt pksmpid;
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
		select count(*) into:nobs2
		from unblind.pkcheckc
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
			print_header = "%nrstr(&L) &protocol.  %nrstr(&C) SAS &sysver.  %nrstr(&R)  PK Checks"
			print_footer = "%nrstr(&L) &sysdate9.  %nrstr(&R) Page %nrstr(&P) of %nrstr(&N) "
			Autofilter = 'All'
			Frozen_Headers='3'
			Absolute_Column_Width='10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10'
  			sheet_name='LIS04'
			);


	title1 j=l "LIS04: Missing PK Data for Study Visit &sysdate9. &systime.";

	%if %eval(&nobs2) > 0 %then %do; 

	proc report data=unblind.pkcheckc nowd style(header)=[background=grey foreground=black fontweight=bold fontsize=8pt]
                                          style(column)=[fontsize=8pt];

		column  flag study source siteid subjid visit pktpt pksmpid colldate testtime;
		where flagn=4;

		define	flag      / "Flag"                 display flow style(header) = {background=grey  foreground=black}; 
		define	study     / "Study"                display flow style(header) = {background=grey  foreground=black};
		define	source    / "Source Data"          display flow style(header) = {background=grey  foreground=black}; 
		define	siteid    / "Site"                 display flow style(header) = {background=grey  foreground=black}; 
		define	subjid    / "Subject"              display flow style(header) = {background=grey  foreground=black}; 
		define	visit     / "Visit"                display flow style(header) = {background=grey  foreground=black};
		define	pktpt     / "Timepoint"            display flow style(header) = {background=grey  foreground=black}; 
		define	pksmpid   / "Unique Smaple ID"     display flow style(header) = {background=grey  foreground=black}; 
		define	colldate  / "Collection Date"      display flow style(header) = {background=grey  foreground=black};
		define	testtime  / "Collection Time"      display flow style(header) = {background=grey  foreground=black};
	run;



						       %end;

	%else %if %eval(&nobs2) = 0 %then %do; 

	data zero_obs_ds;

		flag='Missing PK Data for Study Visit'; study=''; SITEID='';subjid=''; visit='';pktpt='';pksmpid='';colldate='';testtime='';source='';
		label flag='Flag' study='Study' siteid='Site' subjid='Subject' visit='Visit'  pktpt='Timepoint' pksmpid='Sample ID' source='Source Data'
              colldate='Collection Date' testtime='Collection Time';

	run;

	title1 j=l "LIS04: Missing PK Data for Study Visit &sysdate9. &systime.";

	proc report data=zero_obs_ds nowd style(header)=[background=grey foreground=black fontweight=bold fontsize=8pt]
                                          style(column)=[fontsize=8pt];
		column  flag study source siteid subjid visit pktpt pksmpid colldate testtime;
	run;

	proc datasets lib=work nolist nodetails;
		delete zero_obs_ds;
	run;
	quit;
							     	%end;


	********************;
	*** REPORT LIS05 ***;
	********************;

	proc sql noprint;
		select count(*) into:nobs2
		from unblind.pkcheckc
		where flagn=5;
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
			print_header = "%nrstr(&L) &protocol.  %nrstr(&C) SAS &sysver.  %nrstr(&R)  PK Checks"
			print_footer = "%nrstr(&L) &sysdate9.  %nrstr(&R) Page %nrstr(&P) of %nrstr(&N) "
			Autofilter = 'All'
			Frozen_Headers='3'
			Absolute_Column_Width='10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10'
  			sheet_name='LIS05'
			);


	title1 j=l "LIS05: Duplicate Fields on eCRF &sysdate9. &systime.";

	%if %eval(&nobs2) > 0 %then %do; 

	proc report data=unblind.pkcheckc nowd style(header)=[background=grey foreground=black fontweight=bold fontsize=8pt]
                                          style(column)=[fontsize=8pt];

		column  flag study siteid subjid visit pktpt pksmpid colldate testtime;
		where flagn=5;

		define	flag      / "Flag"                 display flow style(header) = {background=grey  foreground=black}; 
		define	study     / "Study"                display flow style(header) = {background=grey  foreground=black};
		define	siteid    / "Site"                 display flow style(header) = {background=grey  foreground=black}; 
		define	subjid    / "Subject"              display flow style(header) = {background=grey  foreground=black}; 
		define	visit     / "Visit"                display flow style(header) = {background=grey  foreground=black};
		define	pktpt     / "Timepoint"            display flow style(header) = {background=grey  foreground=black}; 
		define	pksmpid   / "Unique Smaple ID"     display flow style(header) = {background=grey  foreground=black}; 
		define	colldate  / "Collection Date"      display flow style(header) = {background=grey  foreground=black};
		define	testtime  / "Collection Time"      display flow style(header) = {background=grey  foreground=black};
	run;



						       %end;

	%else %if %eval(&nobs2) = 0 %then %do; 

	data zero_obs_ds;

		flag='Duplicate Fields on eCRF'; study=''; SITEID='';subjid=''; visit='';pktpt='';pksmpid='';colldate='';testtime='';
		label flag='Flag' study='Study' siteid='Site' subjid='Subject' visit='Visit'  pktpt='Timepoint' pksmpid='Sample ID' 
              colldate='Collection Date' testtime='Collection Time' ;

	run;

	title1 j=l "LIS05: Duplicate Fields on eCRF &sysdate9. &systime.";

	*proc print data=zero_obs_ds LABEL noobs;
	run;

	proc report data=zero_obs_ds nowd style(header)=[background=grey foreground=black fontweight=bold fontsize=8pt]
                                          style(column)=[fontsize=8pt];
		column  flag study siteid subjid visit pktpt pksmpid colldate testtime;
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
		select count(*) into:nobs2
		from unblind.pkcheckc
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
			print_header = "%nrstr(&L) &protocol.  %nrstr(&C) SAS &sysver.  %nrstr(&R)  PK Checks"
			print_footer = "%nrstr(&L) &sysdate9.  %nrstr(&R) Page %nrstr(&P) of %nrstr(&N) "
			Autofilter = 'All'
			Frozen_Headers='3'
			Absolute_Column_Width='10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10'
  			sheet_name='LIS06'
			);


	title1 j=l "LIS06: Duplicate Accession Number Across Subjects &sysdate9. &systime.";

	%if %eval(&nobs2) > 0 %then %do; 

	proc report data=unblind.pkcheckc nowd style(header)=[background=grey foreground=black fontweight=bold fontsize=8pt]
                                          style(column)=[fontsize=8pt];

		column  flag study siteid subjid visit pktpt pksmpid acession;
		where flagn=6;

		define	flag      / "Flag"                 display flow style(header) = {background=grey  foreground=black}; 
		define	study     / "Study"                display flow style(header) = {background=grey  foreground=black};
		define	siteid    / "Site"                 display flow style(header) = {background=grey  foreground=black}; 
		define	subjid    / "Subject"              display flow style(header) = {background=grey  foreground=black}; 
		define	visit     / "Visit"                display flow style(header) = {background=grey  foreground=black};
		define	pktpt     / "Timepoint"            display flow style(header) = {background=grey  foreground=black}; 
		define	pksmpid   / "Unique Smaple ID"     display flow style(header) = {background=grey  foreground=black}; 
		define	acession  / "Accession Number"     display flow style(header) = {background=grey  foreground=black};
	run;



						       %end;

	%else %if %eval(&nobs2) = 0 %then %do; 

	data zero_obs_ds;

		flag='Duplicate Accession Number Across Subjects'; study=''; SITEID='';subjid=''; visit='';pktpt='';pksmpid='';acession='';
		label flag='Flag' study='Study' siteid='Site' subjid='Subject' visit='Visit'  pktpt='Timepoint' pksmpid='Sample ID' acession='Accession Number'
              ;

	run;

	title1 j=l "LIS06: Duplicate Accession Number Across Subjects &sysdate9. &systime.";

	*proc print data=zero_obs_ds LABEL noobs;
	run;

	proc report data=zero_obs_ds nowd style(header)=[background=grey foreground=black fontweight=bold fontsize=8pt]
                                          style(column)=[fontsize=8pt];
		column  flag study siteid subjid visit pktpt pksmpid acession;
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
		select count(*) into:nobs2
		from unblind.pkcheckc
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
			print_header = "%nrstr(&L) &protocol.  %nrstr(&C) SAS &sysver.  %nrstr(&R)  PK Checks"
			print_footer = "%nrstr(&L) &sysdate9.  %nrstr(&R) Page %nrstr(&P) of %nrstr(&N) "
			Autofilter = 'All'
			Frozen_Headers='3'
			Absolute_Column_Width='10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10'
  			sheet_name='LIS07'
			);


	title1 j=l "LIS07: Duplicated Record on Vendor &sysdate9. &systime.";

	%if %eval(&nobs2) > 0 %then %do; 

	proc report data=unblind.pkcheckc nowd style(header)=[background=grey foreground=black fontweight=bold fontsize=8pt]
                                          style(column)=[fontsize=8pt];

		column  flag study siteid subjid visit pktpt pksmpid acession;
		where flagn=7;

		define	flag      / "Flag"                 display flow style(header) = {background=grey  foreground=black}; 
		define	study     / "Study"                display flow style(header) = {background=grey  foreground=black};
		define	siteid    / "Site"                 display flow style(header) = {background=grey  foreground=black}; 
		define	subjid    / "Subject"              display flow style(header) = {background=grey  foreground=black}; 
		define	visit     / "Visit"                display flow style(header) = {background=grey  foreground=black};
		define	pktpt     / "Timepoint"            display flow style(header) = {background=grey  foreground=black}; 
		define	pksmpid   / "Unique Smaple ID"     display flow style(header) = {background=grey  foreground=black}; 
		define	acession  / "Accession Number"     display flow style(header) = {background=grey  foreground=black};
	run;



						       %end;

	%else %if %eval(&nobs2) = 0 %then %do; 

	data zero_obs_ds;

		flag='Duplicated Record on Vendor'; study=''; SITEID='';subjid=''; visit='';pktpt='';pksmpid='';acession='';
		label flag='Flag' study='Study' siteid='Site' subjid='Subject' visit='Visit'  pktpt='Timepoint' pksmpid='Sample ID' acession='Accession Number'
              ;

	run;

	title1 j=l "LIS07: Duplicated Record on Vendor &sysdate9. &systime.";

	*proc print data=zero_obs_ds LABEL noobs;
	run;

	proc report data=zero_obs_ds nowd style(header)=[background=grey foreground=black fontweight=bold fontsize=8pt]
                                          style(column)=[fontsize=8pt];
		column  flag study siteid subjid visit pktpt pksmpid acession;
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
		select count(*) into:nobs2
		from unblind.pkcheckc
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
			print_header = "%nrstr(&L) &protocol.  %nrstr(&C) SAS &sysver.  %nrstr(&R)  PK Checks"
			print_footer = "%nrstr(&L) &sysdate9.  %nrstr(&R) Page %nrstr(&P) of %nrstr(&N) "
			Autofilter = 'All'
			Frozen_Headers='3'
			Absolute_Column_Width='10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10'
  			sheet_name='LIS08'
			);


	title1 j=l "LIS08: Duplicate Randomization Number on Vendor &sysdate9. &systime.";

	%if %eval(&nobs2) > 0 %then %do; 

	proc report data=unblind.pkcheckc nowd style(header)=[background=grey foreground=black fontweight=bold fontsize=8pt]
                                          style(column)=[fontsize=8pt];

		column  flag study siteid subjid visit pktpt pksmpid randnum;
		where flagn=8;

		define	flag      / "Flag"                 display flow style(header) = {background=grey  foreground=black}; 
		define	study     / "Study"                display flow style(header) = {background=grey  foreground=black};
		define	siteid    / "Site"                 display flow style(header) = {background=grey  foreground=black}; 
		define	subjid    / "Subject"              display flow style(header) = {background=grey  foreground=black}; 
		define	visit     / "Visit"                display flow style(header) = {background=grey  foreground=black};
		define	pktpt     / "Timepoint"            display flow style(header) = {background=grey  foreground=black}; 
		define	pksmpid   / "Unique Smaple ID"     display flow style(header) = {background=grey  foreground=black}; 
		define	randnum   / "Randomization Number" display flow style(header) = {background=grey  foreground=black};

	run;



						       %end;

	%else %if %eval(&nobs2) = 0 %then %do; 

	data zero_obs_ds;

		flag='Duplicate Randomization Number on Vendor'; study=''; siteid='';subjid=''; visit='';pktpt='';pksmpid='';randnum='';
		label flag='Flag' study='Study' siteid='Site' subjid='Subject' visit='Visit'  pktpt='Timepoint' pksmpid='Sample ID' 
              randnum='Randomization Number';

	run;

	title1 j=l "LIS08: Duplicate Randomization Number on Vendor &sysdate9. &systime.";

	*proc print data=zero_obs_ds LABEL noobs;
	run;

	proc report data=zero_obs_ds nowd style(header)=[background=grey foreground=black fontweight=bold fontsize=8pt]
                                          style(column)=[fontsize=8pt];
		column  flag study siteid subjid visit pktpt pksmpid randnum;
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
		select count(*) into:nobs2
		from unblind.pkcheckc
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
			print_header = "%nrstr(&L) &protocol.  %nrstr(&C) SAS &sysver.  %nrstr(&R)  PK Checks"
			print_footer = "%nrstr(&L) &sysdate9.  %nrstr(&R) Page %nrstr(&P) of %nrstr(&N) "
			Autofilter = 'All'
			Frozen_Headers='3'
			Absolute_Column_Width='10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10'
  			sheet_name='LIS09'
			);


	title1 j=l "LIS09: Sample ID not Unique &sysdate9. &systime.";

	%if %eval(&nobs2) > 0 %then %do; 

	proc report data=unblind.pkcheckc nowd style(header)=[background=grey foreground=black fontweight=bold fontsize=8pt]
                                          style(column)=[fontsize=8pt];

		column  flag study source siteid subjid visit pktpt pksmpid;
		where flagn=9;

		define	flag      / "Flag"                 display flow style(header) = {background=grey  foreground=black}; 
		define	study     / "Study"                display flow style(header) = {background=grey  foreground=black};
		define	source    / "Source Data"          display flow style(header) = {background=grey  foreground=black}; 
		define	siteid    / "Site"                 display flow style(header) = {background=grey  foreground=black}; 
		define	subjid    / "Subject"              display flow style(header) = {background=grey  foreground=black}; 
		define	visit     / "Visit"                display flow style(header) = {background=grey  foreground=black};
		define	pktpt     / "Timepoint"            display flow style(header) = {background=grey  foreground=black}; 
		define	pksmpid   / "Unique Smaple ID"     display flow style(header) = {background=grey  foreground=black}; 

	run;



						       %end;

	%else %if %eval(&nobs2) = 0 %then %do; 

	data zero_obs_ds;

		flag='Sample ID not Unique'; study=''; siteid='';subjid=''; visit='';pktpt='';pksmpid='';source='';
		label flag='Flag' study='Study' siteid='Site' subjid='Subject' visit='Visit'  pktpt='Timepoint' pksmpid='Sample ID' source='Source Data';

	run;

	title1 j=l "LIS09: Sample ID not Unique &sysdate9. &systime.";

	*proc print data=zero_obs_ds LABEL noobs;
	run;

	proc report data=zero_obs_ds nowd style(header)=[background=grey foreground=black fontweight=bold fontsize=8pt]
                                          style(column)=[fontsize=8pt];
		column  flag study source siteid subjid visit pktpt pksmpid;
	run;

	proc datasets lib=work nolist nodetails;
		delete zero_obs_ds;
	run;
	quit;
							     	%end;




	ods tagsets.excelxp close;

	ods listing; 

	title;
	footnote;

	%end;

	%else %do;
    			%put %str(ERR)OR:[PXL]--------------------------------------------------------------------------;
    			%put %str(ERR)OR:[PXL] PFESACQ_PK_RECON_C_CHECKS_REPORT: alert: Dataset PKCHECKC does not exist.;
    			%put %str(ERR)OR:[PXL]--------------------------------------------------------------------------;
		  %end;




    %macend:;
    %put ;
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_PK_RECON_C_CHECKS_REPORT: End of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_pk_recon_c_checks_report;

*%pfesacq_pk_recon_c_checks_report;


