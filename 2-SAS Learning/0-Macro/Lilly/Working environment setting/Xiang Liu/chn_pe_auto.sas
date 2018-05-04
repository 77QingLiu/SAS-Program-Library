/**soh******************************************************************************************************************
Eli Lilly and Company (required)- GSS
CODE NAME (required)              : home/lillyce/prd/project/protocol/studyphase/programtype/author_component_modules/chn_pe_auto.sas
PROJECT NAME (required)           : PROTOCOL | PROJECT
DESCRIPTION (required)            : Input process
SPECIFICATIONS(required)          : N/A
VALIDATION TYPE (required)        : Peer Review
INDEPENDENT REPLICATION (required): N/A
ORIGINAL CODE (required)          : This is the original code
COMPONENT CODE MODULES            : 
SOFTWARE/VERSION# (required)      : SAS/Version 9.2
INFRASTRUCTURE                    : 
DATA INPUT                        : 
OUTPUT                            : 
SPECIAL INSTRUCTIONS              : 
------------------------------------------------------------------------------------------------------------------------------- 
-------------------------------------------------------------------------------------------------------------------------------
DOCUMENTATION AND REVISION HISTORY SECTION (required):

     Author &
Ver# Validator        Code History Description
---- ---------------- -----------------------------------------------------------------------------------------------------
1.0   Xiang Liu       Original version of the code
      Xiaofeng Shi
**eoh*******************************************************************************************************************/

%macro chn_pe_auto;
  %***************************************************************************************;
  %*** Set up directory macro variables
  %***************************************************************************************;
  %global lillycearea lillyceareaflag project protocol protocolname studyphase programtype;
  %let lillycearea = qa;
  %let lillyceareaflag = qa;
  %let project = lyxxxxxx;
  %let protocol = xxx_xxx_xxxx;
  %let protocolname = %upcase(%sysfunc(tranwrd(&protocol, _, -)));
  %let studyphase = final;
  %let programtype = programs_stat;

  %global dir_root compound study analy_phase referenc;
  %let dir_root = lillyce;
  %let compound = &project;
  %let study = &protocol;
  %let analy_phase = &studyphase;
  %let referenc = TDTM;


  %***************************************************************************************;
  %*** For SDDDC-run setup
  %***************************************************************************************;
  %if %substr(&sysscp, 1, 3) eq WIN %then
    %do;
      %global lillycepath projectpath protocolpath studyphasepath 
        datapath statpath edspath pedspath adspath
        metaadspath metashlpath metatflpath
        logpath outputpath acmpath bumspath chn_pe_auto
      ;

      %let lillycepath = g:/lillyce;
      %let projectpath = &lillycepath/&lillycearea/&project;
      %let protocolpath = &projectpath/&protocol;
      %let studyphasepath = &protocolpath/&studyphase; * BASE_STUDYPHASE;

      %let datapath = &studyphasepath/data; 
      %let statpath = &studyphasepath/&programtype;

      %let edspath = &studyphasepath/data/shared/eds; * BASE_EDS;
      %let pedspath = &studyphasepath/data/shared/peds; * BASE_PEDS;
      %let adspath = &datapath/shared/ads; * BASE_ADS; 

      %let metaadspath = &datapath/shared/ads_requirements; * ./data/shared/ads_requirements (relative);
      %let metashlpath = &metaadspath/shells; * ./data/shared/ads_requirements/shells (relative);
      %let metatflpath = &datapath/shared/arc_reporting_metadata; * ./data/shared/arc_reporting_metadata (relative);

      %let logpath = &statpath/system_files;
      %let outputpath = &statpath/tfl_output; * ./programs_stat/tfl_output (relative); 

      %let acmpath = &statpath/author_component_modules; * ./programs_stat/author_component_modules (relative);
      %let bumspath = &lillycepath/prd/general/bums/macro_library; * /lillyce/prd/general/bums/macro_library (absolute);

      %let chn_pe_auto = "&acmpath/chn_pe_auto.sas";

      libname eds "&edspath" access = readonly;
      libname peds "&pedspath" access = readonly;
      libname ads "&adspath"; * access = readonly;
      libname metaads "&metaadspath"; * access = readonly;
      libname metashl "&metashlpath"; * access = readonly;
      libname metatfl "&metatflpath"; * access = readonly;
    %end;
  %else
    %do;
      %* For SDD-run setup;
      %global arcmeta rptlib rptlibv;
      libname arcmeta "&arcmeta"; /*location of arc tool metadata*/
      libname rptlib "&rptlib"; /*location of outputs*/
      libname rptlibv "&rptlibv"; /*location of independent programming outputs*/ 
    %end;

  %***************************************************************************************;
  %*** Setup study specific macro variables and SAS options
  %***************************************************************************************;
  %global linesize pagesize ls ps trt1 trt2 trt3; * customize these macro variables according to your study requirements;

  %let linesize = 133;
  %let pagesize = 47;

  %let ls = &linesize; /*line size*/
  %let ps = &pagesize; /*page size*/


  %let trt1 = xxx;
  %let trt2 = xxx;
  %let trt3 = Total;

  %global format_study;
  %include &format_study; %* This is an input file;

  options 
    mprint 
    mprintnest 
    nomlogic
    nomlogicnest
    nosymbolgen
    source2 
    nodate 
    nonumber 
    nofmterr
    nocenter
    nobyline
    nofullstimer 
    missing = ' ' 
    formchar = '|----|+|---+=|-/\<>*'
    papersize = letter
    orientation = landscape
    linesize = &linesize
    pagesize = &pagesize
    validvarname = upcase
    validfmtname = long
    mautosource 
    sasautos = ("&acmpath" "&bumspath" sasautos)
    fmtsearch = (work metaads)
  ;
%mend chn_pe_auto;

%chn_pe_auto;
