/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX
  Example Call:          Note: Part of program: pfesacq_map_scrf 
               
                         Call from parent submacro pfesacq_map_scrf_process_ds.sas:
                         %pfesacq_map_scrf_char_times(
                            inVar=_&&scrf_variable_&i, 
                            outVar=&&scrf_variable_&i);

-------------------------------------------------------------------------------
 
  Author:                Nathan Hartley, Nathan Johnson, $LastChangedBy: hartlen $
  Creation Date:         12FEB2015                       $LastChangedDate: 2015-12-29 14:23:42 -0500 (Tue, 29 Dec 2015) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/unittesting/testing_area/macros/partnership_macros/pfe/pfesacq_map_scrf_char_times.sas $
 
  Files Created:         None
 
  Program Purpose:       Map raw character time values to HH:MM:SS 
 
                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:
 
    Name:                inVar
      Allowed Values:    Valid SAS variable that holds a char time
      Default Value:     null
      Description:       input variable name that is a character in the format 
                         of times HH:MM, HH:MM:SS, H:MM
 
    Name:                outVar
      Allowed Values:    Valid SAS variable that will hold char time of format 
                         HH:MM:SS
      Default Value:     null
      Description:       Output variable name that will now hold the character 
                         time of format HH:MM:SS
 
  Macro Output:     

    Name:                outVar
      Type:              Macro parameter
      Allowed Values:    Valid SAS variable name
      Default Value:     null
      Description:       Returns char time value as HH:MM:SS

  Macro Dependencies:    Note: Part of program: pfesacq_map_scrf 

                         This is a submacro dependant on calling parent macro: 
                         pfesacq_map_scrf_process_ds.sas

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 1625 $
  
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
Note: Version based on parent macro PFESACQ_MAP_SCRF

Version: 1.0 Date: 20150212 Author: Nathan Hartley

Version: 2.0 Date: 20151229 Author: Nathan Hartley
  Updates:
  1) Updated put statements to match updated test validation

-----------------------------------------------------------------------------*/

%macro pfesacq_map_scrf_char_times(inVar=null, outVar=null);
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_MAP_SCRF_CHAR_TIMES: Start of Submacro;
    %put NOTE:[PXL] PFESACQ_MAP_SCRF_CHAR_TIMES: inVar=&inVar, outVar=&outVar;
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put ;

    &inVar = left(trim(upcase(compress(&inVar,,'WK'))));

    _flag=0;

    * Verify characters used;
    if missing(&inVar) then do;
        &outVar = '';
        _flag=1;
    end;

    * Unacceptable character exists;
    if _flag=0 and verify(&inVar,'0123456789:APM ') ne 0 then do;
        &outVar = '';
        _flag=2;
    end;   

    * Time() formats;
    if _flag=0 and not missing(input(&inVar,?? TIME12.3)) then do;
        &outVar = left(trim(put(input(&inVar, TIME12.3), TIME8.)));
        _flag=3;
    end;

    * Time5 formats;
    if _flag=0 and not missing(input(&inVar,?? TIME5.)) then do;
        &outVar = left(trim(put(input(&inVar, TIME5.), TIME8.)));
        _flag=4;
    end;

    * Time8 formats;
    if _flag=0 and not missing(input(&inVar,?? TIME8.)) then do;
        &outVar = left(trim(put(input(&inVar, TIME8.), TIME8.)));
        _flag=5;
    end;     

    if _flag=0 then do;
        &outVar = '';
        _flag=6;
    end;

    * Pad front zero if not present;
    if length(&outVar) >= 2 then do;
        if substr(&outVar,2,1) = ":" then do;
            &outVar = "0" || &outVar;
        end;
    end;

    * If time is greater than 24:00:00 or not valid;
    if length(&outVar) >= 8 then do;
        if not missing(input(substr(&outVar,1, 2), 8.)) then do;
            if input(substr(&outVar,1, 2), 8.) = 24 then do;
                * 24:MM:00 and minutes > 0;
                if not missing(input(substr(&outVar,4, 2), 8.)) 
                   and input(substr(&outVar,4, 2), 8.) > 0 then do;
                    &outVar = '';
                    _flag=7;
                end;

                * 24:00:SS and seconds > 0;
                if not missing(input(substr(&outVar,7, 2), 8.)) 
                        and input(substr(&outVar,7, 2), 8.) > 0 then do;
                    &outVar = '';
                    _flag=8;
                end;
            end;
            else if input(substr(&outVar,1, 2), 8.) > 24 then do;
                &outVar = '';
                _flag=9;
            end;
        end;
    end;

    %macend:;
    %put ;
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_MAP_SCRF_CHAR_TIMES: End of Submacro;
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_map_scrf_char_times;