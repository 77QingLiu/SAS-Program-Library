/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX
  Example Call:          Note: Part of program: pfesacq_map_scrf 
               
                         Called from parent macro pfesacq_map_scrf:
                         %pfesacq_map_scrf_validate_struct;

-------------------------------------------------------------------------------
 
  Author:                Nathan Hartley, Nathan Johnson, $LastChangedBy: johnson2 $
  Creation Date:         12FEB2015                       $LastChangedDate: 2015-09-22 12:10:16 -0400 (Tue, 22 Sep 2015) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/unittesting/testing_area/macros/partnership_macros/pfe/pfesacq_map_scrf_validate_struct.sas $
 
  Files Created:         None
 
  Program Purpose:       Verify input or source data per structure 
                         'Validation Checks'
 
                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Sources:
 
    1) Work SAS dataset _METADATA (created in parent macro)
 
  Macro Output:     

    Name:                Listing_TAB4
      Type:              SAS work dataset
      Allowed Values:    N/A
      Default Value:     N/A
      Description:       Verifies structure checks as specified per tab 
                         'Validation Checks' and filered on 
                         'Structure Exceptions' on the study design plan


  Macro Dependencies:    This is a submacro dependant on calling parent macro: 
                         pfesacq_map_scrf.sas

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 1103 $

Version: 8.0 Date: 22SEP2015 Author: Nathan Johnson
	Updates:
	1) Modify check C1 to no longer display spurious results when datasets existed
       but not all variables were in sACQ.
    2) Include call to endcheck macro for check _S3.

-----------------------------------------------------------------------------*/

