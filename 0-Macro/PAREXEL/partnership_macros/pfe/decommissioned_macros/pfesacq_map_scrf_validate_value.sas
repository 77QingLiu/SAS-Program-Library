/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        220978 PFE - Data Exchanges
 
  SAS Version:           9.2 and above
  Operating System:      UNIX
  Example Call:          Note: Part of program: pfesacq_map_scrf 
               
                         Called from parent macro pfesacq_map_scrf:
                         %pfesacq_map_scrf_validate_value;

-------------------------------------------------------------------------------
 
  Author:                Nathan Hartley, Nathan Johnson, $LastChangedBy: hartlen $
  Creation Date:         12FEB2015                       $LastChangedDate: 2015-03-26 16:40:01 -0400 (Thu, 26 Mar 2015) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/unittesting/testing_area/macros/partnership_macros/pfe/pfesacq_map_scrf_validate_value.sas $
 
  Files Created:         None
 
  Program Purpose:       Verify input or source data per structure 
                         'Validation Checks'
 
                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Sources:
 
    1) _TEMP2 - work SAS datasets created in parent macro that contains 
       _<scrf variable> and <sacq variable> data for a dataset
    2) Macro variables created in parent macro METADATA work dataset; 
       metadata_total (total records number) and macro variable of each 
       actual variable data
    3) &SRCINPUT..&DATASET - source SAS library and CSDW SCRF dataset
    4) &TAROUTPUT..&DATASET._SACQ - target SAS library and SACQ dataset
 
  Macro Output:     

    Name:                Listing_TAB5
      Type:              SAS work dataset
      Allowed Values:    N/A
      Default Value:     N/A
      Description:       Verifies value checks as specified per tab 
                         'Validation Checks' and filered on 
                         'Value Exceptions' on the study design plan


  Macro Dependencies:    This is a submacro dependant on calling parent macro: 
                         pfesacq_map_scrf.sas

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 492 $

Version: 1.0 Date: 12FEB2015 Author: Nathan Hartley

Version: 2.0 Date: 25MAR2015 Author: Nathan Hartley
  Updates:
  1) added CK_11
  
-----------------------------------------------------------------------------*/

%macro pfesacq_map_scrf_validate_value;
	%put ---------------------------------------------------------------------;
	%put PFESACQ_MAP_SCRF_VALIDATE_VALUE: Start of Submacro;
	%put ---------------------------------------------------------------------;

********************************************************************************
* Internal Use Macros;

  * PURPOSE: Output log message for start of check macro
    INPUT: checkid=CHECK ID Number
           check=description of check
    OUTPUT: Start of check message to log only;
      %macro _StartCheck(checkid=null, check=null);
        %put ---------------------------------------------------------------------;
        %put Check &checkid.: &check;
        %put ---------------------------------------------------------------------;
      %mend _StartCheck;

  * PURPOSE: Output log message for end of check macro
    INPUT: 1) Macro Parameter CHECK=CHECK ID Number
           2) Macro Parameter STATUS=PASS or FAIL Message to display
    OUTPUT: 1) End of check message to log only;
      %macro _EndCheck(check=null, status=null);
        %put ---------------------------------------------------------------------;
        %put Check &check.: Completed: &status;
        %put ---------------------------------------------------------------------;
      %mend _EndCheck;

