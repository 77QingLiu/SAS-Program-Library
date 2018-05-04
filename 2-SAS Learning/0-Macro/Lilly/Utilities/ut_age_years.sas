%macro ut_age_years(fromvar=_default_,tovar=_default_,outvar=_default_,
 decimal=_default_,debug=_default_);
/*soh***************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME           : ut_age_years
CODE TYPE           : Broad-use Module
PROJECT NAME        : N/A
DESCRIPTION         : Computes age in years between two dates.
                      Age is computed as an integer or as a decimal value,
                      as specified by the DECIMAL parameter.
SOFTWARE/VERSION#   : SAS v9.1.3 and SAS v9.2
INFRASTRUCTURE      : SDD v3.4 and MS Windows
LIMITED-USE MODULES : N/A
BROAD-USE MODULES   : /lillyce/prd/general/bums/macro_library/
                      ut_parmdef, ut_logical
INPUT               : called in a data step containing the two date variables
OUTPUT              : a specified variable containing the computed age in years
PROGRAM PURPOSE     : N/A
VALIDATION LEVEL    : 6
REQUIREMENTS        : /lillyce/qa/general/bums/validation_sop_bums/
                      ut_age_years_validation/documentation/ut_age_years_sdd_dl.doc
ASSUMPTIONS         : None.
--------------------------------------------------------------------------------
BROAD-USE MODULE SPECIFIC INFORMATION:
BROAD-USE MODULE TEMPORARY OBJECT PREFIX: _age

PARAMETERS:
Name       Type      Default   Description and Valid Values
---------  --------  --------  -------------------------------------------------
FROMVAR    required            Name of variable containing the starting SAS date
                                of the period to compute age for - e.g. birth date.
TOVAR      required            Name of variable containing the ending SAS date of
                                the period to compute age for - e.g. consent date.
OUTVAR     required  age       Name of output variable that will contain the age
                                computed by this macro. This macro will create
                                this variable, it need not be declared by
                                the user prior to the macro call.
DECIMAL    required  1         %ut_logical value specifying whether to include
                                a decimal portion in OUTVAR. A true value will
                                result in the age value in OUTVAR being a 
                                decimal value.  A false value will result in the
                                age value in OUTVAR being an integer value.
DEBUG      required  0         %ut_logical value specifying whether to turn 
                                debug mode on or off.
--------------------------------------------------------------------------------
USAGE NOTES:

  Must be called in a data step

  The values of the variables specified by FROMVAR and TOVAR must be valid
  SAS date values, ie. an integer value indicating the number of days from
  January 1, 1960.

  Reference formula:

  age=floor((intck('month',&fromvar,&tovar)-(day(&tovar) < day(&fromvar)))/12);

  This macro enhances this reference formula by adding support for decimal
  ages and negative ages.  The reference formula was taken from www.sas.com
  technical tips.
--------------------------------------------------------------------------------
TYPICAL WAYS TO EXECUTE THIS CODE AND DESCRIPTION:

  %ut_age_years(fromvar=birthdt,tovar=consentdt)
  Creates a numeric variable named AGE that contains the decimal value of
  the number of years from BIRTHDT to CONSENTDT

  %ut_age_years(fromvar=birthdt,tovar=consentdt,outvar=lbage)
  This will create a variable named LBAGE the contains a decimal age value.

  %ut_age_years(fromvar=birthdt,tovar=consentdt,decimal=no)
  This will create a variable named AGE that contains an integer age value.
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

     Author &
Ver# Peer Reviewer    Request #        Broad-Use MODULE History Description
---- ---------------- ---------------- -----------------------------------------
1.0   Gregory Steffens                 Original version of the code
      Nihar Rath

2.0   Craig Hansen &  BMRCSH25MAR2011  Update header to reflect code validated for SAS v9.2.
      Shong DeMattos                   Modified header to maintain compliance with current SOP 
                                       Code Header.
**eoh**************************************************************************/

%*=============================================================================;
%* Initialization;
%*=============================================================================;
%if %upcase(&debug) = _DEFAULT_ %then %let debug = 0;
%else %do;
  %ut_logical(debug)
%end;
%ut_parmdef(fromvar,_pdverbose=&debug,_pdrequired=1,_pdmacroname=ut_age_years)
%ut_parmdef(tovar,_pdverbose=&debug,_pdrequired=1,_pdmacroname=ut_age_years)
%ut_parmdef(outvar,age,_pdverbose=&debug,_pdrequired=1,_pdmacroname=ut_age_years)
%ut_parmdef(decimal,1,_pdverbose=&debug,_pdrequired=1,_pdmacroname=ut_age_years)
%ut_parmdef(debug,0,_pdverbose=&debug,_pdrequired=1,_pdmacroname=ut_age_years)
%ut_logical(decimal)
*==============================================================================;
%bquote(* Compute age in years from &fromvar to &tovar assign to &outvar;)
%if &decimal %then %do;
   %bquote (* with decimal;)
%end;
%else %do;
  %bquote(* in integer value;)
