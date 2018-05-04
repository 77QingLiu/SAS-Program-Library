%macro mu_fileexist(filename,alert=p) ;
/*****************************************************************************************
******************************** PAREXEL International ***********************************
******************************************************************************************

Sponsor name: Generic
Study name: Generic, applicable to all
PAREXEL number: Generic

Program name: mu_fileexist.sas
Program location: generic/macros/

Requirements/Purpose: MACRO UTILITY (MU): Determines if an external file exists by using its PATH and name

References: None

Assumptions: None

Input  : FILENAME: The name of the file (including path) to check for existence
         ALERT   : Optional parameter to control how alert messages are written to the SAS/LOg

Output : Macro variable containing the value:
         0 - if the file does not exists
         1 - if the file does exist
        -1 - if an unexpected outcome occurs or missing required parameters
         A calling program check for a postive value is sufficient

Usage Notes: Used within conditional logic or a macro assignment statement
             NOTES: [1] Can not be used as an inline statement.
                    [2] The FILEREF must be assigned usingthe FILENAME statement before invoking 
                        this utility

Programs called: None

******************************************************************************************
Version: 1

Release Date: 27-Feb-2012

Developer/Programmer: Darrell Edgley

*****************************************************************************************
Version: N (always increment by full integers)

Release Date: dd-mon-yyyy date code gets released in to production

Developer/Programmer: enter name of programmer finalizing this change

Details of change: provide a summary of all implemented changes
If applicable list any changes to requirements, references, assumptions, inputs, outputs or
called
*****************************************************************************************
*/

  %let rc = -1 ;

  %if %str("&filename") = %str("") %then %do ;
    %put ALERT_P: &SYSMACRONAME requires that the FILENAME parameter be supplied with an eternal file name (and path if necessary) ;
    %let rc = 0 ;
  %end ;
  %else %do ;
    %**************************************************************************** ;
    %* Check if the external file is valid ....                                ** ;
    %**************************************************************************** ;

    %let _fileex = %sysfunc(fileexist("&filename")) ;

    %if &_fileex >= 1 %then %do ;
      %let rc = 1 ;
    %end ;
    %else %do ;
      %if %upcase(&alert) NE %str(N) %then %do ;
        %put ----------------------------------------------------------------------------------------------;
        %put ALERT_%upcase(&alert): The filename %cmpres(&filename) can not be found. ;
        %put ----------------------------------------------------------------------------------------------;
      %end ;
      %let rc = 0 ;
    %end ;
  %end ;

  %* NOTE: The numeric values below must not have semi-colons after them.  These values are returned ** ;
  %* to the calling program.                                                                         ** ;

  %if %eval(&rc) >= 1 %then %do ;
    1
  %end ;
  %else %if %eval(&rc) = 0 %then %do ;
    0
  %end ;
  %else %do ;
    -1
  %end ;
%mend mu_fileexist ;
