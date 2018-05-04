%macro AHGgetqcstatus(obj=);
    %local macroname;
    %let macroname=&sysmacroname;
    %AHGsavecommandline(&macroname);
    %syslput obj=&obj;
    rsubmit;
        %bquote(%)include '/home/liu04/getqcstatus.sasdrvr';
    endrsubmit;
    %AHGrdown(folder=analysis,filename=qcstatus.sas7bdat,save=0) ;
%mend;





