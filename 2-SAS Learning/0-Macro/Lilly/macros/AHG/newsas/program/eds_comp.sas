/**soh******************************************************************************************************************
Eli Lilly and Company (required)- GSS
CODE NAME (required)              : home/lillyce/qa/ly2189265/h9x_cr_gbdk/intrm1/programs_nonsdd/aweedscompare.sas
PROJECT NAME (required)           : H9X-CR-GBDK | LY2189265
DESCRIPTION (required)            : Compare EDS data on SDD and AWE
SPECIFICATIONS(required)          : N/A
VALIDATION TYPE (required)        : Peer Review
INDEPENDENT REPLICATION (required): N/A  
ORIGINAL CODE (required)          : This is the original code
COMPONENT CODE MODULES            : 
SOFTWARE/VERSION# (required)      : SAS/Version 9.2
INFRASTRUCTURE                    : 
DATA INPUT                        : 
OUTPUT                            : home/lillyce/qa/ly2189265/h9x_cr_gbdk/intrm1/programs_nonsdd/tfl_output/aweedscompare.rtf
SPECIAL INSTRUCTIONS              : 
------------------------------------------------------------------------------------------------------------------------------- 
-------------------------------------------------------------------------------------------------------------------------------
DOCUMENTATION AND REVISION HISTORY SECTION (required):

     Author &
Ver# Validator        Code History Description
---- ---------------- -----------------------------------------------------------------------------------------------------
1.0  Xiang Liu        Original version of the code
     Boyao Shan 
**eoh*******************************************************************************************************************/

/*
%let edsqapath = &studyphasepath/data/shared/eds; * ./data/shared/eds (relative);
%let edsprdpath = /lillyce/prd/ly2189265/h9x_cr_gbdk/final/data/shared/eds;
*/

%let linesize = 133;
%let pagesize = 47;

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
  sasautos = ("&bumspath" sasautos)
  fmtsearch = (work)
;

libname base "&edsqapath";
libname comp "&edsprdpath";

proc printto new file = "&outputpath/aweedscompare.rtf"; 
run;

%macro aweedscompare;
  proc sql noprint;
    create table md1 as
      select *
        from dictionary.tables
        where libname = 'BASE' and memtype = 'DATA'
    ;
  quit;
  data _null_;
    set md1;
    call symputx(compress("datasetname" || put(_n_, best12.)), compress(memname), 'l');
    call symputx("ndatasetname", compress(put(_n_, best12.)), 'l');
  run;
  %local i data;
  %do i = 1 %to &ndatasetname;
    %let data = &&datasetname&i;
    proc compare data = base.&data compare = comp.&data; 
    run;
  %end;
%mend aweedscompare;
%aweedscompare;

proc printto; 
run;

proc printto print = _ibxout_;
run;
%ut_saslogcheck;


