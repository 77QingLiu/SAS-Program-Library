/*------------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

--------------------------------------------------------------------------------
 
  Author:                Nathan Johnson $LastChangedBy: pfzcron $
  Creation Date:         20150924       $LastChangedDate: 2016-08-25 12:30:48 -0400 (Thu, 25 Aug 2016) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfedvscheck.sas $
 
  Files Created:         DVS ECD check report (xls)
 
  Program Purpose:       Compare a project DVS file against a project ECD file and
                         report out discrepancies in checks listed.

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:

    Name:                dvscheck_dvsfile
      Allowed Values:    Valid path and file name
      Default Value:     null
      Description:       Specifies the path and file name of DVS file.
 
    Name:                dvscheck_ecdfile
      Allowed Values:    Valid path and file name
      Default Value:     null
      Description:       Specifies the path and file name of ECD file.
 
    Name:                dvscheck_outpath
      Allowed Values:    valid path
      Default Value:     null
      Description:       Location to which report file will be written.

    Name:                dvscheck_outfile
      Allowed Values:    valid file name
      Default Value:     null
      Description:       Specified file name for report file. If not supplied a 
                         default standard naming convention will be used.

    Name:                dvscheck_protocol
      Allowed Values:    Pfizer protocol number or leave blank
      Default Value:     (null)
      Description:       Pfizer protocol number (if null will try to get from global macro variable PROTOCOL).

    Name:                dvscheck_dvstabs
      Allowed Values:    MULTI, SINGLE
      Default Value:     MULTI
      Description:       Indicator specifying whether incoming DVS file is the older
                         template with a single tab for all checks (SINGLE), or the 
                         newer template with multiple tabs (MULTI).

    Name:                dvscheck_codeitemcol
      Allowed Values:    single letter
      Default Value:     f
      Description:       Specifies which column on multi-tab domain tabls contains
                         the code item values. This parameter allows for variation
                         from the standard template.

    Name:                dvscheck_querytextcol
      Allowed Values:    single letter
      Default Value:     l
      Description:       Specifies which column on multi-tab domain tabls contains
                         the query text values. This parameter allows for variation
                         from the standard template.

    Name:                dvscheck_ecdIncludeInactive
      Allowed Values:    YES, NO
      Default Value:     YES
      Description:       Flag indicating whether checks marked as "InActive" in the
                         ECD file should be included in the comparison.

    Name:                dvscheck_ecdIncludeNonCustom
      Allowed Values:    YES, NO
      Default Value:     YES
      Description:       Flag indicating whether checks not marked as "Custom" in 
                         the ECD file should be included in the comparison.

    Name:                dvscheck_dvsIncludeDeactive
      Allowed Values:    YES, NO
      Default Value:     YES
      Description:       Flag indicating whether checks marked with "Y" for Deactive
                         and "N" for Effective in the DVS file should be included 
                         in the comparison. If set to NO those records will be
                         ignored.

    Name:                dvscheck_fuzzycompare
      Allowed Values:    YES, NO 
      Default Value:     YES
      Description:       In comparing the query text, by default the macro will 
                         upcase the values and remove trailing or leading spaces
                         and any special characters. If the fuzzycompare flag is
                         set to YES, then all spaces and punctuation will also be
                         ignored when comparing the values.

--------------------------------------------------------------------------------
  MODIFICATION HISTORY: Subversion $Rev: 2540 $
--------------------------------------------------------------------------------

    Version: V0.1 Date: 20151118 Author: Nathan Johnson
        1) Initial Version  
    Version: V0.2 Date: 20151123 Author: Nathan Johnson
        1) Updated documentation
    Version: V1.0 Date: 20151125 Author: Nathan Johnson
        1) Various fixes based on testing
    Version: V2.0 Date: 20160211 Author: Nathan Johnson
        1) Add parameter to allow for excluding domains from DVS
        2) Add parameter for excluding Deactive checks from DVS
        3) Add parameter for excluding Non-custom checks from ECD
        4) Add Check Type column to Check Codes Tab
        5) Add Query Text and Error Message columns to Check Codes Tab
        6) Add comments, reviewer name, review date fields to all result tabs
        7) Rename includeInactive parameter to dvscheck_ecdIncludeInactive
        8) Change default value of fuzzycompare to NO
    Version: V3.0 Date: 20160225 Author: Nathan Johnson
        1) Various fixes per user requirements and field testing
    Version: V4.0 Date: 20160817 Author: Nathan Johnson
        1) Add DVS Deactive status to report output
        2) Modify handling of exclusion of deactive dvs checks to handle "X"
           response in that column rather than only Yes or No
        
        
------------------------------------------------------------------------------*/

%macro pfedvscheck
    (
        dvscheck_dvsfile=null
        ,dvscheck_ecdfile=null
        ,dvscheck_outpath=null
        ,dvscheck_outfile=null
        ,dvscheck_protocol=
        ,dvscheck_dvstabs=MULTI
        ,dvscheck_codeitemcol=f
        ,dvscheck_querytextcol=l
        ,dvscheck_ecdIncludeInactive=YES
        ,dvscheck_ecdIncludeNonCustom=YES
        ,dvscheck_dvsIncludeDeactive=NO
        ,dvscheck_fuzzycompare=NO
    );

