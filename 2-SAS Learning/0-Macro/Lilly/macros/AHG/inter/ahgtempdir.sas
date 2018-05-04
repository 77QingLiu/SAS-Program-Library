%macro AHGtempdir;                         
%local theuser;
%let theuser= %sysfunc(getoption(sasuser));          
%scan( &theuser,1,\/)%AHGdelimit%scan( &theuser,2,\/)%AHGdelimit%scan( &theuser,3,\/)
%mend;