********************************************************************************
* CK_V1 - SCRF Variable actual data length is longer than SACQ standard;  
    %_StartCheck(checkid=CK_V1, check=SCRF Variable actual data length is longer than SACQ standard);
    data CK_V1(keep=issue--sacq_variable_value);
        attrib &listing_tab5;
        set work._temp2;
        issue = .;
        issue_id = "";
        priority = "";
        desc = "";
        desc_info = "";
        key = "";
        scrf_dataset = "";
        scrf_variable = "";
        scrf_variable_value = "";
        sacq_variable_value = ""; 

        * Cycle through every metadata variable;
        %do i=1 %to &Metadata_total;
            %if &&scrf_variable_&i = &&sacq_variable_&i
                and "&&scrf_variable_&i" ne 
                and (%upcase("&&scrf_type_&i") = "CHAR"
                   or %upcase("&&scrf_type_&i") = "CHARACTER")
                and "&&sacq_codelist_&i" = "" %then %do;

                if length(_&&scrf_variable_&i) > &&sacq_length_&i then do;
                    issue = .;
                    issue_id = "CK_V1";
                    priority = "WARNING";
                    desc = "SCRF Variable actual data length is longer than SACQ standard";
                    desc_info = catx(" ",
                                     "SCRF &dataset..&&scrf_variable_&i value as a length of",
                                     left(trim(put(length(_&&scrf_variable_&i),8.))),
                                     "but length is",
                                     %left(%trim(&&sacq_length_&i)),
                                     "for SACQ. Truncation of data occurred.");
                    key = catx("-",SITEID,SUBJID,ACTEVENT,DOCNUM,REPEATSN);
                    scrf_dataset = "&dataset";
                    scrf_variable = "&&scrf_variable_&i";
                    scrf_variable_value = _&&scrf_variable_&i;
                    sacq_variable_value = &&scrf_variable_&i;
                    output CK_V1;                    
                end;
            %end;
        %end; * End metadata cycle;
        delete;
    run;

    proc sql noprint;
      select count(*) into: flag
      from CK_V1;
    quit;

    %if &flag > 0 %then %do;
        data listing_tab5;
        set listing_tab5 CK_V1;
        run;
    %end;

    %_EndCheck(check=CK_V1, status=&flag Issues found in &dataset);

********************************************************************************
* CK_V2 - Value not in Pfizer Codelist;  
      %_StartCheck(checkid=CK_V2, check=Value not in Pfizer Codelist);
      data CK_V2(keep=issue--sacq_variable_value);
          attrib &listing_tab5;
          set work._temp2;
              issue = .;
              issue_id = "";
              priority = "";
              desc = "";
              desc_info = "";
              key = "";
              scrf_dataset = "";
              scrf_variable = "";
              scrf_variable_value = "";
              sacq_variable_value = ""; 

              %do i=1 %to &Metadata_total;
                  %if &&scrf_variable_&i = &&sacq_variable_&i
                      and "&&scrf_variable_&i" ne ""
                      and "&&sacq_codelist_&i" ne "" %then %do;

                      if not missing(_&&scrf_variable_&i) and missing(&&scrf_variable_&i.._LONGLABEL) then do;
                          issue = .;
                          issue_id = "CK_V2";
                          priority = "WARNING";
                          desc = "Value not in Pfizer Codelist";
                          desc_info = "SCRF &dataset..&&scrf_variable_&i value is required to be present within Pfizer &&sacq_codelist_standard_&i Codelist &&sacq_codelist_&i but was not found. Value dropped.";
                          key = catx("-",SITEID,SUBJID,ACTEVENT,DOCNUM,REPEATSN);
                          scrf_dataset = "&dataset";
                          scrf_variable = "&&scrf_variable_&i";
                          %if (%upcase("&&scrf_type_&i") = "NUM"
                             or %upcase("&&scrf_type_&i") = "NUMBER"
                             or %upcase("&&scrf_type_&i") = "NUMERIC") %then %do;
                            
                              scrf_variable_value = left(trim(put(_&&scrf_variable_&i, best.)));
                          %end;
                          %else %do;
                              scrf_variable_value = _&&scrf_variable_&i;
                          %end;
                          sacq_variable_value = &&scrf_variable_&i;                      
                          output CK_V2;
                      end;
                  %end;
              %end; * End metadata cycle;
            delete;
      run;

      proc sql noprint;
        select count(*) into: flag
        from CK_V2;
      quit;

      %if &flag > 0 %then %do;
          data listing_tab5;
          set listing_tab5 CK_V2;
          run;
      %end;
      %_EndCheck(check=CK_V2, status=&flag Issues found in &dataset);

