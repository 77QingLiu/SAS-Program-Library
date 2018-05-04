/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Allwyn Dsouza $LastChangedBy: dsouzaal $
  Creation Date:         09DEC2015     $LastChangedDate: 2016-06-10 06:24:47 -0400 (Fri, 10 Jun 2016) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfesacq_ecg_recon_report.sas $
 
  Files Created:         None
 
  Program Purpose:       Report the ECG reconciliation results in an excel file.                      
 
						 Note: Part of program: pfesacq_ecgrecon 

						 This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:		 N/A
 
  Macro Output:          "&protocol_ECG_Recon_&yymmdd.xls" is created at "&path_listings./current" location.

  Macro Dependencies:    Note: Part of program: pfesacq_ecg_recon

                         This is a submacro dependant on calling parent macro: 
                         pfesacq_ecg_recon.sas

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2296 $
  
-----------------------------------------------------------------------------*/

%macro pfesacq_ecg_recon_report;

    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put NOTE:[PXL] &sysmacroname.: Start of Submacro;
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put ;

	options ls=256 ps=64 nocenter;
	
	%macro getNormalisedDset(_dsin=,_vars=,flag=,ods=1);

		%put NOTE:[PXL] ---------------------------------------------------------------------;
	    %put NOTE:[PXL] &sysmacroname.: Preparing data for &_dsin.;
	    %put NOTE:[PXL] ---------------------------------------------------------------------;
	    %put ;
				
		%local i nobs;
		
		%if not %sysfunc(exist(&_dsin.)) %then %do;
			data &_dsin.;
				length flag status $40;
				%let i=1;
				%do %while (%scan(&_vars.,&i.,%str( )) ne %str()) ;
					%scan(&_vars.,&i.,%str( )) = "" ;
					%let i = %eval(&i. + 1);
				%end;
				stop;
			run;
		%end;
		
		proc sql noprint;
			select count(*) into:nobs
			from &_dsin.;
		quit;
			
		%if &nobs. = 0 %then %do ;
			data _dummy;
				length status flag $40;
				status = "No output for this listing";
				flag = "&flag.";
			run;

			data &_dsin. ;
				set &_dsin. _dummy;
			run;

			proc datasets lib=work nolist;
				delete _dummy;
			quit ;
		%end ;

		%if &ods. = 1 %then %do;
			ods tagsets.excelxp
			options ( 
				Orientation = 'landscape'
				FitToPage = 'yes'
				Pages_FitWidth = '1'
				Pages_FitHeight = '100' 
				autofit_height='YES'
				embedded_titles = 'yes'
				embedded_footnotes = 'yes'
				print_header = "%nrstr(&L) &protocol.  %nrstr(&C) SAS &sysver.  %nrstr(&R)  ECG Checks"
				print_footer = "%nrstr(&L) &sysdate9.  %nrstr(&R) Page %nrstr(&P) of %nrstr(&N) "
				Autofilter = 'All'
				Frozen_Headers='3'
				Absolute_Column_Width='10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
	                                   10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
	                                   10, 10, 10'
	  			sheet_name="%upcase(&_dsin.)"
				);
		%end;
		
		title;
		footnote;
		title1 j=l "%upcase(&_dsin.): &flag. &sysdate9. &systime.";
		
	%mend;
	
	%local _style;
	%let _style=display flow style(header) = {background=grey  foreground=black};

	* ---------------------------------------------------------------------;
	* REPORT LIS01 ;
	* ---------------------------------------------------------------------;

	ODS TAGSETS.EXCELXP
	file="&path_listings./current/&protocol._ECG_Checks_&rundate..xls"
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
			print_header = "%nrstr(&L) &protocol.  %nrstr(&C) SAS &sysver.  %nrstr(&R)  ECG Checks"
			print_footer = "%nrstr(&L) &sysdate9.  %nrstr(&R) Page %nrstr(&P) of %nrstr(&N) "
			Frozen_Headers='3'
			Absolute_Column_Width='10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10'
  			sheet_name='LIS01'
			);
	
	%getNormalisedDset(_dsin=lis01,_vars=status flag study subjid cpevent clinsex clindob vendsex venddob,flag=%nrstr(Mismatch of Gender/DOB),ods=0);

	proc report data=lis01 nowd style(header)=[background=lightskyblue foreground=black fontweight=bold fontsize=11pt];

		column status flag study subjid clinsex clindob vendsex venddob;
		
		define	status    / "Data State"            &_style.; 
		define	flag      / "Flag"                  &_style.; 
		define	study     / "Study"                 &_style.;
		define	subjid    / "Subject"               &_style.;
		define	clinsex   / "EDC Gender"            &_style.; 
		define	clindob   / "EDC Date of Birth"     &_style.; 
		define	vendsex   / "Vendor Gender"         &_style.; 
		define	venddob   / "Vendor Date of Birth"  &_style.;

	run;
	
	* ---------------------------------------------------------------------;
	* REPORT LIS02 ;
	* ---------------------------------------------------------------------;
	
	%getNormalisedDset(_dsin=lis02,_vars=status flag study subjid cpevent,flag=Invalid Study ID);

	proc report data=lis02 nowd style(header)=[background=lightskyblue foreground=black fontweight=bold fontsize=11pt] ;
		column  status flag study subjid cpevent;

		define	status    / "Data State"            &_style.; 
		define	flag      / "Flag"                  &_style.; 
		define	study     / "Study"                 &_style.;
		define	subjid    / "Subject"               &_style.; 
		define	cpevent   / "Visit"                 &_style.;

	run;

	* ---------------------------------------------------------------------;
	* REPORT LIS03 ;
	* ---------------------------------------------------------------------;
	
	%getNormalisedDset(_dsin=lis03,_vars=status flag study siteid subjid 
				vend_egtpd vend_cpevent vend_colldate vend_egacttmf vend_egintp vend_egcom,flag=Invalid Visit);

	proc report data=lis03 nowd style(header)=[background=lightskyblue foreground=black fontweight=bold fontsize=11pt];

		column status flag study siteid subjid  
				vend_egtpd vend_cpevent vend_colldate vend_egacttmf vend_egintp vend_egcom;
		
		define	status        / "Data State"               &_style.; 
		define	flag          / "Flag"                     &_style.;
		
		define	study         / "Study"                    &_style.;
		define	siteid        / "Site"                     &_style.;
		define	subjid        / "Subject"                  &_style.; 
		
		define	vend_egtpd    / "Vendor Time Point"        &_style.;
		define	vend_cpevent  / "Vendor Visit"             &_style.;
		define	vend_colldate / "Vendor Collection Date"   &_style.; 
		define	vend_egacttmf / "Vendor Collection Time"   &_style.;
		define  vend_egintp   / "Vendor Interpretation"    &_style.;
		define	vend_egcom    / "Vendor Comment"           &_style.;

	run;
	
	* ---------------------------------------------------------------------;
	* REPORT LIS04 ;
	* ---------------------------------------------------------------------;

	%getNormalisedDset(_dsin=lis04,_vars=status flag study siteid subjid cpevent visitdt egnd egtpd colldate egacttmf egintp egcom 
				vend_egtpd vend_cpevent vend_colldate vend_egacttmf vend_egintp vend_egcom,flag=Mismatch of Result Interpretation);

	proc report data=lis04 nowd style(header)=[background=lightskyblue foreground=black fontweight=bold fontsize=11pt];

		column status flag study siteid subjid cpevent visitdt egnd egtpd colldate egacttmf egintp egcom 
				vend_egtpd vend_cpevent vend_colldate vend_egacttmf vend_egintp vend_egcom;
		
		define	status        / "Data State"               &_style.; 
		define	flag          / "Flag"                     &_style.;
		
		define	study         / "Study"                    &_style.;
		define	siteid        / "Site"                     &_style.;
		define	subjid        / "Subject"                  &_style.; 
		define	cpevent       / "EDC Visit"                &_style.;
		define	visitdt       / "EDC Visit Date"           &_style.;
		define	egnd          / "EDC Done/Not Done"        &_style.; 
		define	egtpd         / "EDC Time Point"           &_style.; 
		define	colldate      / "EDC Collection Date"      &_style.;
		define	egacttmf      / "EDC Collection Time"      &_style.;
		define  egintp        / "EDC Interpretation"       &_style.;
		define	egcom         / "EDC Investigator Comment" &_style.;

		define	vend_egtpd    / "Vendor Time Point"        &_style.;
		define	vend_cpevent  / "Vendor Visit"             &_style.;
		define	vend_colldate / "Vendor Collection Date"   &_style.; 
		define	vend_egacttmf / "Vendor Collection Time"   &_style.;
		define  vend_egintp   / "Vendor Interpretation"    &_style.;
		define	vend_egcom    / "Vendor Comment"           &_style.;

	run;

	* ---------------------------------------------------------------------;
	* REPORT LIS05 ;
	* ---------------------------------------------------------------------;

	%getNormalisedDset(_dsin=lis05,_vars=status flag study siteid subjid 
				vend_egtpd vend_cpevent vend_colldate vend_egacttmf vend_egintp vend_egcom,flag=Missing Result Interpretation);

	proc report data=lis05 nowd style(header)=[background=lightskyblue foreground=black fontweight=bold fontsize=11pt];

		column status flag study siteid subjid  
				vend_egtpd vend_cpevent vend_colldate vend_egacttmf vend_egintp vend_egcom;
		
		define	status        / "Data State"               &_style.; 
		define	flag          / "Flag"                     &_style.;
		
		define	study         / "Study"                    &_style.;
		define	siteid        / "Site"                     &_style.;
		define	subjid        / "Subject"                  &_style.; 
		
		define	vend_egtpd    / "Vendor Time Point"        &_style.;
		define	vend_cpevent  / "Vendor Visit"             &_style.;
		define	vend_colldate / "Vendor Collection Date"   &_style.; 
		define	vend_egacttmf / "Vendor Collection Time"   &_style.;
		define  vend_egintp   / "Vendor Interpretation"    &_style.;
		define	vend_egcom    / "Vendor Comment"           &_style.;

	run;

	* ---------------------------------------------------------------------;
	* REPORT LIS06 ;
	* ---------------------------------------------------------------------;

	%getNormalisedDset(_dsin=lis06,_vars=status flag study siteid subjid 
				vend_egtpd vend_cpevent vend_colldate vend_egacttmf vend_egintp vend_egcom,flag=Invalid Carriage Return);

	proc report data=lis06 nowd style(header)=[background=lightskyblue foreground=black fontweight=bold fontsize=11pt];

		column status flag study siteid subjid 
				vend_egtpd vend_cpevent vend_colldate vend_egacttmf vend_egintp vend_egcom;
		
		define	status        / "Data State"               &_style.; 
		define	flag          / "Flag"                     &_style.;
		
		define	study         / "Study"                    &_style.;
		define	siteid        / "Site"                     &_style.;
		define	subjid        / "Subject"                  &_style.; 
		
		define	vend_egtpd    / "Vendor Time Point"        &_style.;
		define	vend_cpevent  / "Vendor Visit"             &_style.;
		define	vend_colldate / "Vendor Collection Date"   &_style.; 
		define	vend_egacttmf / "Vendor Collection Time"   &_style.;
		define  vend_egintp   / "Vendor Interpretation"    &_style.;
		define	vend_egcom    / "Vendor Comment"           &_style.;

	run;

	* ---------------------------------------------------------------------;
	* REPORT LIS07 ;
	* ---------------------------------------------------------------------;

	%getNormalisedDset(_dsin=lis07,_vars=status flag study siteid subjid cpevent visitdt egnd egtpd colldate egacttmf egintp egcom,
						flag=Same Collection date across Visits CRF);

	proc report data=lis07 nowd style(header)=[background=lightskyblue foreground=black fontweight=bold fontsize=11pt];

		column status flag study siteid subjid cpevent visitdt egnd egtpd colldate egacttmf egintp egcom ;
		
		define	status        / "Data State"               &_style.; 
		define	flag          / "Flag"                     &_style.;
		
		define	study         / "Study"                    &_style.;
		define	siteid        / "Site"                     &_style.;
		define	subjid        / "Subject"                  &_style.; 
		define	cpevent       / "EDC Visit"                &_style.;
		define	visitdt       / "EDC Visit Date"           &_style.;
		define	egnd          / "EDC Done/Not Done"        &_style.; 
		define	egtpd         / "EDC Time Point"           &_style.; 
		define	colldate      / "EDC Collection Date"      &_style.;
		define	egacttmf      / "EDC Collection Time"      &_style.;
		define  egintp        / "EDC Interpretation"       &_style.;
		define	egcom         / "EDC Investigator Comment" &_style.;
	run;

	* ---------------------------------------------------------------------;
	* REPORT LIS08 ;
	* ---------------------------------------------------------------------;

	%getNormalisedDset(_dsin=lis08,_vars=status flag study siteid subjid 
				vend_egtpd vend_cpevent vend_colldate vend_egacttmf vend_egtest vend_egintp vend_egcom,flag=Duplicate Record Vendor);

	proc report data=lis08 nowd style(header)=[background=lightskyblue foreground=black fontweight=bold fontsize=11pt];

		column status flag study siteid subjid 
				vend_egtpd vend_cpevent vend_colldate vend_egacttmf vend_egtest vend_egintp vend_egcom;
		
		define	status        / "Data State"               &_style.; 
		define	flag          / "Flag"                     &_style.;
		
		define	study         / "Study"                    &_style.;
		define	siteid        / "Site"                     &_style.;
		define	subjid        / "Subject"                  &_style.; 
		
		define	vend_egtpd    / "Vendor Time Point"        &_style.;
		define	vend_cpevent  / "Vendor Visit"             &_style.;
		define	vend_colldate / "Vendor Collection Date"   &_style.; 
		define	vend_egacttmf / "Vendor Collection Time"   &_style.;
		define	vend_egtest   / "Vendor Test Name"         &_style.;
		define  vend_egintp   / "Vendor Interpretation"    &_style.;
		define	vend_egcom    / "Vendor Comment"           &_style.;

	run;

	* ---------------------------------------------------------------------;
	* REPORT LIS09 ;
	* ---------------------------------------------------------------------;

	%getNormalisedDset(_dsin=lis09,_vars=status flag study siteid subjid cpevent visitdt egnd egtpd colldate egacttmf egintp egcom,
							flag=Duplicate Record CRF);

	proc report data=lis09 nowd style(header)=[background=lightskyblue foreground=black fontweight=bold fontsize=11pt];

		column status flag study siteid subjid cpevent visitdt egnd egtpd colldate egacttmf egintp egcom;
		
		define	status        / "Data State"               &_style.; 
		define	flag          / "Flag"                     &_style.;
		
		define	study         / "Study"                    &_style.;
		define	siteid        / "Site"                     &_style.;
		define	subjid        / "Subject"                  &_style.; 
		
		define	cpevent       / "EDC Visit"                &_style.;
		define	visitdt       / "EDC Visit Date"           &_style.;
		define	egnd          / "EDC Done/Not Done"        &_style.; 
		define	egtpd         / "EDC Time Point"           &_style.; 
		define	colldate      / "EDC Collection Date"      &_style.;
		define	egacttmf      / "EDC Collection Time"      &_style.;
		define  egintp        / "EDC Interpretation"       &_style.;
		define	egcom         / "EDC Investigator Comment" &_style.;

	run;

	* ---------------------------------------------------------------------;
	* Close ODS and reset titles and footnotes ;
	* ---------------------------------------------------------------------;

	ods tagsets.excelxp close;

	ods listing; 

	title;
	footnote;

	* ---------------------------------------------------------------------;
	* Write RECON report ;
	* ---------------------------------------------------------------------;
	
	%if not %sysfunc(exist(outdir.ecgrecon)) %then %do; 
		%let l_error = 1 ;
	    %put NOTE:[PXL] ------------------------------------------------------------------;
	    %put %str(ERR)OR:[PXL] &sysmacroname.: Dataset ECGRECON does not exist.;
	    %put NOTE:[PXL] ------------------------------------------------------------------;
		%put ;
		%goto macend ;
	%end;
	
	ods tagsets.excelxp
		file="&path_listings./current/&protocol._ECG_Recon_&rundate..xls"
		style=printer
		options ( 
			orientation = 'landscape'
			fittopage = 'yes'
			pages_fitwidth = '1'
			pages_fitheight = '10000' 
			autofit_height='YES'
			embedded_titles = 'yes'
			embedded_footnotes = 'yes'
			print_header = "%nrstr(&L) &protocol.  %nrstr(&C) SAS &sysver.  %nrstr(&R)  ECG Reconciliation"
			print_footer = "%nrstr(&L) &sysdate9.  %nrstr(&R) Page %nrstr(&P) of %nrstr(&N)"
			autofilter = 'All'
			frozen_headers='3'
			absolute_column_Width='10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10'
  			sheet_name='ECG Recon'
			);

	title1 justify=left "ECG Reconciliation";

	proc sql noprint;
		create table work.ecgrecon as
		select * from outdir.ecgrecon
		order by study, subjid, colldtn, visitdt, colldate, cpevent, egacttmf, egtpd, egcom, status,
			vend_subjid, vend_colldate, vend_cpevent, vend_egacttmf, vend_egtpd, vend_egcom, flag;
	quit;

	%if %eval(&sqlobs.) = 0 %then %do;
		data ecgrecon ;
			set ecgrecon ;
			status = "No output for this listing";
		run;
	%end;

	proc report data=ecgrecon nowd style(header)=[background=lightskyblue foreground=black fontweight=bold fontsize=11pt]	;

		column  status flag study siteid subjid visitdt cpevent egnd egtpd colldate egacttmf egcom
                vend_egtpd vend_cpevent vend_colldate vend_egacttmf vend_egcom;

		define	status        / "Data State"               display flow style(header) = {background=white  foreground=black}; 
		define	flag          / "Flag"                     display flow style(header) = {background=white  foreground=black}; 
		define	study         / "Study"                    display flow style(header) = {background=light grey  foreground=black};
		define	siteid        / "Site"                     display flow style(header) = {background=light grey  foreground=black};
		define	subjid        / "Subject"                  display flow style(header) = {background=light grey  foreground=black}; 
		define	cpevent       / "EDC Visit"                display flow style(header) = {background=light grey  foreground=black};
		define	visitdt       / "EDC Visit Date"           display flow style(header) = {background=light grey  foreground=black};
		define	egnd          / "EDC Done/Not Done"        display flow style(header) = {background=light grey  foreground=black}; 
		define	egtpd         / "EDC Time Point"           display flow style(header) = {background=light grey  foreground=black}; 
		define	colldate      / "EDC Collection Date"      display flow style(header) = {background=light grey  foreground=black};
		define	egacttmf      / "EDC Collection Time"      display flow style(header) = {background=light grey  foreground=black};
		define	egcom         / "EDC Investigator Comment" display flow style(header) = {background=light grey  foreground=black};

		define	vend_egtpd    / "Vendor Time Point"        display flow style(header) = {background=dark grey  foreground=black};
		define	vend_cpevent  / "Vendor Visit"             display flow style(header) = {background=dark grey  foreground=black};
		define	vend_colldate / "Vendor Collection Date"   display flow style(header) = {background=dark grey  foreground=black}; 
		define	vend_egacttmf / "Vendor Collection Time"   display flow style(header) = {background=dark grey  foreground=black};
		define	vend_egcom    / "Vendor Comment"           display flow style(header) = {background=dark grey  foreground=black};

		compute colldate;
			if flag='Date/Time mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 
		compute vend_colldate;
			if flag='Date/Time mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 
		
		compute cpevent;
			if flag='Visit mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 
		compute vend_cpevent;
			if flag='Visit mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute egtpd;
			if flag='Timepoint mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 
		compute vend_egtpd;
			if flag='Timepoint mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 
	run;
	
	ods tagsets.excelxp close;

	ods listing;

	title;
	footnote;
	
	* ---------------------------------------------------------------------;
	* HOUSE KEEPING ;
	* ---------------------------------------------------------------------;
	
	proc datasets lib = work memtype = data nolist;
		delete ecgrecon ;
	quit;
	
    %macend:;

	proc datasets lib = work memtype = data nolist;
		delete lis: ;
	quit;

    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put NOTE:[PXL] &sysmacroname.: End of Submacro;
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_ecg_recon_report;