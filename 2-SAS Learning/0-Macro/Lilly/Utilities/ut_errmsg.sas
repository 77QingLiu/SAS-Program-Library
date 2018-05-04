%macro ut_errmsg(msg       = _default_,
                 macroname = _default_,
                 type      = _default_,
                 log       = _default_,
                 print     = _default_,
                 max       = _default_,
                 counter   = _default_,
                 fileback  = _default_,
                 verbose   = _default_,
                 debug     = _default_);

/*soh***************************************************************************
Eli Lilly and Company - Global Statistical Sciences                    
CODE NAME           :  ut_errmsg  
CODE TYPE           :  Broad-use Module   
PROJECT NAME        : 
DESCRIPTION         :  This macro writes informational and
                       error messages to BOTH the SAS log and print
                       files.  
SOFTWARE/VERSION#   :  SAS v9.1.3 and SAS v9.2
INFRASTRUCTURE      :  SDD v3.4 and MS Windows 
LIMITED-USE MODULES :  N/A                
BROAD-USE MODULES   :  ut_parmdef, ut_logical
INPUT               :  N/A
OUTPUT              :  log and/or listing lines as defined by MSG
VALIDATION LEVEL    :  6                  
REQUIREMENTS        :  /lillyce/qa/general/bums/ut_errmsg/documentation/ 
                        ut_errmsg_rd.doc
ASSUMPTIONS         :  1. The syntax of the text string specified for parameter
                          MSG is valid.  See USAGE NOTES below for details.
                       2. The variable specified on parameter COUNTER is NOT a
                          variable in the progam data vector (PDV) in the DATA
                          step from which this module is called.  If it is, the 
                          module cannot detect this condition.  If the variable
                          is numeric, its values will be changed by this module.  
                          If it is character, non-programmed errors will result.
                       3. If the user specifies a fileref on parameter FILEBACK,
                          it must be LOG or PRINT, or a succussfully assigned
				          fileref. The module will detect invalid fileref names and 
	                      fileref names that have not been assigned, but it cannot 
                          detect filerefs that are not successfully assigned
                          because a FILENAME statement was issued with an invalid 
                          directory path.  The file represented by the fileref does 
                          not need to exist prior to the DATA step from which the 
                          module is called.
--------------------------------------------------------------------------------
BROAD-USE MODULE SPECIFIC INFORMATION:                        
BROAD-USE MODULE TEMPORARY OBJECT PREFIX: _ER                       
                      
Parameters:

Name      Type      Default  Description and Valid Values
--------  --------  -------- --------------------------------------------------
MSG       required           The text of the error message to display. See 
                             USAGE NOTES below.

MACRONAME required           The name of the macro calling UT_ERRMSG.  This 
                             macroname will be included when printing MSG so 
                             the user is informed what macro generated the 
                             message.

TYPE      optional  NOTE     The type of error message - NOTE, WARNING or ERROR
                             
LOG       required  1        %ut_logical value specifying whether to write the
                             error message to the SAS log file.

PRINT     required  1        %ut_logical value specifying whether to write the 
                             error message to the SAS print file.

MAX       optional  25       The maximum number of times to write the error 
                             message when called from a DATA step.  If MAX is 
                             null then no limit is put on the number of times 
                             the error message is written.  A value of zero
                             is treated as a null value.  This applies only when 
                             ut_errmsg is called from inside a data step. 

COUNTER   optional  _errmsg  The name of the variable used to count up to MAX.
                             If your data set already has a variable of this
                             default name then override the name with this
                             parameter. This applies only when ut_errmsg is 
                             called from inside a data step. 

FILEBACK  optional  LOG      The fileref to return to when ut_errmsg completes.
                             Ut_errmsg issues a FILE statment so if the calling 
                             macro requires a fileref to be active then ut_errmsg 
                             has to be told what this fileref is. This applies 
                             only when ut_errmsg is called from inside a data 
                             step. 

VERBOSE   required  &debug   %ut_logical value specifying whether verbose mode
                             is on or off.  Default is the value of the 
                             DEBUG parameter

DEBUG     required  0        %ut_logical value specfifying whether debug mode
                             is on or off

--------------------------------------------------------------------------------
Usage Notes:

The TYPE must be NOTE, WARNING, or ERROR.  The TYPE will be prefixed 
to the text specified in MSG and the type will have the letter U prefixed to 
it.  So, 

  %ut_errmsg(msg       = 'invalid value for variable SYMTYP',
             type      = warning,
             macroname = callingmacro)

will print

  UWARNING(CALLINGMACRO): invalid value for variable SYMTYP

FILEBACK is advised when a PUT statement follows a call to UT_ERRMSG in a data
step.

Use a different COUNTER value in each call to UT_ERRMSG within the same data
step.

Although most calls to UT_ERRMSG can be followed safely with a semicolon, there  
are circumstances (in IF/THEN/ELSE blocks) where a semicolon can cause a SAS  
error when following a call to UT_ERRMSG.

PRINT and LOG should not both be false. otherwise no message will be generated.

If this module is called from INSIDE a DATA step, or the value of PRINT is a 
ut_logical TRUE value, then the string "PUT &msg;" must constitute legal syntax 
and not result in any execution errors. I.e., all constant text must be enclosed 
in balanced single or double quotes, and any variable names referenced must exist 
in the DATA step in which the module is called (variable names are only allowed when
the module is called from inside a DATA step).  Any syntax that is valid for the PUT
statement is permitted if it forms a valid statement.  Single quotes may be treated 
as constant text by enclosing them in double quotes, and vice-versa.  If the text 
&MSG is too long to fit on the same line with "U&TYPE(&macroname)", it will begin on
the next line.  To cause part of the string to appear on the same line with
"U&TYPE(&macroname)", break up the string into smaller substrings using multiple 
sets of balanced quotes.  The total number of characters that can be printed on 
one line is 100, regardless of the system setting of the SAS LINESIZE option.

If the module is NOT called from inside a DATA step, and the value of PRINT is a 
ut_logical FALSE value, any string is allowed as long as it does not create invalid 
syntax for the macro call statement, or forms an invalid statement when following
"%PUT". Unpredicatable results may occur with nested or unbalanced quotation marks.

--------------------------------------------------------------------------------
Typical Macro Call(s) and Description:

%ut_errmsg(msg       = Message to print in log file,
           macroname = calingmacro,
           type      = note,
           log       = Y,
           print     = N,
           max       = 25,
           counter   = _errmsg,
           fileback  = log,
           verbose   = 1,
           debug     = 0);

--------------------------------------------------------------------------------
REVISION HISTORY SECTION:                 
                      
         Author &      
  Ver#   Peer Reviewer      Request #          Description
  ----  ----------------    ---------------    -------------------------------
  1.0   Greg Steffens                          Original version of the broad-
        Srinivasa Gudipati                     use module on 29Mar2005.

  2.0   Greg Steffens                          Do not abort when executing in 
                                               SDD

  3.0   Greg Steffens       BMRMSR23JUL2007   
 
  4.0   Craig Hansen        BMRCSH01DEC2010a   Updated header to reflect code 
        Keyi Wu                                validated for SAS v9.2.
                                               Modified header to maintain 
                                               compliance with current SOP Code 
                                               Header.

  5.0  Richard Schneck      BMRRLS03MAY2011    1. Explicitly control system and 
       Shong DeMattos                             DATA step LINESIZE options to
                                                  guarantee same line breaks each
                                                  time the calling program runs
                                                  regardless of the LINESIZE
                                                  system option value.
                                               2. Terminate on excessively long 
                                                  MSG strings to prevent quoted 
                                                  string war nings.
                                               3. Do not abort in PC SAS
                                               4. Set global error-status 
                                                  macrovariable if TYPE=ERROR
                                                  or if an internal error condition
                                                  is triggered in this module
 **eoh*************************************************************************/