********************************************************************************
* CK_V3 - SCRF Char date did not map to SACQ Char Date;  
      %_StartCheck(checkid=CK_V3, check=SCRF Char date did not map to SACQ Char Date);
      data CK_V3(keep=issue--sacq_variable_value);
          attrib &listing_tab5;
          set work._temp2;
              issue = .;
              issue_id = "";
              priority = "";
              desc = "";
              desc_info = "";
              key = "";
              scrf_dataset = "";
              scrf_variable = "";
              scrf_variable_value = "";
              sacq_variable_value = "";  

              * Cycle through every metadata variable;
              %do i=1 %to &Metadata_total;
                  %if "&&scrf_variable_&i" ne "" 
                      and (%upcase("&&scrf_type_&i") = "CHAR"
                      or %upcase("&&scrf_type_&i") = "CHARACTER")              
                      and (%upcase("&&sacq_format_&i") = "YYYY-MM-DD"
                      or %upcase("&&sacq_format_&i") = "YYYYMMDD") %then %do;

                      if not missing(_&&scrf_variable_&i) and missing(&&scrf_variable_&i) then do;
                          * Output any data that did not map to char YYYY-MM-DD format per 
                            submacro pfesacq_map_scrf_char_dates;
                          issue = .;
                          issue_id = "CK_V3";
                          priority = "WARNING";
                          desc = "SCRF Char date did not map to SACQ Char Date";
                          desc_info = "SCRF &dataset..&&scrf_variable_&i value did not map to SCRF date format of YYYY-MM-DD. Value dropped.";
                          key = catx("-",SITEID,SUBJID,ACTEVENT,DOCNUM,REPEATSN);
                          scrf_dataset = "&dataset";
                          scrf_variable = "&&scrf_variable_&i";
                          scrf_variable_value = _&&scrf_variable_&i;
                          sacq_variable_value = &&scrf_variable_&i;                      
                          output Ck_V3;
                      end;
                  %end;
            %end; * End metadata cycle;
            delete;
      run;

      proc sql noprint;
        select count(*) into: flag
        from CK_V3;
      quit;

      %if &flag > 0 %then %do;
          data listing_tab5;
          set listing_tab5 CK_V3;
          run;
      %end;
      %_EndCheck(check=CK_V3, status=&flag Issues found in &dataset);

********************************************************************************
* CK_V4 - SCRF Char time did not map to SACQ Char time;  
      %_StartCheck(checkid=CK_V4, check=SCRF Char time did not map to SACQ Char time);
      data CK_V4(keep=issue--sacq_variable_value);
          attrib &listing_tab5;
          set work._temp2;
          issue = .;
          issue_id = "";
          priority = "";
          desc = "";
          desc_info = "";
          key = "";
          scrf_dataset = "";
          scrf_variable = "";
          scrf_variable_value = "";
          sacq_variable_value = "";  

          * Cycle through every metadata variable;
          %do i=1 %to &Metadata_total;
              %if "&&scrf_variable_&i" ne "" 
                  and (%upcase("&&scrf_type_&i") = "CHAR"
                  or %upcase("&&scrf_type_&i") = "CHARACTER")              
                  and (%upcase("&&sacq_format_&i") = "HH:MM:SS"
                  or %upcase("&&sacq_format_&i") = "HHMMSS") %then %do;

                  if not missing(_&&scrf_variable_&i) and missing(&&scrf_variable_&i) then do;
                      * Output any data that did not map to char YYYY-MM-DD format per 
                        submacro pfesacq_map_scrf_char_dates;
                      issue = .;
                      issue_id = "CK_V4";
                      priority = "WARNING";
                      desc = "SCRF Char time did not map to SACQ Char time";
                      desc_info = "SCRF &dataset..&&scrf_variable_&i value did not map to SCRF time format of HH:MM:SS. Value dropped.";
                      key = catx("-",SITEID,SUBJID,ACTEVENT,DOCNUM,REPEATSN);
                      scrf_dataset = "&dataset";
                      scrf_variable = "&&scrf_variable_&i";
                      scrf_variable_value = _&&scrf_variable_&i;
                      sacq_variable_value = &&scrf_variable_&i;                      
                      output CK_V4;
                  end;
              %end;
        %end; * End metadata cycle;
        delete;
      run;

      proc sql noprint;
        select count(*) into: flag
        from CK_V4;
      quit;

      %if &flag > 0 %then %do;
          data listing_tab5;
          set listing_tab5 CK_V4;
          run;
      %end;
      %_EndCheck(check=CK_V4, status=&flag Issues found in &dataset);

