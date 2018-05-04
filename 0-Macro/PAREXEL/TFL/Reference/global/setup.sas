/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: < Janssen > / <CNTO148PSA3001>
  PXL Study Code:        <218184>

  SAS Version:           <93>
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                <Catlin Wei> $LastChangedBy: $
  Creation / modified:   <09/Apr/2015> / $LastChangedDate: $

  Program Location/name: $HeadURL: $

  Files Created:         None

  Program Purpose:       Define global setup and options to be used by study programs
  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: $
-----------------------------------------------------------------------------*/
/*START PROGRAMMING*/


*----------------------------------------------------------------------------*;
*---  Ensure the project SAS version is SAS 9.3                           ---*;
*----------------------------------------------------------------------------*;

%gmchecksasversion(checksasversion=9.3)

*----------------------------------------------------------------------------*;
*---  DEF_OS.  project - Project/study name. client  - Client name        ---*;
*---  tims    - Tims code.  For unblinded studies the %def_os code needs  ---*;
*---  to be copied (from /opt/pxlcommon/stats/macros/macro_library) here  ---*;
*---  AND updated TO reference the unblinded area                         ---*;
*----------------------------------------------------------------------------*;

%def_os (project=janss218184, client=Janssen, tims=218184);

*----------------------------------------------------------------------------*;
*---  OS_FVARS. mvar     - Global macro variable to create                ---*;
*---  projpath - Directory path (from top level project directory         ---*;
*---             &_proj_pre). Seperate directory levels with :.           ---*;
*---             example: projpath=data:dm                                ---*;
*----------------------------------------------------------------------------*;

%os_fvars(mvar=_global,  projpath=global);              /* place _mvar value in EXCLUDE= parameter of %MIGLOGCHK in LOGCHECK.SAS */
%os_fvars(mvar=_formats, projpath=formats);
%os_fvars(mvar=_macros,  projpath=macros);              /* place _mvar value in EXCLUDE= parameter of %MIGLOGCHK in LOGCHECK.SAS */

*--- Macro to setup delivery type.  type=interim/primary/dmc              ---*;
%MACRO type(type=);
  %os_fvars(mvar=_raw,      projpath=&type.:data:raw);     /* place _mvar value in EXCLUDE= parameter of %MIGLOGCHK in LOGCHECK.SAS */
  %os_fvars(mvar=_dm,       projpath=&type.:data:dm);      /* place _mvar value in EXCLUDE= parameter of %MIGLOGCHK in LOGCHECK.SAS */
  %os_fvars(mvar=_anal,     projpath=&type.:data:analysis);/* place _mvar value in EXCLUDE= parameter of %MIGLOGCHK in LOGCHECK.SAS */
  %os_fvars(mvar=_tab,      projpath=&type.:data:tables);  /* place _mvar value in EXCLUDE= parameter of %MIGLOGCHK in LOGCHECK.SAS */
  %os_fvars(mvar=_fig,      projpath=&type.:data:figures); /* place _mvar value in EXCLUDE= parameter of %MIGLOGCHK in LOGCHECK.SAS */
  %os_fvars(mvar=_lis,      projpath=&type.:data:listings);/* place _mvar value in EXCLUDE= parameter of %MIGLOGCHK in LOGCHECK.SAS */
  %os_fvars(mvar=_pro,      projpath=&type.:data:profiles);/* place _mvar value in EXCLUDE= parameter of %MIGLOGCHK in LOGCHECK.SAS */
  %os_fvars(mvar=_qdanal,   projpath=&type.:data:qanalysis);/* place _mvar value in EXCLUDE= parameter of %MIGLOGCHK in LOGCHECK.SAS */
  %os_fvars(mvar=_qdtab,    projpath=&type.:data:qtables);  /* place _mvar value in EXCLUDE= parameter of %MIGLOGCHK in LOGCHECK.SAS */
  %os_fvars(mvar=_qdfig,    projpath=&type.:data:qfigures); /* place _mvar value in EXCLUDE= parameter of %MIGLOGCHK in LOGCHECK.SAS */
  %os_fvars(mvar=_qdlis,    projpath=&type.:data:qlistings);/* place _mvar value in EXCLUDE= parameter of %MIGLOGCHK in LOGCHECK.SAS */
  %os_fvars(mvar=_panal,    projpath=&type.:prog:analysis);
  %os_fvars(mvar=_pappen,   projpath=&type.:prog:appendix);
  %os_fvars(mvar=_pfig,     projpath=&type.:prog:figures);
  %os_fvars(mvar=_plis,     projpath=&type.:prog:listings);
  %os_fvars(mvar=_ppro,     projpath=&type.:prog:profiles);
  %os_fvars(mvar=_ptab,     projpath=&type.:prog:tables);
  %os_fvars(mvar=_qanal,    projpath=&type.:qcprog:analysis);
  %os_fvars(mvar=_qfig,     projpath=&type.:qcprog:figures);
  %os_fvars(mvar=_qlis,     projpath=&type.:qcprog:listings);
  %os_fvars(mvar=_qpro,     projpath=&type.:qcprog:profiles);
  %os_fvars(mvar=_qtab,     projpath=&type.:qcprog:tables);
  %os_fvars(mvar=_utility,  projpath=macros:utility);
  %os_fvars(mvar=_path,     projpath=&type.);
%MEND type;
%type(type=&_type.);

