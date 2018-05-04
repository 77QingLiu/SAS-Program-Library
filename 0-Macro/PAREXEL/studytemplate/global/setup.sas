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

  Program Purpose:       Define global setup and options to be used by study
                         programs

  Macro Parameters       NA

-------------------------------------------------------------------------------
  MODIFICATION HISTORY:  see Subversion $Rev: $
-----------------------------------------------------------------------------*/
%*----------------------------------------------------------------------------*;
%*---  Ensure the project SAS version is SAS 9.3                           ---*;
%*----------------------------------------------------------------------------*;
%gmCheckSasVersion(checksasversion=9.3)

%*----------------------------------------------------------------------------*;
%*---  Check SVN status of programs run in batch mode                      ---*;
%*----------------------------------------------------------------------------*;
%gmSvnStatus()

%*----------------------------------------------------------------------------*;
%*---  DEF_OS.  project - Project/study name. client  - Client name        ---*;
%*---  tims    - Tims code.  For unblinded studies the %def_os code needs  ---*;
%*---  to be copied (from /opt/pxlcommon/stats/macros/macro_library) here  ---*;
%*---  AND updated TO reference the unblinded area                         ---*;
%*----------------------------------------------------------------------------*;
%def_os (project=<area>, client=<clientshort>, tims=<TIME code>);


%*----------------------------------------------------------------------------*;
%*--- Setup global variables                                               ---*;
%*----------------------------------------------------------------------------*;
%os_fvars(mvar=_global,  projpath=global);
%os_fvars(mvar=_formats, projpath=formats);
%os_fvars(mvar=_macros,  projpath=macros);

%*----------------------------------------------------------------------------*;
%*--- Setup global variables and libraries for transfer                    ---*;
%*----------------------------------------------------------------------------*;
%MACRO tabulate();
  %IF &_type. ~= tabulate %THEN %RETURN;

  %os_fvars(mvar=_metadata,  projpath=&_type.:data:metadata)

  %os_fvars(mvar=_raw,       projpath=&_type.:data:raw)
  %os_fvars(mvar=_rawrand,   projpath=&_type.:data:rawrand)

  %*--- Create on folder per TPV/source ---*;
  %*os_fvars(mvar=_rawecg,   projpath=&_type.:data:rawecg);
  %*os_fvars(mvar=_rawlb,    projpath=&_type.:data:rawlb);

  %os_fvars(mvar=_transfer,  projpath=&_type.:data:transfer)
  %os_fvars(mvar=_ptransfer, projpath=&_type.:prog:transfer)
  %os_fvars(mvar=_qtransfer, projpath=&_type.:qcprog:transfer)

  %os_fvars(mvar=_scratch,   projpath=&_type.:data:scratch)
  %os_fvars(mvar=_qscratch,  projpath=&_type.:data:qscratch)

  %os_fvars(mvar=_pdefine,   projpath=&_type.:prog:define)
  %os_fvars(mvar=_odefine,   projpath=&_type.:outputs:define)

  %*--- For data folders created above ---*;

  LIBNAME metadata "&_metadata" COMPRESS=yes;
  LIBNAME raw      "&_raw"      COMPRESS=yes ACCESS=READONLY;
  LIBNAME rawrand  "&_rawrand"  COMPRESS=yes ACCESS=READONLY;
  %*--- For data folders created above ---*;
  %* LIBNAME rawecg  "&_rawecg"  COMPRESS=yes ACCESS=READONLY;
  %* LIBNAME rawlb  "&_rawlb"   COMPRESS=yes ACCESS=READONLY;
  LIBNAME transfer "&_transfer" COMPRESS=yes;
  LIBNAME scratch  "&_scratch"  COMPRESS=yes;
  LIBNAME qscratch "&_qscratch" COMPRESS=yes;

%MEND tabulate;