/*******************************************************************************
* MACRO SETUP
*******************************************************************************/

    %let dvscheck_MacName        = PFEDVSCHECK;
    %let dvscheck_MacVersion     = $Rev: 2540 $;
    %let dvscheck_MacVersionDate = $LastChangedDate: 2016-08-25 12:30:48 -0400 (Thu, 25 Aug 2016) $;
    %let dvscheck_MacRunDate     = %sysfunc(left(%sysfunc(datetime(), IS8601DT.)));
	%let dvscheck_MacPath        = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfedvscheck.sas $;

    
    %let dvscheck_check_baddomain_n = 0;
    %let dvscheck_check_dvsdup_n = 0;
    %let dvscheck_check_ecddup_n = 0;
    %let dvscheck_check_itemissues_n = 0;
    %let dvscheck_check_querytext_n = 0;
    %let dvscheck_check_baddomain_c =;
    %let dvscheck_check_dvsdup_c =;
    %let dvscheck_check_ecddup_c =;
    %let dvscheck_check_itemissues_c =;
    %let dvscheck_check_querytext_c =;
    
    /***************************************************************************
    * DEFINE MACRO TO WRITE LOG MESSAGES
    ***************************************************************************/
    %macro dvscheck_write_message(notetype,notemessage);
        %if %str("&notetype") = %str("i") %then %do;
            %let _type = INFO;
        %end;
        %else %if %str("&notetype") = %str("n") %then %do;
            %let _type = %str(NOTE);
        %end;
        %else %if %str("&notetype") = %str("e") %then %do;
            %let _type = %str(ERR)OR;
        %end;
        %else %if %str("&notetype") = %str("w") %then %do;
            %let _type = %str(WAR)NING;
        %end;
        
        %put;
        %put &_type.:[PXL][&dvscheck_MacName]%sysfunc(repeat(%str(-),79));
        
        %let countwords = %eval(%sysfunc(countc(%str(&notemessage),%str(@)))+1);
        
        %if %eval(&countwords>0) %then %do;
            %do messagenoteloop=1 %to &countwords;
                %put &_type.:[PXL][&dvscheck_MacName] %scan(&notemessage,&messagenoteloop,"@");
                x "echo  ------ %scan(&notemessage,&messagenoteloop,'@')";
            %end;
        %end;
        %else %do;
            %put &_type.:[PXL][&dvscheck_MacName] &notemessage;
            x "echo  ------ &notemessage";
        %end;
        
        %if %str("&notetype") ^= %str("e") and %str("&notetype") ^= %str("w") %then %do;
            %put &_type.:[PXL][&dvscheck_MacName]%sysfunc(repeat(%str(-),79));
            %put;
        %end;
    %mend;
    

    /***************************************************************************
    * WRITE OUT MACRO INFORMATION
    ***************************************************************************/
    %put ;
    %put INFO:[PXL][&dvscheck_MacName]---------------------------------------------------------------------;
    %put INFO:[PXL][&dvscheck_MacName] &dvscheck_MacName: Macro Started; 
    %put INFO:[PXL][&dvscheck_MacName] Version Number:  &dvscheck_MacVersion ;
    %put INFO:[PXL][&dvscheck_MacName] Version Date:    &dvscheck_MacVersionDate ;
    %put INFO:[PXL][&dvscheck_MacName] File Location:   &dvscheck_MacPath ;
    %put INFO:[PXL][&dvscheck_MacName]---------------------------------------------------------------------;
    %put INFO:[PXL][&dvscheck_MacName] Purpose:         Compare checks in specified DVS file to specified;
    %put INFO:[PXL][&dvscheck_MacName]                  ECD file;
    %put INFO:[PXL][&dvscheck_MacName]---------------------------------------------------------------------;
    %put INFO:[PXL][&dvscheck_MacName] Input:;
    %put INFO:[PXL][&dvscheck_MacName]   1) DVS File: &dvscheck_dvsfile ;
    %put INFO:[PXL][&dvscheck_MacName]   2) ECD File: &dvscheck_ecdfile;
    %put INFO:[PXL][&dvscheck_MacName]   3) Output Location: &dvscheck_outpath;
    %put INFO:[PXL][&dvscheck_MacName]   4) Output File: &dvscheck_outfile;
    %put INFO:[PXL][&dvscheck_MacName]   5) Protocol: &dvscheck_protocol;
    %put INFO:[PXL][&dvscheck_MacName]   6) ECD: Include Inactive Checks: &dvscheck_ecdIncludeInactive;
    %put INFO:[PXL][&dvscheck_MacName]   7) ECD: Include Non-Custom Checks : &dvscheck_ecdIncludeNonCustom;
    %put INFO:[PXL][&dvscheck_MacName]   8) DVS: Include Deactivated Checks : &dvscheck_dvsIncludeDeactive;
    %put INFO:[PXL][&dvscheck_MacName]   9) Use Fuzzy Compare : &dvscheck_fuzzycompare;
    %put INFO:[PXL][&dvscheck_MacName]---------------------------------------------------------------------;
    %put ;

    x "echo -------------------------------------------------------------------------";
    x "echo &dvscheck_MacName VERSION &dvscheck_MacVersion &dvscheck_MacVersionDate";
    x "echo -------------------------------------------------------------------------";
  
    