%* ==============================================================;
%* Call ut_parmdef, ut_logical, initialize macrovariable, setup  ;
%* ==============================================================;
%local i default_count default_fileback default_max 
       datastep linesize options savelsz xerror_status;

%if %bquote(&max)      = _default_ %then %let default_max      = 1;
                                   %else %let default_max      = 0;
%if %bquote(&counter)  = _default_ %then %let default_counter  = 1;
                                   %else %let default_counter  = 0;
%if %bquote(&fileback) = _default_ %then %let default_fileback = 1;
                                   %else %let default_fileback = 0;

%ut_parmdef(debug    ,0,
                      _pdrequired=1,_pdmacroname=ut_errmsg,_pdverbose=0)
%ut_logical(debug)    
%ut_parmdef(verbose  ,&debug,
                      _pdrequired=1,_pdmacroname=ut_errmsg,_pdverbose=&debug)
%ut_logical(verbose) 
%ut_parmdef(msg      ,_pdrequired=1,_pdmacroname=ut_errmsg,_pdverbose=&verbose)
%ut_parmdef(macroname,_pdrequired=1,_pdmacroname=ut_errmsg,_pdverbose=&verbose)
/* _PDVERBOSE=0 for TYPE so that ut_saslogchk will not find the string */
%ut_parmdef(type     ,note,note warning error,
                      _pdrequired=1,_pdmacroname=ut_errmsg,_pdverbose=0)