%macro pfesacq_map_scrf_validate_struct;
  	%put ---------------------------------------------------------------------;
  	%put PFESACQ_MAP_SCRF_VALIDATE_STRUCT: Start of Submacro;
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
    * Create structure and value exception dataset shells;

      %let el_struct_attrib = 
        issue              length=   8 label="Issue #"
        issue_id           length=$200 label="Issue ID"
        priority           length=$200 label="Issue Priority"
        desc               length=$200 label="Issue Description"
        scrf_dataset       length=$200 label="SCRF Dataset"
        scrf_dataset_label length=$256 label="SCRF Dataset Label"
        scrf_variable      length=$200 label="SCRF Variable"
        scrf_type          length=$200 label="SCRF Type"
        scrf_length        length=   8 label="SCRF Length"
        scrf_format        length=$200 label="SCRF Format"
        scrf_label         length=$256 label="SCRF Label"
        sacq_dataset       length=$200 label="SACQ Dataset"
        sacq_variable      length=$200 label="SACQ Variable"
        sacq_core          length=$200 label="SCRF Core"
        sacq_type          length=$200 label="SCRF Type"
        sacq_length        length=   8 label="SCRF Length"
        sacq_format        length=$200 label="SCRF Format"
        sacq_codelist      length=$200 label="SCRF Codelist"
        sacq_label         length=$256 label="SCRF Label";

    ********************************************************************************
    * CK_S1: SCRF Dataset exists that is not in SACQ Standards;
      %_StartCheck(checkid=CK_S1, check=SCRF Dataset exists that is not in SACQ Standards);

      * Get list of SCRF datasets that do not have any variable match to SACQ;
      proc sql noprint;
        create table _CK_S1 as 
        select distinct
          scrf_dataset length=50,
          scrf_dataset_label length=50 
        from (
                select distinct 
                    scrf_dataset, 
                    scrf_dataset_label, 
                    sacq_dataset 
                from _metadata 
                where scrf_dataset is not null and sacq_dataset is null
                        and scrf_dataset not in 
                            (select distinct scrf_dataset
                                from _metadata
                                where scrf_dataset is not null and sacq_dataset is not null
                            )
             )
        group by scrf_dataset
        having count(scrf_dataset) = 1;
        
      quit;

      data CK_S1(keep=issue--sacq_label);
        attrib &el_struct_attrib;
        set _CK_S1;

        if not missing(scrf_dataset) then do;
          issue    = .;
          issue_id = 'CK_S1';
          priority = "%str(WARN)ING";
          desc     = "SCRF Dataset exists that is not in SACQ Standards";
          scrf_variable = 'N/A';
          scrf_type     = '';
          scrf_length   = .;
          scrf_format   = '';
          scrf_label    = '';
          sacq_dataset  = 'N/A';
          sacq_variable = 'N/A';
          sacq_core     = '';
          sacq_type     = '';
          sacq_length   = .;
          sacq_format   = '';
          sacq_codelist = '';
          sacq_label    = '';
          if upcase(scrf_dataset)='LAB_SAFE1' then do;
            priority = "NOTE";
            end;
          output;
        end;
        else do;
          delete;
        end;
      run;

      proc sql noprint;
        select count(*) into: flag
        from CK_S1;
      quit;
      %_EndCheck(check=CK_S1, status=&flag Issues);

    ********************************************************************************
    * CK_S2: SCRF Variable exists but is not in SACQ Standards;
      %_StartCheck(checkid=CK_S2, check=SCRF Variable exists but is not in SACQ Standards);

      data _CK_S2(keep=issue--sacq_label);
        attrib &el_struct_attrib;
        set _metadata;

        if not missing(scrf_variable) and missing(sacq_variable) then do;
          issue    = .;
          issue_id = 'CK_S2';
          priority = "NOTE";
          desc     = "SCRF Variable exists but is not in SACQ Standards";
          sacq_dataset = "N/A";
          sacq_variable = "N/A";
          output;
        end;
        else do;
          delete;
        end;
      run;

      proc sql noprint;
          create table CK_S2 as 
          select a.*
          from _CK_S2 as a
               left join 
               _CK_S1 as b
          on a.scrf_dataset = b.scrf_dataset
          where b.scrf_dataset is null
                and a.scrf_dataset ne 'LAB_SAFE1';
      quit;

      proc sql noprint;
        select count(*) into: flag
        from CK_S2;
      quit;
      %_EndCheck(check=CK_S2, status=&flag Issues);

    ********************************************************************************
    * CK_S3: SACQ Variable is required but not found;
        %_StartCheck(checkid=CK_S3, check=SACQ Variable is required but does not exist);

        /*
        proc sql noprint;
          create table _CK_S3 as
          select a.*
          from _metadata as a
               inner join
               (select distinct scrf_dataset from _metadata where not missing(scrf_dataset)) as b
          on upcase(a.m_dataset) = upcase(catx('_',b.scrf_dataset,'SACQ'))
          where upcase(sacq_core) in ('r','R','R1','R2','R3','REQUIRED');
        quit;
        */
        
        proc sql noprint;
            create table _CK_S3 as
            select *
            from _metadata
            where upcase(sacq_core) in ('r','R','R1','R2','R3','REQUIRED')
                   and scrf_variable is null
                   and sacq_dataset in (select distinct sacq_dataset 
                                        from _metadata 
                                        where scrf_dataset is not null
                                        )
            ;
        quit;
        
        data CK_S3(keep=issue--sacq_label);
          attrib &el_struct_attrib;
          set _CK_S3;

          issue         = .;
          issue_id      = 'CK_S3';
          priority      = "%str(ERR)OR";
          desc          = "SACQ Variable is required but not found";
          scrf_dataset  = "N/A";
          scrf_variable = "N/A";
        run;

        proc sql noprint;
          select count(*) into: flag
          from CK_S3;
        quit;
        %_EndCheck(check=CK_S3, status=&flag Issues);

    ********************************************************************************
    * Modify for output;
    
    * Create work dataset Listing_TAB4;
      data Listing_TAB4;
        set CK_S1 CK_S2 CK_S3;
      run;

    * Sort and remove any blank records;
    proc sort data = Listing_TAB4(where=(not missing(issue_id))); 
        by issue_id scrf_dataset scrf_variable; 
    run;

    * Derive issue number;
    data Listing_TAB4;
        set Listing_TAB4;
        issue = _n_;
    run;

    * clean up datasets;
    proc datasets library=work nolist;
        delete _ck: ck:;
        run;
    quit;
    
    ********************************************************************************
    * End of Macro;
    
    %put ---------------------------------------------------------------------;
    %put PFESACQ_MAP_SCRF_VALIDATE_STRUCT: End of Submacro;
    %put ---------------------------------------------------------------------;
%mend pfesacq_map_scrf_validate_struct;