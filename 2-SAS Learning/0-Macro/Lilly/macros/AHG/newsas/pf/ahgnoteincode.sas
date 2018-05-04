%macro AHGnoteincode(dir=,OS=,);
%if %upcase(&OS)=UNIX %then
%do;
%syslput SASfileDir=&dir;
rsubmit;
%AHGallcodeblock(&sasfileDir);
endrsubmit;

%AHGrdown
            (
             filename=ALLCODEBLOCK.log,
             rpath=/home/liu04/temp/,
	         locpath=&localtemp ,open=1
); 
%end;
%else  
    %do;
    %AHGallcodeblock(&Dir);
    x "&localtemp\ALLCODEBLOCK.log";
    %end;
%MEND;
