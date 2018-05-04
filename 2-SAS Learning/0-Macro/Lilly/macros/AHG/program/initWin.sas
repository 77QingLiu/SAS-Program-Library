%macro setMeUp;
  %global localtemp;
  option noxwait xsync;
  %if &sysscp=WIN %then
    %do;
    dm "clear log";
    dm "clear lst";
    options sasautos=(sasautos "d:\newsas\core" "d:\newsas\inter"  "d:\newsas\adhoc" "d:\bums\");
    options nobyline mprint mrecall;
    %let localtemp=d:\temp;
   
    %AHGfontsize(15);
    %AHGdatadelete;
    %end;
  %else
    %do;
    %end;
%mend;

%setMeUp;

%let ls=256; /*line size*/
%let ps=47; /*page size*/
options ls=&ls ps=&ps;


%let allglobal=;
%let pathroot=f:\lillyce\qa\ly2940680\i4j_mc_hhbh\intrm1;
%let sdtm=f:\lillyce\qa\ly2940680\i4j_mc_hhbh\prelock\data\shared\sdtm;

/*d:\lillyce\qa\ly2940680\i4j_mc_hhbh\intrm1;*/
%let projectpath=&pathroot;
/*%let projectpath=%mysdd(&anypath);*/
/*%let projectpath=%sdddc(&anypath,pre=f:);*/
/*%let localdrive=%substr(&projectpath,1,%eadaml(%index(&projectpath,\lillyce)-1));*/
/*%let root=%substr(&projectpath,%index(&projectpath,\lillyce));*/
%let adam=&projectpath\data\shared\adam;
%let tfl_output=&projectpath\programs_stat\tfl_output ;

%AHGmkdir(&projectpath\replica_programs\validator_component_modules);
%AHGmkdir(&projectpath\replica_programs\replication_output\adam );

%let qcAdam=&projectpath\replica_programs\replication_output\adam;

%let replication_output=&projectpath\replica_programs\replication_output;
options sasautos=(sasautos "d:\newsas\core" "d:\newsas\inter" 
"d:\newsas\adhoc" "d:\bums\"
"%mysdd(&projectpath\replica_programs\validator_component_modules)"
"%mysdd(&projectpath\programs_stat\author_component_modules) ");

libname rsdtm "&sdtm";
libname radam "&adam" ;
libname rqcadam "&qcadam" ;
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








