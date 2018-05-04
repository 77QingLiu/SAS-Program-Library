%macro ut_find_decodes(inlib=_default_,contentsdsn=_default_,mdlib=_default_,
 mdprefix=_default_,select=_default_,exclude=_default_,out=_default_,
 codesuffix=_default_,ldecodesuffix=_default_,sdecodesuffix=_default_,
 striproot=_default_,verbose=_default_,debug=_default_);
/*soh***************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME           : ut_find_decodes
CODE TYPE           : Broad-Use Module
PROJECT NAME        : 
DESCRIPTION         : Creates an output data set that lists all 
                       code, short decode and long decode variables and their
                       relation to each other.
SOFTWARE/VERSION#   : SAS/Version 9
INFRASTRUCTURE      : SDD
LIMITED-USE MODULES : N/A
BROAD-USE MODULES   : ut_parmdef ut_logical ut_titlstrt mdmake ut_errmsg
INPUT               : as defined by parameters: MDLIB, INLIB, CONTENTDSN
OUTPUT              : as defined by OUT parameter
VALIDATION LEVEL    : 6
REQUIREMENTS        : https://sddchippewa.sas.com/webdav/lillyce/qa/general/bums/ut_find_decodes/documentation/ut_find_decodes_rd.doc 
ASSUMPTIONS         : 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
BROAD-USE MODULE/LIMITED-USE MODULE SPECIFIC INFORMATION:

BROAD-USE MODULE TEMPORARY OBJECT PREFIX: _fd

PARAMETERS:
Name          Type     Default    Description and Valid Values
------------- -------- ---------- ----------------------------------------------
MDLIB         optional            Libref of metadata describing the data in
                                   INLIB
MDPREFIX      optional            Prefix for metadata values
SELECT        optional            Optional list of values to select from input data.
                                  List can be space or comma-delimited.
                                  Syntax for comma-delimited lists must conform to: 
                                  select=%str(val1, val2, ..., valn)
EXCLUDE       optional            Optional list of values to exclude from input data
                                  List can be space or comma-delimited.
                                  Syntax for comma-delimited lists must conform to:
                                  exclude=%str(val1, val2, ..., valn)
INLIB         optional            Libref of input data sets where decode 
                                   variables will be searched for
CONTENTSDSN   optional            PROC CONTENTS output data set describing 
                                   input data sets if INLIB data sets are not
                                   available
OUT           optional decodes     SAS dataset name where INLIB data 
                                   with decode variables added will be written
CODESUFFIX    optional            Suffix of variable names whose values are 
                                   codes
LDECODESUFFIX optional LNM        Suffix of variable names whose values are
                                   long decodes
SDECODESUFFIX optional SNM        Suffix of variable names whose values are
                                   short decodes
STRIPROOT     optional _          Character to strip from the end of the root
                                   names
VERBOSE       required 1          %ut_logical value specifying whether verbose
                                   mode is on or off
DEBUG         required 0          %ut_logical value specifying whether debug
                                   mode is on or off.  Debug mode should only be
                                   used by the macro code author when diagnosing
                                   code to find problems.

USAGE NOTES:

Output data set variables
TABLE               data set name
CFORMAT             
CODE_NAME           name of code variable
SHORT_DECODE_NAME   name of short decode variable
LONG_DECODE_NAME    name of long decode variable
ROOT_NAME           root name of code, short and long decode variables
TYPE                (COLUMN or PARAMREL)
COLUMN              if TYPE is PARAMREL, the name of the parameter variable
PARAM               if TYPE is PARAMREL, the value of the parameter variable
PFORMAT             
CODE_TYPE           code variable type - N or C
CODE_LENGTH         Length of code variable
SHORT_DECODE_TYPE   short decode variable type - N or C
SHORT_DECODE_LENGTH length of short decode variable
LONG_DECODE_TYPE    long decode variable type - N or C
LONG_DECODE_LENGTH  length of long decode variable
CODE_EXISTS         does code variable exist in INLIB 
                     1=it does exist
                     0=it does not exist
                     .=unable to determine because INLIB is not specified
TABLE_EXISTS         does table exist in INLIB
                     1=it does exist
                     0=it does not exist
                     .=unable to determine because INLIB is not specified

TYPICAL WAYS TO EXECUTE THIS CODE AND DESCRIPTION:

%ut_find_decodes(inlib=inpdata,
                 mdlib=srcmdata);
Creates an output data set (decodes.sas7bdat) that lists all 
code, short decode and long decode variables and their relation to each other for 
the data in 'inlib' as defined in the metadata library 'mdlib'.

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

     Author &
Ver#  Peer Reviewer   Code History Description
---- ---------------- ----------------------------------------------------------
1.0  Kallin Carter     Original version of the code 22Mar08  BMRKC18AUG2009a
     Melinda Rodgers
**eoh**************************************************************************/