%*----------------------------------------------------------------------------*;
%*--- Setup global variables and libraries for dmc/interim/primary         ---*;
%*----------------------------------------------------------------------------*;
%MACRO tlfs();
  %IF &_type. ~= dmc     AND
      &_type. ~= interim AND
      &_type. ~= primary %THEN %RETURN;

  %os_fvars(mvar=_metadata,  projpath=&_type.:data:metadata)

  %os_fvars(mvar=_raw,       projpath=&_type.:data:raw)

  %os_fvars(mvar=_pdefine,   projpath=&_type.:prog:define)
  %os_fvars(mvar=_odefine,   projpath=&_type.:outputs:define)

  %os_fvars(mvar=_panalysis, projpath=&_type.:prog:analysis)
  %os_fvars(mvar=_qanalysis, projpath=&_type.:qcprog:analysis)
  %os_fvars(mvar=_analysis,  projpath=&_type.:data:analysis)
  %os_fvars(mvar=_qanal,     projpath=&_type.:data:qanal)

  %os_fvars(mvar=_ptables,   projpath=&_type.:prog:tables)
  %os_fvars(mvar=_qtables,   projpath=&_type.:qcprog:tables)
  %os_fvars(mvar=_tables,    projpath=&_type.:data:tables)
  %os_fvars(mvar=_otables,   projpath=&_type.:outputs:tables)

  %os_fvars(mvar=_plistings, projpath=&_type.:prog:listings)
  %os_fvars(mvar=_qlistings, projpath=&_type.:qcprog:listings)
  %os_fvars(mvar=_listings,  projpath=&_type.:data:listings)
  %os_fvars(mvar=_olistings, projpath=&_type.:outputs:listings)

  %os_fvars(mvar=_pfigures,  projpath=&_type.:prog:figures)
  %os_fvars(mvar=_qfigures,  projpath=&_type.:qcprog:figures)
  %os_fvars(mvar=_figures,   projpath=&_type.:data:figures)
  %os_fvars(mvar=_ofigures,  projpath=&_type.:outputs:figures)

  %os_fvars(mvar=_pappendix, projpath=&_type.:prog:appendix)
  %os_fvars(mvar=_qappendix, projpath=&_type.:qcprog:appendix)
  %os_fvars(mvar=_appendix,  projpath=&_type.:data:appendix)
  %os_fvars(mvar=_oappendix, projpath=&_type.:outputs:appendix)

  %os_fvars(mvar=_pprofiles, projpath=&_type.:prog:profiles)
  %os_fvars(mvar=_qprofiles, projpath=&_type.:qcprog:profiles)
  %os_fvars(mvar=_profiles,  projpath=&_type.:data:profiles)
  %os_fvars(mvar=_oprofiles, projpath=&_type.:outputs:profiles)

  %os_fvars(mvar=_qbiostats, projpath=&_type.:qcprog:biostats)

  LIBNAME metadata    "&_metadata" COMPRESS=yes;
  LIBNAME raw         "&_raw"      COMPRESS=yes ACCESS=READONLY;
  LIBNAME analysis    "&_analysis" COMPRESS=yes;
  LIBNAME qanal       "&_qanal"    COMPRESS=yes;
  LIBNAME tables      "&_tables"   COMPRESS=yes;
  LIBNAME listings    "&_listings" COMPRESS=yes;
  LIBNAME figures     "&_figures"  COMPRESS=yes;
  LIBNAME appendix    "&_appendix" COMPRESS=yes;
  LIBNAME profiles    "&_profiles" COMPRESS=yes;

%MEND tlfs;


