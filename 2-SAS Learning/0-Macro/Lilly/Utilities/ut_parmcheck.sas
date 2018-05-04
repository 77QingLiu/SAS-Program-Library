%macro ut_parmcheck(_almacname,_alversion);
/*soh**************************************************************************** 
Eli Lilly and Company - Global Statistical Sciences                       
CODE NAME           : ut_parmcheck             
CODE TYPE           : Broad-use Module          
PROJECT NAME        :                           
DESCRIPTION         : Validates the parameters of the calling macro against 
                    : information about the parameters that is stored in 
                    : parameter-checking metadatasets
SOFTWARE/VERSION #  : SAS/Version 9
INFRASTRUCTURE      : SDD 
LIMITED-USE MODULES : N/A
BROAD-USE MODULES   : ut_parmdef, ut_logical, ut_errmsg, ut_chk_ds, ut_chk_var,
                      ut_restore_env, ut_saslogcheck
INPUT               : N/A                                                 
OUTPUT              : N/A                                       
VALIDATION LEVEL    : 6                  
REQUIREMENTS        : https://sddchippewa.sas.com/webdav/lillyce/qa/general/bums/
                    : ut_parmcheck_env/documentation/ut_parmcheck_rd.doc 
ASSUMPTIONS         : 1. All aspects of the structure of the metadatasets and the
                         information in them is correct
                      2. Information on all of the parameters of the calling macro 
                         are incuded in the observations of the metadatasets that
                         are selected by the values passed in for MACRONAME and
                         VERSION.
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
BROAD-USE MODULE SPECIFIC INFORMATION: 
BROAD-USE MODULE TEMPORARY OBJECT PREFIX: _AL
                        
PARAMETERS:       
 
Name         Type      Default   Description and Valid Values 
-----------  --------  --------  ---------------------------------------------------
_ALMACNAME   required  N/A       The name of the calling macro (used to select the
                                 correct observations in the parameter-checking 
                                 metadatasets)

_ALVERSION   required  N/A       The version number of the calling macro (used to 
                                 select the correct observations in the parameter-
                                 checking metadatasets) 
--------------------------------------------------------------------------------
USAGE NOTES:                                    

This macro is to be used outside of a DATA Step/Procedure.     

There cannot be a local macrovariable called ERROR_STATUS when this module is
called. 

If any parameter of the calling macro fails any of the tests in the parameter-
checking metatadatasets, global macrovariable ERROR_STATUS is given a value of 1.  
If no invalid values are detected, the value of ERROR_STATUS remains unchanged,
or is created with a value of 0 if the macrovariable does not already exist.

To avoid naming conflicts, this module UT_PARMCHECK itself does not have a 
parameter called DEBUG. It inherits the value of any existing macrovariable or
parameter of a calling module called DEBUG that has a valid UT_LOGICAL value.  
If none exists, it assumes DEBUG=0.
-------------------------------------------------------------------------------- 
TYPICAL MACRO CALL AND DESCRIPTION:          

This macro call is to obtain metadata records to validate paramter values for
TEST_BUM version 3: 
 
%ut_parmcheck(TEST_BUM,3);

-------------------------------------------------------------------------------- 
-------------------------------------------------------------------------------- 
REVISION HISTORY SECTION:

       Author &
 Ver#  Peer Reviewer     Request #            Code History Description
 ----  ----------------  -------------------  --------------------------------
 1.0   Craig Hansen       BMRCSH09NOV2009D     Original version of the code
       Melinda Rodgers

 2.0   Craig Hansen       BMRCSH12FEB2010      Allow binary parameters that are
       Melinda Rodgers                         optional and group expressions
                                               representing TRUE and FALSE values
                                               for conditional parameters

 3.0   Craig Hansen       BMRMKC26AUG2010      1. Programming correction to 
       Melinda Rodgers                            prevent truncation of parameter
                                                  values.
                                               2. Check values of parameters 
                                                  represented by group expressions 
                                                  [Libref] and [Fileref] to verify 
                                                  that they represent valid librefs 
                                                  and filerefs. 
                                               3. Allow any required dataset name 
                                                  to include a parameter represented 
                                                  by the group expression [Libref] 
                                                  a constant dataset name.

 4.0   Craig Hansen       BMRMKC03SEP2010a     Correct logic error causing 
       Melinda Rodgers                         non-case-sensitive parameter value 
                                               combinations to be treated as 
                                               case-sensitive.

 5.0   Chuck Bininger     BMRCB12JUL2013       Altered length of variables actual_value 
       Shong Demottos                          and values from $2000 to $200 to  
                                               eliminate warning messages new to SAS 9.2
**eoh***************************************************************************/
%local i j _pfx sdd
       _actlist _defcount _dslist _dsname _invalparmname _invcount _location 
       _ninvspace _nocaselist _notnullonly _notnum _nullonly _parmcall _pgmsrc
       _pname1 _pname2 _pname3 _pname4 _subset _truth _xdev _xqa _xprd _xdebug
       ;

%*==============================================================================;
%* Set prefix assigned to this module                                           ;
%*==============================================================================;
%let _pfx = _al;

%*====================================================;
%*                                                    ;
%*             BEGIN PARAMETER CHECKING               ;
%*                                                    ;
%*====================================================;

%** Get Platform information for which BUM is executing **;
%if %symglobl(_sddusr_) | %symglobl(_sddprc_) | %symglobl(sddparms) %then %let sdd = 1;
                                                                    %else %let sdd = 0;
%if %upcase(%nrbquote(&sysscp)) = WIN %then %let _pda = 0;
                                      %else %let _pda = 1;

