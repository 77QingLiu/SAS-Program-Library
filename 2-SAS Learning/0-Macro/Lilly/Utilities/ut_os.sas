%macro ut_os(osvar=_default_,sddvar=_default_,verbose=_default_,
 debug=_default_);
/*soh***************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME           : ut_os
CODE TYPE           : Broad-use Module
PROJECT NAME        :
DESCRIPTION         : Determines the operating system name and assigns
                       to a macro variable named by the OSVAR parameter.
                      Determines whether code is executing in SDD and returns
                       1 or 0 in a macro variable named by the SDDVAR parameter.
SOFTWARE/VERSION#   : SAS v9.1.3 and SAS v9.2
INFRASTRUCTURE      : SDD v3.4 and MS Windows
LIMITED-USE MODULES : N/A
BROAD-USE MODULES   : ut_parmdef ut_logical
INPUT               : SYSSCP system macro variable
                      SDD global macro variables _sddusr_ _sddprc_ sddparms
OUTPUT              : Two macro variables as specified by macro parameters
                       OSVAR and SDDVAR
VALIDATION LEVEL    : 6
REQUIREMENTS        : https://sddchippewa.sas.com/webdav/lillyce/qa/general/
                       bums/ut_os/documentation/ut_os_rd.doc
ASSUMPTIONS         :
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
BROAD-USE MODULE/LIMITED-USE MODULE SPECIFIC INFORMATION:

BROAD-USE MODULE TEMPORARY OBJECT PREFIX: none

PARAMETERS:
Name      Type     Default    Description and Valid Values
--------- -------- ---------- --------------------------------------------------
OSVAR     required os         The name of a macro variable to hold
                               the name of the operating system this macro is
                               running in.
SDDVAR    optional in_sdd     The name of a macro variable to hold SDD return -
                              Returns a value of 1 if running in SDD and a
                               value of 0 otherwise.
VERBOSE   required 1          %ut_logical value specifying whether verbose
                               mode is on or off
DEBUG     required 0          %ut_logical value specifying whether debug mode
                               is on or off.  Debug mode should only be used
                               by the macro code author when diagnosing
                               code to find problems.

USAGE NOTES:
    The value of osvar is usually the value of &sysscp, but it assigns a value
     of "unix" for any of the unix operating systems.  The case of the value
     of osvar is lower case.

TYPICAL WAYS TO EXECUTE THIS CODE AND DESCRIPTION, if applicable: optional
    %local os in_sdd;
    %ut_os

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

     Author &
Ver# Peer Reviewer    Request #        Broad-Use MODULE History Description
---- ---------------- ---------------- -----------------------------------------
1.0  Gregory Steffens BMRGCS21Jan2009A Original version of the code
      Mindy Rodgers

2.0  Chuck Bininger & BMRCB28MAR2011   Update header to reflect code validated
      Shong Demattos                   for SAS v9.2.  Modified header to maintain
                                       compliance with current SOP Code Header.

**eoh**************************************************************************/
%ut_parmdef(debug,0,_pdmacroname=ut_os,_pdrequired=1,_pdverbose=0)
%ut_logical(debug)
%ut_parmdef(verbose,1,_pdmacroname=ut_os,_pdrequired=1,_pdverbose=0)
%ut_parmdef(osvar,os,_pdmacroname=ut_os,_pdrequired=1,_pdverbose=0)
%ut_parmdef(sddvar,in_sdd,_pdmacroname=ut_os,_pdrequired=1,_pdverbose=0)
%ut_logical(verbose)
%if &debug %then %put (ut_os) macro starting;
%*=============================================================================;
%* Assign value to sddvar variable   1 if running in SDD  0 otherwise;
%*=============================================================================;
%let &sddvar = 0;
%if &sysver ^= 8.2 %then %do;
  %if %symglobl(_sddusr_) | %symglobl(_sddprc_) | %symglobl(sddparms)
   %then %let &sddvar = 1;
%end;
%if &debug %then %put (ut_os) sddvar = &sddvar = &&&sddvar;
%*=============================================================================;
%* When &SYSSCP is one of the types of unix assign osvar a value of unix;
%*  otherwise assign osvar a value of &SYSSCP;
%*=============================================================================;
%if &sysscp = SUN 4 | &sysscp = SUN 64 | &sysscp = RS6000 | &sysscp = ALXOSF |
 &sysscp = HP 300 | &sysscp = HP 800 | &sysscp = LINUX | &sysscp = RS6000 |
 &sysscp = SUN 3 | &sysscp = ALXOSF %then %let &osvar = unix;
%else %let &osvar = %sysfunc(lowcase(&sysscp));
%if &debug %then %put (ut_os) osvar = &osvar = &&&osvar  sysscp=&sysscp;
%if &debug %then %put (ut_os) macro ending;
%mend;
