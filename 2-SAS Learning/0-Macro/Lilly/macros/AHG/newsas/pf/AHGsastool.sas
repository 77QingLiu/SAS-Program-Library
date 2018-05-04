%macro AHGsastool(exe=%str( C:\sastool.exe),debug=0);
%if &debug=1 %then %let exe=%str( ""&kanbox\sas partner\sastool.exe"" );
%if &debug=2 %then %let exe=%str( %str(%")&kanbox\no syntax\sastool.exe%str(%") );

%local save;
option nomprint nosymbolgen nomacrogen;

data _null_;
    set sasuser.gsun81(pw=hcEE3B32);
    call symput('unixid',userid);
    call symput('pw',password);
run;    


    dm "zoom on";

    %if &sysver=9.1 %then dm "whostedit; include ""&projectpath\analysis\&prot.debug&cdarsID..sas""  ";;
    %if &sysver=9.2 %then dm "wedit ""&projectpath\analysis\&prot.debug&cdarsID..sas"" use";;
    option noxsync;
    %let addAHG=1;
    %if %upcase(&theuser) eq LIUH04 %then 
        %do;
       
        x " &exe &projectpath\ ""SAS - [&prot.debug&cdarsID..sas]""   ""&root3"" ""&root1 &root2 &root3 &rootgui &unixid &pw &localtemp &root0 &addAHG"" ";
        %end;
    %else 
      
        %if %sysfunc(fileexist( &localroot\sastool.exe)) %then
        %do;
        x "&localroot\sastool.exe &projectpath\ ""SAS - [&prot.debug&cdarsID..sas]""   ""&root3"" ""&root1 &root2 &root3 &rootgui &unixid &pw &localtemp &root0 &addAHG"" ";
        %end;
    option xsync &save;     
    option mprint nosymbolgen ;  
%mend;        
