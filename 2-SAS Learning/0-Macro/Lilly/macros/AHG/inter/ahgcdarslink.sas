%macro AHGcdarslink(prot,Mac);
%global &mac;
    proc sql noprint;
        select value into :&mac
        from allstd.allstudies
        where upcase(studyid)=upcase("&prot");
        ;
    quit;
%mend;