%** Verify ERROR_STATUS does not exist as a local macrovariable **;
%if %symlocal(error_status) %then %do;
  %ut_errmsg(msg=%sysfunc(compbl("ERROR_STATUS cannot exist as a local macrovariable
                                  when UT_PARMCHECK is executed.")),
                  type=error,print=0,macroname=ut_parmcheck);
  %return;
%end;
%** Initialize ERROR_STATUS if it does not exist as a global macrovariable **;
%if ^%symglobl(error_status) %then %do;
  %global error_status;
  %let error_status = 0;
%end;

%*==============================================================================;     
%* Process parameters                                                           ; 
%*==============================================================================;      
%ut_parmdef(_almacname,,, _pdrequired=1, _pdmacroname=ut_parmcheck, _pdabort=&_pda) 
%ut_parmdef(_alversion,,, _pdrequired=1, _pdmacroname=ut_parmcheck, _pdabort=&_pda)    
;  

%*===========================================================================;
%* Determine DEBUG status from symbol table -                                ;
%* This is so that a DEBUG parameter is not necessary, to avoid possible     ;
%* naming conflicts                                                          ;
%*===========================================================================;
%if %symexist(debug) %then %do;
  %if %sysfunc(indexw(%nrstr(1 Y T YES TRUE ON OUI JA),%upcase(&debug))) %then %let _xdebug = 1;
                                                                         %else %let _xdebug = 0;
%end;
%else %do;
  %let _xdebug=0;
%end;

%*===========================================================================;
%* Verify there are no macrovariables called _ALMACNAME or _ALVERSION,       ; 
%* which would cause naming conflicts.                                       ;
%*===========================================================================;
data _null_;
  set sashelp.vmacro;
  where upcase(name) in('_ALMACNAME','_ALVERSION') and upcase(scope)^='UT_PARMCHECK';
  if _n_=1 then do;
    %ut_errmsg(msg=%sysfunc(compbl("Reserved parameter name _ALMACNAME or _ALVERSION
                                    exists prior to calling UT_PARMCHECK. %str(Er)rors 
                                    could occur as a result of naming conflicts.")),
             type=warning,print=0,macroname=ut_parmcheck);
  end;
run;

%*=============================================================================;
%* Delete temporary datasets to prevent contamination from previous runs       ; 
%*=============================================================================;
%ut_restore_env(prefixlist=&_pfx,optds=,debug=&_xdebug);

%*=============================================================================;
%* Save the initial values of the SAS system options                           ; 
%*=============================================================================;
proc optsave out=&_pfx.optsave;
run;
%if ^&_xdebug %then %do;                          
  options nomprint nomlogic nosymbolgen;        
%end;

%*================================================================================;
%* Search the metadata files for the relevant observations                        ;
%* -------------------------------------------------------                        ;
%* Search each copy (in PRD/QA/DEV) in the metadataset PARMCHK_PARMS for the      ;
%* observations that match the values passed in on parameters MACRONAME and       ;
%* VERSION. Search PRD first, then QA, then DEV.                                  ; 
%*================================================================================;
%if &sdd and %symglobl(sddparms) %then %do;
  %let _pgmsrc=DEV;
  data _null_;
    set &sddparms(keep=parmtype valtype value id);
    where lowcase(parmtype)='logfile' and lowcase(valtype)='path';
         if index(value,'/lillyce/prd') then call symputx('_pgmsrc','PRD','L');
    else if index(value,'/lillyce/qa')  then call symputx('_pgmsrc','QA' ,'L');
    stop;
  run;
  data _null_;
    set &sddparms(keep=parmtype valtype value id);
    where lowcase(parmtype)='folder' and lowcase(valtype)='path';
    if index(value,'/lillyce/prd/general/bums/macro_library') then call symputx('_xprd',strip(id),'L');
    if index(value,'/lillyce/qa/general/bums/macro_library')  then call symputx('_xqa' ,strip(id),'L');
    if index(value,'/lillyce/dev/general/bums/macro_library') then call symputx('_xdev',strip(id),'L');
  run;
  %let _location=;
  %if %bquote(&_xprd)^= %then %do;
    libname _xprd "&&&_xprd" access=readonly;    
    %if %sysfunc(exist(_xprd.parmchk_parms)) %then %do;
      data _null_;
        set _xprd.parmchk_parms(keep=macro_name version);
        where upcase(strip(macro_name)) = "%qupcase(&_almacname)" and 
              upcase(strip(version))    = "%qupcase(&_alversion)";
        if _n_=1 then call symputx('_location','prd','L');
        stop;
      run;
    %end;
    libname _xprd clear;
  %end;
  %if %bquote(&_location)= and &_pgmsrc^=PRD %then %do;
    %if %bquote(&_xqa)^= %then %do;
      libname _xqa "&&&_xqa" access=readonly;    
      %if %sysfunc(exist(_xqa.parmchk_parms)) %then %do;
        data _null_;
          set _xqa.parmchk_parms(keep=macro_name version);
          where upcase(strip(macro_name)) = "%qupcase(&_almacname)" and 
                upcase(strip(version))    = "%qupcase(&_alversion)";
          if _n_=1 then call symputx('_location','qa','L');
          stop;
        run;
      %end;
      libname _xqa clear;
    %end;
  %end;
  %if %bquote(&_location)= and &_pgmsrc=DEV %then %do;
    %if %bquote(&_xdev)^= %then %do;
      libname _xdev "&&&_xdev" access=readonly;  
      %if %sysfunc(exist(_xdev.parmchk_parms)) %then %do;
        data _null_;
          set _xdev.parmchk_parms(keep=macro_name version);
          where upcase(strip(macro_name)) = "%qupcase(&_almacname)" and 
                upcase(strip(version))    = "%qupcase(&_alversion)";
          if _n_=1 then call symputx('_location','dev','L');
          stop;
        run;
      %end;
      libname _xdev clear;
    %end;
  %end;
  %if %bquote(&_location)= %then %do;
    %ut_errmsg(msg=%sysfunc(compbl("The metadata records for the macro/version indicated by parameters 
                                    MACRONAME and VERSION are not in any of the metadatasets in 
                                    PRD, QA, or DEV.")),
               type=warning,print=0,macroname=ut_parmcheck);
  %end;
  libname parmlib "&&&&&&_x&_location" access=readonly;
%end;
%if %sysfunc(libref(parmlib))^=0 %then %do;
  %ut_errmsg(msg=%sysfunc(compbl("There must be a libref PARMLIB assigned in order to access the 
                                  parameter-checking metadatasets.")),
             type=warning,print=0,macroname=ut_parmcheck);
%end;

%** Verify the existence of the parameter-info datasets and variables **;
%ut_chk_ds(dslist = %sysfunc(compbl(parmlib.parmchk_parms        parmlib.parmchk_parm_values 
                                    parmlib.parmchk_parm_combos  parmlib.parmchk_default_if 
                                    parmlib.parmchk_invalid_if   parmlib.parmchk_required_input)),
           required_yn = Y,
           debug       = &_xdebug)
           ;

%*===================================================;
%*                                                   ;
%*          BEGIN BUM MAIN PROCESSING                ;
%*                                                   ;
%*===================================================;

%*************************************************************;
%*  Obtain the required records from the parm-info datasets  *;
%*************************************************************;

%** Subset all datasets to the specified macro name and version **;
%let _subset = %sysfunc(compbl(%str(where upcase(macro_name)="%qupcase(&_almacname)" and 
                                    strip(version)="&_alversion")));
data &_pfx.parms;  
  set parmlib.parmchk_parms(keep=macro_name version parm_name default required case_sensitive);
  &_subset; drop macro_name version; run;
data &_pfx.parmvals;  
  set parmlib.parmchk_parm_values(keep=macro_name version parm_name value value_type);  
  &_subset; drop macro_name version; run;
data &_pfx.combos;  
  set parmlib.parmchk_parm_combos(keep=macro_name version name: value:);  
  &_subset; drop macro_name version; run;
data &_pfx.defif;  
  set parmlib.parmchk_default_if(keep=macro_name version parm_name value cond:);  
  &_subset; drop macro_name version; run;
data &_pfx.invif;  
  set parmlib.parmchk_invalid_if(keep=macro_name version parm_name value cond:);  
  &_subset; drop macro_name version; run;
data &_pfx.reqinp;  
  set parmlib.parmchk_required_input(keep=macro_name version sas: cond:);  
  &_subset; drop macro_name version; run;

%***************************************;
%*  Get info from the PARMS worksheet  *;
%***************************************;
data &_pfx.parms;
  length parm_name $32;
  set &_pfx.parms(keep=parm_name required default case_sensitive);
  parm_name = strip(upcase(parm_name));
  parm_num + 1;
run;

%************************************************************;
%*  Get ACTUAL parameter values, add basic parameter info   *;
%************************************************************;
data &_pfx.actparms; 
  length parm_name $32;
  set sashelp.vmacro;
  where upcase(scope) = "%qupcase(&_almacname)";
  parm_name = upcase(strip(name));
  keep parm_name value;
  rename value=actual_value;
run;
proc sort data=&_pfx.parms;    by parm_name; run;
proc sort data=&_pfx.actparms; by parm_name; run;
data &_pfx.actparms;
  merge &_pfx.actparms(in=x) &_pfx.parms(in=y);
  by parm_name; 
  if ^x then do;
    put parm_name=;
    %ut_errmsg(msg=%sysfunc(compbl("At least one parameter in the parameter-checking metadata
                                    is not an actual parameter of the calling macro.")),
               type=error,print=0,macroname=ut_parmcheck);
    call symputx('error_status','1'); 
  end;
  if ^y then do;
    put parm_name=;
    %ut_errmsg(msg=%sysfunc(compbl("At least one parameter or local macrovariable of the calling macro is not 
     in the parameter-checking metadata.")),
               type=note,print=0,macroname=ut_parmcheck);
  end;
  if y;
run;
%if %ut_numobs(&_pfx.actparms)=0 %then %do;
  %ut_errmsg(msg=%sysfunc(compbl("No observations are in the parameter-checking metadata
        for the parameters of macro %qupcase(&_almacname), version %qupcase(&_alversion).")),
             type=error,print=0,macroname=ut_parmcheck);
  %let error_status = 1;  
  %return;
%end;

%***************************************************************************;
%*  Get VALID-parms and INVALID-parms info from the PARM_VALUES worksheet  *;
%***************************************************************************;
data &_pfx.parmvals;
  length parm_name $32;
  set &_pfx.parmvals;
  parm_name=upcase(strip(parm_name));
run;
proc sort data=&_pfx.actparms; by parm_name; run;
proc sort data=&_pfx.parmvals; by parm_name; run;
data &_pfx.parmvals &_pfx.invalparms; 
  merge &_pfx.parmvals(in=x) &_pfx.actparms(in=y);
  by parm_name; if x and y;
       if upcase(strip(value_type))='VALID'   then output &_pfx.parmvals;
  else if upcase(strip(value_type))='INVALID' then output &_pfx.invalparms;
  drop value_type;
run;
proc sort data=&_pfx.parmvals;    
  by parm_name; 
run;
data &_pfx.parmvals;
  length actual_value values $200;
  retain values;
  set &_pfx.parmvals;
  by parm_name;
  if first.parm_name then values='';
  if ^index(value,'[') then values = catx(' ',values,value);
                       else values = value;
  if last.parm_name;
  if upcase(actual_value)='_DEFAULT_' then do;
    if upcase(default)^='[NONE]' then actual_value = strip(default);
                                 else actual_value = ' ';
  end;
  if upcase(values)='[LOGICAL]' then do;
         if indexw('1 Y YES T TRUE ON OUI JA',   upcase(actual_value)) then actual_value = '[TRUE]';
    else if indexw('0 N NO F FALSE OFF NON NEIN',upcase(actual_value)) then actual_value = '[FALSE]';
  end;
  drop value;
run;
%if %ut_numobs(&_pfx.invalparms)>0 %then %do;
  %let _invalparmname=;
  data &_pfx.invalparms;
    set &_pfx.invalparms;
    if upcase(case_sensitive)='N' then do;
      value = upcase(value);
      actual_value = upcase(actual_value);
    end;
    if strip(value) = strip(actual_value) then do;
      call symputx('_invalparmname',strip(parm_name),'L');
      stop;
    end;
  run;
  %if %bquote(&_invalparmname)^= %then %do;
    %ut_errmsg(msg=%sysfunc(compbl("The value of parameter %qupcase(&_invalparmname) is invalid as defined
                                    on the PARM_VALUES worksheet.")),
                type=warning,print=0,macroname=ut_parmcheck);
    %let error_status = 1;
  %end;
%end;

%********************************************;
%*  Build calls to UT_PARMDEF / UT_LOGICAL  *;
%********************************************;
data &_pfx.parmdef;
  length default valuelist parmdefcall $2000;
  set &_pfx.parmvals;
  if index(upcase(default),'[NONE]') then default='[DUMMY]';
  if ^index(values,'[') then valuelist = values;
                        else valuelist = '[DUMMY]';
       if upcase(required)       = 'Y' then pdrequired   = '1';
  else if upcase(required)       = 'N' then pdrequired   = '0';         
       if upcase(case_sensitive) = 'N' then pdignorecase = '1';
  else if upcase(case_sensitive) = 'Y' then pdignorecase = '0';  
  parmdefcall = catx(',',parm_name,default,valuelist,
                         cats('_pdrequired=',pdrequired),
                         cats('_pdignorecase=',pdignorecase),
                         "_pdmacroname=&_almacname"
                         );
  parmdefcall = tranwrd(parmdefcall,'[DUMMY]','');
  parmdefcall = tranwrd(parmdefcall,', ,',',,');  
  parmdefcall = tranwrd(parmdefcall,', ,',',,');
  keep parmdefcall parm_num;
run;
proc sort data=&_pfx.parmdef;
  by parm_num;
run;

data _null_;
  set &_pfx.parmdef;
  call symputx('_parmcall'||strip(put(_n_,best.)),strip(parmdefcall),'L');
run;
%do i = 1 %to %ut_numobs(&_pfx.parmdef);
  %ut_parmdef(&&_parmcall&i)
%end;
;
data &_pfx.logical;
  set &_pfx.parmvals;
  where upcase(strip(values))='[LOGICAL]' and actual_value^='';
run;
data _null_;
  set &_pfx.logical;
  call symputx('_logcall'||compress(put(_n_,best.)),strip(parm_name),'L');
run;
%do i = 1 %to %ut_numobs(&_pfx.logical);
  %ut_logical(&&_logcall&i)
%end;
;

%**********************************;
%*  Verify LIBREFs and FILEREFs   *;
%**********************************;
data &_pfx.librefs;
  set &_pfx.parmvals(keep=parm_name values actual_value);
  where upcase(values)='[LIBREF]' and actual_value^=' ';
  if libref(actual_value)^=0 then do;
    parm_name = upcase(strip(parm_name));
    put 'UER' 'ROR (UT_PARMCHECK): The value of parameter ' parm_name 
        'is not a valid assigned SAS libref.';
    output;
  end;
run;
%if %ut_numobs(&_pfx.librefs)>0 %then %return;
data &_pfx.filerefs;
  set &_pfx.parmvals(keep=parm_name values actual_value);
  where upcase(values)='[FILEREF]' and actual_value^=' ';
  if fileref(actual_value)^=0 then do;
    parm_name = upcase(strip(parm_name));
    put 'UER' 'ROR (UT_PARMCHECK): The value of parameter ' parm_name 
        'is not a valid assigned SAS fileref.';
    output;
  end;
run;
%if %ut_numobs(&_pfx.filerefs)>0 %then %return;

%*******************************;
%*  Set conditional defaults   *;
%*******************************;
data &_pfx.cond(keep=_rowid cond:) &_pfx.defparm(drop=cond:);
  length parm_name condition_parameter $32;
  set &_pfx.defif;
  parm_name           = upcase(strip(parm_name));
  condition_parameter = upcase(strip(condition_parameter));
  _rowid + 1;
run;
%** Get actual values for parm name and condition parm **;
data &_pfx.temp;
  length parm_name $32;
  set &_pfx.parmvals(keep=parm_name actual_value);
run;
proc sort data=&_pfx.defparm; by parm_name; run;
proc sort data=&_pfx.temp;    by parm_name; run;
data &_pfx.defparm;
  merge &_pfx.defparm(in=x) &_pfx.temp;
  by parm_name; if x;
run;
data &_pfx.temp;
  length parm_name $32;
  set &_pfx.parmvals(keep=parm_name actual_value case_sensitive);
  rename parm_name = condition_parameter
         actual_value = condition_actual
         case_sensitive = condition_case
         ;
run;
proc sort data=&_pfx.cond; by condition_parameter; run;
proc sort data=&_pfx.temp; by condition_parameter; run;
data &_pfx.cond;
  merge &_pfx.cond(in=x) &_pfx.temp;
  by condition_parameter; if x;
run;
proc sort data=&_pfx.cond;    by _rowid; run;
proc sort data=&_pfx.defparm; by _rowid; run;
data &_pfx.defif;
  merge &_pfx.cond &_pfx.defparm;
  by _rowid;
run;
%let _defcount = 0;
data &_pfx.defif;
  set &_pfx.defif;
  _cmatch = 0;
  %** Determine value match for condition parameter **;
  if upcase(condition_case)='N' then do;
    condition_actual = upcase(condition_actual);
    condition_value  = upcase(condition_value);
  end;
       if upcase(condition_value)='[NULL]'     and condition_actual=''  then _cmatch = 1;
  else if upcase(condition_value)='[NOT_NULL]' and condition_actual^='' then _cmatch = 1;
  else if strip(condition_value) = strip(condition_actual) then _cmatch = 1;
  %** Switch value of condition-match flag for inequality **;
  if upcase(condition_operator) ='NE' then _cmatch = 1-_cmatch; 
  %** Set default value if actual value is null **;
  if _cmatch=1 and actual_value='' then do;
    _count + 1;
    call symputx('_defparm' ||strip(put(_count,best.)),upcase(parm_name),'L');
    call symputx('_defcond' ||strip(put(_count,best.)),upcase(condition_parameter),'L');    
    call symputx('_defvalue'||strip(put(_count,best.)),value,'L');
    call symputx('_defcount',_count,'L');
  end;
run;

%if &_defcount>0 %then %do;
  %do i = 1 %to &_defcount;
    %ut_errmsg(msg=%sysfunc(compbl("Parameter &&_defparm&i will default to a value of 
                                    &&_defvalue&i due to the value specified for
                                    &&_defcond&i.")),
               type=note,print=0,macroname=ut_parmcheck);
    %let &&_defparm&i = &&_defvalue&i;
  %end;
  data &_pfx.parmvals;
    set &_pfx.parmvals;
      %do i = 1 %to &_defcount;
        %if &i>1 %then %do; else %end;
        if upcase(parm_name)="&&_defparm&i" then actual_value="&&_defvalue&i"; 
      %end;
  run;
%end;

%*************************************************;
%*  Verify Numeric and Null/Not-Null Parameters  *;
%*************************************************;
proc sort data=&_pfx.parmvals out=&_pfx.numcheck;
  by parm_name;
  where upcase(values) in('[NUMERIC]','[NUMERIC_LIST]','[NULL]','[NOT_NULL]');
run;
%let _notnum      = 0;
%let _nullonly    = 0;
%let _notnullonly = 0;
data &_pfx.numcheck;
  set &_pfx.numcheck;
  by parm_name; 
  where actual_value^='';
  if upcase(values)='[NUMERIC]' then do;
    if input(actual_value,?? 32.)=. then call symputx('_notnum','1','L');
  end; 
  else if upcase(values)='[NUMERIC_LIST]' then do;
    i=1;
    do while(scan(actual_value,i,' ')^=' ');
      _item = scan(actual_value,i,' ');
      if input(_item,?? 32.)=. then call symputx('_notnum','1','L');
      i=i+1;
    end;
  end;
  else if upcase(values)='[NULL]'     and actual_value^='' then call symputx('_nullonly','1','L');
  else if upcase(values)='[NOT_NULL]' and actual_value=''  then call symputx('_notnullonly','1','L');
  drop i _item;
run;
%if &_notnum %then %do;
  %ut_errmsg(msg=%sysfunc(compbl("At least one parameter defined as a numeric or a list of numerics
                                 has a non-numeric value.")),
             type=warning,print=0,macroname=ut_parmcheck);
  %let error_status = 1;
%end;
%if &_nullonly %then %do;
  %ut_errmsg(msg=%sysfunc(compbl("At least one parameter defined as a NULL-only has a non-null value.")),
             type=warning,print=0,macroname=ut_parmcheck);
  %let error_status = 1;
%end;
%if &_notnullonly %then %do;
  %ut_errmsg(msg=%sysfunc(compbl("At least one parameter defined as a NOT-NULL-only has a null value.")),
             type=warning,print=0,macroname=ut_parmcheck);
  %let error_status = 1;
%end;

%************************************************************;
%*  Verify Parameters representing Datasets and Variables   *;
%************************************************************;
proc sort data=&_pfx.parmvals out=&_pfx.namechk;
  by parm_name;
  where strip(upcase(values)) 
    in('[SAS_DATASET]','[SAS_DATASET_LIST]','[SAS_VARIABLE]','[SAS_VARIABLE_LIST]');
run;
data &_pfx.namechk;
  set &_pfx.namechk;
  by parm_name; 
  where actual_value^='';
run;
%let _ninvspace=0;
data &_pfx.dsnamechk;
  length dscall $2000;
  set &_pfx.namechk;
  where upcase(values) in('[SAS_DATASET]','[SAS_DATASET_LIST]'); 
  dscall = cats('dslist=',actual_value,',');
  dscall = cats(dscall,'required_yn=0,debug=&_xdebug');
  call symputx('_dscall'||strip(put(_n_,best.)),dscall,'L');
  if ^index(upcase(values),'LIST') and index(strip(actual_value),' ') then do;
    _count + 1;
    call symputx('_invspace' ||strip(put(_count,best.)),upcase(parm_name),'L');
    call symputx('_ninvspace',strip(put(_count,best.)),'L');
  end;
run;
%do i = 1 %to %ut_numobs(&_pfx.dsnamechk);
  %ut_chk_ds(&&_dscall&i)
%end;
;
%do i = 1 %to &_ninvspace;
  %ut_errmsg(msg=%sysfunc(compbl("Only one dataset name is allowed on 
                                  parameter &&_invspace&i.")),
             type=error,print=0,macroname=ut_parmcheck);
  %let error_status = 1;
%end;
%let _ninvspace=0;
data &_pfx.varnamechk;
  length varcall $2000;
  set &_pfx.namechk;
  where upcase(values) in('[SAS_VARIABLE]','[SAS_VARIABLE_LIST]'); 
  varcall = cats('dslist=,varlist=',actual_value,',');
  varcall = cats(varcall,'type=,debug=&_xdebug');
  call symputx('_varcall'||strip(put(_n_,best.)),varcall,'L');
  if ^index(upcase(values),'LIST') and index(strip(actual_value),' ') then do;
    _count + 1;
    call symputx('_invspace' ||strip(put(_count,best.)),upcase(parm_name),'L');
    call symputx('_ninvspace',strip(put(_count,best.)),'L');
  end;
run;
%do i = 1 %to %ut_numobs(&_pfx.varnamechk);
  %ut_chk_var(&&_varcall&i);
%end;
%do i = 1 %to &_ninvspace;
  %ut_errmsg(msg=%sysfunc(compbl("Only one variable name is allowed on 
                                  parameter &&_invspace&i.")),
             type=error,print=0,macroname=ut_parmcheck)
  %let error_status = 1;
%end;
;

%***********************************;
%*  Verify parameter combinations  *;
%***********************************;
data &_pfx.combos;
  set &_pfx.combos;
  name1 = strip(upcase(name1));
  name2 = strip(upcase(name2));
  name3 = strip(upcase(name3));
  name4 = strip(upcase(name4));
run;
proc sql noprint;
  select upcase(parm_name) into :_nocaselist separated by ' '
  from &_pfx.parmvals
  where upcase(case_sensitive)='N'
  ;
quit;

%** Loop through the sets of variables to be checked **;
proc sort data=&_pfx.combos out=&_pfx.combovars(keep=name1 name2 name3 name4) nodupkey;
  by name1 name2 name3 name4;
run;
proc sort data=&_pfx.combos;
  by name1 name2 name3 name4;
run;
%do i = 1 %to %ut_numobs(&_pfx.combovars);
  data &_pfx.combovars&i;
    set &_pfx.combovars(firstobs=&i obs=&i);
  run;
  data &_pfx.combo&i;
    merge &_pfx.combos &_pfx.combovars&i(in=x);
    by name1 name2 name3 name4; if x;
  run;
  %let _pname1=;
  %let _pname2=;
  %let _pname3=;
  %let _pname4=;
  data _null_;
    set &_pfx.combovars&i;
    array pnames{*} $ name1-name4;
    do i=1 to dim(pnames);
      call symputx(cats('_pname',put(i,best.)),upcase(strip(pnames{i})),'L');
    end;
  run; 
  data &_pfx.combo&i;
    %do j = 1 %to 4;
      %if %bquote(&&_pname&j)^= %then %do;
        attrib &&_pname&j length=$200;
      %end;
    %end;
    set &_pfx.combo&i;
    %do j = 1 %to 4;
      %if %bquote(&&_pname&j)^= %then %do;
        &&_pname&j = value&j;
      %end;
    %end;
    array achrs{*} $ _character_;
    _allmiss = 1;
    do i=1 to dim(achrs);
      if achrs{i}^='' then _allmiss=0;
      if index(achrs{i},'[') or indexw("&_nocaselist",upcase(vname(achrs{i}))) then do;
        achrs{i}=upcase(achrs{i});
      end;
    end;
    if _allmiss then delete;
    drop i _allmiss name1-name4 value1-value4;
  run;
  data &_pfx.parms&i;
    set &_pfx.parmvals;
    where upcase(parm_name) in("&_pname1","&_pname2","&_pname3","&_pname4");
    parm_name = upcase(parm_name);
    if indexw("&_nocaselist",upcase(parm_name)) then actual_value = upcase(actual_value);
  run;
  %let _actlist=;
  %do j = 1 %to 4;
    %if %bquote(&&_pname&j)^= %then %do;
      %let _actlist = &_actlist &&_pname&j;
    %end;
  %end;
  proc transpose data = &_pfx.parms&i out=&_pfx.act&i(keep=&_actlist);
    var actual_value;
    id parm_name;
  run;
  data &_pfx.act&i;
    length &_actlist $200;
    set &_pfx.act&i;
    array achrs{*} $ &_actlist;
    do i=1 to dim(achrs);
      if achrs{i}='' then achrs{i}='[NULL]';
    end;
    drop i;
  run;
  %do j = 1 %to 4;
    %if %bquote(&&_pname&j)^= %then %do;
       data &_pfx.act&i;
         length &_actlist $200;
         set &_pfx.act&i;
         output;
         if &&_pname&j^='[NULL]' then do;
           &&_pname&j = '[ANY]';      output;
           &&_pname&j = '[NOT_NULL]'; output;
         end; 
         else do;
           &&_pname&j = '[ANY]';  output;
         end;
       run;
    %end;
  %end;
  proc sort data=&_pfx.act&i;   by &_actlist; run; 
  proc sort data=&_pfx.combo&i; by &_actlist; run; 
  %let _nomatch=1;
  data _null_;
    merge &_pfx.act&i(in=x) &_pfx.combo&i(in=y);
    by &_actlist;
    if x and y then do;
      call symputx('_nomatch','0');
      stop;
    end;
  run;
  %if &_nomatch %then %do;
    %ut_errmsg(msg=%sysfunc(compbl("An invalid combination of values was passed in for the 
                                   following parameters: %qupcase(&_actlist)")),
               type=warning,print=0,macroname=ut_parmcheck)
    %let error_status = 1; 
  %end;
%end;  %** End of loop through variable combinations **; 
data _null_;
  set &_pfx.combovars end=eof;
  call symputx(cats('_combo',put(_n_,best.)),catx(' ',name1,name2,name3,name4),'L');
  if eof then 
    call symputx('_nobs',_n_,'L');
run;

%*********************************************;
%*  Check for conditionally invalid values   *;
%*********************************************;
data &_pfx.cond(keep=_rowid cond:) &_pfx.invparm(drop=cond:);
  length parm_name condition_parameter $32;
  set &_pfx.invif;
  parm_name           = upcase(strip(parm_name));
  condition_parameter = upcase(strip(condition_parameter));
  _rowid + 1;
run;

%** Get actual values and case-sensitivity for parm name and condition parm **;
data &_pfx.temp;
  length parm_name $32;
  set &_pfx.parmvals(keep=parm_name actual_value case_sensitive);
run;
proc sort data=&_pfx.invparm; by parm_name; run;
proc sort data=&_pfx.temp;    by parm_name; run;
data &_pfx.invparm;
  merge &_pfx.invparm(in=x) &_pfx.temp;
  by parm_name; if x;
run;
data &_pfx.temp;
  length parm_name $32;
  set &_pfx.parmvals(keep=parm_name actual_value case_sensitive);
  rename parm_name = condition_parameter
         actual_value = condition_actual
         case_sensitive = condition_case;
run;
proc sort data=&_pfx.cond; by condition_parameter; run;
proc sort data=&_pfx.temp; by condition_parameter; run;
data &_pfx.cond;
  merge &_pfx.cond(in=x) &_pfx.temp;
  by condition_parameter; if x;
run;
proc sort data=&_pfx.cond;    by _rowid; run;
proc sort data=&_pfx.invparm; by _rowid; run;
data &_pfx.invif;
  merge &_pfx.cond &_pfx.invparm;
  by _rowid;
run;

%let _invcount = 0;
data _null_;
  set &_pfx.invif;
  _cmatch = 0;
  _pmatch = 0;
  %** Determine value match for condition parameter **;
  if upcase(condition_case)='N' then do;
    condition_actual = upcase(condition_actual);
    condition_value  = upcase(condition_value);
  end;
       if upcase(condition_value)='[NULL]'     and condition_actual=''  then _cmatch = 1;
  else if upcase(condition_value)='[NOT_NULL]' and condition_actual^='' then _cmatch = 1;
  else if strip(condition_value) = strip(condition_actual) then _cmatch = 1;
  %** Switch value of condition-match flag for inequality **;
  if upcase(condition_operator) ='NE' then _cmatch = 1-_cmatch; 
  %** Determine value match for result parameter **;
  if upcase(case_sensitive)='N' then do;
    actual_value = upcase(actual_value);
    value        = upcase(value);
  end;
       if strip(upcase(value))='[NULL]'     and actual_value=''  then _pmatch = 1;
  else if strip(upcase(value))='[NOT_NULL]' and actual_value^='' then _pmatch = 1;
  else if strip(value) = strip(actual_value) then _pmatch = 1;
  if _cmatch=1 and _pmatch=1 then do;
    _count + 1;
    call symputx('_invparm'||strip(put(_count,best.)),upcase(parm_name),'L');
    call symputx('_invcond'||strip(put(_count,best.)),upcase(condition_parameter),'L');    
    call symputx('_invcount',_count,'L');
  end;
run;
%do i = 1 %to &_invcount;
  %ut_errmsg(msg=%sysfunc(compbl("An invalid combination of values has been specified for
                                  parameters &&_invparm&i and &&_invcond&i..")),
             type=warning,print=0,macroname=ut_parmcheck)
  %let error_status = 1;
%end;

%*********************************;
%*  Verify required input data   *;
%*********************************;
data &_pfx.reqinp;
  length condition_parameter $32;
  set &_pfx.reqinp;
  condition_parameter = upcase(strip(condition_parameter));
run;
proc sort data=&_pfx.reqinp;
  by condition_parameter;
run;
%** Get actual values and determine match for condition parms **;
proc sort data = &_pfx.reqinp 
          out  = &_pfx.cond(keep=condition_parameter)
          nodupkey;
  by condition_parameter;
run;
data &_pfx.temp;
  length parm_name $32;
  set &_pfx.parmvals(keep=parm_name actual_value case_sensitive);
  rename parm_name = condition_parameter
         actual_value = condition_actual
         case_sensitive = condition_case;
run;
proc sort data=&_pfx.temp; by condition_parameter; run;
data &_pfx.cond;
  merge &_pfx.cond(in=x) &_pfx.temp;
  by condition_parameter; if x;
run;
data &_pfx.reqinp;
  merge &_pfx.cond &_pfx.reqinp;
  by condition_parameter;
run;
data &_pfx.reqinp;
  set &_pfx.reqinp;
  %** Determine value match for condition parameter **;
  if condition_parameter^='' then do;
    if upcase(condition_case)='N' then do;
      condition_actual = upcase(condition_actual);
      condition_value  = upcase(condition_value);
    end;
         if upcase(condition_value)='[NULL]'     and condition_actual=''  then _cmatch = 1;
    else if upcase(condition_value)='[NOT_NULL]' and condition_actual^='' then _cmatch = 1;
    else if strip(condition_value) = strip(condition_actual) then _cmatch = 1;
    %** Switch value of condition-match flag for inequality **;
    if upcase(condition_operator)='NE' then _cmatch = 1-_cmatch; 
  end;
  else _cmatch=1;  %** Match is automatically true if there are no conditions **;
  if _cmatch;
  drop _cmatch condition:;
run;
** Blank out dataset names that include parameter-specified libref **;
**   if the actual specified parameter value is null               **;
proc sort data=&_pfx.reqinp out=&_pfx.dsparm(keep=sas_datasets) nodupkey;
  by sas_datasets;
  where substr(sas_datasets,1,1)='&' and index(sas_datasets,'..');
run;
%if %ut_numobs(&_pfx.dsparm)>0 %then %do;
  data &_pfx.dsparm;
    length parm_name $32;
    set &_pfx.dsparm;
    parm_name = substr(scan(sas_datasets,1,'.'),2);
    keep parm_name sas_datasets;
  run;
  data &_pfx.temp;
    length parm_name $32;
    set &_pfx.parmvals(keep=actual_value parm_name);
    where actual_value = '';
    drop actual_value;
  run;
  proc sort data=&_pfx.temp;   by parm_name; run;
  proc sort data=&_pfx.dsparm; by parm_name; run;
  data &_pfx.dsparm;
    merge &_pfx.dsparm(in=x) &_pfx.temp(in=y);
    by parm_name; if x and y;
    keep sas_datasets;
  run;
  proc sort data=&_pfx.dsparm; by sas_datasets; run;
  proc sort data=&_pfx.reqinp; by sas_datasets; run;
  data &_pfx.reqinp;
     merge &_pfx.reqinp &_pfx.dsparm(in=x);
     by sas_datasets;
     if x then delete;
  run;
%end;
** Build call to ut_chk_ds **;
proc sort data=&_pfx.reqinp out=&_pfx.reqds(keep=sas_datasets) nodupkey;
  by sas_datasets;
  where sas_datasets^='' and sas_variables='';
run;
data &_pfx.reqds;
  length dscall $2000;
  set &_pfx.reqds;
  dscall = cats('dslist=',sas_datasets,',');
  dscall = cats(dscall,'required_yn=1,debug=&_xdebug');
  call symputx('_dscall'||strip(put(_n_,best.)),dscall,'L');
run;
%do i = 1 %to %ut_numobs(&_pfx.reqds);
  %ut_chk_ds(&&_dscall&i)
%end;
;
proc sort data = &_pfx.reqinp 
          out  = &_pfx.reqvar(keep=sas_datasets sas_variables sas_variable_type) 
          nodupkey;
  by sas_datasets sas_variables;
  where sas_datasets^='' and sas_variables^='';
run;
data &_pfx.reqvar;
  length varcall $2000;
  set &_pfx.reqvar;
  _type = substr(sas_variable_type,1,1);
  varcall = cats('dslist=',sas_datasets,',varlist=',sas_variables,',');
  varcall = cats(varcall,'type=',_type,',debug=&_xdebug');
  call symputx('_varcall'||strip(put(_n_,best.)),varcall,'L');
run;
%do i = 1 %to %ut_numobs(&_pfx.reqvar);
  %ut_chk_var(&&_varcall&i);
%end;
;

%*========================================================;
%* Delete temporary datasets and reset system options     ; 
%*========================================================;
%ut_restore_env(prefixlist = &_pfx,
                optds      = &_pfx.optsave,
                optlist    = MPRINT MLOGIC SYMBOLGEN,  
                debug      = &_xdebug);

%mend ut_parmcheck;
/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="-4edc3164:13fd3456e86:3e88" sddversion="3.5" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter dependsaction="ENABLE" obfuscate="N" label="SAS log" systemtype="&star;LOG&star;" tabname="System Files" baseoption="A" advanced="N" order="1" id="&star;LOG&star;" canlinktobasepath="Y" protect="N" userdefined="S" filetype="LOG"*/
/*   processid="P1" required="N" resolution="INPUT" enable="N" type="LOGFILE">*/
/*  </parameter>*/
/*  <parameter dependsaction="ENABLE" obfuscate="N" label="SAS output" systemtype="&star;LST&star;" tabname="System Files" baseoption="A" advanced="N" order="2" id="&star;LST&star;" canlinktobasepath="Y" protect="N" userdefined="S" filetype="LST"*/
/*   processid="P1" required="N" resolution="INPUT" enable="N" type="LSTFILE">*/
/*  </parameter>*/
/*  <parameter dependsaction="ENABLE" obfuscate="N" label="Process parameter values" systemtype="SDDPARMS" tabname="System Files" baseoption="A" advanced="N" order="3" id="SDDPARMS" canlinktobasepath="Y" protect="N" userdefined="S" filetype="SAS7BDAT"*/
/*   processid="P1" required="N" resolution="INPUT" enable="N" type="PARMFILE">*/
/*  </parameter>*/
/*  <parameter id="DEBUG" resolution="INTERNAL" type="TEXT" order="4">*/
/*  </parameter>*/
/*  <parameter id="I" resolution="INTERNAL" type="TEXT" order="5">*/
/*  </parameter>*/
/*  <parameter id="_PFX" resolution="INTERNAL" type="TEXT" order="6">*/
/*  </parameter>*/
/*  <parameter id="ERROR_STATUS" resolution="INTERNAL" type="TEXT" order="7">*/
/*  </parameter>*/
/*  <parameter id="J" resolution="INTERNAL" type="TEXT" order="8">*/
/*  </parameter>*/
/*  <parameter id="_PDA" resolution="INTERNAL" type="TEXT" order="9">*/
/*  </parameter>*/
/*  <parameter id="_ALMACNAME" resolution="INTERNAL" type="TEXT" order="10">*/
/*  </parameter>*/
/*  <parameter id="_ALVERSION" resolution="INTERNAL" type="TEXT" order="11">*/
/*  </parameter>*/
/*  <parameter id="SDD" resolution="INTERNAL" type="TEXT" order="12">*/
/*  </parameter>*/
/*  <parameter id="_ACTLIST" resolution="INTERNAL" type="TEXT" order="13">*/
/*  </parameter>*/
/*  <parameter id="_DEFCOUNT" resolution="INTERNAL" type="TEXT" order="14">*/
/*  </parameter>*/
/*  <parameter id="_DSLIST" resolution="INTERNAL" type="TEXT" order="15">*/
/*  </parameter>*/
/*  <parameter id="_DSNAME" resolution="INTERNAL" type="TEXT" order="16">*/
/*  </parameter>*/
/*  <parameter id="_INVALPARMNAME" resolution="INTERNAL" type="TEXT" order="17">*/
/*  </parameter>*/
/*  <parameter id="_INVCOUNT" resolution="INTERNAL" type="TEXT" order="18">*/
/*  </parameter>*/
/*  <parameter id="_LOCATION" resolution="INTERNAL" type="TEXT" order="19">*/
/*  </parameter>*/
/*  <parameter id="_NINVSPACE" resolution="INTERNAL" type="TEXT" order="20">*/
/*  </parameter>*/
/*  <parameter id="_NOCASELIST" resolution="INTERNAL" type="TEXT" order="21">*/
/*  </parameter>*/
/*  <parameter id="_NOTNULLONLY" resolution="INTERNAL" type="TEXT" order="22">*/
/*  </parameter>*/
/*  <parameter id="_NOTNUM" resolution="INTERNAL" type="TEXT" order="23">*/
/*  </parameter>*/
/*  <parameter id="_NULLONLY" resolution="INTERNAL" type="TEXT" order="24">*/
/*  </parameter>*/
/*  <parameter id="_PARMCALL" resolution="INTERNAL" type="TEXT" order="25">*/
/*  </parameter>*/
/*  <parameter id="_PGMSRC" resolution="INTERNAL" type="TEXT" order="26">*/
/*  </parameter>*/
/*  <parameter id="_PNAME1" resolution="INTERNAL" type="TEXT" order="27">*/
/*  </parameter>*/
/*  <parameter id="_PNAME2" resolution="INTERNAL" type="TEXT" order="28">*/
/*  </parameter>*/
/*  <parameter id="_PNAME3" resolution="INTERNAL" type="TEXT" order="29">*/
/*  </parameter>*/
/*  <parameter id="_PNAME4" resolution="INTERNAL" type="TEXT" order="30">*/
/*  </parameter>*/
/*  <parameter id="_SUBSET" resolution="INTERNAL" type="TEXT" order="31">*/
/*  </parameter>*/
/*  <parameter id="_TRUTH" resolution="INTERNAL" type="TEXT" order="32">*/
/*  </parameter>*/
/*  <parameter id="_XDEV" resolution="INTERNAL" type="TEXT" order="33">*/
/*  </parameter>*/
/*  <parameter id="_XQA" resolution="INTERNAL" type="TEXT" order="34">*/
/*  </parameter>*/
/*  <parameter id="_XPRD" resolution="INTERNAL" type="TEXT" order="35">*/
/*  </parameter>*/
/*  <parameter id="_XDEBUG" resolution="INTERNAL" type="TEXT" order="36">*/
/*  </parameter>*/
/*  <parameter id="_X" resolution="INTERNAL" type="TEXT" order="37">*/
/*  </parameter>*/
/*  <parameter id="_LOGCALL" resolution="INTERNAL" type="TEXT" order="38">*/
/*  </parameter>*/
/*  <parameter id="_DEFPARM" resolution="INTERNAL" type="TEXT" order="39">*/
/*  </parameter>*/
/*  <parameter id="_DEFVALUE" resolution="INTERNAL" type="TEXT" order="40">*/
/*  </parameter>*/
/*  <parameter id="_DEFCOND" resolution="INTERNAL" type="TEXT" order="41">*/
/*  </parameter>*/
/*  <parameter id="_DSCALL" resolution="INTERNAL" type="TEXT" order="42">*/
/*  </parameter>*/
/*  <parameter id="_INVSPACE" resolution="INTERNAL" type="TEXT" order="43">*/
/*  </parameter>*/
/*  <parameter id="_VARCALL" resolution="INTERNAL" type="TEXT" order="44">*/
/*  </parameter>*/
/*  <parameter id="_PNAME" resolution="INTERNAL" type="TEXT" order="45">*/
/*  </parameter>*/
/*  <parameter id="_NOMATCH" resolution="INTERNAL" type="TEXT" order="46">*/
/*  </parameter>*/
/*  <parameter id="_INVPARM" resolution="INTERNAL" type="TEXT" order="47">*/
/*  </parameter>*/
/*  <parameter id="_INVCOND" resolution="INTERNAL" type="TEXT" order="48">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/