/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX
  Example Call:          Note: Part of program: pfesacq_map_scrf 
               
						             Call from parent submacro pfesacq_map_scrf_process_ds.sas:
	                       %pfesacq_map_scrf_char_dates(
	                          inVar=_&&scrf_variable_&i, 
	                    	    outVar=&&scrf_variable_&i);

-------------------------------------------------------------------------------
 
  Author:                Nathan Hartley, Nathan Johnson, $LastChangedBy: hartlen $
  Creation Date:         12FEB2015                       $LastChangedDate: 2016-01-27 15:16:51 -0500 (Wed, 27 Jan 2016) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/unittesting/testing_area/macros/partnership_macros/pfe/pfesacq_map_scrf_char_dates.sas $
 
  Files Created:         None
 
  Program Purpose:       Map raw character dates to YYYY-MM-DD format with 
                         unknowns as YYYY-XX-XX 
 
                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:
 
    Name:                inVar
      Allowed Values:    Valid SAS variable that holds a char date
      Default Value:     null
      Description:       Input variable name that is a character date in the 
                         format of YYYY-MM-DD, DDMMMYYYY, or DD-MMM-YYY with 
                         possible unknowns
 
    Name:                outVar
      Allowed Values:    Valid SAS variable that will hold char date 
                         as YYYY-MM-DD
      Default Value:     null
      Description:       Output variable name that will now hold the character 
                         date of format YYYY-MM-DD
 
  Macro Output:     

    Name:                outVar
      Type:              Macro parameter
      Allowed Values:    Valid SAS variable name
      Default Value:     null
      Description:       Returns char date value as YYYY-MM-DD

  Macro Dependencies:    Note: Part of program: pfesacq_map_scrf 

                         This is a submacro dependant on calling parent macro: 
                         pfesacq_map_scrf_process_ds.sas

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 1742 $
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
Note: Version based on parent macro PFESACQ_MAP_SCRF

Version: 1.0 Date: 20150212 Author: Nathan Hartley

Version: 2.0 Date: 20151229 Author: Nathan Hartley
  1) Updated put statements to match updated test validation

Version: 3.0 Date: 20160127 Author: Nathan Hartley
  1) Add mapping of XXXXXYYYY to YYYY-XX-XX dates

-----------------------------------------------------------------------------*/