%*=============================================================================;
%* Parameter processing and initialization;
%*=============================================================================;
%ut_parmdef(inlib,_pdmacroname=ut_find_decodes,_pdrequired=0)
%ut_parmdef(contentsdsn,_pdmacroname=ut_find_decodes,_pdrequired=0)
%ut_parmdef(mdlib,_pdmacroname=ut_find_decodes,_pdrequired=0)
%ut_parmdef(mdprefix,_pdmacroname=ut_find_decodes,_pdrequired=0)
%ut_parmdef(select,_pdmacroname=ut_find_decodes,_pdrequired=0)
%ut_parmdef(exclude,_pdmacroname=ut_find_decodes,_pdrequired=0)
%ut_parmdef(codesuffix,_pdmacroname=ut_find_decodes,_pdrequired=0)
%ut_parmdef(sdecodesuffix,snm,_pdmacroname=ut_find_decodes,_pdrequired=0)
%ut_parmdef(ldecodesuffix,lnm,_pdmacroname=ut_find_decodes,_pdrequired=0)
%ut_parmdef(out,decodes,_pdmacroname=ut_find_decodes,_pdrequired=0)
%ut_parmdef(striproot,_,_pdmacroname=ut_find_decodes,_pdrequired=0)
%ut_parmdef(verbose,1,_pdmacroname=ut_find_decodes,_pdrequired=1)
%ut_parmdef(debug,0,_pdmacroname=ut_find_decodes,_pdrequired=1)
%ut_logical(verbose)
%ut_logical(debug)
%local titlstrt i cp param paramrel column colprel mdsn;
%ut_titlstrt
title&titlstrt
 "(ut_find_decodes) Finding decode variables from &inlib &contentsdsn &mdlib";

%if %bquote(&mdlib)=  && %bquote(&inlib)=  && %bquote(&contentsdsn)= %then %do;
  %ut_errmsg(msg='non-null values should be provided for atleast one of MDLIB, INLIB and CONTENTSDSN parameters',type=warning,
   macroname=ut_find_decodes);
%end;
%else %do;


