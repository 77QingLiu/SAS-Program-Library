/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX
  Example Call:          Note: Part of program: pfesacq_map_scrf 
               
                         Call from parent submacro pfesacq_map_scrf_process_ds.sas:
                         %pfesacq_map_scrf_codelist_num(
                         dataset_name=_temp2, 
					                   variable_name=&&scrf_variable_&i, 
					                   standard=&&sacq_codelist_standard_&i, 
					                   codelist_name=&&sacq_codelist_&i);

-------------------------------------------------------------------------------
 
  Author:                Nathan Hartley, Nathan Johnson, $LastChangedBy: hartlen $
  Creation Date:         12FEB2015                       $LastChangedDate: 2015-12-30 13:44:11 -0500 (Wed, 30 Dec 2015) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/unittesting/testing_area/macros/partnership_macros/pfe/pfesacq_map_scrf_codelist_num.sas $
 
  Files Created:         None
 
  Program Purpose:       Map raw numeric variables that have a codelist from 
                         sequence number to long label value 
 
                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:
 
    Name:                dataset_name
      Allowed Values:    Valid SAS dataset containing input var variable_name
      Default Value:     null
      Description:       Source Input SAS dataset
 
    Name:                variable_name
      Allowed Values:    Valid SAS variable that maps to a codelist
      Default Value:     null
      Description:       Output variable name that will now hold the character 
                         time of format HH:MM:SS

    Name:                standard
      Allowed Values:    DATA STANDARDS, GRADES, OTHER [values found in SACQ 
                         metadata CODELISTS]
      Default Value:     null
      Description:       Codelists categorized into standards, specifies which
                         codelist to use (same name between them)

    Name:                codelist_name
      Allowed Values:    Codelist name [values found in SACQ metadata 
                         CODELISTS]
      Default Value:     null
      Description:       Codelist name to look up value to code to long label
 
  Macro Output:     

    Name:                variable_name
      Type:              Macro parameter
      Allowed Values:    Valid SAS variable name
      Default Value:     null
      Description:       Returns long label if value found as sequence number
                         per codelist name from SACQ metadata CODELISTS

  Macro Dependencies:    Note: Part of program: pfesacq_map_scrf 

                         This is a submacro dependant on calling parent macro: 
                         pfesacq_map_scrf_process_ds.sas

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 1631 $

Version: 9.0 Date: 20150924 Author: Nathan Johnson
    Updates:
    1) Updated to remove input function for processing of numeric variables.

-----------------------------------------------------------------------------*/

%macro pfesacq_map_scrf_codelist_num(dataset_name=null, variable_name=null, standard=null, codelist_name=null);
	%put %STR(****************************************************);
	%put NOTE:[PXL] PFESACQ_MAP_SCRF_CODELIST_NUM: Start Submacro;
	%put NOTE:[PXL] PFESACQ_MAP_SCRF_CODELIST_NUM: dataset_name=&dataset_name, variable_name=&variable_name, standard=&standard, codelist_name=&codelist_name;
	proc sql noprint;
		create table _&dataset_name as
		select a.*, b.LONG_LABEL as &variable_name._LONGLABEL
		from &dataset_name as a 
		     left join
		     SACQ_MD.codelists as b 
		on b.standard = "&standard"
		   and b.codelist_name = "&codelist_name"
		   and a.&variable_name = b.SEQ_NUMBER;
	quit;

	data &dataset_name;
		set _&dataset_name;
		if not missing(&variable_name) and missing(&variable_name._LONGLABEL) then do;
            &variable_name = ''; * Drop non-codelist conformant values;
		end;
		else do;
			&variable_name = &variable_name._LONGLABEL;
		end;
	run;

	%put NOTE:[PXL] PFESACQ_MAP_SCRF_CODELIST_NUM: End of Submacro;
%mend pfesacq_map_scrf_codelist_num;