/*****************************************************************************
* PARAMETER CHECKS
*****************************************************************************/
    %dvscheck_write_message(i,PARAMETER CHECKS);
    
    /***************************************************************************
    * Global MAD macro GMPXLERR (unsucessiful execution flag);
    ***************************************************************************/
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
            %dvscheck_write_message(e,Global macro GMPXLERR = 1 - macro not executed);
            %goto MacErr;
        %end;

        
    /***************************************************************************
    * MACRO MUST BE RUN IN SAS 9.3
    ***************************************************************************/
    %if &SYSVER ne 9.3 %then %do;
        %dvscheck_write_message(e,Macro was run from SAS Version &sysver. Must be run from 9.3);
        %goto MacErr;
    %end;

    /***************************************************************************
	* Generate run date time for output listing and transfer_log update;
    ***************************************************************************/
	%global cdatetime;
	data _null_;
		format _cdatetime E8601DT.;
		_cdatetime = datetime();
		call symput('dvscheck_cdatetime',compress(put(_cdatetime, E8601DT.),'-:'));
		call symput('dvscheck_cdatetimen',put(_cdatetime, E8601DT.));
	run;

    
    /***************************************************************************
    * CHECK THAT PROTOCOL VARIABLE IS SET
    ***************************************************************************/
    %let _check = 0;
    proc sql noprint;
        select count(*) into: _check
        from sashelp.vmacro
        where scope='GLOBAL'
        and name='PROTOCOL';
    quit;
    %if %str("&dvscheck_protocol") = %str("") %then %do;
        %if %eval(&_check = 0)%then %do;
            %dvscheck_write_message(e,PROTOCOL Not Specified and Global Macro Variable PROTOCOL does not exist);
            %goto macErr;
        %end;
        %else %do;
            %let dvscheck_protocol = &protocol;
        %end;
    %end;
    
    /***************************************************************************
    * CHECK THAT DVS FILE EXISTS
    ***************************************************************************/
    %if %eval(%sysfunc(fileexist(&dvscheck_dvsfile)) = 0) %then %do;
        %dvscheck_write_message(e,Input DVS File does not exist: &dvscheck_dvsfile);
        %goto macerr;
    %end;

    /***************************************************************************
    * CHECK THAT DVS FILE IS IN CORRECT FORMAT
    ***************************************************************************/
    %let dvscheck_dvsfileext = %scan(&dvscheck_dvsfile,-1,".");
    %if %str("&dvscheck_dvsfileext") ne %str("xlsx") %then %do;
        %dvscheck_write_message(e,Input DVS File is not in XLSX format);
        %goto macerr;
    %end;
    
    /***************************************************************************
    * CHECK THAT ECD FILE EXISTS
    ***************************************************************************/
    %if %eval(%sysfunc(fileexist(&dvscheck_ecdfile)) = 0) %then %do;
        %dvscheck_write_message(e,Input ECD File does not exist@ECD File = &dvscheck_ecdfile);
        %goto macerr;
    %end;
    
    /***************************************************************************
    * CHECK THAT ECD FILE IS IN CORRECT FORMAT
    ***************************************************************************/
    %let dvscheck_ecdfileext = %scan(&dvscheck_ecdfile,-1,".");
    %if %str("&dvscheck_ecdfileext") ne %str("xlsx") %then %do;
        %dvscheck_write_message(e,Input ECD File is not in XLSX format);
        %goto macerr;
    %end;
    
    /***************************************************************************
    * CHECK THAT OUTPUT DIRECTORY EXISTS
    ***************************************************************************/
    %if %eval(%sysfunc(fileexist(&dvscheck_outpath)) = 0) %then %do;
        %dvscheck_write_message(e,Output Directory does not exist: &dvscheck_outpath);
        %goto macerr;
    %end;
    
    /***************************************************************************
    * CHECK OUTPUT FILE NAME
    ***************************************************************************/
    %if %str("&dvscheck_outfile") = %str("null") 
        or %str("&dvscheck_outfile") = %str("") %then %do;
        %let dvscheck_outfile = &dvscheck_protocol._dvs_ecd_check_&dvscheck_cdatetime..xls;
    %end;
    
    %else %if %eval(%sysfunc(index(%str(&dvscheck_outfile),%str(.xls))) = 0) %then %do;
        %let dvscheck_outfile = &dvscheck_outfile..xls;
    %end;
    
    %dvscheck_write_message(i, Output File: &dvscheck_outfile);

    
    
    