%ut_parmdef(log      ,1,
                     _pdrequired=1,_pdmacroname=ut_errmsg,_pdverbose=&verbose)
%ut_logical(log)     
%ut_parmdef(print    ,1,
                     _pdrequired=1,_pdmacroname=ut_errmsg,_pdverbose=&verbose)
%ut_logical(print)    
%ut_parmdef(max      ,25,
                     _pdrequired=0,_pdmacroname=ut_errmsg,_pdverbose=&verbose)
%ut_parmdef(counter  ,_errmsg,
                     _pdrequired=0,_pdmacroname=ut_errmsg,_pdverbose=&verbose)
%ut_parmdef(fileback ,log,
                     _pdrequired=0,_pdmacroname=ut_errmsg,_pdverbose=&verbose)
%*;

%** Initialize standard linesize and internal error status **;
%let linesize = 100;
%let xerror_status = 0;

%** Upcase TYPE and MACRONAME **;
%let type      = %upcase(&type);
%let macroname = %upcase(&macroname);

%** Determine whether called from within a data step **;
%if %qupcase(%bquote(&sysprocname)) = DATASTEP %then %let datastep = 1;
                                               %else %let datastep = 0;

%if &datastep = 0 %then %do;  
  %* ==============================================;
  %* Process UT_ERRMSG from outside any data step. ;
  %* ==============================================;

  %** Set line size for this module, save value to restore **;
  %let savelsz = %sysfunc(getoption(linesize));
  options linesize = &linesize;
  %if &debug %then %put UNOTE(UT_ERRMSG): Beginning execution of macro UT_ERRMSG.;

  %** Initialize ERROR_STATUS macrovariable **;
  %if %symlocal(error_status) %then %do;
    %put;
    %put UERROR(UT_ERRMSG): ERROR_STATUS cannot exist as a local macrovariable.; 
    %let xerror_status = 1;
  %end;
  %else %if ^%symglobl(error_status) %then %do;
    %global error_status;
    %let error_status = 0;
  %end;
  %else %if %bquote(&error_status)= %then %do; 
    %let error_status = 0;
  %end;
  
  %** Set error status for invalid parameters **;
        %if %bquote(&macroname)=                          %then %let xerror_status=1;
  %else %if %bquote(&log)    ^=0 and %bquote(&log)    ^=1 %then %let xerror_status=1;
  %else %if %bquote(&print)  ^=0 and %bquote(&print)  ^=1 %then %let xerror_status=1;
  %else %if %bquote(&debug)  ^=0 and %bquote(&debug)  ^=1 %then %let xerror_status=1;
  %else %if %bquote(&verbose)^=0 and %bquote(&verbose)^=1 %then %let xerror_status=1;

  %** Verify MSG is not null **;
  %if %bquote(&msg)= %then %do;
    %put;
    %put UERROR(UT_ERRMSG): No message specified to be printed.; 
    %let xerror_status = 1;
  %end;

  %** Check for excessive message length **;
  %let msg = %sysfunc(strip(&msg));
  %let msg = %sysfunc(compbl(&msg));
  %if %length(&msg)>260 %then %do;
    %put;
    %put UERROR(UT_ERRMSG): Value of parameter MSG exceeds 260 characters;
    %let xerror_status = 1;
  %end;

  %** Verify MACRONAME is not null and is a valid SAS name **;
  %if %bquote(&macroname)= %then %do;
    %put;
    %put UERROR(UT_ERRMSG): A null value was specified for MACRONAME.;
    %let xerror_status = 1;
  %end;  
  %else %if ^%sysfunc(nvalid(&macroname)) %then %do;
    %put;
    %put UERROR(UT_ERRMSG): Value of MACRONAME is not a valid SAS macro name.;
    %let xerror_status = 1;
  %end;

  %** Check for valid TYPE value, set ERROR_STATUS if TYPE=ERROR **;
  %if %bquote(&type)=_default_ or %bquote(&type)= %then %do;
    %let type = NOTE;
    %put;
    %put UNOTE(UT_ERRMSG): TYPE not specified. Defaulting to NOTE.; 
  %end;  
  %else %if %bquote(&type)^=NOTE     and 
            %bquote(&type)^=WARNING  and
            %bquote(&type)^=ERROR 
  %then %do;
    %put;
    %put UERROR(UT_ERRMSG): TYPE has invalid value.;
    %let xerror_status = 1;
  %end;

  %** Verify either LOG or PRINT is set to print message **;
  %if ^&log and ^&print %then %do;
    %put;
    %put UERROR(UT_ERRMSG): Both LOG and PRINT are FALSE. No message will be printed.; 
    %let xerror_status = 1;
  %end;

  %** Verify MAX, COUNTER, and FILEBACK are null if called outside any DATA step **;
  %if ^&default_max and %bquote(&max)^= %then %do; 
    %put;
    %put UNOTE(UT_ERRMSG): UT_ERRMSG was not called from within a DATA step.; 
    %put UNOTE(UT_ERRMSG): The value specified for MAX will be ignored.;
  %end;  
  %if ^&default_counter and %bquote(&counter)^= %then %do; 
    %put;
    %put UNOTE(UT_ERRMSG): UT_ERRMSG was not called from within a DATA step.; 
    %put UNOTE(UT_ERRMSG): The value specified for COUNTER will be ignored.;
  %end;
  %if ^&default_fileback and %bquote(&fileback)^= %then %do; 
    %put;
    %put UNOTE(UT_ERRMSG): UT_ERRMSG was not called from within a DATA step.; 
    %put UNOTE(UT_ERRMSG): The value specified for FILEBACK will be ignored.;
  %end;

  %** Print message if no internal errors found **;
  %if ^&xerror_status %then %do;
    %if &print %then %do;
      %** Add quotes to MSG if necessary **;
      %local msgq firstchar lastchar;
      %let firstchar = %qsubstr(&msg,1,1);
      %let lastchar  = %qsubstr(&msg,%length(&msg),1);
      %if (&firstchar = %str(%") & &lastchar = %str(%")) | 
          (&firstchar = %str(%') & &lastchar = %str(%')) %then %let msgq = &msg;
                                                         %else %let msgq = %str("&msg"); 
      data _null_; 
        file print linesize=&linesize;
        put / @1 "U%substr(&type,1,2)" "%substr(&type,3)(&macroname): " &msgq;
        stop;
      run;
    %end;
    %if &log %then %put U&type(&macroname): &msg;
  %end;
  
  %** Restore linesize option **;
  %if &debug %then %put UNOTE(UT_ERRMSG): Ending execution of macro UT_ERRMSG.;
  options linesize = &savelsz;

  %** Set global error-status macrovariable if internal error found,  **;
  %**   or if user specified TYPE = ERROR                             **;
  %if &type = ERROR or &xerror_status %then %do;
    %let error_status = 1;
  %end;

