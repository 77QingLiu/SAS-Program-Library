/*----------------------------------------------------------------------------
DARE SAS Utility Macro: util_mvar_test.sas
GRADES Algorithm Reference: n/a
------------------------------------------------------------------------------
Purpose:

       Tests for the existence of a macro variable

Assumptions:
       This macro is able to run in a data step or procedure.

       Returns a 1 when the macro variable exists and 0 otherwise,
       assuming that the SASHELP.VMACRO view is available. Returns
       a -1 if the SASHELP.VHELP view is not available.

Calls to:
       -none-

Other Inputs:
       -none-

Other Outputs:
       -none-


Usage notes:

1) Write a message when an expected macro variable is not defined.

%if ^%util_mvar_test(_mvar=abcd) %then %put macro variable ABCD is not defined.

2) Globalize the variable that holds the returned number of
observations if not defined by the user of the NOBS macro ;

%macro nobs(data,_mvar=);

%if ^%util_mvar_test(_mvar=&_mvar) %then %do;
  %global &_mvar;
%end;

... see nobs code ...

%mend nobs;

-------------------------------------------------------------------------------
History
-------------------------------------------------------------------------------
This code was originally developed by HOFFMAN CONSULTING as part of a FREEWARE
macro tool set. Its use is restricted to current and former clients of
HOFFMAN CONSULTING as well as other professional colleagues. Questions
and suggestions may be sent to TRHoffman@sprynet.com.

11MAR99 TRHoffman Creation - with much help from Tom Abernathy.
-------------------------------------------------------------------------------
Revision 1.0 Kent Nassen 2002/08/05 Initial creation based on mvartest.sas
         from HCTOOLS as noted above.
-----------------------------------------------------------------------------*/
%macro util_mvar_test
(_mvar=   /* Name of macro variable */
);

%*****************************************************************************;
%* SPECIFICATION 0 -                                                         *;
%* - Define local variables needed by the program.                           *;
%*   _dsid = data set ID (return code from sys function OPEN)                *;
%*   _rc = return code from sys function CLOSE                               *;
%*****************************************************************************;
%local _dsid _rc;

%*****************************************************************************;
%* SPECIFICATION 1 -                                                         *;
%* - Use sys function OPEN to open sashelp.vmacro where name is _mvar        *;
%*      and scope is not UTIL_MVAR_TEST, assigning return code in _dsid.     *;
%* NOTE: may use dictionary.macros instead of sashelp.vmacro since that      *;
%*   should be faster.                                                       *;
%*****************************************************************************;
%let _dsid = %sysfunc(open(sashelp.vmacro(where=
  (name=%upcase("&_mvar") & scope ^= 'UTIL_MVAR_TEST'))));

%*****************************************************************************;
%* SPECIFICATION 2 -                                                         *;
%* - If macro variable _mvar was successfully found (_dsid is positive) then *;
%*   just eval that sys function FETCH of _dsid is not -1.  Should return 1  *;
%*   if the eval is true.  Use sys function CLOSE to close _dsid, assigning  *;
%*   _rc as the return code from the close.                                  *;
%*****************************************************************************;
%if (&_dsid) %then %do;
  %eval(%sysfunc(fetch(&_dsid)) ^= -1)
  %let _rc = %sysfunc(close(&_dsid));
%end;

%*****************************************************************************;
%* SPECIFICATION 3 -                                                         *;
%* - If macro variable _mvar was not found in sashelp.vmacro, then return    *;
%*   the value -1.                                                           *;
%*****************************************************************************;
%else
  -1
;

%mend util_mvar_test;