%end;
*==============================================================================;
if &fromvar ^= . & &tovar ^= . then do;
  %*---------------------------------------------------------------------------;
  %* Use INTCK function to determine the number of months from fromvar to tovar;
  %*---------------------------------------------------------------------------;
  &outvar = intck('month',&fromvar,&tovar);
  %if &debug %then %do;
    put / 'UNOTE: (ut_age_years)' _n_= &fromvar= &tovar= &outvar= 'months';
  %end;
  if &outvar ^= . then do;
    if &outvar > 0 | (&outvar = 0 & (day(&tovar) > day(&fromvar))) then do;
      *------------------------------------------------------------------------;
      * Positive age values;
      *------------------------------------------------------------------------;
      %*-----------------------------------------------------------------------;
      %* Compute the integer portion of age;
      %* Get true number of months by subtracting 1 from intck number of months;
      %*  when the day of tovar is before the day of fromvar;
      %* Divide this true number of months by 12 to convert to years;
      %*-----------------------------------------------------------------------;
      if &outvar ^= 0 then
       &outvar = int((&outvar - (day(&tovar) < day(&fromvar))) / 12);
      %if &debug %then %do;
        put 'UNOTE: (ut_age_years)' _n_= &fromvar= &tovar= &outvar= 
         'years (integer)  positive';
      %end;
      %if &decimal %then %do;
        %*---------------------------------------------------------------------;
        %* Compute the decimal portion of age and add it to the integer portion;
        %*---------------------------------------------------------------------;
        if ^ (month(&fromvar) = 2 & day(&fromvar) = 29) then do;
          _agefromdttoyr = mdy(month(&fromvar),day(&fromvar),year(&tovar) -
           (&tovar < mdy(month(&fromvar),day(&fromvar),year(&tovar))));
          _agedaysnyear = mdy(month(_agefromdttoyr),day(_agefromdttoyr),
           year(_agefromdttoyr) + 1) - _agefromdttoyr;
        end;
        else do;
          _agefromdttoyr = mdy(2,28,
           year(&tovar) - (&tovar < (mdy(2,28,year(&tovar)) + 1))) + 1;
          _agedaysnyear = mdy(2,28,year(_agefromdttoyr) + 1) + 1
           - _agefromdttoyr;
        end;
        &outvar = &outvar + abs((&tovar - _agefromdttoyr) / _agedaysnyear);
        %if &debug %then %do;
          put 'UNOTE: (ut_age_years)' _n_= &fromvar= &tovar= _agefromdttoyr= :
           date9. _agedaysnyear= &outvar= 'years (decimal) positive';
          if _agedaysnyear ^ in (365 366) then put 'UER' 'ROR: (ut_age_years) '
           'incorrect number of days in year ' _n_= _agedaysnyear=; 
        %end;
      %end;
    end;
    else do;
      *------------------------------------------------------------------------;
      * Negative and zero age values;
      *------------------------------------------------------------------------;
      %*-----------------------------------------------------------------------;
      %* Compute the integer portion of age;
      %* Get true number of months by adding 1 to the intck number of months;
      %*  when the day of tovar is after the day of fromvar;
      %* Divide this true number of months by 12 to convert to years;
      %*-----------------------------------------------------------------------;
      &outvar = int((&outvar + (day(&tovar) > day(&fromvar))) / 12);
      %if &debug %then %do;
        put 'UNOTE: (ut_age_years)' _n_= &fromvar= &tovar= &outvar= 
         'years (integer) negative';
      %end;
      %if &decimal %then %do;
        %*---------------------------------------------------------------------;
        %* Compute the decimal portion of age and subtract it from the integer;
        %*  portion;
        %*---------------------------------------------------------------------;
        if ^ (month(&fromvar) = 2 & day(&fromvar) = 29) then do;
          _agefromdttoyr = mdy(month(&fromvar),day(&fromvar),year(&tovar) +
           (&tovar > mdy(month(&fromvar),day(&fromvar),year(&tovar))));
          _agedaysnyear = _agefromdttoyr - 
           mdy(month(_agefromdttoyr),day(_agefromdttoyr),
           year(_agefromdttoyr) - 1);
        end;
        else do;
          _agefromdttoyr = mdy(3,1,
           year(&tovar) + (&tovar > (mdy(3,1,year(&tovar)) - 1))) - 1;
          _agedaysnyear = _agefromdttoyr - mdy(2,28,year(_agefromdttoyr) - 1)
          ;
        end;
        &outvar = &outvar - abs((&tovar - _agefromdttoyr) / _agedaysnyear);
        %if &debug %then %do;
          put 'UNOTE: (ut_age_years)' _n_= &fromvar= &tovar= _agefromdttoyr= :
           date9. _agedaysnyear= &outvar= 'years (decimal) negative';
          if _agedaysnyear ^ in (365 366) then put 'UER' 'ROR: (ut_age_years) '
           'incorrect number of days in year ' _n_= _agedaysnyear=; 
        %end;
      %end;
    end;
  end;
  else do;
    put 'UWAR' 'NING: (ut_age_years) Invalid date values ' _n_= &fromvar=
     &tovar=;
    &outvar = .;
  end;
end;
else &outvar = .;
%if &decimal %then %do;
  drop _agefromdttoyr _agedaysnyear;
%end;
%if &debug %then %do;
  put 'UNOTE: (ut_age_years)' _n_= &fromvar= &tovar= &outvar= 'years' /;
%end;
label &outvar = "Number of years between &fromvar and &tovar";
%mend;
/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="138e667:12efc4af4fe:-318f" sddversion="3.4" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="1" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="FROMVAR" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="2" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="TOVAR" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="3" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="OUTVAR" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="4" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="DECIMAL" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="5" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="DEBUG" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/