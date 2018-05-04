/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Shiva Bhimreddy, $LastChangedBy:  $
  Creation Date:         20AUG2015                       $LastChangedDate:  $
 
  Program Location/Name: $HeadURL: $
 
  Files Created:         None
 
  Program Purpose:       Report the Lab reconciliation results in an excel file.                      
 
						 Note: Part of program: pfesacq_lab_recon 

						 This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:
 
  Macro Output:          "&protocol_LAB Recon_&yymmdd.xls" is created at "&path_listings./current" location.

  Macro Dependencies:    Note: Part of program: pfesacq_lab_recon

                         This is a submacro dependant on calling parent macro: 
                         pfesacq_lab_recon.sas

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev:  $
  
-----------------------------------------------------------------------------*/

%macro pfesacq_lab_recon_report();
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_LAB_RECON_REPORT: Start of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

	options ls=256 ps=64 nocenter; 

	%if %sysfunc(exist(outdir.labrecon)) %then %do;

	proc sql noprint;
		select count(*) into:nobs
		from outdir.labrecon;
	quit;

/* Listing outputs */
ODS TAGSETS.EXCELXP
	file="&path_listings./current/&protocol._Lab Recon_&rundate..xls"
	STYLE=Printer
	OPTIONS ( 
			Orientation = 'landscape'
			FitToPage = 'yes'
			Pages_FitWidth = '1'
			Pages_FitHeight = '10000' 
			autofit_height='YES'
			embedded_titles = 'yes'
			embedded_footnotes = 'yes'
			print_header = "%nrstr(&L) &protocol.  %nrstr(&C) SAS &sysver.  %nrstr(&R)  Lab Reconciliation"
			print_footer = "%nrstr(&L) &sysdate9.  %nrstr(&R) Page %nrstr(&P) of %nrstr(&N) "
			Autofilter = 'All'
			Frozen_Headers='3'
			Absolute_Column_Width='10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10'
  			sheet_name='Lab Recon'
			);


	title1 justify=left "Lab Reconciliation";

	%if %eval(&nobs) > 0 %then %do; 

	proc sort data=outdir.labrecon out=labrecon;
		by study subjid colldtn colldate cpevent lbcat testtime
		   clinstdy vendstdy 
		   clinsubj vendsubj 
		   clinvis vendvis
		   clincat vendcat
		   clindt venddt
		   clintm vendtm
           lnotdone clintpt clinsmpid invcom
           vendtpt vendsmpid lab_com siteid recon flag;
	run;

	proc report data=labrecon nowd style(header)=[background=lightskyblue foreground=black fontweight=bold fontsize=11pt]	;

		column  status flag classmis study siteid subjid  /*colldate lbcat cpevent*/
                clinvis visitdt clincat lnotdone clintpt clindt %if &testtime= %then %do;%end; %else %do;clintm %end; clinsmpid invcom
                vendsubj vendcat vendtpt vendvis venddt %if &testtime= %then %do;%end; %else %do; vendtm %end; vendsmpid lab_com   ;

		define	status    / "Data State"               display flow style(header) = {background=white  foreground=black}; 
		define	flag      / "Flag"                     display flow style(header) = {background=white  foreground=black};
		define  classmis  / "Classification Mismatch"  display flow style(header) = {background=white  foreground=black}; ;
		define	study     / "Study"                    display flow style(header) = {background=light grey  foreground=black};
		define	siteid    / "Site"                     display flow style(header) = {background=light grey  foreground=black};
		define	subjid    / "Subject"                  display flow style(header) = {background=light grey  foreground=black}; 
		*define	colldate  / order order=internal noprint; 
		*define	lbcat     / order order=internal noprint; 
		*define	cpevent   / order order=internal noprint; 
		define	clinvis   / "EDC Visit"                display flow style(header) = {background=light grey  foreground=black};
		define	visitdt   / "EDC Visit Date"           display flow style(header) = {background=light grey  foreground=black};
		define	clincat   / "EDC Classification"       display flow style(header) = {background=light grey  foreground=black}; 
		define	lnotdone  / "EDC Done/Not Done"        display flow style(header) = {background=light grey  foreground=black}; 
		define	clintpt   / "EDC Time Point"           display flow style(header) = {background=light grey  foreground=black}; 
		define	clindt    / "EDC Collection Date"      display flow style(header) = {background=light grey  foreground=black};
		%if &testtime= %then %do;%end; %else %do; define	clintm    / "EDC Collection Time"      display flow style(header) = {background=light grey  foreground=black};%end;
		define	clinsmpid / "EDC Lab Sample Id (Accession Number)" display flow style(header) = {background=light grey  foreground=black}; 
		define	invcom    / "EDC Investigator Comment" display flow style(header) = {background=light grey  foreground=black};

		define	vendsubj  / "Vendor Subject"           display flow style(header) = {background=dark grey  foreground=black}; 
		define	vendcat   / "Vendor Classification"    display flow style(header) = {background=dark grey  foreground=black}; 
		define	vendtpt   / "Vendor Time Point"        display flow style(header) = {background=dark grey  foreground=black};
		define	vendvis   / "Vendor Visit"             display flow style(header) = {background=dark grey  foreground=black};
		define	venddt    / "Vendor Collection Date"   display flow style(header) = {background=dark grey  foreground=black}; 
		%if &testtime= %then %do;%end; %else %do; define	vendtm    / "Vendor Collection Time"   display flow style(header) = {background=dark grey  foreground=black}; %end;
		define	vendsmpid / "Vendor Sample ID"         display flow style(header) = {background=dark grey  foreground=black}; 
		define	lab_com   / "Vendor Comment"           display flow style(header) = {background=dark grey  foreground=black}; 


		compute clindt;
			if flag='Date/Time mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 
		compute venddt;
			if flag='Date/Time mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute clinsmpid;
			if flag='Sample ID mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 
		compute vendsmpid;
			if flag='Sample ID mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute clincat;
			if /*flag='Classification mismatch' or*/ classmis='Yes' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 
		compute vendcat;
			if /*flag='Classification mismatch' or*/ classmis='Yes' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute clinvis;
			if flag='Visit mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 
		compute vendvis;
			if flag='Visit mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute clintpt;
			if flag='Timepoint mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 
		compute vendtpt;
			if flag='Timepoint mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 
	run;


			       %end;

	%else %if %eval(&nobs) = 0 %then %do; 

	data labrecon;

		flag=''; clinstdy='';siteid=''; clinsubj=''; clinvis=''; clinvdt='';lnotdone='';clintpt='';clindt='';clintm='';clinsmpid='';invcom=''; clindt=''; clincat=''; lbnd='';
        vendsubj=''; status='';vendvis=''; venddt=''; vendtm=''; vendsmpid='';vendtpt='';vendcat=''; lbtest=''; lab_com='';

	run;

	title1 justify=left "Lab Reconciliation";

	proc print data=labrecon LABEL;
		id flag;
	run;

							     	%end;

	ods tagsets.excelxp close;


	ods listing; 

	title;
	footnote;

	proc datasets lib=work;
		delete labrecon;
	run;
			

	%end;

	%else %do;
    			%put %str(ERR)OR:[PXL]------------------------------------------------------------------;
    			%put %str(ERR)OR:[PXL] PFESACQ_LAB_RECON_REPORT: alert: Dataset LABRECON does not exist.;
    			%put %str(ERR)OR:[PXL]------------------------------------------------------------------;
		  %end;





    %macend:;
    %put ;
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_LAB_RECON_REPORT: End of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_lab_recon_report;



