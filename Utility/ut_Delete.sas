*--------------------------------------------------------------------------------------------------
Program Purpose:       The macro %ut_Delete delete specified dataset in specified library

                        The macro by default ABORTs if the dataset is not present. 

    Macro Parameters:

        Name:                lib
            Allowed Values:    Any valid libname
            Default Value:     WORK
            Description:       The name of library where dataset to be deleted.

        Name:                DelMem
            Allowed Values:    Any valid SAS items in SAS library
            Default Value:     ALL (seperated by space)
            Description:       The name of SAS items to be deleted

        Name:                KepMem
            Allowed Values:    Any valid SAS items in SAS library
            Default Value:     None (used when only DelMem=ALL, seperated by space)
            Description:       Keep specified member when deleting all library

        Name:                MemType
            Allowed Values:    ACCESS ALL CATALOG DATA FDB MDDB PROGRAM VIEW
            Default Value:     DATA
            Description:       The type of SAS items to be deleted

--------------------------------------------------------------------------------------------------*;

%MACRO ut_Delete( lib     = WORK
                 ,DelMem  = ALL
                 ,KepMem  = 
                 ,MemType = DATA);
    %pv_Start(ut_Delete)
    
    %* Parameter validation %*;
    %pv_Define( ut_Delete ,lib ,_pmRequired = 1 ,_pmAllowed = SASNAME);
    %pv_Define( ut_Delete ,DelMem ,_pmRequired = 1 ,_pmAllowed = SASNAME);
    %pv_Define( ut_Delete ,KepMem ,_pmRequired = 0 ,_pmAllowed = SASNAME);
    %pv_Define( ut_Delete ,MemType ,_pmRequired = 1 ,_pmAllowed = ACCESS ALL CATALOG DATA FDB MDDB PROGRAM VIEW);


    %local  ut_Delete_macroname 
            ut_Delete_member;
    %let    ut_Delete_macroname = &SYSMACRONAME;
    %let    ut_Delete_member = ut_Delete_member;

    %if &DelMem = ALL & %length(&KepMem) = 0 %then %do;
        proc datasets library=&lib memtype=&MemType nolist kill;
        quit;    
    %end;

    %else %if &DelMem = ALL %then %do;
        proc sql;
            select strip(memname) into :ut_Delete_member separated by ' '
            from dictionary.Tables
            where  upcase(libname)="&lib" 
                   and upcase(memtype) = "&MemType" 
                   and memname not in (%ut_QuoteLST(&KepMem));
        quit;
        proc datasets library=&lib memtype=&MemType nolist;
            delete &ut_Delete_member;
        quit;        
    %end;
    %else %do;
        proc datasets library=&lib memtype=&MemType nolist;
            delete &DelMem;
        quit;
    %end;

    %pv_End(ut_Delete)
%MEND;