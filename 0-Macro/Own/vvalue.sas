/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        222354

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Allen Zeng $LastChangedBy: $
  Creation Date:         09Oct2016 / $LastChangedDate: $

  Program Location/name: $HeadURL: $

  Files Created:         NA

  Program Purpose:       Automagically copy variable value

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: $
-----------------------------------------------------------------------------*/
%macro vvalue();
store;
gsubmit "%nrstr(%%let) var=%nrstr(%%nrstr%()";
gsubmit buf=default;
gsubmit ");";

gsubmit '
proc sql noprint;
    select distinct &var into :varlst separated by "@"
    from &syslast
    ;
quit;

%let increment=%eval(&increment+1);

filename clip clipbrd;

data _null_;
    file clip;
    length value $200;
	if &increment <= countw("&varlst", "@") then value=scan("&varlst", &increment, "@");
	else value=scan("&varlst", countw("&varlst", "@"), "@");
    put value;
run;

filename clip clear;';
%mend vvalue;