%if %bquote(&mdlib) ^= %then %do;
  *============================================================================;
  * Find decode variables with metadata;
  *============================================================================;

  %mdmake(inlib=&mdlib,inprefix=&mdprefix,outlib=work,outprefix=_fd,
   inselect=&select,inexclude=&exclude,mode=replace,contents=0,
   verbose=&verbose,debug=&debug)
  *----------------------------------------------------------------------------;
  * Create data sets of codes (format type 2) short decodes (format type 3) and;
  *  long decodes (format type 4);
  * Separate each according to whether they are unique or multiple;
  *  unique - code and decodes match by common cformat within a table;
  *           and there are not muliple code or decode variables with shared;
  *           format;
  *  multiple - there are multiple code variables with shared format and;
  *             multiple decode variables with shared format, so a root_name;
  *             is required to determine which decodes associate with which;
  *             codes;
  *----------------------------------------------------------------------------;
  %do i = 1 %to 2;
    %if &i = 1 %then %do;
      %let cp=c;
      %let param =;
      %let paramrel =;
      %let column =;
      %let colprel = column;
      %let mdsn = columns;
    %end;
    %else %do;
      %let cp = p;
      %let param = param;
      %let paramrel = paramrel;
      %let column = column;
      %let colprel = paramrel;
      %let mdsn = columns_param;
    %end;
    *--------------------------------------------------------------------------;
    %bquote(* Process the code and decode variables defined in &mdsn);
    *--------------------------------------------------------------------------;
    proc sort data = _fd&mdsn
     (keep = table column &param &paramrel &cp.format &cp.formatflag
     where = (&cp.format ^= ' ' & &cp.formatflag in (2 3 4)))
     out = _fdcolfmts;
      by table &column &param &cp.format &cp.formatflag;
    run;
    data _fducodes     _fdmcodes
         _fdusdecodes  _fdmsdecodes
         _fduldecodes  _fdmldecodes
         _fdmnoroot_name;
      set _fdcolfmts;
      by table &column &param &cp.format &cp.formatflag;
      length root_name suffix $ 32;
      *........................................................................;
      * Create root_name;
      *........................................................................;
      if &cp.formatflag = 2 then suffix = left(upcase("&codesuffix"));
      else if &cp.formatflag = 3 then suffix = left(upcase("&sdecodesuffix"));
      else if &cp.formatflag = 4 then suffix = left(upcase("&ldecodesuffix"));
      if suffix ^= ' ' then do;
        if trim(left(reverse(&colprel))) =: trim(left(reverse(suffix))) then
         root_name = substr(&colprel,1,length(&colprel) - length(suffix));
      end;
      else do;
        if &cp.formatflag = 2 then root_name = &colprel;
        else root_name = ' ';
      end;
      %if %bquote(&striproot) ^= %then %do;
        if root_name ^= ' ' & length(root_name) >= length("&striproot") then do;
          if substr(root_name,length(root_name) - length("&striproot") + 1)
           = "&striproot" then root_name =
           substr(root_name,1,length(root_name) - length("&striproot"));
        end;
      %end;
      *........................................................................;
      * Create output data sets;
      *........................................................................;
      if &cp.formatflag = 2 then do;
        if first.&cp.formatflag + last.&cp.formatflag = 2 then output _fducodes;
        else if root_name ^= ' ' then output _fdmcodes;
        else output _fdmnoroot_name;
      end;
      else if &cp.formatflag = 3 then do;
        if first.&cp.formatflag + last.&cp.formatflag = 2 then
         output _fdusdecodes;
        else if root_name ^= ' ' then output _fdmsdecodes;
        else output _fdmnoroot_name;
      end;
      else if &cp.formatflag = 4 then do;
        if first.&cp.formatflag + last.&cp.formatflag = 2 then
         output _fduldecodes;
        else if root_name ^= ' ' then output _fdmldecodes;
        else output _fdmnoroot_name;
      end;
      keep table column &param &paramrel &cp.format &cp.formatflag root_name;
    run;
    *--------------------------------------------------------------------------;
    * Merge code and decode variable information when they are unique trios;
    * Create output data sets;
    * _fduallcols    has all 3 variables - code shortdecode longdecode;
    * _fdunotallcols missing 1 or more variables and has shared root_name;
    * _fdunoroot     missing 1 or more variables but has no shared root_name;
    *--------------------------------------------------------------------------;
    data _fduallcols _fdunotallcols _fdunoroot_name;
      merge
       _fducodes    (in=fromc drop=&cp.formatflag
                    rename=(&colprel=code root_name=code_root_name))
       _fdusdecodes (in=froms drop=&cp.formatflag
                rename=(&colprel=short_decode root_name=short_decode_root_name))
       _fduldecodes (in=froml drop=&cp.formatflag
                rename=(&colprel=long_decode root_name=long_decode_root_name));
      by table &column &param &cp.format;
      length code_name short_decode_name long_decode_name root_name $ 32;
      code_name = code;
      short_decode_name = short_decode;
      long_decode_name = long_decode;

      if code_root_name ^= ' ' &
       (code_root_name = short_decode_root_name | short_decode_root_name = ' ')
       & (code_root_name = long_decode_root_name | long_decode_root_name = ' ')
       then root_name = code_root_name;
      else if short_decode_root_name ^= ' ' &
       (short_decode_root_name = long_decode_root_name |
       long_decode_root_name = ' ') then root_name = short_decode_root_name;
      else if long_decode_name ^= ' ' then root_name = long_decode_root_name;

      if fromc & froms & froml then output _fduallcols;
      else if root_name ^= ' ' then output _fdunotallcols;
      else output _fdunoroot_name;

      keep table &column &param code_name short_decode_name long_decode_name
       &cp.format root_name;
    run;
    %if &verbose & (%bquote(&codesuffix) ^= | %bquote(&sdecodesuffix) ^= |
     %bquote(&ldecodesuffix) ^= ) %then %do;
      proc print data = _fdunoroot_name width=minimum;
        title%eval(&titlstrt + 1) "(ut_find_decodes) Incomplete trios from "
         "&mdsn with same format but no root name";
      run;
      title%eval(&titlstrt + 1);
    %end;
    *--------------------------------------------------------------------------;
    * Merge code and decode variable information when they are not unique trios;
    *  by adding root_name to the BY statement;
    * _fdmuallcols    has all 3 variables - code shortdecode longdecode;
    * _fdmunotallcols missing 1 or more variables and has shared root_name;
    * _fdmmcodes      multiples that cannot be made unique by root_name;
    * _fdmmsdecodes   multiples that cannot be made unique by root_name;
    * _fdmmldecodes   multiples that cannot be made unique by root_name;
    *--------------------------------------------------------------------------;
    proc sort data = _fdmcodes;
      by table &column &param &cp.format root_name;
    run;
    proc sort data = _fdmsdecodes;
      by table &column &param &cp.format root_name;
    run;
    proc sort data = _fdmldecodes;
      by table &column &param &cp.format root_name;
    run;
    data _fdmucodes _fdmmcodes;
      set _fdmcodes;
      by table &column &param &cp.format root_name;
      if first.root_name + last.root_name = 2 then output _fdmucodes;
      else output _fdmmcodes;
    run;
    data _fdmusdecodes _fdmmsdecodes;
      set _fdmsdecodes;
      by table &column &param &cp.format root_name;
      if first.root_name + last.root_name = 2 then output _fdmusdecodes;
      else output _fdmmsdecodes;
    run;
    data _fdmuldecodes _fdmmldecodes;
      set _fdmldecodes;
      by table &column &param &cp.format root_name;
      if first.root_name + last.root_name = 2 then output _fdmuldecodes;
      else output _fdmmldecodes;
    run;
    data _fdmuallcols _fdmunotallcols;
      merge
       _fdmucodes    (in=fromc drop=&cp.formatflag
                     rename=(&colprel=code))
       _fdmusdecodes (in=froms drop=&cp.formatflag
                     rename=(&colprel=short_decode))
       _fdmuldecodes (in=froml drop=&cp.formatflag
                     rename=(&colprel=long_decode));
      by table &column &param &cp.format root_name;
      length code_name short_decode_name long_decode_name root_name $ 32;
      code_name = code;
      short_decode_name = short_decode;
      long_decode_name = long_decode;
      if fromc & froms & froml then output _fdmuallcols;
      else output _fdmunotallcols;
      keep table &column &param code_name short_decode_name long_decode_name
       &cp.format root_name;
    run;
    *--------------------------------------------------------------------------;
    * Merge _fdunotallcols with _fdmunotallcols;
    *  incomplete trios from unique and nonunique but made unique by root_name;
    *--------------------------------------------------------------------------;
    proc sort data = _fdunotallcols;
      by table &column &param &cp.format root_name;
    run;
    proc sort data = _fdmunotallcols;
      by table &column &param &cp.format root_name;
    run;
    data _fdumallcols;
      merge _fdunotallcols (in=fromu rename = (code_name=cu
                           short_decode_name=sdu long_decode_name=ldu))
            _fdmunotallcols (in=frommu rename = (code_name = cmu
                        short_decode_name=sdmu long_decode_name=ldmu))
      ;
      by table &column &param &cp.format root_name;
      length code_name short_decode_name long_decode_name $ 32;

      if cu ^= ' ' then code_name = cu;
      else if cmu ^= ' ' then code_name = cmu;
      if sdu ^= ' ' then short_decode_name = sdu;
      else if sdmu ^= ' ' then short_decode_name = sdmu;
      if ldu ^= ' ' then long_decode_name = ldu;
      else if ldmu ^= ' ' then long_decode_name = ldmu;

