/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Nathan Hartley $LastChangedBy: hartlen $
  Creation Date:         20160819       $LastChangedDate: 2016-08-19 11:04:40 -0400 (Fri, 19 Aug 2016) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfestudy_contacts.sas $
 
  Files Created:         1) None
 
  Program Purpose:       Purpose of this macro is to: <br />
                         1) Read study study_contacts.csv and create macro variables for CDBP, Stat, and PCDA eamil 
                            address lists

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has not been validated for use only in PAREXEL's
                         working environment yet.
 
  Macro Parameters:
 
    Name:                In_PXL_Code
      Allowed Values:    Valid Study PAREXEL code
      Default Value:     null
      Description:       Valid Study PAREXEL code, if null will attempt to get from global macro PXL_CODE

    Name:                In_Path_Study_Contacts
      Allowed Values:    Valid Kennet Directory
      Default Value:     null
      Description:       Valid Directory that contains study_contacts.csv file

    Name:                Out_MV_Emails_CDBP
      Allowed Values:    Existing macro value name
      Default Value:     null
      Description:       Sets email list of CDBP primary and backup if given or creates global 
                         Emails_CDBP to hold the emails

    Name:                Out_MV_Emails_Stat
      Allowed Values:    Existing macro value name
      Default Value:     null
      Description:       Sets email list of Stat primary and backup if given or creates global 
                         Emails_Stat to hold the emails

    Name:                Out_MV_Emails_PCDA
      Allowed Values:    Existing macro value name
      Default Value:     null
      Description:       Sets email list of PCDA if given or creates global 
                         Emails_PCDA to hold the emails         

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2522 $

-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
  MODIFICATION VERSIONS: 

  Ver | Date     | Author         | Updates
  -----------------------------------------------------------------------------
  1.0 | 20160819 | Nathan Hartley | Initial Version

-----------------------------------------------------------------------------*/

