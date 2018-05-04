/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX
  Example Call:          Note: Part of program: pfesacq_sae_recon 
               
                         Call from parent submacro pfesacq_sae_recon.sas:
                         %pfesacq_sae_recon_report();

-------------------------------------------------------------------------------
 
  Author:                Shiva Bhimreddy, $LastChangedBy: bhimres $
  Creation Date:         01JUN2015                       $LastChangedDate: 2015-10-01 17:22:10 -0400 (Thu, 01 Oct 2015) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfesacq_sae_recon_report.sas $
 
  Files Created:         None
 
  Program Purpose:       Merge the EDC AE dataset with the safety (CSV/XLS) AE dataset
                         and see if there are any mismatches for the AE Death Date.                      
 
                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:
 
  Macro Output:  

  Macro Dependencies:    Note: Part of program: pfesacq_sae_recon

                         This is a submacro dependant on calling parent macro: 
                         pfesacq_sae_recon.sas

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2284 $
  
-----------------------------------------------------------------------------*/

%macro pfesacq_sae_recon_report();
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_SAE_RECON_REPORT: Start of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

	options ls=256 ps=64 nocenter; 

	proc sql noprint;
		select count(*) into:nobs
		from outdir.allchecks;
	quit;

/* Listing outputs */
ODS TAGSETS.EXCELXP
	file="&path_listings./current/&protocol._SAE Recon_&rundate..xls"
	/*file="&inlib./SAE Recon.xls"*/
	STYLE=Printer
	OPTIONS ( 
			Orientation = 'landscape'
			FitToPage = 'yes'
			Pages_FitWidth = '1'
			Pages_FitHeight = '100' 
			/*embedded_titles = 'yes' */
			autofit_height='YES'
			Autofilter = 'All'
			Frozen_Headers='Yes'
			Absolute_Column_Width='15, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
                                   10, 10, 10'
  			sheet_name='SAE Recon Mismatches'
			);



	%if %eval(&nobs) > 0 %then %do; 

	proc report data=outdir.allchecks nowd style(header)=[background=lightskyblue foreground=black fontweight=bold fontsize=11pt]	;

		column  flag category /*ae1 ae2 ae3 ae4 ae5 ae6 ae7 ae8 ae9 ae10*/
                safecase lsafedt  safestudy safesubj safedob safesex safest safeen safeterm safedecd safeser saferel safeacn safepres safedth tradenam
				clincase lstchgts clinstudy clinsubj clindob clinsex clinst clinen clinterm clindecd clinser clinrel clinacn aeacndr1 aeacndr2 aeacndr3 aeacndr4 clinpres aegrade clindth
                sdrgcaus drg1nam drg1caus drg2nam drg2caus drg3nam drg3caus drg4nam drg4caus;
				*invcom invalhis invalcas;
		
		define	flag      / "Flag"                          display   flow style(header) = {background=white  foreground=black}; 
		*define	mismatch  / "Mismatch"                      display   flow style(header) = {background=white  foreground=black}; 

		define	category  /  "Multiple mismatches"          display   flow style(header) = {background=white  foreground=black};


		define	safecase  / "AER Number"                    display   flow style(header) = {background= gray foreground=black}; 
		define	lsafedt   / "Latest Safety FU Date"         display   flow style(header) = {background= gray foreground=black}; 
		define	safestudy / "Protocol Study No."            display   flow style(header) = {background= gray foreground=black}; 
		define	safesubj  / "Patient ID"                    display   flow style(header) = {background= gray foreground=black}; 
		define	safedob   / "Date of Birth"                 display   flow style(header) = {background= gray foreground=black}; 
		define	safesex   / "Sex"                           display   flow style(header) = {background= gray foreground=black}; 
		define	safest    / "Onset Date"                    display   flow style(header) = {background= gray foreground=black}; 
		define	safeen    / "Cessation Date"                display   flow style(header) = {background= gray foreground=black}; 
		define	safeterm  / "Verbatim Term"                 display   flow style(header) = {background= gray foreground=black};
		define	safedecd  / "Preferred Term"                display   flow style(header) = {background= gray foreground=black}; 
		define	safeser   / "Event Seriousness"             display   flow style(header) = {background= gray foreground=black};
		define	saferel   / "Causality per Reporter"        display   flow style(header) = {background= gray foreground=black}; 
		define	safeacn   / "Action Taken"                  display   flow style(header) = {background= gray foreground=black}; 
		define	safepres  / "Clinical Outcome"              display   flow style(header) = {background= gray foreground=black};
		define	safedth   / "Date of Death"                 display   flow style(header) = {background= gray foreground=black}; 
		define	tradenam  / "Suspect Trade (Generic) Name"  display   flow style(header) = {background= gray foreground=black}; 

		define	clincase  / "CASE ID"         display   flow style(header) = {background=light gray   foreground=black};
		define	lstchgts  / "LSTCHGTS"        display   flow style(header) = {background=light gray   foreground=black}; 
		define	clinstudy / "STUDY"           display   flow style(header) = {background=light gray   foreground=black}; 
		define	clinsubj  / "PT"              display   flow style(header) = {background=light gray   foreground=black};
		define	clindob   / "Date of Birth"   display 	flow style(header) = {background=light gray   foreground=black};
		define	clinsex   / "Sex"             display   flow style(header) = {background=light gray   foreground=black};
		define	clinst    / "START DATE"      display   flow style(header) = {background=light gray   foreground=black};
		define	clinen    / "STOP DATE"       display   flow style(header) = {background=light gray   foreground=black};
		define	clinterm  / "AE TERM "        display   flow style(header) = {background=light gray   foreground=black} width=10;
		define	clindecd  / "Preferred Term"  display   flow style(header) = {background=light gray   foreground=black};
		define	clinser   / "SERIOUS"         display   flow style(header) = {background=light gray   foreground=black};
		define	clinrel   / "RELATED"         display   flow style(header) = {background=light gray   foreground=black};
		define	clinacn   / "ACTION ST DRUG"  display   flow style(header) = {background=light gray   foreground=black};
		define	aeacndr1  /   display   flow style(header) = {background=light gray   foreground=black};
		define	aeacndr2  /   display   flow style(header) = {background=light gray   foreground=black};
		define	aeacndr3  /   display   flow style(header) = {background=light gray   foreground=black};
		define	aeacndr4  /   display   flow style(header) = {background=light gray   foreground=black};

		define	clinpres  / "PRESENT"         display   flow style(header) = {background=light gray   foreground=black};
		define	aegrade   / "GRADE"           display   flow style(header) = {background=light gray   foreground=black};
		define	clindth   / "Date of Death"   display   flow style(header) = {background=light gray   foreground=black};
		define	sdrgcaus  / "Study Drug Cause of Adverse Event"   display   flow style(header) = {background=light gray   foreground=black};
		define	drg1nam   / "Drug 1 Name "       display   flow style(header) = {background=light gray   foreground=black};
		define	drg1caus  / "Drug 1 Causality "  display   flow style(header) = {background=light gray   foreground=black};
		define	drg2nam   / "Drug 2 Name "       display   flow style(header) = {background=light gray   foreground=black};
		define	drg2caus  / "Drug 2 Causality "  display   flow style(header) = {background=light gray   foreground=black};
		define	drg3nam   / "Drug 3 Name "       display   flow style(header) = {background=light gray   foreground=black};
		define	drg3caus  / "Drug 3 Causality "  display   flow style(header) = {background=light gray   foreground=black};
		define	drg4nam   / "Drug 4 Name "       display   flow style(header) = {background=light gray   foreground=black};
		define	drg4caus  / "Drug 4 Causality "  display   flow style(header) = {background=light gray   foreground=black};



		*define	invalhis  / "Invalid/Historical"  display flow style(header) = {background=light gray foreground=black}; 
		*define	invalcas  / "Invalid Case Reason" display flow style(header) = {background=light gray foreground=black}; 


		compute clinstudy;
			if flag='Study Number mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute safestudy;
			if flag='Study Number mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute clinsubj;
			if flag='Patient ID mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute safesubj;
			if flag='Patient ID mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute clindob;
			if flag='DOB mismatch' or index(category,'DOB')>0 then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute safedob;
			if flag='DOB mismatch' or index(category,'DOB')>0 then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute clinsex;
			if flag='Gender mismatch' or index(category,'Sex')>0 then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute safesex;
			if flag='Gender mismatch' or index(category,'Sex')>0 then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute clinser;
			if flag='Seriousness mismatch' or index(category,'Seriousness')>0 then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute safeser;
			if flag='Seriousness mismatch' or index(category,'Seriousness')>0 then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute clincase;
			if flag='Case ID mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute safecase;
			if flag='Case ID mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute clinterm;
			if flag='Verbatim Term mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute safeterm;
			if flag='Verbatim Term mismatch' then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute clindecd;
			if flag='Preferred Term mismatch' or index(category,'Preferred Term')>0 then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute safedecd;
			if flag='Preferred Term mismatch' or index(category,'Preferred Term')>0 then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute clinst;
			if flag='Start Date mismatch' or index(category,'Start Date')>0 then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute safest;
			if flag='Start Date mismatch' or index(category,'Start Date')>0 then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute clinen;
			if flag='Stop Date mismatch' or index(category,'End Date')>0 then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute safeen;
			if flag='Stop Date mismatch' or index(category,'End Date')>0 then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute clinpres;
			if flag='Outcome mismatch' or index(category,'Outcome')>0 then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute safepres;
			if flag='Outcome mismatch' or index(category,'Outcome')>0 then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute clinrel;
			if flag='Causality mismatch' or index(category,'Causality')>0 then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute saferel;
			if flag='Causality mismatch' or index(category,'Causality')>0 then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute clinacn;
			if flag='Action mismatch' or index(category,'Action')>0 then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute safeacn;
			if flag='Action mismatch' or index(category,'Action')>0 then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute clindth;
			if flag='Date of Death mismatch' or index(category,'Death')>0 then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

		compute safedth;
			if flag='Date of Death mismatch' or index(category,'Death')>0 then call define(_col_, "style", "style={background=yellow}");
		endcomp; 

	run;



						       %end;

	%else %if %eval(&nobs) = 0 %then %do; 

	data zero_obs_ds;
		flag=''; clinstdy=''; safestdy=''; clinsubj=''; safesubj=''; clindob=''; safedob=''; clinsex=''; safesex='';
		clindecd=''; safedecd=''; clinser=''; safeser=''; clincase=''; safecase=''; clinterm=''; safeterm=''; clinst=''; safest=''; clinen=''; safeen='';
		clinpres=''; safepres=''; clinrel=''; saferel=''; clinacn=''; safeacn=''; clingrad=''; invalhis=''; invalcas=''; clindth=''; safedth='';
		lsafedt='';lstchgts='';tradenam='';ae1=.;ae2=.;ae3=.;ae4=.;ae5=.;ae6=.;ae7=.;ae8=.;ae9=.;ae10=.;
	run;

	proc print data=zero_obs_ds LABEL;
		id desc;
	run;

	proc datasets lib=work;
		delete zero_obs;
	run;
							     	%end;

ods tagsets.excelxp close;


ods listing; 






    %macend:;
    %put ;
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_SAE_RECON_REPORT: End of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_sae_recon_report;



