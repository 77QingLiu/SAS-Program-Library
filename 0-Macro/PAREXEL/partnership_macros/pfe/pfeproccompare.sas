  /*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
  
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
  
  SAS Version:           9.2 and above
  Operating System:      UNIX
  
  -------------------------------------------------------------------------------
   
  Author:                Nathan Hartley $LastChangedBy: hartlen $
  Creation Date:         20150821       $LastChangedDate: 2016-07-01 15:15:39 -0400 (Fri, 01 Jul 2016) $
  
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfeproccompare.sas $
  
  Files Created:         Listings describing differences if found and details used for the proc compare PDF and XLS

  Program Purpose:       Compare two SAS libraries for all datasets against structure and value differences

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.

                         This macro has not been validated for use only in PAREXEL's
                         working environment yet.
  
  Macro Parameters:
  
    Name:                pfeproccompare_pxl_code
      Allowed Values:    PAREXEL study number or leave blank
      Default Value:     null
      Description:       PAREXEL study number or will try to get the value from global macro PXL_CODE
  
    Name:                pfeproccompare_protocol
      Allowed Values:    Pfizer protocol number or leave blank
      Default Value:     null
      Description:       Pfizer protocol number or will try to get the value from global macro PROTOCOL
  
    Name:                pfeproccompare_lib_pri
      Allowed Values:    Valid SAS library
      Default Value:     null
      Description:       SAS library used to for proc compare
  
    Name:                pfeproccompare_lib_qc
      Allowed Values:    Valid SAS library
      Default Value:     null
      Description:       SAS library used to for proc compare
  
    Name:                pfeproccompare_path_listings
      Allowed Values:    Valid UNIX directory path
      Default Value:     null
      Description:       Location to save created listing
  
    Name:                pfeproccompare_addDateTime
      Allowed Values:    Y|N
      Default Value:     N
      Description:       If Y then will add date and time to listing output file name
 
    Name:                pfeproccompare_forceSort
      Allowed Values:    Y|N
      Default Value:     N
      Description:       If Y then will force sort before proc compare by _all_

  Global Macrovariables:
 
    Name:                pfeproccompare_PassOrFail
      Usage:             Creates
      Description:       Sets to PASS or FAIL depnding on Macro proc compare outcome
 
    Name:                pfeproccompare_NumIssuesAttrib
      Usage:             Creates
      Description:       Sets to number of issues or differences in structure/SAS attributes found
 
    Name:                pfeproccompare_NumIssuesValues
      Usage:             Creates
      Description:       Sets to number of issues or differences in values found

    Name:                pfeproccompare_ListingName
      Usage:             Creates
      Description:       Sets to name of output listing created (root of pdf/xls)

  -------------------------------------------------------------------------------
  MODIFICATION HISTORY: Subversion $Rev: 2380 $
  -----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
	Version | Date     | Author         | Modifications
	1.0     | 20150821 | Nathan Hartley | Initial Version
	2.0     | 20160701 | Nathan Hartley | *See below
		1) Set to output pri and qc on same line for attribute difference to easier see the change
		2) Added title2 and title3 to hold primary and compare/qc paths to excel output
		3) Modified DIFF value see added/dropped variables/attrib diff easier
		4) Added sort by _all_ around proc compare for added input parm pfeproccompare_forceSort=Y
		5) Modified tagsets.excelxp output to highlight in red
  
  -----------------------------------------------------------------------------*/