/*****************************************************************************
* DVS FILE
*****************************************************************************/
    %dvscheck_write_message(i,GET DVS FILE);
    
    
    /***************************************************************************
    * MULTI-TAB FORMAT (NEWER TEMPLATE)
    ***************************************************************************/
    %if %str("&dvscheck_dvstabs") = %str("MULTI") %then %do;
        * READ IN CHECK SUMMARY TAB TO GET LIST OF DOMAINS;
        proc import out=_dvscheck_dvs_domains_in
                    datafile="&dvscheck_dvsfile"
                    dbms=xlsx
                    replace
                    ;
            sheet="Check Summary";
            getnames=no;
        run;
        
        %if %eval(%sysfunc(exist(_dvscheck_dvs_domains_in))=0) %then %do;
            %dvscheck_write_message(e,Cannot read Check Summary tab of &dvscheck_dvstabs.-tab DVS file
                                       @Ensure that file is in &dvscheck_dvstabs.-tab format.);
            %goto macerr;
        %end;

        %let dvscheck_ndomains = 0;
        
        data _dvscheck_dvs_domains;
          length domain $50. comments $200.;
          set _dvscheck_dvs_domains_in;
          if _n_ > 1;
          domain = compress(a,,'kw');
          comments = "";
          keep domain comments;
          if upcase(compress(domain,,'ka')) not in ("PDLISTINGS","LISTINGS","");
        run;
        
        data _dvscheck_dvs_domains;
            set _dvscheck_dvs_domains;
            n = _n_;
            call symput('dvscheck_ndomains',strip(put(n,best.)) );
        run;
        
        %dvscheck_write_message(i,NUMBER OF DOMAINS: &dvscheck_ndomains);
        
        %if %eval(&dvscheck_ndomains = 0) %then %do;
            %dvscheck_write_message(e,Cannot read any domains in Check Summary Tab of DVS file
                                       @Ensure that file is in &dvscheck_dvstabs.-tab format.);
            %goto macerr;
        %end;
        
        * CREATE BASE DVS DATASET;
        data _dvscheck_dvschecks;
            length codeitem domain $50. i 8. deactive $20. querytext $1000.;
            codeitem = "";
            domain = "";
            i = .;
            querytext = "";
            deactive = "";
            delete;
        run;
        
        * LOOP THROUGH DOMAINS TO READ IN CHECKS;
        %do i=1 %to &dvscheck_ndomains;
            * get ith domain info;
            proc sql noprint;
                select domain into:dvscheck_idomain
                from _dvscheck_dvs_domains
                where n = &i
                ;
            quit;
            %let dvscheck_idomain = %trim(%left(&dvscheck_idomain));


            %dvscheck_write_message(i,READ IN EXCEL TAB &i: &dvscheck_idomain);

            proc import out=d&i
                        datafile="&dvscheck_dvsfile"
                        dbms=xlsx
                        replace
                        ;
                sheet="&dvscheck_idomain";
                getnames=no;

            run;

            %if %sysfunc(exist(d&i)) %then %do;
                data d&i;
                    set d&i (keep=a b &dvscheck_codeitemcol &dvscheck_querytextcol
                                where=(&dvscheck_codeitemcol ne "")
                             );
                    length codeitem domain $50. i 8. deactive effective $20. querytext $1000.;

                    codeitem = strip(compress(&dvscheck_codeitemcol,,'kw'));
                    querytext = strip(compress(&dvscheck_querytextcol,,'kw'));
                    effective = upcase(strip(compress(a,,'kw')));
                    deactive = upcase(strip(compress(b,,'kw')));
                    domain = "&dvscheck_idomain";
                    i = &i;
                    
                    if codeitem ne "" and index(codeitem,"Check Code") = 0;
                    
                    %if %str("&dvscheck_dvsIncludeDeactive") = %str("NO") %then %do;
                        %* if IncludeDeacitve flag is NO then remove records when 
                            Effective is No and Deacitve is Yes;
                        %* 2016-08-17 in some cases effective and deactive are 
                            marked with X rather than specified with Yes and No;
                        if upcase(substr(effective,1,1)) in ("N","")
                                and upcase(substr(deactive,1,1)) in ("Y","X")
                            then delete;
                    %end;
                    keep codeitem domain deactive i querytext;
                run;

                %let _dvscheck_nrec = 0;
                proc sql noprint;
                    select count(*) into:_dvscheck_nrec
                    from d&i;
                quit;
                
                %if %eval(&_dvscheck_nrec = 0) %then %do;
                    %dvscheck_write_message(w,NO CHECKS FOUND FOR SHEET &i: &dvscheck_idomain);
                    
                    proc sql;
                        update _dvscheck_dvs_domains
                        set comments = "";
                        where domain = "dvscheck_idomain"
                        ;
                    quit;
                %end;
                %else %do;
                    proc append base=_dvscheck_dvschecks data=d&i force;
                    run;
                %end;
                
                proc sql;
                    drop table d&i;
                quit;
            %end;
            
            %else %do;
                %dvscheck_write_message(w,TAB NOT FOUND FOR SHEET &i: &dvscheck_idomain);
                
                proc sql;
                    update _dvscheck_dvs_domains
                    set comments = "";
                    where domain = "dvscheck_idomain"
                    ;
                quit;
            %end;
        %end;
        
        * COMBINE INDIVIDUAL CHECKS WITH LIST OF DOMAINS;
        proc sort data=_dvscheck_dvs_domains;
            by domain;
        run;
        
        proc sort data=_dvscheck_dvschecks;
            by domain;
        run;

        data _dvscheck_dvs _dvscheck_check_baddomain;
            merge _dvscheck_dvs_domains (in=a) _dvscheck_dvschecks (in=b);
            by domain;
            indomains = a;
            inchecks = b;
            
            length indomainsc inchecksc $4. comments $200.;
            if indomains = 1 then indomainsc = "Yes";
            else indomainsc = "No";
            
            if inchecks = 1 then inchecksc = "Yes";
            else inchecksc = "No";
            
            if a and b then output _dvscheck_dvs;
            else do;
                comments = "";
                output _dvscheck_check_baddomain;
            end;
        run;
        
        proc sql noprint;
            select count(*) into:dvscheck_check_baddomain_n
            from _dvscheck_check_baddomain
            ;
        quit;

    %end;
    
    /***************************************************************************
    * SINGLE-TAB FORMAT (OLDER TEMPLATE)
    ***************************************************************************/
    %else %do;
        * confirm that file is in single-tab template format;
        proc import out=_dvscheck_dvs_in
                    datafile="&dvscheck_dvsfile"
                    dbms=xlsx
                    replace
                    ;
            sheet="Check Summary";
            getnames=no;
        run;

        proc sql noprint;
            select count(*) into:dvscheck_dvsfilecheck
            from _dvscheck_dvs_in
            where strip(compress(F,,'kw')) = "Edit Check Counts by CRF"
            ;
        quit;
        
        %if %eval(&dvscheck_dvsfilecheck = 0) %then %do;
            %dvscheck_write_message(e,DVS file not in correct SINGLE-tab format);
            %goto macerr;
        %end;
        
        
        proc import out=_dvscheck_dvs_in
                    datafile="&dvscheck_dvsfile"
                    dbms=xlsx
                    replace
                    ;
            sheet="Edit Checks";
            getnames=yes;
        run;
        
        %if %eval(%sysfunc(exist(_dvscheck_dvs_in))=0) %then %do;
            %dvscheck_write_message(e,Cannot read Edit Checks tab of &dvscheck_dvstabs.-tab DVS file);
            %goto macerr;
        %end;
        
        data _dvscheck_dvs;
            set _dvscheck_dvs_in;
            length domain codeitem $50. comments $200. querytext $1000.;
            
            codeitem = strip(compress(check_code,,'kw'));
            querytext = strip(compress(var14,,'kw'));
            domain = strip(compress(crf,,'kw'));
            comments = "";
            
            if codeitem ne "";
            
            %if %str("&dvscheck_dvsIncludeDeactive") = %str("NO") %then %do;
                %* if IncludeDeacitve flag is NO then remove records when Effective is No and Deacitve is Yes;
                        %* 2016-08-17 in some cases effective and deactive are 
                            marked with X rather than specified with Yes and No;
                if strip(compress(effective,,'kw')) ne "" 
                    and strip(compress(deactive,,'kw')) ne "" then do;
                    
                    if substr(upcase(strip(compress(effective,,'kw'))),1,1) in ("N","")
                        and substr(upcase(strip(compress(deactive,,'kw'))),1,1) in ("Y","X")
                    then delete;
                end;
            %end;
            keep domain codeitem querytext deactive comments;
        run;
        
    %end;
    
    proc sql noprint;
        create table _dvscheck_check_dvsdup as
        select * from _dvscheck_dvs
        where codeitem in (select codeitem from _dvscheck_dvs
                            group by domain, codeitem
                            having count(*) > 1)
        ;

        select count(*) into:dvscheck_check_dvsdup_n
        from _dvscheck_check_dvsdup
        ;
    quit;

    proc sort data=_dvscheck_dvs nodupkey;
        by codeitem;
    run;
    
   