********************************************************************************
* CK_V5 - SACQ Header Variable value is NULL;  
      %_StartCheck(checkid=CK_V5, check=SACQ Header Variable value is NULL);
      data CK_V5(keep=issue--sacq_variable_value);
          attrib &listing_tab5;
          set work._temp2;
          issue = .;
          issue_id = "";
          priority = "";
          desc = "";
          desc_info = "";
          key = "";
          scrf_dataset = "";
          scrf_variable = "";
          scrf_variable_value = "";
          sacq_variable_value = "";  

          * Cycle through every metadata variable;
          %do i=1 %to &Metadata_total;
              %if "&&scrf_variable_&i" = "ACCESSTS"
                  or "&&scrf_variable_&i" = "ACTEVENT"
                  or "&&scrf_variable_&i" = "COLLDATE"
                  or "&&scrf_variable_&i" = "CPEVENT"
                  or "&&scrf_variable_&i" = "INV"
                  or "&&scrf_variable_&i" = "LSTCHGTS"
                  or "&&scrf_variable_&i" = "PID"
                  or "&&scrf_variable_&i" = "PROJCODE"
                  or "&&scrf_variable_&i" = "PROTNO"
                  or "&&scrf_variable_&i" = "REPEATSN"
                  or "&&scrf_variable_&i" = "SID"
                  or "&&scrf_variable_&i" = "SITEID"
                  or "&&scrf_variable_&i" = "STUDY"
                  or "&&scrf_variable_&i" = "STUDYID"
                  or "&&scrf_variable_&i" = "SUBEVE"
                  or "&&scrf_variable_&i" = "SUBJID"
                  or "&&scrf_variable_&i" = "TRIALNO"
                  or "&&scrf_variable_&i" = "VISIT" %then %do;

                  if missing(_&&scrf_variable_&i) then do;
                      * Header or key variables are always required to have data;
                      issue = .;
                      issue_id = "CK_V5";
                      priority = "WARNING";
                      desc = "SACQ Header Variable value is NULL";
                      desc_info = "SCRF &dataset..&&scrf_variable_&i value is null. Pfizer standards requires all header/key variable values to present.";
                      key = catx("-",SITEID,SUBJID,ACTEVENT,DOCNUM,REPEATSN);
                      scrf_dataset = "&dataset";
                      scrf_variable = "&&scrf_variable_&i";
                      scrf_variable_value = "";
                      sacq_variable_value = &&scrf_variable_&i;                      
                      output CK_V5;
                  end;
              %end;
        %end; * End metadata cycle;
        delete;
      run;

      proc sql noprint;
        select count(*) into: flag
        from CK_V5;
      quit;

      %if &flag > 0 %then %do;
          data listing_tab5;
          set listing_tab5 CK_V5;
          run;
      %end;
      %_EndCheck(check=CK_V5, status=&flag Issues found in &dataset);

