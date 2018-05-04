/* -------------------------------------------------------------------
                          CDARS System Module
   -------------------------------------------------------------------
   $Source: /home/liu04/bin/macros/batchQC.sas,v $
   $Revision: 1.2 $
   $Author: liu04 $
   $Locker:  $
   $State: Exp $

   $Purpose:

   $Assumptions:

   $Inputs:
   $Outputs:

   $Called by:
   $Calls to:

   $Usage notes: Comment header items that end with a trailing '$'
                 are automatically populated by RCS.  The remaining


   $System archet: UNIX

   -------------------------------------------------------------------
                          Modification History
   -------------------------------------------------------------------
   $Log: batchQC.sas,v $

**********************************/
%macro AHGbatchqcPDS(obj,sasext=sas7bdat,refresh=0,wait=5,version=,prg=qc_pds_&obj..sas,sasver=9);
    %local macroname;
    %let macroname=&sysmacroname;
    %AHGsavecommandline(&macroname);   
    %if &version eq  %then
        %do;

        %AHGrpipe(rcsnum -d &root3/data -f &obj..&sasext|sed "s/.*\///"  ,rptversion)  ;
        %let version=%trim(&rptversion);
        %AHGpm(version);
        %end;

    data singleQCprg;
      length obj prg lst log $50;
      obj="&obj";
      prg="&prg";
      lst=tranwrd("&prg",'.sas','.lst');
      log=tranwrd("&prg",'.sas','.log');
    run;

  %local prg lst log;
  data _null_;
    set singleQCprg;
    call symput('prg',trim(prg));
    call symput('lst',trim(lst));
    call symput('log',trim(log));
  run;

  
  data _null_;
    %local tempfile;
    %let tempfile=&localtemp\tmp%substr(%sysfunc(normal(0)).tmp,4);
    file "&tempfile";


    %if &refresh=1 %then put " %nrstr(%AHGuptogbackToL(folder=analysis,filename=&prg,cmt=&comment);) ";;

    put "rsubmit;";

    put "x ""cd &root3/analysis"";";

    put  'x ksh -c " '  " test -e &root3/analysis/&lst"  ' && '   " rm -f &root3/analysis/&lst "   ' "; ' ;

    put  'x ksh -c " '  " test -e &root3/analysis/&log"  ' && '   " rm -f &root3/analysis/&log "  ' "; ' ;
    %if &sasver ne 9 %then
        %do;
        put "x ""/Volumes/app/sas/sas8/sas &prg -noterminal  -autoexec autoexec.sas -engine V8 -log &log " ;
        put " -print &lst -config /Volumes/app/sas/sas8/sasv8.cfg "";" ;
        %end;
    %else
        %do;
        put "x ""/usr/local/bin/sas92 &prg -noterminal  -autoexec autoexec.sas -engine V9 -log &log " ;
        put " -print &lst -config /Volumes/app/sas/sas9.2/SASFoundation/9.2/sasv9.cfg "";" ;
        %end;

    /*save a version copy*/
    %if &version ne %then
      %do;
      put "x ""cp &log &log._v&version..log"";";
      put "x ""cp &lst &lst._v.&version..lst"";";
      %end;

    put "endrsubmit;";
  run;

  


  %include "&tempfile";

  data _null_;
    x=sleep(&wait);
  run;

/*    %if &downqcdoc=1 %then*/
      %do;
      x "IF EXIST %bquote(&projectpath)\analysis\&log del %bquote(&projectpath)\analysis\&log";
      %AHGrdown(folder=analysis,filename=&log,save=0,open=1) ;
      x "IF EXIST %bquote(&projectpath)\analysis\&lst del %bquote(&projectpath)\analysis\&lst";    
      %AHGrdown(folder=analysis,filename=&lst,save=0,open=1) ;

      %end;



%mend;