/*****************************************************************************
* ECD FILE
*****************************************************************************/
    %dvscheck_write_message(i,GET ECD FILE);
   
    proc import out=_dvscheck_ecd_in
                datafile="&dvscheck_ecdfile"
                dbms=xlsx
                replace
                ;
        sheet="Edit Checks";
        getnames=yes;
    run;
    
    %if %eval(%sysfunc(exist(_dvscheck_ecd_in))=0) %then %do;
        %dvscheck_write_message(e,Cannot read Edit Checks tab of ECD file
                                   @Ensure that file is in correct format.);
        %goto macerr;
    %end;

    data _dvscheck_ecd;
        length codeitem form domain $50. comments $200. querytext_ecd $1000.;
        set _dvscheck_ecd_in;
        
        codeitem = strip( compress(Edit_Check_Identifier,,'kw') );
        querytext_ecd = strip(compress(var14,,'kw'));
        form = strip(compress(form_name,,'kw'));
        domain = form;
        comments = "";
        
        if codeitem ne ""
            %if %str("&dvscheck_ecdIncludeInactive") = %str("NO") %then %do;
                and strip(compress(status,,'kw')) = "Active" 
            %end;
            %if %str("&dvscheck_ecdIncludeNonCustom") = %str("NO") %then %do;
                and strip(compress(check_type,,'kw')) = "Custom"
            %end;
            ;
            
        keep codeitem form domain querytext_ecd status check_type comments;
    run;
    
    proc sql noprint;
        create table _dvscheck_check_ecddup as
        select * from _dvscheck_ecd
        where codeitem in (select codeitem from _dvscheck_ecd
                            group by codeitem
                            having count(*) > 1)
        ;

        select count(*) into:dvscheck_check_ecddup_n
        from _dvscheck_check_ecddup
        ;
    quit;

    proc sort data=_dvscheck_ecd nodupkey;
        by codeitem;
    run;
    

    
