%macro AHGReQCpassed(bugids,version=,comment=,folder=);
    %local macroname;
    %let macroname=&sysmacroname;
    %AHGsavecommandline(&macroname);   

    %local bugid object i;

    %do i= 1 %to  %AHGcount(&bugids);
        %let bugid=%scan(&bugids,&i,%str( ));
        proc sql noprint;
            select filename into :object
            from netall.allqcdoc
            where upcase(bugid)=upcase("&bugid")
            ;
        quit;
        %if &object ne %then
            %AHGqcdocen(
            &object
            ,folder=&folder
            ,user=&user,users=&users,studyname=&prot,version=&version, 
            status=1,reason=&comment,bugids=&bugid);
        %else %do; option xwait; x "echo &bugid is not in the library";%end;
        option noxwait;
        %let bugid=;
        %let object=;
    %end;


%mend;
