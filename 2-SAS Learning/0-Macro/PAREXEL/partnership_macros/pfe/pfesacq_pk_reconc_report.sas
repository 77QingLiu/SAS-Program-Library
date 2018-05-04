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
 
  Program Purpose:       Report the PK reconciliation results in an excel file.                      
 
						 Note: Part of program: pfesacq_pk_recon 

						 This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:
 
  Macro Output:          "&protocol_PK Recon Central_&yymmdd.xls" is created at "&path_listings./current" location.

  Macro Dependencies:    Note: Part of program: pfesacq_pk_recon

                         This is a submacro dependant on calling parent macro: 
                         pfesacq_pk_recon.sas

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev:  $
  
-----------------------------------------------------------------------------*/

%macro pfesacq_pk_reconc_report();
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_PK_RECONC_REPORT: Start of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

	options ls=256 ps=64 nocenter; 

	%if %sysfunc(exist(unblind.pkcrecon)) %then %do;

	proc sql noprint;
		select count(*) into:nobs
		from unblind.pkcrecon;
	quit;

/* Listing outputs */
ODS TAGSETS.EXCELXP
	file="&path_listings./current/&protocol._Central PK Recon_&rundate..xls"
	STYLE=Printer
	OPTIONS ( 
			Orientation = 'landscape'
			FitToPage = 'yes'
			Pages_FitWidth = '1'
			Pages_FitHeight = '10000' 
			autofit_height='YES'
			embedded_titles = 'NO'
			embedded_footnotes = 'yes'
			print_header = "%nrstr(&L) &protocol.  %nrstr(&C) SAS &sysver.  %nrstr(&R)  PK Reconciliation"
			print_footer = "%nrstr(&L) &sysdate9.  %nrstr(&R) Page %nrstr(&P) of %nrstr(&N) "
			Autofilter = 'All'
			Frozen_Headers='3'
			Absolute_Column_Width='5, 5, 5, 9, 7, 9, 5, 8, 6, 7,
                                   6, 7, 7, 5, 5, 9, 7, 8, 7, 7,
                                   7, 7, 7'
  			sheet_name='Central PK Reconciliation'
			);


	*title1 justify=left "PK Reconciliation";

	%if %eval(&nobs) > 0 %then %do; 

	proc sort data=unblind.pkcrecon out=pkcrecon;
		by study /*clinstdy vendstdy */
		   siteid /*clinsite vendsite*/
           subjid /*clinsubj vendsubj  */
		   visit /*clinvis vendvis*/
		   pktpt clintpt vendtpt
		   pksmpid clinsmpid vendsmpid
		   colldate testtime 
		   pnotdone invcom
           pk_com  recon flag;
	run;

	ods escapechar='^';

	proc report data=pkcrecon nowd style(header)=[background=white foreground=black fontweight=bold fontsize=8pt]	
                                  style(column)=[fontsize=8pt];

		*column  ("^S={background=BILG} CRF/eCRF data"     clinstdy clinsite clinsubj clinvis visitdt dcmname pnotdone clinrnum clintpt colldate testtime clinsmpid invcom)
                ("^S={backgroundcolor=CYAN} Vendor Data"  vendstdy vendsite vendsubj vendvis vendrnum vendtpt vendsmpid pk_com)
				status flag;
		column  clinstdy clinsite clinsubj clinvis visitdt /*dcmname*/ pnotdone clinrnum clintpt colldate testtime clinsmpid invcom
                vendstdy vendsite vendsubj vendvis vendrnum vendtpt vendsmpid pk_com
				status flag;

		*define	colldate  / order order=internal noprint; 

		define	clinstdy  / "Study"                    display flow style(header) = {background=BILG  foreground=black};
		define	clinsite  / "Site"                     display flow style(header) = {background=BILG  foreground=black};
		define	clinsubj  / "Subject"                  display flow style(header) = {background=BILG  foreground=black}; 
		define	clinvis   / "Visit"                    display flow style(header) = {background=BILG  foreground=black};
		define	visitdt   / "Visit Date"               display flow style(header) = {background=BILG  foreground=black};
		*define	dcmname   / "Form"                     display flow style(header) = {background=BILG  foreground=black}; 
		define	pnotdone  / "Not Done?"                display flow style(header) = {background=BILG  foreground=black}; 
		define	clinrnum  / "Randomization Number"     display flow style(header) = {background=BILG  foreground=black}; 
		define	clintpt   / "Time Point"               display flow style(header) = {background=BILG  foreground=black}; 
		define	colldate  / "Collection Date"          display flow style(header) = {background=BILG  foreground=black};
		define	testtime  / "Collection Time"          display flow style(header) = {background=BILG  foreground=black};
		define	clinsmpid / "Unique Sample ID"         display flow style(header) = {background=BILG  foreground=black}; 
		define	invcom    / "Investigator Comment"     display flow style(header) = {background=BILG  foreground=black};

		define	vendstdy  / "Study"                    display flow style(header) = {background=lightskyblue  foreground=black};
		define	vendsite  / "Site"                     display flow style(header) = {background=lightskyblue  foreground=black};
		define	vendsubj  / "Subject"                  display flow style(header) = {background=lightskyblue  foreground=black}; 
		define	vendvis   / "Visit"                    display flow style(header) = {background=lightskyblue  foreground=black};
		define	vendrnum  / "Randomization Number"     display flow style(header) = {background=lightskyblue  foreground=black}; 
		define	vendtpt   / "Time Point"               display flow style(header) = {background=lightskyblue  foreground=black};
		define	vendsmpid / "Unique Sample ID"         display flow style(header) = {background=lightskyblue  foreground=black}; 
		define	pk_com    / "PK Comment"               display flow style(header) = {background=lightskyblue  foreground=black}; 

		define	status    / "Data State"               display flow style(header) = {background=light grey  foreground=black}; 
		define	flag      / "Flag"                     display flow style(header) = {background=light grey  foreground=black};


		compute clinsmpid;
			if flag='Sample ID mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 
		compute vendsmpid;
			if flag='Sample ID mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute clintpt;
			if flag='Timepoint mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 
		compute vendtpt;
			if flag='Timepoint mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute clinvis;
			if flag='Visit mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 
		compute vendvis;
			if flag='Visit mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute clinrnum;
			if flag='Randomization mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 
		compute vendrnum;
			if flag='Randomization mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 


	run;


			       %end;

	%else %if %eval(&nobs) = 0 %then %do; 

	data pkcrecon;

		flag=''; clinstdy='';clinsite=''; clinsubj=''; clinvis=''; clinrnum='';visitdt='';pnotdone='';*dcmname='';clintpt='';colldate='';testtime='';clinsmpid='';invcom=''; 
        status='';vendstdy='';vendsite=''; vendsubj=''; vendvis=''; venrnum='';vendsmpid='';vendtpt='';pk_com='';

	run;

	title1 justify=left "PK Reconciliation";

	proc print data=pkcrecon LABEL;
		id flag;
	run;

							     	%end;

	ods tagsets.excelxp close;


	ods listing; 

	title;
	footnote;

	proc datasets lib=work;
		delete pkcrecon;
	run;
	quit;			

	%end;

	%else %do;
    			%put %str(ERR)OR:[PXL]------------------------------------------------------------------;
    			%put %str(ERR)OR:[PXL] PFESACQ_PK_RECONC_REPORT: alert: Dataset PKCRECON does not exist.;
    			%put %str(ERR)OR:[PXL]------------------------------------------------------------------;
		  %end;





    %macend:;
    %put ;
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_PK_RECONC_REPORT: End of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_pk_reconc_report;