%*      if (code_name ^= ' ') + (short_decode_name ^= ' ') +
       (long_decode_name ^= ' ') > 1 then output;

      keep table &column &param code_name short_decode_name long_decode_name
       &cp.format root_name;
    run;
    *--------------------------------------------------------------------------;
    * Combine unique trios and nonunique trios that were made unique by;
    *  root_name;
    * Deliberately does not include mmcodes mmsdecodes mmldecodes and;
    *  mnoroot_name data sets;
    *--------------------------------------------------------------------------;
    data _fdout&colprel;
      set _fduallcols     (in = fromu)
          _fdmuallcols    (in = frommu)
          _fdumallcols    (in = fromum)
          _fdunoroot_name (in = fromunoroot)
      ;
      length type $ 8;
      type = "&colprel";
      from_uallcols = fromu;
      from_muallcols = frommu;
      from_umallcols = fromum;
      from_noroot = fromunoroot;
      keep table &column &param code_name short_decode_name
       long_decode_name &cp.format root_name type from_uallcols
       from_muallcols from_umallcols from_noroot;
    run;
    proc sort data = _fdout&colprel;
      by table code_name &column &param;
    run;
    %if &verbose %then %do;
      title%eval(&titlstrt + 1) "(ut_find_decodes) &mdsn "
       "Code and Decode Variables not included the output data set";
      proc print data = _fdmmcodes width=minimum;
        title%eval(&titlstrt + 2) "(ut_find_decodes) &mdsn "
         "Code variable that cannot be made unique by root_name";
      run;
      proc print data = _fdmmsdecodes width=minimum;
        title%eval(&titlstrt + 2) "(ut_find_decodes) &mdsn "
         "Short decode variables that cannot be made unique by root_name";
      run;
      proc print data = _fdmmldecodes width=minimum;
        title%eval(&titlstrt + 2) "(ut_find_decodes) &mdsn "
         "Long decode variables that cannot be made unique by root_name";
      run;
      proc print data = _fdmnoroot_name width=minimum;
        title%eval(&titlstrt + 2) "(ut_find_decodes) &mdsn "
         "Variables that cannot be made unique because they have no root_name";
      run;
      title%eval(&titlstrt + 1);
    %end;
    %if &debug %then %do;
      proc print data = _fdcolfmts width=minimum;
        title%eval(&titlstrt + 1) "(ut_find_decodes) DEBUG _fdcolfmts &mdsn";
      run;
      proc print data = _fducodes width=minimum;
        title%eval(&titlstrt + 1) "(ut_find_decodes) DEBUG _fducodes &mdsn";
      run;
      proc print data = _fdmcodes width=minimum;
        title%eval(&titlstrt + 1) "(ut_find_decodes) DEBUG _fdmcodes &mdsn";
      run;
      proc print data = _fdusdecodes width=minimum;
        title%eval(&titlstrt + 1) "(ut_find_decodes) DEBUG _fdusdecodes &mdsn";
      run;
      proc print data = _fdmsdecodes width=minimum;
        title%eval(&titlstrt + 1) "(ut_find_decodes) DEBUG _fdmsdecodes &mdsn";
      run;
      proc print data = _fduldecodes width=minimum;
        title%eval(&titlstrt + 1) "(ut_find_decodes) DEBUG _fduldecodes &mdsn";
      run;
      proc print data = _fdmldecodes width=minimum;
        title%eval(&titlstrt + 1) "(ut_find_decodes) DEBUG _fdmldecodes &mdsn";
      run;
      proc print data = _fduallcols width=minimum;
        title%eval(&titlstrt + 1) "(ut_find_decodes) DEBUG _fduallcols &mdsn";
      run;
      proc print data = _fdunotallcols width=minimum;
        title%eval(&titlstrt + 1)
         "(ut_find_decodes) DEBUG _fdunotallcols &mdsn";
      run;
      proc print data = _fdumallcols width=minimum;
        title%eval(&titlstrt + 1) "(ut_find_decodes) DEBUG _fdumallcols &mdsn";
      run;
      proc print data = _fdmuallcols width=minimum;
        title%eval(&titlstrt + 1) "(ut_find_decodes) DEBUG _fdmuallcols &mdsn";
      run;
      proc print data = _fdmunotallcols width=minimum;
        title%eval(&titlstrt + 1)
         "(ut_find_decodes) DEBUG _fdmunotallcols &mdsn";
      run;
      proc print data = _fdout&colprel width=minimum;
        title%eval(&titlstrt + 1) "(ut_find_decodes) DEBUG _fdout&colprel";
      run;
      title%eval(&titlstrt + 1);
    %end;
  %end;
  *----------------------------------------------------------------------------;
  * Combine columns and paramrels;
  *----------------------------------------------------------------------------;
   data _fdout;
    set _fdoutcolumn _fdoutparamrel;
    by table code_name;
    keep table column param code_name short_decode_name
     long_decode_name cformat pformat root_name type;
  run;

