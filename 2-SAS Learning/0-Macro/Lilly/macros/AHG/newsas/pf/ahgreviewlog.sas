%macro AHGreviewlog(tabno,tailor=0,ext=log);

    %AHGrpipe(basename $(tabnum2tot &tabno &root3),tablog)  ;

    %let tablog=%sysfunc(tranwrd(&tablog,.tot,_rpt.&ext ) );
    %AHGrdown(rlevel=3,folder=logs,filename=&tablog,open=1);

%mend;