********************************************************************************
* CK_V6 - SCRF Dataset to SACQ Dataset Number of Obs Mismatch;  
      %_StartCheck(checkid=CK_V6, check=SCRF Dataset to SACQ Dataset Number of Obs Mismatch);

      * If no obs then no dataset to check;
      proc sql noprint;
        select count(*) into: nobs
        from sashelp.vtable
        where libname=%upcase("&tarOutput")
              and memname=%upcase("&dataset._SACQ");
      quit;
      %if &nobs > 0 %then %do;
          proc sql noprint;
            select count(*) into: scrf_number
            from &srcInput..&dataset;
          quit;      

          proc sql noprint;
            select count(*) into: sacq_number
            from &tarOutput..&dataset._SACQ;
          quit;

          %if &scrf_number ne &sacq_number %then %do;
              data CK_V6;
                  attrib &listing_tab5;
                  issue = .;
                  issue_id = "CK_V6";
                  priority = "ERROR";
                  desc = "SCRF Dataset to SACQ Dataset Number of Obs Mismatch";
                  desc_info = "SCRF &dataset has &scrf_number observations but SACQ &dataset._SACQ has &sacq_number observations.  These values must match.";
                  key = "N/A";
                  scrf_dataset = "&dataset";
                  scrf_variable = "N/A";
                  scrf_variable_value = "";
                  sacq_variable_value = "";  
              run;

              %let flag = 1;

              data listing_tab5;
              set listing_tab5 CK_V6;
              run;         
          %end;
          %else %do;
              %let flag = 0;
          %end;
      %end;
      %else %do;
          * No raw dataset obs so no SACQ dataset;
          %let flag = 0;
      %end;

      %_EndCheck(check=CK_V6, status=&flag Issues found in &dataset);

********************************************************************************
* CK_V7 - SCRF Dataset to SACQ Dataset Number of Unique Subjects Mismatch;  
      %_StartCheck(checkid=CK_V7, check=SCRF Dataset to SACQ Dataset Number of Unique Subjects Mismatch);

      * If no obs then no dataset to check;
      proc sql noprint;
        select count(*) into: nobs
        from sashelp.vtable
        where libname=%upcase("&tarOutput")
              and memname=%upcase("&dataset._SACQ");
      quit;
      %if &nobs > 0 %then %do;
          proc sql noprint;
            select count(*) into: scrf_number
            from (select distinct PID from &srcInput..&dataset);
          quit;      

          proc sql noprint;
            select count(*) into: sacq_number
            from (select distinct PID from &tarOutput..&dataset._SACQ);
          quit;

          %if &scrf_number ne &sacq_number %then %do;
              data CK_V7;
                  attrib &listing_tab5;
                  issue = .;
                  issue_id = "CK_V7";
                  priority = "ERROR";
                  desc = "SCRF Dataset to SACQ Dataset Number of Unique Subjects Mismatch";
                  desc_info = "SCRF &dataset has &scrf_number unique subjects but SACQ &dataset._SACQ has &sacq_number unique subjects.  These values must match.";
                  key = "N/A";
                  scrf_dataset = "&dataset";
                  scrf_variable = "N/A";
                  scrf_variable_value = "";
                  sacq_variable_value = "";  
              run;

              %let flag = 1;

              data listing_tab5;
              set listing_tab5 CK_V7;
              run;         
          %end;
          %else %do;
              %let flag = 0;
          %end;
      %end;
      %else %do;
          * No raw dataset obs so no SACQ dataset;
          %let flag = 0;
      %end;          

      %_EndCheck(check=CK_V7, status=&flag Issues found in &dataset);

********************************************************************************
* CK_V8 - SACQ header variable PROTNO does not equal global macro variable;  
      %_StartCheck(checkid=CK_V8, check=SACQ header variable PROTNO does not equal global macro variable);

      data CK_V8(keep=issue--sacq_variable_value);
          attrib &listing_tab5;
          set  &srcInput..&dataset;
          format _all_;
          
          issue = .;
          issue_id = "";
          priority = "";
          desc = "";
          desc_info = "";
          key = "";
          scrf_dataset = "";
          scrf_variable = "";
          scrf_variable_value = "";
          sacq_variable_value = ""; 

          if not missing(scrf_variable) and PROTNO ne "&PROTOCOL" then do;
              issue = .;
              issue_id = "CK_V8";
              priority = "ERROR";
              desc = "SACQ header variable PROTNO does not equal global macro variable";
              desc_info = "SCRF &dataset header/key variable PROTNO has value not matching project_setup.sas set global macro variable PROTOCOL [&PROTOCOL]. These values must match.";
              key = catx("-",SITEID,SUBJID,ACTEVENT,DOCNUM,REPEATSN);
              scrf_dataset = "&dataset";
              scrf_variable = "PROTNO";
              scrf_variable_value = PROTNO;
              sacq_variable_value = PROTNO; 
              output;
          end; 
          else 
              delete;
      run;

      proc sql noprint;
        select count(*) into: flag
        from CK_V8;
      quit;

      %if &flag > 0 %then %do;
          data listing_tab5;
          set listing_tab5 CK_V8;
          run;
      %end;

      %_EndCheck(check=CK_V8, status=&flag Issues found in &dataset);

