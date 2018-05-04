%macro AHGreadtot(totname,tempfile=&localtemp\&sysmacroname.temp.sas,clean=0);
  %global drvrname;
  %local thefile;
  %let thefile=tot23423;
  filename &thefile "&localtemp\&sysmacroname&prot..txt";
  data _null_;
    file &thefile;
    infile "&projectpath\tools\&totname" dlm='^' truncover;
    length letstring $400 mac $50 value $300;
    input mac value;
    format global $100.;
    global='%global '|| trim(mac)||';';
    put global;
    if upcase(mac) eq 'DRVRNAME' then call symput('drvrname',trim(value));
  run;
  %include &thefile;

  %AHGpm(drvrname);
  %if &clean=1 %then x del &localtemp\ENVARS.txt ; ;
  x "copy &projectpath\tools\&totname &localtemp\temp.txt";
/*
  data &tempdsn;
    set &tempdsn;
    call symput( mac,value );
  run;
*/

%mend;
