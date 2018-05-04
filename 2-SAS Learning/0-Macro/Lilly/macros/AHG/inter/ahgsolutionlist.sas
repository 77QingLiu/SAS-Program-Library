%macro AHGsolutionlist(by=,object=);
    %local i  objWhere wherestr macroname Nobs;
    %let macroname=&sysmacroname;
    %do i= 1 %to %AHGcount(&object);
    %let wherestr="%scan(&object,&i,%str( ))"  ;
    %let objwhere=&objwhere %str( or upcase(object)=upcase( &wherestr) );
    %end;
    
    %let objwhere=0 &objwhere;
    %AHGpm(objwhere);
    %*savecommandline(&macroname); 
    data SOLUTIONS;
        set netall.SOLUTIONS(rename=(_TEMV001=object));
        %if %length(&object) %then where &objwhere;;
    run;
    proc sql noprint;
        select count(*) into :Nobs
        from solutions
        ;quit;
 %if &nobs >0 %then DM "VT SOLUTIONS" VIEWTABLE:SOLUTIONS;
%mend;