%end;  %** End of processing UT_ERRMSG outside any data step **;

%else %if &datastep = 1 %then %do;
  %* ===========================================;
  %* Process UT_ERRMSG from within a data step. ;
  %* ===========================================;

  %** Do loop is needed so UT_ERRMSG can be called from within **;
  %**   an if ... then ... structure **;
  do;
    file log linesize=&linesize;
    %if &debug %then %do;
      put;
      put 'UNOTE(UT_ERRMSG): Beginning execution of macro UT_ERRMSG.';
    %end;

    %** Initialize ERROR_STATUS macrovariable **;
    %if %symlocal(error_status) %then %do;
      put;
      put 'UER' 'ROR(UT_ERRMSG): ERROR_STATUS cannot exist as a local macrovariable.'; 
      %let xerror_status = 1;
    %end;
    %else %if ^%symglobl(error_status) %then %do;
      %global error_status;
      %let error_status = 0;
    %end;
    %else %do; 
      %if %bquote(&error_status)= %then %do; 
        %let error_status = 0;
      %end;
    %end;

    %** Set error status for invalid parameters **;
          %if %bquote(&macroname)=                          %then %let xerror_status=1;
    %else %if %bquote(&log)    ^=0 and %bquote(&log)    ^=1 %then %let xerror_status=1;
    %else %if %bquote(&print)  ^=0 and %bquote(&print)  ^=1 %then %let xerror_status=1;
    %else %if %bquote(&debug)  ^=0 and %bquote(&debug)  ^=1 %then %let xerror_status=1;
    %else %if %bquote(&verbose)^=0 and %bquote(&verbose)^=1 %then %let xerror_status=1;

    %** Verify MSG is not null **;
    %if %bquote(&msg)= %then %do;
      put;
      put 'UER' 'ROR(UT_ERRMSG): No message specified to be printed.'; 
      %let xerror_status = 1;
    %end;

    %** Check for excessive message length **;
    %let msg = %sysfunc(strip(&msg));
    %let msg = %sysfunc(compbl(&msg));
    %if %length(&msg)>260 %then %do;
      put;
      put 'UER' 'ROR(UT_ERRMSG): Value of parameter MSG exceeds 260 characters.';
      %let xerror_status = 1;
    %end;

	%** Verify MACRONAME is a valid SAS name **;
    %if %bquote(&macroname)= %then %do;
      put;
      put 'UER' 'ROR(UT_ERRMSG): A null value was specified for MACRONAME.';
      %let xerror_status = 1;
    %end;  
    %else %if ^%sysfunc(nvalid(&macroname)) %then %do;
      put;
      put 'UER' 'ROR(UT_ERRMSG): Value of MACRONAME is not a valid SAS macro name.';
      %let xerror_status = 1;
    %end;

    %** Check for valid TYPE value, set ERROR_STATUS if TYPE=ERROR **;
    %if %bquote(&type)=_default_ or %bquote(&type)= %then %do;
      %let type = NOTE;
      put;
      put 'UNOTE(UT_ERRMSG): TYPE not specified. Defaulting to NOTE.'; 
    %end;
    %else %if %bquote(&type)^=NOTE     and 
              %bquote(&type)^=WARNING  and
              %bquote(&type)^=ERROR 
    %then %do;
      put;
      put 'UER' 'ROR(UT_ERRMSG): TYPE has invalid value.';
      %let xerror_status = 1;
    %end;

    %** Verify either LOG or PRINT is set to print message **;
    %if ^&log and ^&print %then %do;
      put; 
      put 'UER' 'ROR(UT_ERRMSG): Both LOG and PRINT are FALSE. No message will be printed.'; 
      %let xerror_status = 1;
    %end;

	%** Verify the value of MAX is a number **;
    %if %bquote(&max)^= %then %do;
      %if %sysfunc(notdigit(&max)) %then %do;
        put;
        put 'UER' 'ROR(UT_ERRMSG): MAX must be a positive integer if specified.'; 
        %let xerror_status = 1;
      %end;
      %else %if %bquote(&max) = 0 %then %do;
        %let max=;
        put;
        put 'UNOTE(UT_ERRMSG): A zero value of MAX is equivalent to a null value.'; 
      %end;
    %end;

    %** Verify COUNTER is a valid variable name **;
    %if %bquote(&counter)^= %then %do;
      %if ^%sysfunc(nvalid(&counter)) %then %do;
        put;
        put 'UER' 'ROR(UT_ERRMSG): Value of COUNTER is not a valid SAS variable name.';
        %let xerror_status = 1;
      %end;
    %end;

    %** Check for non-null MAX values when COUNTER is null **;
    %if %bquote(&counter)= and %bquote(&max)^= and ^&default_max %then %do; 
      put;
      put 'UNOTE(UT_ERRMSG): The value specified for MAX is ignored when COUNTER is null.'; 
    %end;

    %** Check for non-null COUNTER values when MAX is null**;
    %if %bquote(&max)= and %bquote(&counter)^= and ^&default_counter %then %do; 
      put;
      put 'UNOTE(UT_ERRMSG): The value specified for COUNTER is ignored when MAX is null.'; 
    %end;

    %** Verify FILEBACK is a valid fileref **;
    %if %bquote(&fileback)^= %then %do;
      %if ^%sysfunc(nvalid(&fileback)) or %length(&fileback)>8 %then %do;
        put;
        put 'UER' 'ROR(UT_ERRMSG): Value of FILEBACK is not a valid SAS fileref name.';
        %let xerror_status = 1;
      %end;
      %if %qupcase(&fileback)^=LOG and %qupcase(&fileback)^=PRINT %then %do;
        %if %sysfunc(fileref(&fileback))>0 %then %do;
          put; 
          put 'UER' 'ROR(UT_ERRMSG): Value of FILEBACK is not an assigned SAS fileref.';
          %let xerror_status = 1;
        %end;
      %end;
    %end;

    %** Print message if no internal errors found **;
    %if ^&xerror_status %then %do;
      %if %bquote(&max)^= and %bquote(&counter)^= %then %do;
        &counter + 1;
        if &counter <= &max then do;
      %end;
      %if &print %then %do;
        file print linesize=&linesize;
        put / @1 "U%substr(&type,1,2)" "%substr(&type,3)(&macroname): " &msg;
        %if %bquote(&max)^= and %bquote(&counter)^= %then %do;
          if &counter = &max then do;
	        put;
            put "UN" "OTE(UT_ERRMSG): The limit specified by MAX=&max has been reached.";
            put "UN" "OTE(UT_ERRMSG): Further messages of this type will not be printed.";
          end;
        %end;
      %end;
      %if &log %then %do;
        file log linesize=&linesize;
        put / @1 "U%substr(&type,1,2)" "%substr(&type,3)(&macroname): " &msg;
        %if %bquote(&max)^= and %bquote(&counter)^= %then %do;
          if &counter = &max then do;
	        put;
            put "UN" "OTE(UT_ERRMSG): The limit specified by MAX=&max has been reached.";
            put "UN" "OTE(UT_ERRMSG): Further messages of this type will not be printed.";
          end;
        %end;
      %end;
      %if %bquote(&max)^= and %bquote(&counter)^= %then %do;
        end;
        drop &counter;
      %end;

      %** Reset destination to FILEBACK **;
      %if %bquote(&fileback)^= %then %do;
        file &fileback;
      %end;
    %end;  %** End of no internal errors found **;

    %** Set global error-status macrovariable if internal error found,  **;
    %**   or if user specified TYPE = ERROR                             **;
    %if &type = ERROR or &xerror_status %then %do;
      call symputx('error_status','1');
    %end;
  end;
%end;   %** End of processing UT_ERRMSG inside a data step **;

%mend ut_errmsg;
