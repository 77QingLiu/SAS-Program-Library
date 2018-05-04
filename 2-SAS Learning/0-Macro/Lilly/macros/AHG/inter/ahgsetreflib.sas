%macro AHGsetreflib(refdir);
%let refproj=&refdir;
libname  refdata "&refdir\data" access=readonly; 
libname  refdatv "&refdir\data_vai" access=readonly;
libname  refdatr "&refdir\data_report" access=readonly;
libname  refraw "&refdir\view" access=readonly;
libname  refAnal "&refdir\analysis" access=readonly;


%mend;