/*****************************************************************************
* MERGE DVS AND ECD
*****************************************************************************/
    %dvscheck_write_message(i,MERGE DVS AND ECD DATA);
    
    data _dvscheck_dvsecd _dvscheck_check_itemissues _dvscheck_check_querytext;
        merge _dvscheck_ecd (in=a) _dvscheck_dvs (in=b);
        by codeitem;
        
        length codeitem_ecd codeitem_dvs $50.;
        
        inecd = a;
        indvs = b;
                
        if form = "" then form = domain;

        if inecd then codeitem_ecd = codeitem;
        else if indvs then codeitem_dvs = codeitem;
        
        * clean up query text strings for comparisons;
        query_ecd = strip(compress(upcase(querytext_ecd),,'kw'));
        query_dvs = strip(compress(upcase(querytext    ),,'kw'));
        
        * if fuzzycompare parameter is set to yes, then compress out spaces and punctuation;
        %if %str("&dvscheck_fuzzycompare") = %str("YES") %then %do;
            query_ecd = compress( query_ecd, ,'sp');
            query_dvs = compress( query_dvs, ,'sp');
        %end;

        output _dvscheck_dvsecd;
        
        if a ne b then do;
            output _dvscheck_check_itemissues;
        end;
        
        if a and b and query_ecd ne query_dvs then do;
            output _dvscheck_check_querytext;
        end;
        
    run;

    * do not include check code differences for domains not found in DVS;
    %if %sysfunc(exist(_dvscheck_check_baddomain)) %then %do;
        data _dvscheck_check_itemissues_;
            set _dvscheck_check_itemissues;
        run;
        
        proc sql;
            create table _dvscheck_check_itemissues as
            select * from _dvscheck_check_itemissues_
            where form not in (select domain from _dvscheck_check_baddomain)
            ;
        quit;
    %end;
    
    proc sql noprint;
        select count(*) into:dvscheck_check_itemissues_n
        from _dvscheck_check_itemissues
        ;
        select count(*) into:dvscheck_check_querytext_n
        from _dvscheck_check_querytext
        ;
    quit;
    

