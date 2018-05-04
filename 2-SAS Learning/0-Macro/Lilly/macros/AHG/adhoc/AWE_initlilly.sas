%macro AWE_initlilly;
%global ls ps statdrive SAdrive  ;
%let statdrive=\\gh3nas01\gh3nas_sales.grp\LCDDMAC\STATS;
%let SAdrive=&statdrive\sa;
%let ls=256; /*line size*/
%let ps=47; /*page size*/
options ls=&ls ps=&ps;
option lrecl=max;

option formdlim='';
%if %upcase(&sysscp) = WIN %then 
%do;
%global projectpath ads eds non fld1st fld2nd adam tfl_output qcAdam replication_output authorMac validMac macro1st macro2nd out1st out2nd;
%if %AHGblank(&fld1st) %then %let fld1st=programs_nonsdd;
%if %AHGblank(&fld2nd) %then %let fld2nd=replica_programs_nonsdd;
%let projectpath=&pathroot;
%let adam=&projectpath\data\shared\adam;
%let tfl_output=&projectpath\&fld1st\tfl_output ;
%let qcAdam=&projectpath\&fld2nd\replication_output\adam;
%let replication_output=&projectpath\&fld2nd\replication_output;
%let authorMac=&projectpath\&fld1st\author_component_modules;
%let validMac=&projectpath\&fld2nd\validator_component_modules;
%let macro1st=&authorMac;
%let macro2nd=&validMac;
%let out1st=&tfl_output;
%let out2nd=&replication_output;
%AHGmkdir(%mysdd(&projectpath\&fld2nd\validator_component_modules));


options sasautos=(sasautos "d:\newsas\core" "d:\newsas\inter" 
"d:\newsas\adhoc" "d:\bums\"
"%mysdd(&projectpath\&fld2nd\validator_component_modules)"
"%mysdd(&projectpath\&fld1st\author_component_modules) ");

%if %sysfunc(fileexist(&sdtm)) %then libname rsdtm "&sdtm";;
%if %sysfunc(fileexist(&adam)) %then libname radam "&adam" ;;
%if %sysfunc(fileexist(&qcadam)) %then libname rqcadam "&qcadam" ;;

%AHGmkdir(%mysdd(&sdtm));
%AHGmkdir(%mysdd(&adam));
%AHGmkdir(%mysdd(&qcadam));
%AHGmkdir(%mysdd(&replication_output));
%AHGmkdir(%mysdd(&tfl_output));
libname lsdtm "%mysdd(&sdtm)"  ;
libname ladam "%mysdd(&adam)"  ;
libname lqcadam "%mysdd(&qcadam)" ;

libname sdtm (lsdtm rsdtm);
libname adam (ladam radam);
libname qcadam (lqcadam rqcadam);
%end;
%mend;