%macro pfestudy_contacts(
	In_PXL_Code            = null,
	In_Path_Study_Contacts = null,
	Out_MV_Emails_CDBP     = null,
	Out_MV_Emails_Stat     = null,
	Out_MV_Emails_PCDA     = null);

	%local MacroVersion;
	%let MacroVersion = 1.0;

    %* Macro Utilities

        %* MACRO: pfestudy_contacts_LogMessage
         * PURPOSE: Standardize Macro Log Message Output
         * INPUT: 
         *   1) noteType - i=INFO, n=NOTE, e=ERR OR, w=WARN ING
         *   2) noteMessage - Message text with @ for line breaks\
         *   3) macroName - Macro breadcrumbs
         * OUTPUT: 
         *   1) Log Message
         *;
	        %macro pfestudy_contacts_LogMessage(noteType, noteMessage, macroName);
	            %local _type i countwords;

	            %if %str("&notetype") = %str("i") %then %do;
	                %put ;
	                %let _type = INFO;
	            %end;
	            %else %if %str("&notetype") = %str("n") %then %do;
	                %let _type = %str(NOTE);
	            %end;
	            %else %if %str("&notetype") = %str("e") %then %do;
	                %put ;
	                %let _type = %str(ERR)OR;
	                %let GMPXLERR = 1;
	            %end;
	            %else %if %str("&notetype") = %str("w") %then %do;
	                %put ;
	                %let _type = %str(WAR)NING;
	            %end;

	            %if %str("&notetype") ne %str("n") %then %do; 
	                %* HEADER LINE;
	                %put &_type.:[PXL]%sysfunc(repeat(%str(-),79));
	            %end;
	            
	            %* BODY;
	            %let countwords = %eval(%sysfunc(countc(%str(&noteMessage),%str(@)))+1);
	            
	            %if %eval(&countwords>0) %then %do;
	                %do i=1 %to &countwords;
	                    %put &_type.:[PXL] &macroName: %scan(&noteMessage,&i,"@");
	                %end;
	            %end;
	            %else %do;
	                %put &_type.:[PXL] &macroName: &noteMessage;
	            %end;
	            
	            %if %str("&notetype") ne %str("n") %then %do; 
	                * FOOTER LINE;
	                %put &_type.:[PXL]%sysfunc(repeat(%str(-),79));
	                %put;                   
	            %end;
	        %mend pfestudy_contacts_LogMessage; 

	%* Process Macros;
		%macro pfestudy_contacts_Initialize;
			%pfestudy_contacts_LogMessage(i, Start of Macro, pfestudy_contacts->pfestudy_contacts_Initialize);

		    %* pfestudy_contacts_Initialize Macro Variables;
		    	%local
		    		SMARTSVN_Version
		    		MacroLocation
		    		MacroLastChangeDateTime
		    		MacroRunDate
		    		MacroRUnDateTime
		    	;

		    	%let SMARTSVN_Version = ;
		        data _null_;
		            %* Derive from SMARTSVN updated string as revision number;
		            VALUE = "$Rev: 2522 $";
		            VALUE = compress(VALUE,'$Rev: ');
		            call symput('SMARTSVN_Version', VALUE);
		        run;
		      	%let MacroLocation = ; %* Derive from SMARTSVN updated string below;
		      	data _null_;
		  		    VALUE = "$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfestudy_contacts.sas $";
		              %* Replace Smart SVN Repository name with actual UNIX path used;
		              VALUE = tranwrd(VALUE,'HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/', '/opt/pxlcommon/stats/');
		              VALUE = compress(VALUE,'$');
		              call symput('MacroLocation', VALUE);
		  	    run;
		      	%let MacroLastChangeDateTime = %substr("$LastChangedDate: 2016-08-19 11:04:40 -0400 (Fri, 19 Aug 2016) $", 20, 26); %* Derived from SMARTSVN string;
		      	%let MacroRunDate = %sysfunc(left(%sysfunc(date(), yymmddn8.)));
		      	%let MacroRUnDateTime = %sysfunc(left(%sysfunc(datetime(), IS8601DT.)));

		    %put NOTE:[PXL] -------------------------------------------------------------------------------------------;
		    %put NOTE:[PXL] Name                     : PFESTUDY_CONTACTS;
            %put NOTE:[PXL] Version                  : &MacroVersion;
            %put NOTE:[PXL] SMARTSVN Revision        : &SMARTSVN_Version;
            %put NOTE:[PXL] SMARTSVN Last Update Date: &MacroLastChangeDateTime;
            %put NOTE:[PXL] Run By                   : %upcase(&sysuserid);
            %put NOTE:[PXL] Run Date                 : &MacroRUnDateTime;
            %put NOTE:[PXL] Macro Location           : &MacroLocation;
            %put NOTE:[PXL] ;
            %put NOTE:[PXL] Purpose: Read study_contacts.csv and derive emails lists to macro varaibles;
            %put NOTE:[PXL] Input Parameters:;
            %put NOTE:[PXL]    In_PXL_Code = &In_PXL_Code;
            %put NOTE:[PXL]    In_Path_Study_Contacts = &In_Path_Study_Contacts;
            %put NOTE:[PXL]    Out_MV_Emails_CDBP = &Out_MV_Emails_CDBP;
            %put NOTE:[PXL]    Out_MV_Emails_Stat = &Out_MV_Emails_Stat;
            %put NOTE:[PXL]    Out_MV_Emails_PCDA = &Out_MV_Emails_PCDA;            
		    %put NOTE:[PXL] -------------------------------------------------------------------------------------------;

			%pfestudy_contacts_LogMessage(i, End of Macro, pfestudy_contacts->pfestudy_contacts_Initialize);
		%mend pfestudy_contacts_Initialize;

		%macro pfestudy_contacts_CheckInput;
			%pfestudy_contacts_LogMessage(i, Start of Macro, pfestudy_contacts->pfestudy_contacts_CheckInput);

			%local EXISTS;

			%* Verify Global Macro Variable GMPXLERR;
	            proc sql noprint;
	                select count(*) into: EXISTS
	                from sashelp.vmacro
	                where upcase(scope) = "GLOBAL" and upcase(name) = "GMPXLERR";
	            quit;          
	            %if &EXISTS = 1 %then %do;
	            	%if %eval(&GMPXLERR ne 0) %then %do;
	            		%* GMPXLERR must be 0 or break out of macro;
						%pfestudy_contacts_LogMessage(e, %str(Global Macro Variable GMPXLERR ne 0:GMPXLERR= &GMPXLERR), 
							pfestudy_contacts->pfestudy_contacts_CheckInput);
						%goto macerr;
	            	%end;
	            %end;
	            %else %global GMPXLERR; %let GMPXLERR = 0;

	        %* Verify Global Macro Variable DEBUG;
                proc sql noprint;
                    select count(*) into: EXISTS
                    from sashelp.vmacro
                    where upcase(scope) = "GLOBAL" and upcase(name) = "DEBUG";
                quit;
	            %if &EXISTS = 1 %then %do;
                    %if %eval(&DEBUG = 0) %then %do;
                        OPTION NOMPRINT NOMLOGIC NOSYMBOLGEN NOFMTERR SOURCE NOTES;
                    %end;
                    %else %if %eval(&DEBUG = 1) %then %do;
                        OPTION MPRINT MLOGIC SYMBOLGEN SOURCE NOTES;
                    %end;
                    %else %do;
	            		%* DEBUG must be 0 or 1;
						%pfestudy_contacts_LogMessage(e, %str(Global Macro Variable DEBUG ne 0 or 1:DEBUG= &DEBUG),
							pfestudy_contacts->pfestudy_contacts_CheckInput);
						%goto macerr;
	            	%end;
	            %end;
	            %else %global DEBUG; %let DEBUG = 0;

	        %* Verify Input Parameters In_PXL_Code and In_Path_Study_Contacts
	            1) In_PXL_Code must always be given
                2) In_Path_Study_Contacts is either given or derived
                3) Verify study_contacts.csv found in expected location;
				%if "&In_Path_Study_Contacts" = "null" %then %do;
					%let In_Path_Study_Contacts = /projects/pfizr%left(%trim(&In_PXL_Code))/macros;
				%end;
				
				%if %sysfunc(fileexist(&In_Path_Study_Contacts/study_contacts.csv)) = 0 %then %do;
					%* Expected file study_contacts.csv not found;
					%pfestudy_contacts_LogMessage(e, 
						Input Parameter In_Path_Study_Contacts does not exist:
						@In_Path_Study_Contacts= &In_Path_Study_Contacts/study_contacts.csv, 
						pfestudy_contacts->pfestudy_contacts_CheckInput);				
					%goto macerr;
				%end;

			%* Verify Output Macro Variables or Create as global macro output;
				%macro _ckmv(mvn=, dmv=);
					%if "&&&mvn" = "null" 
					    or "&&&mvn" = "" %then %do;
					    %* Default to created output global macro variable;
					    %let &mvn = &dmv;
						%global &dmv;
						%let &dmv = ;
						%pfestudy_contacts_LogMessage(n, &mvn set to Global &dmv, pfestudy_contacts->pfestudy_contacts_CheckInput);	
					%end;
					%else %do;
						%* Given a macro variable to populate;
		                proc sql noprint;
		                    select count(*) into: EXISTS
		                    from sashelp.vmacro
		                    where upcase(name) = "%upcase(&&&mvn)";
		                quit;
		            	%if &EXISTS = 0 %then %do;
		            		%* If user sets input parameter Out_MV_Emails_CDBP then they are required to have 
		            		   initiated the macro variable already;
							%pfestudy_contacts_LogMessage(e, Input Parameter &mvn does specify
								@an existing macro variable:
								@&mvn= &&&mvn, pfestudy_contacts->pfestudy_contacts_CheckInput);	
								%let GMPXLERR = 1;
		            	%end;
		           	%end;					
				%mend _ckmv;
				%_ckmv(mvn=Out_MV_Emails_CDBP, dmv=Emails_CDBP); %if &GMPXLERR = 1 %then %goto macerr;
				%_ckmv(mvn=Out_MV_Emails_Stat, dmv=Emails_Stat); %if &GMPXLERR = 1 %then %goto macerr;
				%_ckmv(mvn=Out_MV_Emails_PCDA, dmv=Emails_PCDA); %if &GMPXLERR = 1 %then %goto macerr;


			%goto macend;
	        %macerr:; 
	        	%let GMPXLERR = 1; 
	        	%pfestudy_contacts_LogMessage(e, Abnormal end to program. Review Log., pfestudy_contacts->pfestudy_contacts_CheckInput);
	        %macend:; 
	        	%pfestudy_contacts_LogMessage(i, End of Macro, pfestudy_contacts->pfestudy_contacts_CheckInput);
		%mend pfestudy_contacts_CheckInput;

		%macro pfestudy_contacts_CreateOutput;
			%pfestudy_contacts_LogMessage(i, Start of Macro, pfestudy_contacts->pfestudy_contacts_CreateOutput);

 		    %* Get study team email contacts from metadata file;
            proc import datafile="&In_Path_Study_Contacts/study_contacts.csv"
                out=study_emails
                dbms=csv
                replace;
                getnames=no;
            run;

          	%* Check for successiful load of emails;
            %if NOT %sysfunc(exist(study_emails)) %then %do;
                %pfestudy_contacts_LogMessage(e, 
                    %str(Error reading study_contacts.csv from 
                    	@In_Path_Study_Contacts=&In_Path_Study_Contacts),
                    pfestudy_contacts->pfestudy_contacts_CreateOutput);
                %goto macerr;		                    	
            %end;

            %* study_contacts should have emails entered as:
            	na@parexel.com - n/a so do not use
              	tbd@parexel.com - to be determined so do not use
              	me@parexel.com - one email
              	or use a semi colon to seperate for more 2+ emails;
              	%macro _getEmails(cat=, mv=);
	                data _null_;
	                    length emails var3 $1500.;
	                    retain emails;
	                    set study_emails end=eof;

	                    if VAR1 = "&cat" and not missing(VAR3) then do;
	                        if VAR3 = "na@parexel.com" or VAR3 = "tbd@parexel.com" then delete;
	                        VAR3 = tranwrd(VAR3, ';', "' '"); * Handle muiltiple email addresse;
	                        VAR3 = compress(VAR3,' ');
	                        VAR3 = left(trim(VAR3));
	                        emails = left(trim(emails));
	                        emails = catx(" ", emails, "'", VAR3, "'");
	                        emails = left(trim(emails));
	                    end;

	                    if eof then do;
	                        if not missing(emails) then do;
	                            emails = compress(emails);
	                            emails = tranwrd(emails, "''", "' '");
	                            call symput("&&&mv", emails);
	                        end;
	                    end;       		
	                run;
              	%mend _getEmails;              	
              	%_getEmails(cat=CDBPSAS, mv=Out_MV_Emails_CDBP);
              	%_getEmails(cat=STATPROG, mv=Out_MV_Emails_Stat);
              	%_getEmails(cat=PCDA, mv=Out_MV_Emails_PCDA);

              	%let &Out_MV_Emails_CDBP = %left(%trim(&&&Out_MV_Emails_CDBP));
              	%let &Out_MV_Emails_Stat = %left(%trim(&&&Out_MV_Emails_Stat));
              	%let &Out_MV_Emails_PCDA = %left(%trim(&&&Out_MV_Emails_PCDA));

				%if "%left(%trim(&&&Out_MV_Emails_CDBP))" = "" %then %do;
					%pfestudy_contacts_LogMessage(e,
						study_contacts.csv does not contain emails for CDBPSAS
						@CDBPSAS PRIM and BCKUP are required to be present
						@In_Path_Study_Contacts= &In_Path_Study_Contacts,
						pfestudy_contacts->pfestudy_contacts_CreateOutput);
				%end; 

				%if "%left(%trim(&&&Out_MV_Emails_Stat))" = "" %then %do;
					%pfestudy_contacts_LogMessage(n, 
						study_contacts.csv does not contain emails for STATPROG, 
						pfestudy_contacts->pfestudy_contacts_CreateOutput);	 
				%end; 

				%if "%left(%trim(&&&Out_MV_Emails_PCDA))" = "" %then %do;
					%pfestudy_contacts_LogMessage(n, 
						study_contacts.csv does not contain emails for PCDA, 
						pfestudy_contacts->pfestudy_contacts_CreateOutput);	 
				%end; 												
			%goto macend;
	        %macerr:; 
	        	%let GMPXLERR = 1; 
	        	%pfestudy_contacts_LogMessage(e, Abnormal end to program. Review Log., pfestudy_contacts->pfestudy_contacts_CreateOutput);
	        %macend:; 
	        	%pfestudy_contacts_LogMessage(i, End of Macro, pfestudy_contacts->pfestudy_contacts_CreateOutput);
		%mend pfestudy_contacts_CreateOutput;

		%macro pfestudy_contacts_CleanUp;
			%pfestudy_contacts_LogMessage(i, Start of Macro, pfestudy_contacts->pfestudy_contacts_CleanUp);

          	%* Macro End Setup Reset;
				title;
				footnote;
				OPTIONS fmterr quotelenmax; * Reset Ignore format notes in log;
				options printerpath='';

			%* Remove work datasets;
				%macro _rm_wds(dsn=null);
					proc sql noprint;
						select count(*) into: exists
						from sashelp.vtable 
						where libname='WORK' and memname="&dsn";

  				        %if &exists > 0 %then %do;
  				        	drop table &dsn;
  				        %end;						
					quit;
				%mend _rm_wds;
				%_rm_wds(dsn=STUDY_EMAILS);

			%* Macro End Remove Catalogs Created;
				%macro delcat(catn=null);
					proc sql noprint;
						select count(*) into: exists
						from sashelp.vcatalg
						where libname = "WORK"
						and memname = "%upcase(&catn)";
					quit;
					%if %eval(&exists > 0) %then %do;
						proc catalog catalog=&catn kill; run; quit;
					%end;            
				%mend delcat;
				%delcat(catn=PARMS); %* Unknown how PARMS is created but should be removed if it is;

				%pfestudy_contacts_LogMessage(i, End of Macro, pfestudy_contacts->pfestudy_contacts_CleanUp);
		%mend pfestudy_contacts_CleanUp;

	%* Process;
		%pfestudy_contacts_LogMessage(i, Start of Macro, pfestudy_contacts);

		%pfestudy_contacts_Initialize;
		%pfestudy_contacts_CheckInput; %if &GMPXLERR = 1 %then %goto macerr;
		%pfestudy_contacts_CreateOutput; %if &GMPXLERR = 1 %then %goto macerr;

	    %put NOTE:[PXL] -------------------------------------------------------------------------------------------;
	    %put NOTE:[PXL] Name: PFESTUDY_CONTACTS;
        %put NOTE:[PXL] Source File = &In_Path_Study_Contacts/study_contacts.csv;
        %put NOTE:[PXL] ;        
        %put NOTE:[PXL] Macro Variable Output:;        
        %put NOTE:[PXL]    &Out_MV_Emails_CDBP = &&&Out_MV_Emails_CDBP;
        %put NOTE:[PXL]    &Out_MV_Emails_Stat = &&&Out_MV_Emails_Stat;
        %put NOTE:[PXL]    &Out_MV_Emails_PCDA = &&&Out_MV_Emails_PCDA;            
	    %put NOTE:[PXL] -------------------------------------------------------------------------------------------;		

        %goto macend;
        %macerr:;
            %pfestudy_contacts_LogMessage(e, Abnormal end to program. Review Log., pfestudy_contacts);
        %macend:;
            %pfestudy_contacts_CleanUp;
            %pfestudy_contacts_LogMessage(i, End of Macro, pfestudy_contacts);

%mend pfestudy_contacts;