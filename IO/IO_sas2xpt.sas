
%macro IO_sas2xpt;

    %local l_dsetsnew l_dsetnew;
    %local memlabels memlabel_new;

    proc sql noprint;
        select lowcase(memname) into :l_dsetsnew separated by " "
        from sashelp.vtable
        where upcase(libname) eq "TRANSFER" and upcase(memtype) eq "DATA" and memname ^= " "
        order by memname
    ;
    quit;

    proc sql noprint;
        select memlabel into :memlabels separated by "."
        from sashelp.vtable
        where upcase(libname) eq "TRANSFER" and upcase(memtype) eq "DATA" and memname ^= " "
        order by memname
    ;
    quit;

    %put &l_dsetsnew;
    %put &memlabels;

    %let ii = 1;

    %do %while(%scan(&l_dsetsnew., &ii.) ne);
        %let l_dsetnew = %scan(&l_dsetsnew., &ii.);
        %let memlabel_new=%scan(&memlabels., &ii.,.);

        %put &l_dsetnew;
        LIBNAME temp xport "&_xpt/&l_dsetnew..xpt";

        data &l_dsetnew.(sortedby=_null_ label=&memlabel_new.);
            set transfer.&l_dsetnew.;
        run;

        PROC COPY IN=work OUT=temp MEMTYPE=data;
            select &l_dsetnew.;
        RUN;
        QUIT;

        LIBNAME temp CLEAR;
        %let ii = %eval(&ii. + 1);
    %end;

%mend IO_sas2xpt;

%xpt2loc(libref=work, 
           memlist=Thisisalongdatasetname, 
           filespec='c:\trans.v9xpt' )



%let _xpt = /lillyce/prd/ly2940680/i4j_mc_hhbh/csr1/data/analysis/shared/adam;
libname TRANSFER "/lillyce/prd/ly2940680/i4j_mc_hhbh/csr1/data/analysis/shared/adam";
%IO_sas2xpt;

libname TRANSFER "/home/c244032/test";
%let _xpt = /home/c244032/test;
0123456789012345678901234567890123456789


 %xpt2loc(libref=transfer, 
           memlist=a, 
           filespec='/home/c244032/test/a.v9xpt' )
       