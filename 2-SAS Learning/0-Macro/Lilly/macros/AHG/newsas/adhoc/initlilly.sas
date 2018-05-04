%macro initlilly;
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
%global out2 tfl PGM2
projectpath ads adam tfl_output qcAdam replication_output authorMac validMac macro1st macro2nd out1st out2nd;
%let projectpath=&pathroot;
%let adam=&projectpath\data\shared\adam;
%let ads=&projectpath\data\shared\ads;
%let tfl_output=&projectpath\programs_stat\tfl_output ;
%let qcAdam=&projectpath\replica_programs\replication_output\adam;
%let replication_output=&projectpath\replica_programs\replication_output;
%let authorMac=&projectpath\replica_programs\validator_component_modules;
%let validMac=&projectpath\replica_programs\validator_component_modules;
%let macro1st=&authorMac;
%let macro2nd=&validMac;
%let out1st=&tfl_output;
%let out2nd=&replication_output;
%let tfl=&projectpath\programs_stat\system_files;
%let out2=&replication_output;
%Let pgm2=&projectpath\replica_programs;
%AHGmkdir(%mysdd(&projectpath\replica_programs\validator_component_modules));


options sasautos=(sasautos "d:\newsas\core" "d:\newsas\inter" 
"d:\newsas\adhoc" "d:\bums\"
"%mysdd(&projectpath\replica_programs\validator_component_modules)"
"%mysdd(&projectpath\replica_programs\validator_component_modules\ahg)"
"%mysdd(&projectpath\programs_stat\author_component_modules) ");

libname rsdtm "&sdtm";
libname radam "&adam" ;
libname rqcadam "&qcadam" ;
libname rads "&ads";
libname rtfl  "&projectpath\programs_stat\system_files";


%AHGmkdir(%mysdd(&sdtm));
%AHGmkdir(%mysdd(&adam));
%AHGmkdir(%mysdd(&qcadam));
%AHGmkdir(%mysdd(&ads));
%AHGmkdir(%mysdd(&replication_output));
%AHGmkdir(%mysdd(&tfl_output));
%AHGmkdir(%mysdd(&projectpath\programs_stat\system_files));
libname lsdtm "%mysdd(&sdtm)"  ;
libname ladam "%mysdd(&adam)"  ;
libname lqcadam "%mysdd(&qcadam)" ;
libname lads "%mysdd(&ads)" ;
libname ltfl  "%mysdd(&projectpath\programs_stat\system_files)";


libname sdtm (lsdtm rsdtm);
libname adam (ladam radam);
libname qcadam (lqcadam rqcadam);
libname tfl (ltfl rtfl);
libname out2 "&out2";

  data sasuser.beforeruntot;
    set sashelp.vmacro(keep=name scope);
    where scope='GLOBAL';
  run;
%end;
%mend;