********************************************************************************
* CK_V9 - SACQ Variable is R1 but has missing values;  
      %_StartCheck(checkid=CK_V9, check=SACQ Variable is R1 but has missing values);

      data CK_V9(keep=issue--sacq_variable_value);
          attrib &listing_tab5;
          set work._temp2;
          issue = .;
          issue_id = "";
          priority = "";
          desc = "";
          desc_info = "";
          key = "";
          scrf_dataset = "";
          scrf_variable = "";
          scrf_variable_value = "";
          sacq_variable_value = ""; 

          * Cycle through every metadata variable;
          %do i=1 %to &Metadata_total;
              %if &&scrf_variable_&i = &&sacq_variable_&i
                  and "&&scrf_variable_&i" ne 
                  and %upcase("&&sacq_core_&i") = "R1" 
                  and "&&scrf_variable_&i" ne "ACCESSTS"
                  and "&&scrf_variable_&i" ne "ACTEVENT"
                  and "&&scrf_variable_&i" ne "COLLDATE"
                  and "&&scrf_variable_&i" ne "COLLDATF"
                  and "&&scrf_variable_&i" ne "CPEVENT"
                  and "&&scrf_variable_&i" ne "INV"
                  and "&&scrf_variable_&i" ne "LSTCHGTS"
                  and "&&scrf_variable_&i" ne "PID"
                  and "&&scrf_variable_&i" ne "PROJCODE"
                  and "&&scrf_variable_&i" ne "PROTNO"
                  and "&&scrf_variable_&i" ne "REPEATSN"
                  and "&&scrf_variable_&i" ne "SID"
                  and "&&scrf_variable_&i" ne "SITEID"
                  and "&&scrf_variable_&i" ne "STUDY"
                  and "&&scrf_variable_&i" ne "STUDYID"
                  and "&&scrf_variable_&i" ne "SUBEVE"
                  and "&&scrf_variable_&i" ne "SUBJID"
                  and "&&scrf_variable_&i" ne "TRIALNO"
                  and "&&scrf_variable_&i" ne "VISIT" %then %do;

                  if missing(_&&sacq_variable_&i) then do;
                      issue = .;
                      issue_id = "CK_V9";
                      priority = "WARNING";
                      desc = "SACQ Variable is R1 but has missing values";
                      desc_info = "SCRF &dataset..&&scrf_variable_&i is required R1 variable but the value is missing. It is required to always have values.";
                      key = catx("-",SITEID,SUBJID,ACTEVENT,DOCNUM,REPEATSN);
                      scrf_dataset = "&dataset";
                      scrf_variable = "&&scrf_variable_&i";
                      scrf_variable_value = "";
                      sacq_variable_value = &&sacq_variable_&i;
                      output;                      
                  end;
              %end;
          %end; * End metadata cycle;
          delete;
      run;

      proc sql noprint;
        select count(*) into: flag
        from CK_V9;
      quit;

      %if &flag > 0 %then %do;
          data listing_tab5;
          set listing_tab5 CK_V9;
          run;
      %end;

      %_EndCheck(check=CK_V9, status=&flag Issues found in &dataset);

