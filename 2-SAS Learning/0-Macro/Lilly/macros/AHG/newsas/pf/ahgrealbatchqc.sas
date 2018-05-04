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
   Revision 1.2  2009/05/20 09:05:09  liu04
   add auto version option





**********************************/
%macro AHGRealbatchQC(tables,execute=1,second=5,downall=1,tailor=1,sasver=8);
    %local macroname;
    %let macroname=&sysmacroname;
    %AHGsavecommandline(&macroname); 

    %local rpt lst log table maintailor;
    %let maintailor=&tailor;
    %do i=1 %to %AHGcount(&tables);
        %let  table=%scan(&tables,&i,%str( ));
        %if &execute=1 %then %AHGbatchqc(obj=&table,refresh=0,wait=&second,downqcdoc=0,downrpt=0,version=,tailor=&maintailor,sasver=&sasver);
        %else %put batchqc(obj=&table,refresh=0,wait=&second,downqcdoc=0,downrpt=0,version=,tailor=&maintailor,sasver=&sasver);
        
        %let rpt=&rpt &table..rpt;
        %let log=&log qc&table..log;
        %let lst=&lst qc&table..lst;
        %AHGpm(rpt log lst);
    %end;
/*
    %let rcommand=%str(
    x "cd &root3/analysis; cat &rpt >&root3/analysis/batchqc.rpt" ;
    x "cd &root3/analysis; cat &lst >&root3/analysis/batchqc.lst" ;
    x "cd &root3/analysis; cat &log >&root3/analysis/batchqc.log" ;
    );
*/    


    %let rcommand=%str(
     cd &root3/analysis; cat &rpt >&root3/analysis/batchqc.rpt;
     cd &root3/analysis; cat &lst >&root3/analysis/batchqc.lst;
     cd &root3/analysis; cat &log >&root3/analysis/batchqc.log;
    );

    %if &execute=1 %then %AHGsubmitrcommand(cmd=&rcommand);
    %else %AHGpm(rcommand);;
        
    

    %if &downall=1 %then
        %do;
        %AHGrdown(folder=analysis,filename=batchqc*,save=0) ;
        x "%bquote(&projectpath)\analysis\batchqc.rpt";
        x "%bquote(&projectpath)\analysis\batchqc.lst";
        x "%bquote(&projectpath)\analysis\batchqc.log";
        %end;

%mend;