/*****************************************************************************
* CREATE OUTPUT FILE
*****************************************************************************/
    %dvscheck_write_message(i,CREATE OUTPUT FILE:@&dvscheck_outpath./&dvscheck_outfile);

    ods listing close; 
    ods tagsets.excelxp file= "&dvscheck_outpath./&dvscheck_outfile";
    
    * Set titles and footnotes;
    title;
    title1 justify=left "DVS / ECD Comparison Report";
    title2 justify=left "ECD File: &dvscheck_ecdfile";
    title3 justify=left "DVS File: &dvscheck_dvsfile";
    title4 j=l " ";
    
    footnote1 j=l "PAREXEL International Confidential";
    footnote2 j=l "Produced by %upcase(&sysuserid) on &sysdate9";
    
    /***************************************************************************
    * TAB 1: SUMMARY
    ***************************************************************************/
        ods tagsets.excelxp options (
                            Orientation = "landscape"
                            Embedded_Titles = "Yes"
                            Row_Repeat = "Header"
                            Autofit_Height = "Yes"
                            Autofilter = "All"
                            Frozen_Headers = "Yes"
                            Gridlines = "Yes"
                            default_column_width= "30, 30"
                            sheet_name = "Summary"
                            zoom = "70"
                            frozen_headers = "7"
                            row_repeat = "7"
                            );

        data _dvscheck_tab1;
            length col1 col2 $200. col2n 8.;
            col1 = "Listing Name";
            col2 = "&dvscheck_outfile";
            output;
            col1 = "Run Date and Time";
            col2 = "&dvscheck_MacRunDate";
            output;
            col1 = "Run by";
            col2 = "&sysuserid";
            output;
            col1 = "";
            col2 = "";
            output;
            col1 = "Run Macro";
            col2 = "&dvscheck_MacName v &dvscheck_MacVersion (&dvscheck_MacVersionDate.)";
            output;
            col1 = "";
            col2 = "";
            output;
            col1 = "Input";
            col2 = "";
            output;
            col1 = "ECD File";
            col2 = "&dvscheck_ecdfile";
            output;
            col1 = "DVS File";
            col2 = "&dvscheck_dvsfile";
            output;
            col1 = "";
            col2 = "";
            output;
            col1 = "Comparison Parameters";
            col2 = "";
            output;
            col1 = "ECD: Inactive Checks Included?";
            col2 = "&dvscheck_ecdIncludeInactive";
            output;
            col1 = "ECD: Non-Custom Checks Included?";
            col2 = "&dvscheck_ecdIncludeNonCustom";
            output;
            col1 = "DVS: Deactivated Checks Included?";
            col2 = "&dvscheck_dvsIncludeDeactive";
            output;
            col1 = "Query Text Compare: Ignore punctuation and spaces?";
            col2 = "&dvscheck_fuzzycompare";
            output;
            col1 = "";
            col2 = "";
            output;
            col1 = "Results Summary";
            col2 = "";
            output;
            col1 = "Domain Tab Issues";
            if &dvscheck_check_baddomain_n > 0 then 
                col2 = "DVS Tabs Not Found or Tabs With No Checks. In DVS form, check that tab matches form name in Check_Summary tab."
                    || " (Only applicable to multi-tab DVS forms.) See 'DVS Tabs' worksheet for details.";
            else col2 = "";
            col2n = &dvscheck_check_baddomain_n;
            output;
            col1 = "Duplicate DVS Check Items";
            if &dvscheck_check_dvsdup_n > 0 then 
                col2 = "Check Item Name repeated in DVS file. Please check and remove duplicates. See 'Duplicate DVS Items' tab for details.";
            else col2 = "";
            col2n = &dvscheck_check_dvsdup_n;
            output;
            col1 = "Duplicate ECD Check Items";
            if &dvscheck_check_ecddup_n > 0 then
                col2 = "Check Item Name repeated in ECD file. Please check and remove duplicates. See 'Duplicate ECD Items' tab for details.";
            else col2 = "";
            col2n = &dvscheck_check_ecddup_n;
            output;
            col1 = "Check Item Discrepancies";
            if &dvscheck_check_itemissues_n > 0 then 
                col2 = "Check Item appears on DVS but not ECD, or ECD but not DVS. See 'Check Codes' tab for details.";
            else col2 = "";
            col2n = &dvscheck_check_itemissues_n;
            output;
            col1 = "Check Item Query Text Discrepancies";
            if &dvscheck_check_querytext_n > 0 then 
                col2 = "%str(Err)or Message in ECD does not match Query Text in DVS. See 'Query Text' tab for details";
            else col2 = "";
            col2n = &dvscheck_check_querytext_n;
            output;
        run;
            
        title5 j=l "Results Summary";
        proc report data= _dvscheck_tab1 style(column)={tagattr='Format:Text' vjust=top};
            columns col1 col2 col2n;
            define col1 / display "Report Item" width=20;
            define col2 / display "Value" width=50;
            define col2n / display "N" width=10 left;
            compute col1; 
                if col1 in ("Results Summary","Input","Comparison Parameters") then
                    call define(_row_,"style","style={background=gray font_weight=bold font_face='Arial, Helvetica' font_size=12pt }");
            endcomp;
            compute col2n; 
                if col2n > 0 then
                    call define(_row_,"style","style={background=verylightred}");
            endcomp;
        run; quit;

    /***************************************************************************
    * TAB 2: DVS TABS
    ***************************************************************************/
    %if %eval(&dvscheck_check_baddomain_n > 0) %then %do;

        ods tagsets.excelxp options (
                            sheet_name = "DVS Tabs"
                            );
                            
        title5 j=l "DVS Tabs Not Found or Tabs With No Checks (Applicable only for newer DVS template)";
        proc report data= _dvscheck_check_baddomain style(column)={tagattr='Format:Text' vjust=top};
            columns domain indomainsc inchecksc comments;
            define domain / display "Domain" width=15;
            define indomainsc / display "In Check_Summary" width=20 center;
            define inchecksc / display "Has Domain Tab" width=20 center;
            define comments / display "Comments" width=30;
        run; quit;
    %end;

    /***************************************************************************
    * TAB 3: DUPLICATE DVS ITEMS
    ***************************************************************************/
    %if %eval(&dvscheck_check_dvsdup_n > 0) %then %do;
    
        ods tagsets.excelxp options (
                            sheet_name = "Duplicate DVS Items"
                            );
                            
        title5 j=l "Checks Duplicated in DVS File";
        proc report data= _dvscheck_check_dvsdup style(column)={tagattr='Format:Text' vjust=top};
            columns domain codeitem querytext comments;
            define domain / display "Domain" width=15;
            define codeitem / display "Check Item" width=20;
            define querytext / display "Query Text" width=40;
            define comments / display "Comments" width=30;
        run; quit;
    %end;

    /***************************************************************************
    * TAB 4: DUPLICATE ECD ITEMS
    ***************************************************************************/
    %if %eval(&dvscheck_check_ecddup_n > 0) %then %do;
    
        ods tagsets.excelxp options (
                            sheet_name = "Duplicate ECD Items"
                            );
                            
        title5 j=l "Checks Duplicated in ECD File";
        proc report data= _dvscheck_check_ecddup style(column)={tagattr='Format:Text' vjust=top};
            columns domain codeitem status querytext_ecd comments;
            define domain / display "Domain" width=15;
            define codeitem / display "Check Item" width=20;
            define status / display "Status" width=10 center;
            define querytext_ecd / display "Query Text" width=40;
            define comments / display "Comments" width=30;
        run; quit;
    %end;
    
    /***************************************************************************
    * TAB 5: CHECK CODES
    ***************************************************************************/
    %if %eval(&dvscheck_check_itemissues_n > 0) %then %do;
        ods tagsets.excelxp options (
                            sheet_name = "Check Codes"
                            frozen_headers = "8"
                            row_repeat = "8"
                            );
                            
        title5 j=l "Check Codes in only DVS or ECD";
        proc report data= _dvscheck_check_itemissues style(column)={tagattr='Format:Text' vjust=top};
            columns form 
                    ("ECD" status check_type codeitem_ecd querytext_ecd)
                    ("DVS" deactive codeitem_dvs querytext)
                    comments
                    ;
            define form / display "Form" width=15;
            define status / display "ECD/Status" width=8 center;
            define check_type / display "ECD/Check/Type" width=8 center;
            define codeitem_ecd / display "ECD Check" width=20;
            define querytext_ecd / display "ECD Query Text" width=30;
            define deactive / display "DVS/Deactive/Status" width=8 center;
            define codeitem_dvs / display "DVS Check" width=20;
            define querytext / display "DVS Query Text" width=30;
            define comments / display "Comments" width=30;
        run; quit;
    %end;
    
    /***************************************************************************
    * TAB 6: QUERY TEXT
    ***************************************************************************/
    %if %eval(&dvscheck_check_querytext_n > 0) %then %do;
        ods tagsets.excelxp options (
                            sheet_name = "Query Text"
                            frozen_headers = "8"
                            row_repeat = "8"
                            );
                            
        title5 j=l "Query Text Differs Between ECD and DVS";
        proc report data= _dvscheck_check_querytext style(column)={tagattr='Format:Text' vjust=top};
            columns form 
                    codeitem 
                    ("ECD" status check_type querytext_ecd)
                    ("DVS" querytext deactive)
                    comments
                    ;
            define form / display "Form" width=15;
            define codeitem / display "Check Item" width=20;
            define status / display "ECD/Status" width=10 center;
            define check_type / display "ECD/Check/Type" width=10 center;
            define querytext_ecd / display "ECD Error Message" width=40;
            define querytext / display "DVS Query Text" width=40;
            define deactive  / display "DVS/Deactive/Status" width=10;
            define comments / display "Comments" width=40;
        run; quit;
    %end;


    /***************************************************************************
    * CLOSE LISTING OUTPUT
    ***************************************************************************/
    ods tagsets.excelxp close;
    ods listing;
  
    /***************************************************************************
    * CLEAN UP
    ***************************************************************************/
    
	%put ;
    
    %dvscheck_write_message(i,BAD Domains        : &dvscheck_check_baddomain_n
                             @Duplicate DVS Items: &dvscheck_check_dvsdup_n
                             @Duplicate ECD Items: &dvscheck_check_ecddup_n
                             @Item Issues        : &dvscheck_check_itemissues_n
                             @Query Text Issues  : &dvscheck_check_querytext_n);

    
    
	%goto macEnd;
    
	%macErr:;
	%put %str(ERR)OR:[PXL][&dvscheck_MacName] Abnormal end to program. Review Log.;
	%put %str(ERR)OR:[PXL][&dvscheck_MacName]%sysfunc(repeat(%str(-),79));

    
	%macEnd:;

    %let nds = 0;
    proc sql noprint;
        select count(*) into:nds
        from sashelp.vtable
        where libname = "WORK" and index(memname,"_DVSCHECK")
        ;
    quit;
    
    %if %eval(&nds > 0) %then %do;
        
        proc datasets library=work nolist;
            delete _dvscheck:;
            run;
        quit;
    %end;
    
    %symdel nds /nowarn;


	%put ;
	%put INFO:[PXL]%sysfunc(repeat(%str(-),79));
	%put INFO:[PXL] &dvscheck_MacName: Macro Completed ;
	%put INFO:[PXL]      File Location : &dvscheck_MacPath ;
	%put INFO:[PXL]      Version Number: &dvscheck_MacVersion ;
	%put INFO:[PXL]      Version Date  : &dvscheck_MacVersionDate ;
	%put INFO:[PXL]%sysfunc(repeat(%str(-),79));
	%put ;

    options notes source;
    title;
    footnote;
%mend;