********************************************************************************
* CK_V10 - SACQ Variable is R2 but no values are populated;  

      %_StartCheck(checkid=CK_V10, check=SACQ Variable is R2 but no values are populated);

      data CK_V10(keep=issue--sacq_variable_value);
          attrib &listing_tab5;
          issue = .;
          issue_id = "";
          priority = "";
          desc = "";
          desc_info = "";
          key = "";
          scrf_dataset = "";
          scrf_variable = "";
          scrf_variable_value = "";
          sacq_variable_value = "";
      run;

      * Cycle through every metadata variable;
        %do i=1 %to &Metadata_total;
            %if &&scrf_variable_&i = &&sacq_variable_&i
                and "&&scrf_variable_&i" ne 
                and %upcase("&&sacq_core_&i") = "R2" %then %do;

                proc sql noprint;
                    select count(*) into: cnt_r2
                    from _temp2
                    where _&&sacq_variable_&i is not null;
                quit;

                %if cnt_r2 = 0 %then %do;
                    data _CK_V10(keep=issue--sacq_variable_value);
                        attrib &listing_tab5;
                        issue = .;
                        issue_id = "CK_V10";
                        priority = "WARNING";
                        desc = "SACQ Variable is R2 but no values are populated";
                        desc_info = "SCRF &dataset..&&scrf_variable_&i is required R2 variable but no values were populated. It is required to have at least one value.";
                        key = "N/A";
                        scrf_dataset = "&dataset";
                        scrf_variable = "&&scrf_variable_&i";
                        scrf_variable_value = "";
                        sacq_variable_value = ""; 
                    run;

                    proc sql noprint;
                      select count(*) into: flag1
                      from _CK_V10;
                    quit;

                    %if &flag1 > 0 %then %do;
                        data CK_V10;
                            set CK_V10 _CK_V10;
                        run;
                    %end;
                %end; * End R2 no obs found check;
            %end; * End R2 var check;
        %end; * End metadata cycle;

        proc sql noprint;
          select count(*) into: flag2
          from CK_V10;
        quit;

        %if &flag2 > 0 %then %do;
            data listing_tab5;
            set listing_tab5 CK_V10;
            run;
        %end;


      %_EndCheck(check=CK_V10, status=&flag2 Issues found in &dataset);

********************************************************************************
* CK_V11 - SCRF or RAW dataset contains 0 observations;

      %_StartCheck(checkid=CK_V11, check=SCRF or RAW dataset contains 0 observations);        

      * If no obs then no dataset to check;
      proc sql noprint;
        select count(*) into: nobs
        from sashelp.vtable
        where libname=%upcase("&tarOutput")
              and memname=%upcase("&dataset._SACQ");
      quit;
      %if &nobs > 0 %then %do;
          proc sql noprint;
            select count(*) into: sacq_number
            from &tarOutput..&dataset._SACQ;
          quit;

          %if &sacq_number = 0 %then %do;
              data CK_V11;
                  attrib &listing_tab5;
                  issue = .;
                  issue_id = "CK_V11";
                  priority = "ERROR";
                  desc = "SCRF or RAW dataset contains 0 observations";
                  desc_info = "Any dataset that does not have any observations will not be included in the transfer.  This will cause failure at Pfizer CAL read.";
                  key = "N/A";
                  scrf_dataset = "&dataset";
                  scrf_variable = "N/A";
                  scrf_variable_value = "";
                  sacq_variable_value = "";  
              run;

              %let flag = 1;

              data listing_tab5;
              set listing_tab5 CK_V11;
              run;         
          %end;
          %else %do;
              %let flag = 0;
          %end;
      %end;
      %else %do;
          * No raw dataset obs so no SACQ dataset;
          %let flag = 0;
      %end;          

      %_EndCheck(check=CK_V11, status=&flag Issues found in &dataset);

********************************************************************************
* Modidy for output;

    * Total of tab4 will be starting number for tab5 issue if present;
    proc sql noprint;
        select count(*) into: _total_lab4
        from Listing_TAB4;
    quit;

    * Sort and remove any blank records;
    proc sort data = Listing_TAB5(where=(not missing(issue_id))); 
        by issue_id scrf_dataset scrf_variable; 
    run;

    * Derive issue number (starting with tab4 max obs + 1);
    data Listing_TAB5;
        set Listing_TAB5;
        issue = _n_ + &_total_lab4;
    run; 

********************************************************************************
* End of Macro;
  %put ---------------------------------------------------------------------;
  %put PFESACQ_MAP_SCRF_VALIDATE_VALUE: End of Submacro;
  %put ---------------------------------------------------------------------;
%mend pfesacq_map_scrf_validate_value;