/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   <client> / <protocol>
  PXL Study Code:        <TIME Code>

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                <author> / $LastChangedBy:  $
  Creation Date:         <date in DDMMMYYYY format> / $LastChangedDate:  $

  Program Location/Name: $HeadURL: $

  Files Created:         None

  Program Purpose:       To direct SAS to create formats

  Macro Parameters       NA

-------------------------------------------------------------------------------
  MODIFICATION HISTORY:  see Subversion $Rev: $
-----------------------------------------------------------------------------*/
/* Include global formats */

%INCLUDE "&_formats./formats.sas";

PROC FORMAT LIBRARY=work;

/* Type specific formats go here */

RUN;

%*----------------------------------------------------------------------------*;
%*--- Incase you need to export or print format catalog. Change output     ---*;
%*--- destination to permanent library if necessary                        ---*;
%*----------------------------------------------------------------------------*;

/*
%LET destination_library=work;
PROC FORMAT LIBRARY=&destination_library. CNTLOUT=&destination_library..formats;

PROC SORT DATA=&destination_library..formats;
  BY fmtname;
RUN;

PROC PRINTTO NEW FILE="&_formats.formats.txt";
RUN;

PROC PRINT DATA=&destination_library..formats NOOBS LABEL WIDTH=MIN;
  %LET obyline=%SYSFUNC(GETOPTION(byline));
  %LET ols = %SYSFUNC(GETOPTION(ls));
  %LET ops = %SYSFUNC(GETOPTION(ps));
  TITLE1 "SAS format definitions";
  OPTIONS byline ls=158 ps=57;
  BY fmtname ;
  VAR start end label;
QUIT;RUN;
OPTIONS &obyline. ls=&ols. ps=&ops.;
PROC PRINTTO; RUN;

*/