%* check if a variable has a cformat and a pformat of type 2,3, 4 and warn user
   and use pformat if variable is a paramrel
;

  *----------------------------------------------------------------------------;
  * Add lengths of the two decode variables and types of all 3 variables;
  *----------------------------------------------------------------------------;
  proc sort data = _fdcolumns (keep=table column clength ctype)  out = _fdlens;
    by table column;
  run;
  proc sort data = _fdout;
    by table code_name;
  run;
  data _fdout;
    merge _fdout (in=fromout)
          _fdlens (in=fromlens rename=(column=code_name
                   clength=code_length ctype=code_type));
    by table code_name;
    if fromout;
  run;
  proc sort data = _fdout;
    by table short_decode_name;
  run;
  data _fdout;
    merge _fdout (in=fromout)
          _fdlens (in=fromlens rename=(column=short_decode_name
                   clength=short_decode_length ctype=short_decode_type));
    by table short_decode_name;
    if fromout;
  run;
  proc sort data = _fdout;
    by table long_decode_name;
  run;
  data _fdout;
    merge _fdout (in=fromout)
          _fdlens (in=fromlens rename=(column=long_decode_name
                   clength=long_decode_length ctype=long_decode_type));
    by table long_decode_name;
    if fromout;
  run;

  %if %bquote(&inlib) ^= | %bquote(&contentsdsn) ^= %then %do;
    *--------------------------------------------------------------------------;
    * If INLIB or CONTENTSDSN is also specified then verify whether code;
    *  variable exists and add code_exists flag variable to output data set;
    *  Add TABLE_EXISTS flag variable too to indicate whether the table exists;
    *--------------------------------------------------------------------------;
    %if %bquote(&inlib) ^= %then %do;
      proc contents data = &inlib.._all_ out=_fdcont  noprint;
      run;
    %end;
    %else %if %bquote(&contentsdsn) ^= %then %do;
      data _fdcont;
        set &contentsdsn;
      run;
    %end;
    data _fdcont;
      set _fdcont;
      memname = upcase(memname);
      name = upcase(name);
    run;
    proc sort data = _fdcont;
      by memname name;
    run;
    proc sort data = _fdout;
      by table code_name;
    run;
    data _fdout (drop = code_type_contents)
     _fdcode_type_incorrect (keep=table code_name code_type code_type_contents);
      merge
       _fdout  (in=fromout)
       _fdcont (in=fromcont keep=memname name type
               rename=(memname=table name=code_name type=code_type_contents));
      by table code_name;
      if fromout;
      if fromcont then do;
        code_exists = 1;
        if lowcase(code_type) = 'c' & code_type_contents = 1 then do;
          output _fdcode_type_incorrect;
          code_type = 'N';
        end;
        else if lowcase(code_type) = 'n' & code_type_contents = 2 then do;
          output _fdcode_type_incorrect;
          code_type = 'C';
        end;
      end;
      else code_exists = 0;
      output _fdout;
    run;
    data _fdcont_mems;
      set _fdcont (keep=memname);
      by memname;
      if first.memname;
    run;
    data _fdout;
      merge _fdout        (in=fromout)
            _fdcont_mems (in=fromcont rename=(memname=table));
      by table;
      if fromout;
      if fromcont then table_exists = 1;
      else table_exists = 0;
    run;
    %if &verbose %then %do;
      proc print data = _fdcode_type_incorrect  width=minimum;
        title%eval(&titlstrt + 1) "(ut_find_decodes) Code variables defined in "
         "metadata with an incorrect type";
      run;
      data _fdtable_not_exist;
        set _fdout (keep = table table_exists  where = (table_exists = 0));
        keep table;
      run;
      proc print data = _fdtable_not_exist  width=minimum;
        title%eval(&titlstrt + 1) "(ut_find_decodes) Tables defined in "
         "metadata that do not exist in INLIB";
      run;
      proc print data = _fdout (where = (code_exists = 0)) width=minimum;
        title%eval(&titlstrt + 1) "(ut_find_decodes) Code variables defined in "
         "metadata that do not exist in INLIB";
      run;
      title%eval(&titlstrt + 1);
    %end;
  %end;
  %else %do;
    data _fdout;
      set _fdout;
      code_exists = .;
      table_exists = .;
    run;
  %end;
  *----------------------------------------------------------------------------;
  * Create output data set;
  *----------------------------------------------------------------------------;
  proc sort data = _fdout  out = _fddecodes;
    by table column param code_name short_decode_name long_decode_name;
  run;


	proc sql;
		title "the list of all decode variables (short /long) for which there is no corresponding code variable";
		select long_decode_name,short_decode_name from _fddecodes where 
		code_name is missing  and long_decode_name is not missing and short_decode_name is not missing;
	quit;

	proc sql;
		title "the list of all code variables for which there are no corresponding decode variables";
		select code_name from _fddecodes 
		where code_name is not missing and long_decode_name is missing and short_decode_name is missing;
	quit;