%macro pfeproccompare(
	pfeproccompare_pxl_code=null,
	pfeproccompare_protocol=null,
	pfeproccompare_lib_pri=null,
	pfeproccompare_lib_qc=null,
	pfeproccompare_path_listings=null,
	pfeproccompare_addDateTime=N,
	pfeproccompare_forceSort=N);

	%put NOTE:[PXL] ***********************************************************************;
	%put NOTE:[PXL] Macro Startup;
	%put NOTE:[PXL] ***********************************************************************;
		OPTIONS nofmterr; * Ignore format notes in log;
		title;
    	footnote;

		* Macro Variable Declarations;
			%let pfeproccompare_MacroName        = PFEPROCCOMPARE;
			%let pfeproccompare_MacroVersion     = 2.0;
			%let pfeproccompare_MacroVersionDate = 20160701;
			%*let pfeproccompare_MacroPath        = /opt/pxlcommon/stats/macros/unittesting/testing_area/macros/partnership_macros/pfe;
			%let pfeproccompare_MacroPath        = /opt/pxlcommon/stats/macros/macros/partnership_macros/pfe;
			%let pfeproccompare_RunDateTime      = %sysfunc(compress(%sysfunc(left(%sysfunc(datetime(), IS8601DT.))), '-:'));

			* Global return macros;
			%global pfeproccompare_PassOrFail pfeproccompare_NumIssuesAttrib pfeproccompare_NumIssuesValues pfeproccompare_ListingName;
			%let pfeproccompare_PassOrFail = FAIL; * PASS or FAIL;
			%let pfeproccompare_NumIssuesAttrib = null; * Number of issues found in SAS attributes;	
			%let pfeproccompare_NumIssuesValues = null; * Number of issues found in Values;
			%let pfeproccompare_ListingName = null; * Listing path and file name for pdf and xls;

			* Local Variables;
			%let pfeprocompare_pathpri = null;
			%let pfeprocompare_pathqc = null;

			* Log output input parameters;
			%put INFO:[PXL]----------------------------------------------;
			%put INFO:[PXL] &pfeproccompare_MacroName: Macro Started; 
    		%put INFO:[PXL] File Location: &pfeproccompare_MacroPath ;
    		%put INFO:[PXL] Version Number: &pfeproccompare_MacroVersion ;
    		%put INFO:[PXL] Version Date: &pfeproccompare_MacroVersionDate ;
			%put INFO:[PXL] Run DateTime: &pfeproccompare_RunDateTime;    		
    		%put INFO:[PXL] ;
    		%put INFO:[PXL] Purpose: Compare two SAS libraries for all datasets against structure and value differences ; 			
			%put INFO:[PXL] Input Parameters:;
			%put INFO:[PXL]		1) pfeproccompare_pxl_code = &pfeproccompare_pxl_code;
			%put INFO:[PXL]		2) pfeproccompare_protocol = &pfeproccompare_protocol;
			%put INFO:[PXL]		3) pfeproccompare_lib_pri = &pfeproccompare_lib_pri;
			%put INFO:[PXL]		4) pfeproccompare_lib_qc = &pfeproccompare_lib_qc;
			%put INFO:[PXL]		5) pfeproccompare_path_listings = &pfeproccompare_path_listings;
			%put INFO:[PXL]----------------------------------------------;			

	    * Global MAD macro DEBUG (option statement);
	        proc sql noprint;
	            select count(*) into: _DEBUG_Exist
	            from sashelp.vmacro
	            where scope='GLOBAL'
	                  and name='DEBUG';
	        quit;
	        %if &_DEBUG_Exist = 0 %then %do;
	            * MAD macro DEBUG does not exist, create and set to 0;
	            %global DEBUG;
	            %let DEBUG=0;
	        %end;
	        %else %do;
	            %if &DEBUG=0 %then %do;
	                OPTION NOMPRINT NOMLOGIC NOSYMBOLGEN;
	                %* OPTION NOMPRINT NOMLOGIC NOSYMBOLGEN NOSOURCE NONOTES;
	            %end;
	            %else %do;
	                OPTION MPRINT MLOGIC SYMBOLGEN SOURCE NOTES;
	            %end;
	        %end;

	    * Global MAD macro GMPXLERR (unsucessiful execution flag);
	        proc sql noprint;
	            select count(*) into: _GMPXLERR_Exist
	            from sashelp.vmacro
	            where scope='GLOBAL'
	                  and name='GMPXLERR';
	        quit;
	        %if &_GMPXLERR_Exist = 0 %then %do;
	            * MAD macro GMPXLERR does not exist, create and set to 0;
	            %global GMPXLERR;
	            %let GMPXLERR=0;
	        %end;
	        %else %if &GMPXLERR = 1 %then %do;
	            * Parent macro execution unsuccessful, goto end;
	            %put %str(ERR)OR:[PXL] &pfeproccompare_MacroName: Global macro GMPXLERR = 1, macro not executed;
	            %goto MacErr;
	        %end;

	%put NOTE:[PXL] ***********************************************************************;
	%put NOTE:[PXL] Verify and Set Parameters;
	%put NOTE:[PXL] ***********************************************************************;

		* pfeproccompare_pxl_code;
			%if %str("&pfeproccompare_pxl_code") = %str("null") %then %do;
				* If not set, use global macro pxl_code if exists;
				proc sql noprint;
					select count(*) into: cnt
					from sashelp.vmacro
					where scope = "GLOBAL"
					      and name = "PXL_CODE";
				quit;
				%if %eval(&cnt = 0) %then %do;
					* Global macro not found, exit macro;
					%put %str(ERR)OR:[PXL] &pfeproccompare_MacroName: Input Parameter pfeproccompare_pxl_code is null and global macro pxl_code not found;
	            	%goto MacErr;					
				%end;
				%else %do;
					* Global macro found, use it;
					%let pfeproccompare_pxl_code = &pxl_code;
				%end;
			%end;
			%put NOTE:[PXL] pfeproccompare_pxl_code = &pfeproccompare_pxl_code;

		* pfeproccompare_protocol;
			%if %str("&pfeproccompare_protocol") = %str("null") %then %do;
				* If not set, use global macro protocol if exists;
				proc sql noprint;
					select count(*) into: cnt
					from sashelp.vmacro
					where scope = "GLOBAL"
					      and name = "PROTOCOL";
				quit;
				%if %eval(&cnt = 0) %then %do;
					* Global macro not found, exit macro;
					%put %str(ERR)OR:[PXL] &pfeproccompare_MacroName: Input Parameter pfeproccompare_protocol is null and global macro protocol not found;
	            	%goto MacErr;					
				%end;
				%else %do;
					* Global macro found, use it;
					%let pfeproccompare_protocol = &pxl_code;
				%end;
			%end;
			%put NOTE:[PXL] pfeproccompare_protocol = &pfeproccompare_protocol;	

		* pfeproccompare_lib_pri;
			proc sql noprint;
				select count(*) into: cnt
				from sashelp.vslib
				where libname = "%upcase(&pfeproccompare_lib_pri)";
			quit;
			%if %eval(&cnt = 0) %then %do;
				%put %str(ERR)OR:[PXL] &pfeproccompare_MacroName: Input Parameter pfeproccompare_lib_pri is not a valid SAS library: &pfeproccompare_lib_pri;
	            %goto MacErr;
			%end;
			%else %do;
				proc sql noprint;
					select path into: pfeprocompare_pathpri
					from sashelp.vslib
					where libname = "%upcase(&pfeproccompare_lib_pri)"; 
				quit;
			%end;

			%put NOTE:[PXL] pfeproccompare_lib_pri = %left(%trim(&pfeproccompare_lib_pri));
			%put NOTE:[PXL] pfeprocompare_pathpri = &pfeprocompare_pathpri;

		* pfeproccompare_lib_qc;
			proc sql noprint;
				select count(*) into: cnt
				from sashelp.vslib
				where libname = "%upcase(&pfeproccompare_lib_qc)";
			quit;
			%if %eval(&cnt = 0) %then %do;
				%put %str(ERR)OR:[PXL] &pfeproccompare_MacroName: Input Parameter pfeproccompare_lib_qc is not a valid SAS library: &pfeproccompare_lib_qc;
	            %goto MacErr;
			%end;
			%else %do;
				proc sql noprint;
					select path into: pfeprocompare_pathqc
					from sashelp.vslib
					where libname = "%upcase(&pfeproccompare_lib_qc)"; 
				quit;
			%end;			

			%put NOTE:[PXL] pfeproccompare_lib_qc = %left(%trim(&pfeproccompare_lib_qc));
			%put NOTE:[PXL] pfeprocompare_pathqc = &pfeprocompare_pathqc;

		* pfeproccompare_path_listings;
			%if not %sysfunc(fileexist(&pfeproccompare_path_listings)) %then %do;
				%put %str(ERR)OR:[PXL] &pfeproccompare_MacroName: Input Parameter pfeproccompare_path_listings is not a valid directory: &pfeproccompare_path_listings;
	            %goto MacErr;			
			%end;

			%put NOTE:[PXL] pfeproccompare_path_listings = &pfeproccompare_path_listings;

		* pfeproccompare_addDateTime;
			%if %str("&pfeproccompare_addDateTime") ne %stR("Y")
			    and %str("&pfeproccompare_addDateTime") ne %stR("N") %then %do;

				%put %str(ERR)OR:[PXL] &pfeproccompare_MacroName: Input Parameter pfeproccompare_addDateTime is not Y or N: &pfeproccompare_addDateTime;
	            %goto MacErr;
			%end;

		%if %str("&pfeproccompare_addDateTime") = %str("Y") %then %do;
			%let pfeproccompare_ListingName = %left(%trim(%left(%trim(&pfeproccompare_path_listings))/%left(%trim(&pfeproccompare_pxl_code)) %left(%trim(&pfeproccompare_protocol)) Proc Compare Listing %left(%trim(&pfeproccompare_RunDateTime))));
		%end;
		%else %do;
			%let pfeproccompare_ListingName = %left(%trim(%left(%trim(&pfeproccompare_path_listings))/%left(%trim(&pfeproccompare_pxl_code)) %left(%trim(&pfeproccompare_protocol)) Proc Compare Listing));
		%end;

	%put NOTE:[PXL] ***********************************************************************;
	%put NOTE:[PXL] Setup Overview for Listing Output;
	%put NOTE:[PXL] ***********************************************************************;

		proc sql noprint;
			create table dataset_info as
			select
				coalescec(a.memname, b.memname) as memname,
				'***FAILED***' as OverAllPassFail,
				coalescec(a.memlabel, b.memlabel) as memlabel,
				coalesce(a.crdate, b.crdate) as crdate format=DATETIME20.,
				coalesce(a.nobs, b.nobs) as nobs,
				coalesce(a.nvar, b.nvar) as nvar
			from 
				(select * from sashelp.vtable where libname = "%upcase(&pfeproccompare_lib_pri)") as a 
				full outer join
				(select * from sashelp.vtable where libname = "%upcase(&pfeproccompare_lib_qc)") as b
			on 
				a.memname  = b.memname
			order by memname;
		quit;

	%put NOTE:[PXL] ***********************************************************************;
	%put NOTE:[PXL] Check SAS Attributes Match;
	%put NOTE:[PXL] ***********************************************************************;

		* QC dataset not found in PRIMARY;
            proc sql noprint;
                create table qc_only_datasets as
                select 
                    a.memname,
                    'QC dataset not found in PRIMARY' as diff
                from 
                	(select memname from sashelp.vstable where libname = "%upcase(&pfeproccompare_lib_qc)") as a
                    left join
                    (select memname from sashelp.vstable where libname = "%upcase(&pfeproccompare_lib_pri)") as b 
                on 
                	a.memname = b.memname
                where 
                	b.memname is null
                order by b.memname;
            quit;

        * PRIMARY dataset not found in QC;
            proc sql noprint;
                create table pri_only_datasets as
                select 
                    a.memname,
                    'PRIMARY dataset not found in QC' as diff
                from 
                	(select memname from sashelp.vstable where libname = "%upcase(&pfeproccompare_lib_pri)") as a
                    left join
                    (select memname from sashelp.vstable where libname = "%upcase(&pfeproccompare_lib_qc)") as b 
                on 
                	a.memname = b.memname
                where 
                	b.memname is null
                order by a.memname;
            quit;			

        * SAS Attribute Differences;
			proc sql noprint;
				create table _e3_1 as
				select 'PRIMARY record not found in QC' as diff, memname, name, type, length, label, format, informat
				from sashelp.vcolumn
				where libname="%upcase(&pfeproccompare_lib_pri)";

				create table _e3_2 as
				select 'QC record not found in PRIMARY' as diff, memname, name, type, length, label, format, informat
				from sashelp.vcolumn
				where libname="%upcase(&pfeproccompare_lib_qc)";

				%* Merge pri and qc by dataset and variables;
				create table _e3_3 as
				select 
					coalescec(a.diff, b.diff) as diff,
					coalescec(a.memname, b.memname) as memname,
					coalescec(a.name, b.name) as name,
					a.type as pri_type,
					b.type as qc_type,
					a.length as pri_length,
					b.length as qc_length,
					a.label as pri_label,
					b.label as qc_label,
					a.format as pri_format,
					b.format as qc_format,
					a.informat as pri_informat,
					b.informat as qc_informat
				from _e3_1 as a full outer join _e3_2 as b 
				on 
					a.memname = b.memname
					and a.name = b.name
				order by 2, 3;

				%* Remove 'QC dataset not found in PRIMARY' dataset variables;
				create table _e3_4 as 
				select a.*
				from _e3_3 as a full outer join qc_only_datasets as b 
				on a.memname = b.memname 
				where b.memname is null;

				%* Remove 'PRIMARY dataset not found in QC' dataset variables;
				create table e3 as
				select a.*
				from _e3_4 as a full outer join pri_only_datasets as b 
				on a.memname = b.memname 
				where b.memname is null;
			quit;

			%* Derive difference in variable or attributes;
			data e3;
				set e3;

				%* PRIMARY variable not found in QC;
				if not missing(pri_type) and missing(qc_type) then 
					diff = "PRIMARY variable not found in QC";

				%* QC variable not found in PRIMARY;
				else if missing(pri_type) and not missing(qc_type) then 
					diff = "QC variable not found in PRIMARY";

				%* Attribute Differences;
				else if 
					 pri_type ne qc_type
					 or pri_length ne qc_length
					 or pri_label ne qc_label
					 or pri_format ne qc_format
					 or pri_informat ne qc_informat then 

					diff = "Attribute Differences";

				%* Match on everything then delete;
				else 
					delete;
			run;

		* Create final dataset;
			data IssuesAttrib;
				attrib 
					diff length=$200 label='Difference'
					memname length=$200 label='Dataset'
					name label='Variable'

					pri_type label='PRI Type'
					qc_type label='QC Type'

					pri_length label='PRI Length'
					qc_length label='QC Length'

					pri_format label='PRI Format'
					qc_format label='QC Format'

					pri_informat label='PRI Informat'
					qc_informat label='QC Informat'

					pri_label label='PRI Label'
					qc_label label='QC Label';
			set pri_only_datasets qc_only_datasets e3;
			run;

			proc sort data=IssuesAttrib; by memname name diff; run;	

			proc sql noprint;
				select count(*) into: pfeproccompare_NumIssuesAttrib
				from IssuesAttrib;
			quit;

			%put NOTE:[PXL] pfeproccompare_NumIssuesAttrib = %left(%trim(&pfeproccompare_NumIssuesAttrib));

	%put NOTE:[PXL] ***********************************************************************;
	%put NOTE:[PXL] Setup Overview for Listing Output - Add Attribute Records;
	%put NOTE:[PXL] ***********************************************************************;
        proc sql noprint;
            create table dataset_info_final as
            select a.*, coalesce(b.TotalAttribIssues, 0) as TotalAttribIssues
            from 
              	dataset_info as a 
              	left join
              	( 
              		select memname, count(*) as TotalAttribIssues
                  	from IssuesAttrib
                  	group by memname) as b
            on a.memname = b.memname
            order by a.memname;
        quit;

	%put NOTE:[PXL] ***********************************************************************;
	%put NOTE:[PXL] Check SAS Values Match;
	%put NOTE:[PXL] ***********************************************************************;
	    %let pfeproccompare_NumIssuesValues = 0;		

      	* Create macro array of datasets to compare;
	      	proc sql noprint;
	          	create table _ds as
	          	select a.memname
	          	from 
	              	(select memname from sashelp.vstable where libname = "%upcase(&pfeproccompare_lib_pri)") as a
	              	inner join
	              	(select memname from sashelp.vstable where libname = "%upcase(&pfeproccompare_lib_qc)") as b 
	          	on a.memname = b.memname;   
	        
	          	select count(*) into :ds_total
	          	from _ds;

	          	select memname into :ds_1-:ds_%left(%trim(&ds_total))
	          	from _ds;
	      	quit;

	    * Cycle through each dataset and proc compare;
	      	%do i=1 %to &ds_total;
	      		%put NOTE:[PXL] Reviewing &&ds_&i;

	      		%if %str("&pfeproccompare_forceSort") = %str("Y") %then %do;
	      			%put NOTE:[PXL] Input Parameter pfeproccompare_forceSort = Y: Forcing sort by _all_ for compare;
	      			proc sort data=&pfeproccompare_lib_pri..&&ds_&i out=pri; by _all_; run;
	      			proc sort data=&pfeproccompare_lib_qc..&&ds_&i out=qc; by _all_; run;

	          		proc compare base=pri compare=qc
	          		out=result_&&ds_&i outnoequal outbase outcomp outdif noprint CRITERION=0.00000001;
	          		run;
	          	%end;
	          	%else %do;
	          		%put NOTE:[PXL] Input Parameter pfeproccompare_forceSort = N: Using sort as is for compare;
					proc compare base=&pfeproccompare_lib_pri..&&ds_&i compare=&pfeproccompare_lib_qc..&&ds_&i
	          		out=result_&&ds_&i outnoequal outbase outcomp outdif noprint CRITERION=0.00000001;
	          		run;
	          	%end;

	          	proc sql noprint;
	          		select nobs into :total_obs
	          		from sashelp.vtable
	          		where libname = "WORK"
	          		      and memname = "%upcase(result_&&ds_&i)";
	          	quit;
	          	%put NOTE:[PXL] total_obs = %left(%trim(&total_obs));

	          	%if %eval(&total_obs > 0) %then %do;
		          	proc sql noprint;
		              	select count(*) into :cnt
		              	from result_&&ds_&i
		              	where _TYPE_ = 'DIF';
		          	quit;
	          	%end;
	          	%else %do;
	          		%let cnt = 0;
	          	%end;
	          	%put NOTE:[PXL] cnt = %left(%trim(&cnt));

	          	* Append total value issues to each overview dataset;
	          	data dataset_info_final;
	          		label
	          			memname = "Dataset"
	          			OverAllPassFail = "Overall PASS or FAIL"
	          			TotalAttribIssues = "Total SAS Attribute Differences"
	          			TotalValueIssues = "Total Value Differences"
	          			memlabel = "Dataset Label"
	          			crdate = "Dataset Creation DateTime"
	          			nobs = "Number of Obserations"
	          			nvar = "Number of Variables"
	          		;
	          	set dataset_info_final;
	              	if memname = %str("&&ds_&i") then do;
	                 	TotalValueIssues = input(left(trim(symget('cnt'))), 8.);
	              	end;
	              	if missing(TotalValueIssues) then TotalValueIssues = 0;

	              	if TotalAttribIssues = 0 and TotalValueIssues = 0 then 
	              		OverAllPassFail = 'PASSED';
	              	else 
	              		OverAllPassFail = '***FAILED***';
	          	run;

	          	%let pfeproccompare_NumIssuesValues = %eval(&pfeproccompare_NumIssuesValues + &cnt);
	      	%end;

	%put NOTE:[PXL] ***********************************************************************;
	%put NOTE:[PXL] Derive Overall pfeproccompare_PassOrFail;
	%put NOTE:[PXL] ***********************************************************************;
		%put NOTE:[PXL] Total SAS Attribute Differences = %left(%trim(&pfeproccompare_NumIssuesAttrib));
		%put NOTE:[PXL] Total Matching Record but Value Differences = %left(%trim(&pfeproccompare_NumIssuesValues));

		%if %eval(&pfeproccompare_NumIssuesAttrib > 0) or %eval(&pfeproccompare_NumIssuesValues > 0) %then %do;
			%let pfeproccompare_PassOrFail = FAIL;
		%end;
		%else %do;
			%let pfeproccompare_PassOrFail = PASS;
		%end;
		%let pfeproccompare_ListingName = &pfeproccompare_ListingName - &pfeproccompare_PassOrFail;

		%put NOTE:[PXL] Overall Proc Compare PASS/FAIL: &pfeproccompare_PassOrFail;

	%put NOTE:[PXL] ***********************************************************************;
	%put NOTE:[PXL] Output PDF Listing;
	%put NOTE:[PXL] ***********************************************************************;

		ods listing close;
		ods pdf file="%left(%trim(&pfeproccompare_ListingName..pdf))" /* bookmarkgen=no bookmarklist=none */;

		ods pdf anchor = 'Overview' startpage=now;
		options missing='';
		ods proclabel "Overview";
		title "&pfeproccompare_pxl_code &pfeproccompare_protocol Proc Compare Listing";
		data _null_;
			file print ps=73 ls=172 notitles;
			put "Purpose:";
			put "Compare primary datasets to quality control datasets and list any differences found.";
			put ;
			put "---------------------------------------------------------------------------------------";
			put "Run By: %upcase(&sysuserid)";
			put "Run On: &pfeproccompare_RunDateTime";
			put ;
			put "Run Macro Name: &pfeproccompare_MacroName";
			put "Run Macro Version: &pfeproccompare_MacroVersion";
			put "Run Macro Version Date: &pfeproccompare_MacroVersionDate";
			put "Run Macro Location: &pfeproccompare_MacroPath";
			put ;
			put "---------------------------------------------------------------------------------------";
			put "PAREXEL Study Code: &pfeproccompare_pxl_code";
			put "PROTOCOL: &pfeproccompare_protocol";
			put "Primary Dataset Path: %left(%trim(&pfeprocompare_pathpri))";
			put "QC Dataset Path: %left(%trim(&pfeprocompare_pathqc))";
			put ;
			put "Overall Comparison PASSED/FAILED: &pfeproccompare_PassOrFail";
			put ;
			put "Total SAS Attribute Differences Found: %left(%trim(&pfeproccompare_NumIssuesAttrib))";
			put "Total Value Differences Found: %left(%trim(&pfeproccompare_NumIssuesValues))";
			put ;
			put "---------------------------------------------------------------------------------------";
			put "Issue details listed on next page";
			put ;
		run;

		ods proclabel "Proc Compare Dataset Overview";
		title "&pfeproccompare_pxl_code &pfeproccompare_protocol Proc Compare Dataset Overview";
		proc report data = dataset_info_final nowd; 
			column OBS memname OverAllPassFail TotalAttribIssues TotalValueIssues memlabel crdate nobs nvar; 
			define OBS / computed;
			compute OBS;
				DSOBS + 1;
				OBS = DSOBS;
			endcompute;
		run;

		ods proclabel "SAS Attribute Differences";
		%if %eval(&pfeproccompare_NumIssuesAttrib > 0) %then %do;
		title "&pfeproccompare_pxl_code &pfeproccompare_protocol Proc Compare Total of %left(%trim(&pfeproccompare_NumIssuesAttrib)) SAS Attribute Differences";
		proc report data = IssuesAttrib nowd; 
			column OBS diff memname name pri_type qc_type pri_length qc_length pri_format qc_format pri_informat qc_informat pri_label qc_label; 
			define OBS / computed;
			compute OBS;
				DSOBS + 1;
				OBS = DSOBS;
				endcompute;
			run;
		%end;

		options nolabel;
		%if %eval(&pfeproccompare_NumIssuesValues > 0) %then %do;
			%do i=1 %to &ds_total;

				proc sql noprint;
					select count(*) into :cnt
					from result_&&ds_&i
					where _TYPE_ = 'DIF';
				quit;

				%if %eval(&cnt > 0) %then %do;			
					ods proclabel "Value Differences &&ds_&i";
					title "&pfeproccompare_pxl_code &pfeproccompare_protocol Proc Compare &&ds_&i Total of %left(%trim(&cnt)) Value Differences (limited to display first 100 obs)";
					options nolabel;
					proc report data = result_&&ds_&i (firstobs=1 obs=100) nowd; 
					run;
				%end; %* End per domain issue check;
			%end; %* End do loop;
		%end; %* End any value issus check;
		options label;

		ods pdf close;
		ods listing; 

	%put NOTE:[PXL] ***********************************************************************;
	%put NOTE:[PXL] Output XLS Listing;
	%put NOTE:[PXL] ***********************************************************************;

		ods listing close;
		ods tagsets.excelxp file= "%left(%trim(&pfeproccompare_ListingName..xls))";

		ods tagsets.excelxp options (
		  	Orientation = "landscape"
		  	Embedded_Titles = "Yes"
		  	Row_Repeat = "Header"
		  	Autofit_Height = "Yes"
		  	Autofilter = "All"
		  	Frozen_Headers = "Yes"
		  	Gridlines = "Yes"
		  	Zoom = "80"
		  	Default_column_width= "10"
		  	frozen_headers = "5"
		  	row_repeat = "5");

		title1 justify=left "&pfeproccompare_pxl_code &pfeproccompare_protocol Proc Compare Dataset Overview";
		title2 justify=left "Primary Dataset Path: %left(%trim(&pfeprocompare_pathpri))";
		title3 justify=left "Compare/QC Dataset Path: %left(%trim(&pfeprocompare_pathqc))";

		ods tagsets.excelxp options ( sheet_name = "Dataset Overview" absolute_column_width= "5, 10, 15, 10, 10, 10, 20, 10, 10, 10");
		  	proc report data = dataset_info_final nowd; 
				column OBS memname OverAllPassFail TotalAttribIssues TotalValueIssues memlabel crdate nobs nvar; 
				define OBS / computed;

				compute OBS;
					DSOBS + 1;
					OBS = DSOBS;
				endcompute;

				compute nvar;
					if OverAllPassFail = '***FAILED***' then 
						call define(_ROW_,'style','style={background=lightred font_weight=bold}');
				endcompute;		      
		  	run;

		  %if %eval(&pfeproccompare_NumIssuesAttrib > 0) %then %do;
		      	ods tagsets.excelxp options ( sheet_name = "SAS Attribute Diff" absolute_column_width= "5, 20, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 25, 25");
		      	title1 justify=left "&pfeproccompare_pxl_code &pfeproccompare_protocol Proc Compare Total of %left(%trim(&pfeproccompare_NumIssuesAttrib)) SAS Attribute Differences";
		      	title2 justify=left "Primary Dataset Path: %left(%trim(&pfeprocompare_pathpri))";
				title3 justify=left "Compare/QC Dataset Path: %left(%trim(&pfeprocompare_pathqc))";
		      	proc report data = IssuesAttrib style(column)={tagattr='Format:Text'}; 
		          	column OBS diff memname name pri_type qc_type pri_length qc_length pri_format qc_format pri_informat qc_informat pri_label qc_label; 
		          	define OBS / computed; %* Have to define as computed if derived in compute block;
		          	define pri_length / display; %* Have to define numeric as display to use in compute blocks;
		          	define qc_length / display; %* Have to define numeric as display to use in compute blocks;

		          	compute OBS; %* Derive as record number;
		              	DSOBS + 1;
		              	OBS = DSOBS;
		          	endcompute;

		          	%* Set highlighting based on differences;
		          	compute qc_label;
		          		if diff in ('PRIMARY dataset not found in QC','QC dataset not found in PRIMARY') then do; 
		          			call define('memname','style','style={background=lightred font_weight=bold}');
		          		end;

		          		else if diff in ('PRIMARY variable not found in QC','QC variable not found in PRIMARY') then do;
		          			call define('memname','style','style={background=lightred font_weight=bold}');
		          			call define('name','style','style={background=lightred font_weight=bold}');
		          		end;

		          		else do;
			          		if pri_type ne qc_type then do;
			          			call define('pri_type','style','style={background=lightred font_weight=bold}');
			          			call define('qc_type','style','style={background=lightred font_weight=bold}');
			          		end;
			          		if pri_length ne qc_length then do;
			          			call define('pri_length','style','style={background=lightred font_weight=bold}');
			          			call define('qc_length','style','style={background=lightred font_weight=bold}');
			          		end;			          		
			          		if pri_format ne qc_format then do;
			          			call define('pri_format','style','style={background=lightred font_weight=bold}');
			          			call define('qc_format','style','style={background=lightred font_weight=bold}');
			          		end;
			          		if pri_informat ne qc_informat then do;
			          			call define('pri_informat','style','style={background=lightred font_weight=bold}');
			          			call define('qc_informat','style','style={background=lightred font_weight=bold}');
			          		end;
			          		if pri_label ne qc_label then do;
			          			call define('pri_label','style','style={background=lightred font_weight=bold}');
			          			call define('qc_label','style','style={background=lightred font_weight=bold}');
			          		end;			          					          		
		          		end;
		          	endcompute;
		      	run;
		  %end;

		  options nolabel;
		  %if %eval(&pfeproccompare_NumIssuesValues > 0) %then %do;
		      %do i=1 %to &ds_total;
		          proc sql noprint;
		              select count(*) into :cnt
		              from result_&&ds_&i
		              where _TYPE_ = 'DIF';
		          quit;

		          %if %eval(&cnt > 0) %then %do;
		          		
		              	ods tagsets.excelxp options ( sheet_name = "&&ds_&i Value Diff" Default_column_width= "10");
		              	title1 justify=left "&pfeproccompare_pxl_code &pfeproccompare_protocol Proc Compare &&ds_&i Total of %left(%trim(&cnt)) Value Differences (limited to display first 100 obs)";
		      			title2 justify=left "Primary Dataset Path: %left(%trim(&pfeprocompare_pathpri))";
						title3 justify=left "Compare/QC Dataset Path: %left(%trim(&pfeprocompare_pathqc))";		              	
		              	options nolabel;
		              	proc report data = result_&&ds_&i (firstobs=1 obs=100) style(column)={tagattr='Format:Text'}; 
		              	run;
		          %end; %* End per domain issue check;
		      %end; %* End do loop;
		  %end; %* End any value issus check;         
		  options label;

		ods tagsets.excelxp close;
		ods listing;

	%put NOTE:[PXL] ***********************************************************************;
	%put NOTE:[PXL] Macro End;
	%put NOTE:[PXL] ***********************************************************************;
	    %goto MacEnd;
	    %MacErr:;
	    %put %str(ERR)OR:[PXL] ---------------------------------------------------;
	    %put %str(ERR)OR:[PXL] &pfeproccompare_MacroName: Abnormal end to macro;
	    %put %str(ERR)OR:[PXL] &pfeproccompare_MacroName: See log for details;
	    %put %str(ERR)OR:[PXL] ---------------------------------------------------;
	    %let GMPXLERR=1;

		%MacEnd:;
		title;
    	footnote;
    	OPTIONS fmterr; * Reset Ignore format notes in log;
    	OPTIONS missing=.;

    	proc datasets lib=work nolist; 
    		delete dataset_info e3 pri_only_datasets qc_only_datasets _ds _e3_1 _e3_2 _e3_3 _e3_4 pri qc;
    	quit;
    	run;

		%put INFO:[PXL]----------------------------------------------;
		%put INFO:[PXL] &pfeproccompare_MacroName: Macro Completed; 
		%put INFO:[PXL] Output: ;
		%put INFO:[PXL] pfeproccompare_PassOrFail = &pfeproccompare_PassOrFail; * PASS or FAIL;
		%put INFO:[PXL] pfeproccompare_NumIssuesAttrib = %left(%trim(&pfeproccompare_NumIssuesAttrib)); * Number of issues found in SAS attributes;	
		%put INFO:[PXL] pfeproccompare_NumIssuesValues = %left(%trim(&pfeproccompare_NumIssuesValues)); * Number of issues found in Values;
		%put INFO:[PXL] pfeproccompare_ListingName = &pfeproccompare_ListingName; * Listing path and file name for pdf and xls;		
		%put INFO:[PXL]----------------------------------------------;

%mend pfeproccompare;