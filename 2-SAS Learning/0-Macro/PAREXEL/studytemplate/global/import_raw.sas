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

  Program Purpose:       template for loading xpt files

  Macro Parameters       NA

-------------------------------------------------------------------------------
  MODIFICATION HISTORY:  see Subversion $Rev: $
-----------------------------------------------------------------------------*/
*--- Remove read-only from Raw Library                                    ---*;
LIBNAME raw "&_raw." COMPRESS=yes;

*--- Use for xpt files that require proc cimport                          ---*;
%MACRO cimport(filename=%STR());
  FILENAME temp "&_dm.&filename.";

  PROC CIMPORT LIBRARY=raw INFILE=temp;
  RUN;QUIT;

  FILENAME temp CLEAR;
%MEND cimport;

*--- Update calls as needed                                               ---*;
*%cimport(filename=%STR(xxxx.xpt));
*%cimport(filename=%STR(xxxx_formats.xpt));

*--- Use for xpt files that require xport with proc copy                  ---*;
%MACRO cpimport(filename=%STR());
  LIBNAME temp xport "&_dm.&filename.";

  PROC COPY IN=temp OUT=raw MEMTYPE=data;
  RUN;QUIT;

  LIBNAME temp CLEAR;
%MEND cpimport;

*--- Update calls as needed                                               ---*;
*%cpimport(filename=%STR(xx.xpt));

*--- Apply read-only to Raw Library                                       ---*;
LIBNAME raw "&_raw." COMPRESS=yes ACCESS=READONLY;

PROC CONTENTS DATA = raw._ALL_ DETAILS FMTLEN VARNUM CENTILES;
QUIT;RUN;