%end;
%else %if %bquote(&contentsdsn) ^= | %bquote(&inlib) ^= %then %do;
  *============================================================================;
  * Find decode variables without metadata, using a proc contents data set;
  *============================================================================;
  %if %bquote(&inlib) ^= %then %do;
    proc contents data = &inlib.._all_ out=_fdcont  noprint;
    run;
  %end;
  %else %if %bquote(&contentsdsn) ^= %then %do;
    data _fdcont;
      set &contentsdsn;
    run;
  %end;
  *----------------------------------------------------------------------------;
  * Create data sets for code short decode and long decode variables;
  *  based on the suffixes specified for each type of variable;
  *----------------------------------------------------------------------------;
  %let else =;
  data _fdsdecodes (keep= memname name root_name short_decode_type short_decode_length)
   _fdldecodes (keep=memname name root_name long_decode_type long_decode_length)
   _fdnondecodes(keep=memname name root_name code_type code_length)
  ;
    set _fdcont;
    memname = upcase(memname);
    name = upcase(name);
    length root_name $ 32;
    %if %bquote(&sdecodesuffix) ^= %then %do;
      if upcase(left(reverse(name))) =:
       "%upcase(%sysfunc(reverse(&sdecodesuffix)))" then do;
        root_name = substr(name,1,length(name) - length("&sdecodesuffix"));
        %if %bquote(&striproot) ^= %then %do;
          if substr(root_name,length(root_name),1) = "&striproot" then
           root_name = substr(root_name,1,length(root_name) - 1);
        %end;
        if type = 2 then short_decode_type = 'C';
        else short_decode_type = 'N';
        short_decode_length = length;
        output _fdsdecodes;
      end;
      %let else = else;
    %end;

    %if %bquote(&sdecodesuffix)= %then %do;
        root_name = name;
        %if %bquote(&striproot) ^= %then %do;
          if substr(root_name,length(root_name),1) = "&striproot" then
           root_name = substr(root_name,1,length(root_name) - 1);
        %end;
        if type = 2 then short_decode_type = 'C';
        else short_decode_type = 'N';
        short_decode_length = length;
        output _fdsdecodes;
	 %end;



    %if %bquote(&ldecodesuffix) ^= %then %do;
      &else if upcase(left(reverse(name))) =:
       "%upcase(%sysfunc(reverse(&ldecodesuffix)))" then do;
        root_name = substr(name,1,length(name) - length("&ldecodesuffix"));
        %if %bquote(&striproot) ^= %then %do;
          if substr(root_name,length(root_name),1) = "&striproot" then
           root_name = substr(root_name,1,length(root_name) - 1);
        %end;

        if type = 2 then long_decode_type = 'C';
        else long_decode_type = 'N';
        long_decode_length = length;
        output _fdldecodes;
      end;
      %let else = else;
    %end;
    %else %do;
      &else do;
        root_name = name;
        %if %bquote(&striproot) ^= %then %do;
          if substr(root_name,length(root_name),1) = "&striproot" then
           root_name = substr(root_name,1,length(root_name) - 1);
        %end;
        if type = 2 then short_code_type = 'C';
        else long_decode_type = 'N';
        long_decode_length = length;
        output _fdldecodes;
      end;
    %end;

    %if %bquote(&codesuffix) ^= %then %do;
      &else if upcase(left(reverse(name))) =:
       "%upcase(%sysfunc(reverse(&codesuffix)))" then do;
        root_name = name;
        %if %bquote(&striproot) ^= %then %do;
          if substr(root_name,length(root_name),1) = "&striproot" then
           root_name = substr(root_name,1,length(root_name) - 1);
        %end;
        if type = 2 then code_type = 'C';
        else code_type = 'N';
        code_length = length;
        output _fdnondecodes;
      end;
    %end;
    %else %do;
      &else do;
        root_name = name;
        %if %bquote(&striproot) ^= %then %do;
          if substr(root_name,length(root_name),1) = "&striproot" then
           root_name = substr(root_name,1,length(root_name) - 1);
        %end;
        if type = 2 then code_type = 'C';
        else code_type = 'N';
        code_length = length;
        output _fdnondecodes;
      end;
    %end;
  run;
  proc sort data = _fdsdecodes;
    by memname root_name;
  run;
  proc sort data = _fdldecodes;
    by memname root_name;
  run;
  *----------------------------------------------------------------------------;
  * Merge short and long decode variable names by data set and root name;
  *----------------------------------------------------------------------------;
  data _fdsldecodes;
    merge _fdsdecodes (in=fromshort rename=(name=short_decode_name))
          _fdldecodes (in=fromlong  rename=(name=long_decode_name));
    by memname root_name;
    keep memname short_decode_name long_decode_name root_name
			short_decode_type short_decode_length
     		long_decode_type long_decode_length;
  run;
  *----------------------------------------------------------------------------;
  * Merge code variable names with decode variable names by data set and root;
  *  name;
  *----------------------------------------------------------------------------;
  proc sort data = _fdnondecodes;
    by memname root_name;
  run;
  data _fdout  _fdone_decode_only;
    merge _fdsldecodes (in=fromsl)
          _fdnondecodes (in=fromnon rename=(name=code_name));
    by memname root_name;
    if (code_name ^= ' ') + (short_decode_name ^= ' ') +
     (long_decode_name ^= ' ') > 1 then output _fdout;
    if code_name = ' ' &
     ((short_decode_name = ' ') + (long_decode_name = ' ') = 1) then
     output _fdone_decode_only;
    rename memname=table;
    keep memname root_name code_name code_type code_length short_decode_name long_decode_name
			short_decode_type short_decode_length
     		long_decode_type long_decode_length;
  run;
  *----------------------------------------------------------------------------;
  * Write code decode variable names data set to output data set;
  *----------------------------------------------------------------------------;
  data _fddecodes;
    set _fdout;
    length column $ 32 cformat $ 13 type $ 8  param $ 32  pformat $ 13
     code_exists 8;
    column = ' ';
    cformat = ' ';
    type = 'COLUMN  ';
    param = ' ';
    pformat = ' ';
    code_exists = 1;
    table_exists = 1;
  run;
  %if &verbose %then %do;
    proc print data = _fdone_decode_only width=minimum;
      by table;
      var code_name short_decode_name long_decode_name;
      title%eval(&titlstrt + 1) 
       "(ut_find_decodes) Decode variables without a related code variable "
       "and without a related decode variable";
    run;
    title%eval(&titlstrt + 1);
  %end;
