%macro AHGrelib(studyid,createdsn=1);
    %local netall tempusers i;
    %local qcdir;
    %let qcdir=&preadandwrite\allstudies\&studyid;
    %AHGfindusers(&qcdir,outusers=tempusers);
    

    proc sql noprint;
        select  trim(path) into :netall
        from sashelp.vlibnam
        where libname=upcase("netall");
        ;
    quit;


    libname netall "&qcdir\all";
    %local user qcdocs;
    %do i=1 %to %AHGcount(&tempusers);
        %put @@@@@@@@@@@@@@set templib@@@@@@@@@@@@@@@@@@@@@@@@;
        %let user=%scan(&tempusers,&i);
        libname &user "&qcdir\&user";
        %if %sysfunc(exist(&user..qcdoc)) %then %let qcdocs=&qcdocs &user..qcdoc;
    %end;


    %if &createdsn=1 and &qcdocs ne %then 
        %do;

            data temp.qcdoc&studyid;
            ;
            set &qcdocs;
            run;

       %end;

    %do i=1 %to %AHGcount(&tempusers);
        %let user=%scan(&tempusers,&i);
        %if (%sysfunc(libname(&user))) %then  %put %sysfunc(sysmsg());
    %end;

    %do i=1 %to %AHGcount(&users);
        %let user=%scan(&users,&i);
        %put ############setlib back;
        libname &user "&netdir\&user"; ;
    %end;


   libname netall "%left(&netall)";
%mend;



