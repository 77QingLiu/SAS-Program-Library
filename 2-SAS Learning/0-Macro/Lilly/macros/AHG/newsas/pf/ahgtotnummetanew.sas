/* -------------------------------------------------------------------
                          PDS System Module
   -------------------------------------------------------------------
   $Source: /Volumes/app/cdars/prod/prjB012/csr_pds1/B0121004/saseng/pds1_0/macros/RCS/eff_sod.sas,v $
   $Revision: 1.2 $
   $Name:  $
   $Author: yuz02 $
   $Locker:  $
   $State: Exp $
   $Purpose    : 

   $Assumptions:

   $Inputs     :

   $Outputs    :

   $Called by  :
   $Calls to   :

   $Usage notes:

   $System archet: UNIX

   -------------------------------------------------------------------
                          Modification History
   -------------------------------------------------------------------
   $Log: eff_sod.sas,v $



 -------------------------------------------------------------------
*/
%macro AHGtotnumMetaNew(cutoff=,offset=);
%if &offset eq %then 
    %do;
    data _null_;
        date=date();
        if mod((date-18490),7)=0 then call symput('offset',-3);
        else  call symput('offset',-1);
    run;
    %end;

%if &cutoff eq %then 
%do;
%AHGrpipe( %str(getdateoffset.pl --offset &offset),mycutoff);
%let cutoff=&mycutoff;
%end;
%AHGsubmitRcommand(cmd=option noxwait noxsync);
%AHGrpipe( %str(totandnum &root3 &cutOff>&userhome/temp/&prot.totandnum.rpt %nrstr(&)),q);

%AHGrpipe( %str(dsnlist &root3 &cutOff>&userhome/temp/&prot.dsnlist.rpt %nrstr(&)),q);
%AHGrpipe( %str(totanddesc &root3 > ~/temp/&prot.desc.txt %nrstr(&)),q );
%mend;