%end;

%if &debug %then %do;
  proc print data = _fddecodes  width=minimum;
    by table;
    title%eval(&titlstrt + 1) "(ut_find_decodes) Output Data Set";
  run;
  title%eval(&titlstrt + 1);
%end;

%if &out ^= %then %do;
	data &out;
		set _fddecodes;
	run;
%end;
%else %do;
	data decodes;
		set _fddecodes;
	run;
%end;

%end;


%if ^ &debug %then %do;
  *============================================================================;
  * Cleanup at end of ut_find_decodes macro;
  *============================================================================;
  proc datasets lib=work nolist;
    delete _fd:;
  run; quit;
%end;
title&titlstrt;
%mend;
/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="7d53d8:126beb3699f:3e4b" sddversion="3.4" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="1" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="INLIB" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="2" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="CONTENTSDSN" maxlength="256"*/
/*   tabname="Parameters" processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="3" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="MDLIB" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="4" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="MDPREFIX" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="5" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="SELECT" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="6" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="EXCLUDE" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="7" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="OUT" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="8" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="CODESUFFIX" maxlength="256"*/
/*   tabname="Parameters" processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="9" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="LDECODESUFFIX" maxlength="256"*/
/*   tabname="Parameters" processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="10" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="SDECODESUFFIX" maxlength="256"*/
/*   tabname="Parameters" processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="11" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="STRIPROOT" maxlength="256"*/
/*   tabname="Parameters" processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="12" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="VERBOSE" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="13" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="DEBUG" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="14" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="TITLSTRT" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter id="I" resolution="INTERNAL" type="TEXT" order="15">*/
/*  </parameter>*/
/*  <parameter id="CP" resolution="INTERNAL" type="TEXT" order="16">*/
/*  </parameter>*/
/*  <parameter id="PARAM" resolution="INTERNAL" type="TEXT" order="17">*/
/*  </parameter>*/
/*  <parameter id="PARAMREL" resolution="INTERNAL" type="TEXT" order="18">*/
/*  </parameter>*/
/*  <parameter id="COLUMN" resolution="INTERNAL" type="TEXT" order="19">*/
/*  </parameter>*/
/*  <parameter id="COLPREL" resolution="INTERNAL" type="TEXT" order="20">*/
/*  </parameter>*/
/*  <parameter id="MDSN" resolution="INTERNAL" type="TEXT" order="21">*/
/*  </parameter>*/
/*  <parameter id="ELSE" resolution="INTERNAL" type="TEXT" order="22">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/