*--- Setup Libnames                                                       ---*;
LIBNAME raw         "&_raw"      COMPRESS=yes ACCESS=READONLY;
LIBNAME analysis    "&_anal"     COMPRESS=yes;
LIBNAME tables      "&_tab"      COMPRESS=yes;
LIBNAME figures     "&_fig"      COMPRESS=yes;
LIBNAME listings    "&_lis"      COMPRESS=yes;
LIBNAME profiles    "&_pro"      COMPRESS=yes;
LIBNAME qcanal      "&_qdanal"   COMPRESS=yes;
LIBNAME qctab       "&_qdtab"    COMPRESS=yes;
LIBNAME qcfig       "&_qdfig"    COMPRESS=yes;
LIBNAME qclis       "&_qdlis"    COMPRESS=yes;
LIBNAME UTILITY     "&_utility"  COMPRESS=yes;

*--- Set SAS options                                                      ---*;
%GLOBAL _ps _ls;
%LET _ps=47;
%LET _ls=133;
OPTIONS LS=&_ls. ps=&_ps. CENTER NODATE NONUMBER NOBYLINE MERGENOBY=ERROR YEARCUTOFF=1920 NOMPRINT SOURCE2
        MRECALL NOSYMBOLGEN LABEL NOBYLINE MISSING="" FMTSEARCH=(work analysis) MSGLEVEL=I NOTHREADS noquotelenmax
        FORMCHAR='*_---*+*---+=*-/\<>*' orientation=landscape papersize=letter
        MAUTOSOURCE SASAUTOS=("&_macros." %SYSFUNC(COMPRESS(%SYSFUNC(GETOPTION(sasautos)),() )));

ODS PATH global.odscat (UPDATE) work.templat(update) sasuser.templat(read) sashelp.tmplmst (READ);
ODS ESCAPECHAR="~";

*--- Place any other project-specific instructions here                   ---*;
%GLOBAL _blank _line;
DATA _NULL_;
  CALL SYMPUT("_blank", REPEAT(" ", %EVAL(&_ls.-1)));
  CALL SYMPUT("_line", REPEAT("_", %EVAL(&_ls.-1)));
  call symput("PXLWAR", "WAR"||"NING:[PXL]");
  call symput("PXLERR", "ERR"||"OR:[PXL]");
RUN;

*--- Underlining justification calls for ODS RTF                          ---*;
%GLOBAL _spanc _spanl _spanr _spanu _spancj _page blinded;
%LET _spanc=\brdrb\brdrs\qc;
%LET _spanl=\brdrb\brdrs\ql;
%LET _spanr=\brdrb\brdrs\qr;
%LET _spanu=\brdrb\brdrs\ul;
%LET _spancj=\qc;
%LET _page={Page \field {\*\fldinst PAGE\*\MERGEFORMAT}} {of \field {\*\fldinst NUMPAGES \*\MERGEFORMAT}};

*--- Mount common macro                                              ---*;
proc sql noprint;
    select XPATH into :prg
        from SASHELP.VEXTFL
        where lowcase(XPATH) like '%.sas'
        ;
quit;

%macro comp;
%let prx=%sysfunc(prxparse(/(\/prog\/)/));

%if %sysfunc(prxmatch(&prx, &prg)) %then %do;
    %put Compliling macro common under main site;
    options sasautos=("&_PROJPRE./dmc/prog/analysis", %SYSFUNC(COMPRESS(%SYSFUNC(GETOPTION(sasautos)),() )), sasautos);
%end;
%else %do;
    %put Compliling macro common under qc site;
    options sasautos=("&_PROJPRE./dmc/qcprog/analysis", %SYSFUNC(COMPRESS(%SYSFUNC(GETOPTION(sasautos)),() )), sasautos);
%end;
%mend;

%comp

*--- Mount rtf templates                                                  ---*;;
%inc "&_global.rtf.sas";

*--- Global variables ---*;
%global blinded blindedad crosswk blindtype meddraver;

*--- Define Treatment type(blinded/unblinded) ----*;
*--- Total Column for blinded type ----*;
*    Y: for the DMC open session, keep Total column;
*    N: for the DMC close session, keep all columns(A/B/C/Total);

%let meddraver=18.0;
%let blindedad=N;
%let crosswk=16;

*When only generate blind output (&BLINDTYPE.=B), dataset and output name will be like 'B_T1.xx'.
 When only generate unblind output (&BLINDTYPE.=UNB), dataset and output name will be like 'UNB_T1.xx'.
 When generate both blind and unblind output (&BLINDTYPE.=BOTH), then both 'B_T1.xx' and 'UNB_T1.xx' will be created.
 ;
%let blindtype=BOTH;

*--- Added by Catlin Wei 2015-10-30; 
*--- Global variables for indent and hanging indent---*;

%global ind1st ind2nd ind3rd ind4th ind5th ind6th ri7 ri8 nodata space study;

/*Change to the protocol no of your project*/
%let study=CNTO148AKS3001;
/*end*/

%let ind1st=~R'\fi-86\li86 ';            /*1st indentation 0.125"   */
%let ind2nd=~R'\fi-86\li266 ';           /*2nd indentation 0.25"    */
%let ind3rd=~R'\fi-86\li446 ';           /*3rd indentation 0.375"   */
%let ind4th=~R'\fi-86\li626 ';           /*4th indentation 0.50"( etc.)*/
%let ind5th=~R'\fi-86\li806 ';           /*5th indentation */
%let ind6th=~R'\fi-86\li986 ';           /*6th indentation */

%let ri7=~R'\ri420 ';              /*Add 7 blanks in right side*/
%let ri8=~R'\ri1000 ';              /*Add 8 blanks in right side*/

%let nodata=No data to report.;   /*create no data output*/

/*Adding non-breaking space*/
%let space=~{unicode 00A0};