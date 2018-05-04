%macro AHGissuelist(by=,object=);
    %local i  objWhere wherestr macroname Nobs;
    %let macroname=&sysmacroname;
    %do i= 1 %to %AHGcount(&object);
    %let wherestr="%scan(&object,&i,%str( ))"  ;
    %let objwhere=&objwhere %str( or upcase(object)=upcase( &wherestr) );
    %end;
    
    %let objwhere=0 &objwhere;

    %*savecommandline(&macroname); 
    data qclib.Issues;
        set netall._01critical_issue netall._02non_critical_issue;
        keep bugid object issue version comment datetime;
        format comment $500.;
        %if %length(&object) %then where &objwhere;;
    run;
    %AHGdatasort(data=qclib.Issues, by=&by object version datetime);
    proc sql noprint;
        select count(*) into :Nobs
        from qclib.Issues
        ;quit;
 %if &nobs >0 %then    
dm  "vt qclib.Issues openmode=edit" viewtable:qclib.Issues ;
%mend;