%*----------------------------------------------------------------------------*;
%*--- Setup global variables and libraries for listings                    ---*;
%*----------------------------------------------------------------------------*;
%MACRO listings();
  %IF &_type. ~= listing %THEN %RETURN;

  %os_fvars(mvar=_metadata,  projpath=&_type.:data:metadata)

  %os_fvars(mvar=_raw,      projpath=projpath=&_type.:data:raw)

  %os_fvars(mvar=_poffline, projpath=&_type.:prog:offline)
  %os_fvars(mvar=_qoffline, projpath=&_type.:qcprog:offline)
  %os_fvars(mvar=_offline , projpath=&_type.:data:offline)
  %os_fvars(mvar=_ooffline, projpath=&_type.:outputs:offline)

  %os_fvars(mvar=_ppd,      projpath=&_type.:prog:pd)
  %os_fvars(mvar=_qpd,      projpath=&_type.:qcprog:pd)
  %os_fvars(mvar=_pd ,      projpath=&_type.:data:pd)
  %os_fvars(mvar=_opd,      projpath=&_type.:outputs:pd)

  %os_fvars(mvar=_pmedical, projpath=&_type.:prog:medical)
  %os_fvars(mvar=_qmedical, projpath=&_type.:qcprog:medical)
  %os_fvars(mvar=_medical , projpath=&_type.:data:medical)
  %os_fvars(mvar=_omedical, projpath=&_type.:outputs:medical)

  LIBNAME metadata    "&_metadata" COMPRESS=yes;
  LIBNAME raw         "&_raw"      COMPRESS=yes ACCESS=READONLY;
  LIBNAME offline     "&_offline"  COMPRESS=yes;
  LIBNAME pd          "&_pd"       COMPRESS=yes;
  LIBNAME medical     "&_medical"  COMPRESS=yes;

%MEND listings;
%tabulate()
%tlfs()
%listings()

%INCLUDE "&_global./mdglobal.sas";

%*----------------------------------------------------------------------------*;
%*--- Set SAS options                    ---*;
%*----------------------------------------------------------------------------*;
%GLOBAL _ps _ls;
%LET _ps=47;
%LET _ls=133;
OPTIONS ORIENTATION=LANDSCAPE PAPERSIZE=LETTER LS=&_ls. ps=&_ps.                      /* Pagesize                */
        NODATE NONUMBER NOBYLINE LABEL                                                /* Titles                  */
        CENTER FORMCHAR='*_---*+*---+=*-/\<>*' MISSING=""                             /* Layout                  */
        FMTSEARCH=(work analysis) MRECALL MAUTOSOURCE                                 /* Environmental settings  */
        SASAUTOS=("&_macros." %SYSFUNC(COMPRESS(%SYSFUNC(GETOPTION(sasautos)),() )))  /* Environmental settings  */
        MERGENOBY=ERROR YEARCUTOFF=1920 MSGLEVEL=I                                    /* Error Handling          */
        NOMPRINT NOSYMBOLGEN NOMLOGIC SOURCE2                                         /* Debug Information       */
        /* Suggested options which should be manually enabled by the primary if needed */
        /* NOQUOTELENMAX */ /* Disables WARNING if text in quotes is more than 262 characters long. Enable this option when using gmIntext macros */
        ;
%*----------------------------------------------------------------------------*;
%*--- Set ODS options                                                      ---*;
%*----------------------------------------------------------------------------*;
ODS PATH global.odscat (UPDATE) sasuser.templat(READ) sashelp.tmplmst(READ);
ODS ESCAPECHAR="~";


%*----------------------------------------------------------------------------*;
%*--- Lines for Layout                                                     ---*;
%*----------------------------------------------------------------------------*;
%GLOBAL _blank _line;
DATA _NULL_;
  CALL SYMPUT("_blank", REPEAT(" ", %EVAL(&_ls.-1)));
  CALL SYMPUT("_line",  REPEAT("_", %EVAL(&_ls.-1)));
RUN;


%*----------------------------------------------------------------------------*;
%*--- Place any other project-specific instructions here                   ---*;
%*----------------------------------------------------------------------------*;
%*INCLUDE "&_global./&_type./formats.sas";
%*INCLUDE "&_global./rtf.sas";
%*INCLUDE "&_global./pdf.sas";
%*OPTIONS SASAUTOS=("<path to partnershipmacros>" %SYSFUNC(COMPRESS(%SYSFUNC(GETOPTION(sasautos)),() )));