%macro pfesacq_map_scrf_char_dates(inVar=null, outVar=null);
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_MAP_SCRF_CHAR_DATES: Start of Submacro;
    %put NOTE:[PXL] PFESACQ_MAP_SCRF_CHAR_DATES: inVar=&inVar, outVar=&outVar;
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put ;
    
    &inVar = left(trim(upcase(compress(&inVar,,'WK'))));

    _endflag=0;

    if missing(&inVar) then do;
        &outVar = '';
        _endflag=1;
    end;

	* YYYY* Year is not Valid;
	    if _endflag=0 and length(&inVar) >= 4 then do;
	    	if verify(substr(&inVar,1,4),'0123456789') = 0
	           and not missing(input(substr(&inVar,1,4),?? 8.)) and 
	           (1850 > input(substr(&inVar,1,4),?? 8.) or input(substr(&inVar,1,4),?? 8.) > 3015) then do;
       			&outVar = '';
       			_endflag=1;
       		end;
	    end;

	* DDMMMYYYY Year is not Valid;
		if _endflag=0 and length(&inVar) >= 9 then do;
	    	if verify(substr(&inVar,6,4),'0123456789') = 0
	       	   and not index(&inVar,'-')
	           and not missing(input(substr(&inVar,6,4),?? 8.)) and 
	           (1850 > input(substr(&inVar,6,4),?? 8.) or input(substr(&inVar,6,4),?? 8.) > 3015) then do;
       			&outVar = '';
       			_endflag=1;
       		end;
	    end;

	* DD-MMM-YYYY Year is not Valid;
		if _endflag=0 and length(&inVar) >= 11 then do;
    		if verify(substr(&inVar,8,4),'0123456789') = 0
               and not missing(input(substr(&inVar,8,4),?? 8.)) 
    	       and substr(&inVar,3,1) = '-' and substr(&inVar,7,1) = '-'
    	       and (1850 > input(substr(&inVar,8,4),?? 8.) or input(substr(&inVar,8,4),?? 8.) > 3015) then do;
   				&outVar = '';
   				_endflag=1;
       		end;
    	end;

	* DD-MMM---YY is not Valid;
    	if _endflag=0 and length(&inVar) >= 9 then do;
    		if substr(&inVar,7,3) = '---' then do;
				&outVar = '';
				_endflag=1;
       		end;
		end;

	* Valid YYYY-MM-DD dates;
		if _endflag=0 and length(&inVar) = 10 then do;
    		if substr(&inVar,5,1) = '-' and substr(&inVar,8,1) = '-'
               and not missing (input(&inVar,?? YYMMDD10.)) then do;
        		&outVar = left(trim(put(input(&inVar,YYMMDD10.),YYMMDD10.)));
        		_endflag=1;
        	end;
    	end;

	* Valid DDMMMYYYY dates;
		if _endflag=0 and length(&inVar) = 9 then do;
    		if not index(&inVar,'-')
               and not missing(input(&inVar,?? DATE9.)) then do;
        		&outVar = left(trim(put(input(&inVar,DATE9.),YYMMDD10.)));
        		_endflag=1;
        	end;
    	end;	    	

	* Valid DD-MMM-YYYY or D-MMM-YYYY dates;
		if _endflag=0 and length(&inVar) >= 10 then do;
    		if (substr(&inVar,2,1) = '-' or substr(&inVar,3,1) = '-') 
               and not missing (input(&inVar,?? DATE11.)) then do;
        		&outVar = left(trim(put(input(&inVar,DATE11.),YYMMDD10.)));
        		_endflag=1;
        	end;
    	end;

	* Check unknowns;
		if &inVar in ('UNK','UNK-UN','UNK-UN-UN','UNK-UK-UK','UNK-UK','UNUNUNK','UKUKUNK','UNUKUNK') then do;
	        &outVar = '';
	        _endflag=1;
    	end;

	* YYYY-XX-XX;
		if _endflag=0 and length(&inVar) >= 10 then do;
    		if substr(&inVar,6,2) in ('','UN','XX','UK','NK') 
	           and substr(&inVar,9,2) in ('','UN','XX','UK','NK') then do;
        		&outVar = catx('-',substr(&inVar,1,4),"XX","XX");
        		_endflag=1;
        	end;
    	end;

	* YYYY-MM-XX;
		if _endflag=0 and length(&inVar) >= 10 then do;
    		if 01 <= input(substr(&inVar,6,2),?? 8.) <= 12 
	           and substr(&inVar,9,2) in ('','UN','XX','UK','NK') then do;
        		&outVar = catx('-',substr(&inVar,1,4),substr(&inVar,6,2),"XX");
        		_endflag=1;
        	end;
    	end;

	* YYYY-XX-DD;
		if _endflag=0 and length(&inVar) >= 10 then do;
    		if substr(&inVar,6,2) in ('UN','XX','UK','NK') 
	           and 01 <= input(substr(&inVar,9,2),?? 8.) <= 31 then do;
        		&outVar = catx('-',substr(&inVar,1,4),"XX",substr(&inVar,9,2));
        		_endflag=1;
        	end;
    	end;

	* UNUNKYYYY or XXXXXYYYY;
		if _endflag=0 and length(&inVar) >= 9 then do;
    		if substr(&inVar,1,5) = 'UNUNK' or substr(&inVar,1,5) = 'XXXXX'
               and 1850 < input(substr(&inVar,6,4),?? 8.) < 3015 then do;
        		&outVar = catx('-',substr(&inVar,6,4),"XX","XX");
        		_endflag=1;
        	end;
    	end;

	* UNUNYYYY;
		if _endflag=0 and length(&inVar) >= 9 then do;
    		if substr(&inVar,1,4) = 'UNUN' 
               and 1850 < input(substr(&inVar,5,4),?? 8.) < 3015 then do;
        		&outVar = catx('-',substr(&inVar,5,4),"XX","XX");
        		_endflag=1;
        	end;
    	end;    

	* DUNKYYYY or DXXXYYYY;
		if _endflag=0 and length(&inVar) >= 8 then do;
    		if (substr(&inVar,2,3) = 'UNK' or substr(&inVar,2,3) = 'XXX')
               and 1 <= input(substr(&inVar,1,1),?? 8.) <= 9 
               and 1850 < input(substr(&inVar,5,4),?? 8.) < 3015 then do;
        		&outVar = catx('-',substr(&inVar,5,4),"XX","0"||substr(&inVar,1,1)); 
        		_endflag=1;
        	end;
    	end;

	* DDUNKYYYY or DDXXXYYYY;
		if _endflag=0 and length(&inVar) >= 9 then do;
    		if (substr(&inVar,3,3) = 'UNK' or substr(&inVar,3,3) = 'XXX')
               and 1 <= input(substr(&inVar,1,2),?? 8.) <= 31
               and 1850 < input(substr(&inVar,6,4),?? 8.) < 3015 then do;
        		&outVar = catx('-',substr(&inVar,6,4),"XX",substr(&inVar,1,2)); 
        		_endflag=1;
        	end;
    	end;

	* UNMMMYYYY;
		if _endflag=0 and length(&inVar) >= 9 then do;
    		if substr(&inVar,1,2) in ('UN','XX','UK')
               and substr(&inVar,3,3) in ('JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC') 
               and 1850 < input(substr(&inVar,6,4),?? 8.) < 3015 then do;
        		&outVar = substr(left(trim(put(input("01"||substr(&inVar,3,7), DATE9.),YYMMDD10.))),1,8)||"XX";  
        		_endflag=1;
        	end;
    	end;

	* UN-UNK-YYYY or UK-UNK-YYYY;
		if _endflag=0 and length(&inVar) >= 11 then do;
    		if substr(&inVar,1,7) in ("UN-UNK-","UK-UNK-","XX-XXX-") then do;
        		&outVar = catx('-',substr(&inVar,8,4),"XX","XX");  
        		_endflag=1;
        	end;
    	end;

	* UN-UN-YYYY or UK-UK-YYYY or XX-XX-YYYY;
		if _endflag=0 and length(&inVar) >= 10 then do;
    		if substr(&inVar,1,6) in ("UN-UN-","UK-UK-","XX-XX-") then do;
        		&outVar = catx('-',substr(&inVar,7,4),"XX","XX");   
        		_endflag=1;
        	end;
    	end;

	* D-UNK-YYYY;
		if _endflag=0 and length(&inVar) >= 10 then do;
    		if substr(&inVar,2,4) = '-UNK' 
               and 1 <= input(substr(&inVar,1,1),?? 8.) <= 9 
               and 1850 < input(substr(&inVar,7,4),?? 8.) < 3015 then do;
        		&outVar = catx('-',substr(&inVar,7,4),"XX","0"||substr(&inVar,1,1));    
        		_endflag=1;
        	end;
    	end;

	* DD-UNK-YYYY or DD-XXX-YYYY;
		if _endflag=0 and length(&inVar) >= 11 then do;
    		if (substr(&inVar,3,4) = '-UNK' or substr(&inVar,3,4) = '-XXX')
               and 1 <= input(substr(&inVar,1,2),?? 8.) <= 31
               and 1850 < input(substr(&inVar,8,4),?? 8.) < 3015 then do;
        		&outVar = catx('-',substr(&inVar,8,4),"XX",substr(&inVar,1,2));    
        		_endflag=1;
        	end;
    	end;

	* UN-MMM-YYYY;
		if _endflag=0 and length(&inVar) >= 11 then do;
    		if substr(&inVar,1,2) in ('UN','XX','UK')
               and substr(&inVar,4,3) in ('JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC') 
               and 1850 < input(substr(&inVar,8,4),?? 8.) < 3015 
               and not missing(input(compress("01"||substr(&inVar,4,8),'-'),?? DATE9.)) then do;
        		&outVar = substr(left(trim(put(input(compress("01"||substr(&inVar,4,8),'-'), DATE9.),YYMMDD10.))),1,8)||"XX";    
        		_endflag=1;
        	end;
    	end;

    if _endflag=0 then do;
    	&outVar = ''; * Drop date values not expected;        
    end;

    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_MAP_SCRF_CHAR_DATES: End of Submacro;
    %put NOTE:[PXL] ---------------------------------------------------------------------;
%mend pfesacq_map_scrf_char_dates;