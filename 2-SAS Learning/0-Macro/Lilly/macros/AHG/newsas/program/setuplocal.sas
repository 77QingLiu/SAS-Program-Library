%macro setMeUp;
  %global localtemp;
  option noxwait xsync mrecall;
    dm "clear log";
    dm "clear lst";
    options sasautos=(sasautos "d:\newsas\core" "d:\newsas\inter"  "d:\newsas\adhoc" "d:\bums\");
    options  noxwait nobyline mprint mrecall missing='' lrecl=max;
    %let localtemp=d:\temp;
    %let slash=\;
   
    %AHGfontsize(15);
    %AHGdatadelete;
    %AHGmkdir(%AHGtempdir);
%mend;

%setMeUp;

/*%AHGopenfile(d:\newsas\debug.sas,sas);*/
%AHGopenfile(h:\mango.txt,sas);
%AHGopenfile(h:\debug.sas,sas);

