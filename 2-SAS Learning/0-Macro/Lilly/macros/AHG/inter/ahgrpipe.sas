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

%macro AHGrpipe(rcommand,lmacro,print=no,format=$32767.,dlm=%str( ));
%global rcrpipe;


%if &lmacro=q %then 
%do;
%AHGsubmitrcommand(cmd=&rcommand);
%goto exit;
%end;

%syslput rcommand=%bquote(&rcommand);
%syslput lmacro=&lmacro;
%syslput rmycmd=&rcommand;
%syslput rformat=%str(&format);
%syslput rdlm=%str(&dlm);
%syslput rpiperesult=;


rsubmit;

    data _null_;
    filename pip  pipe "ksh -c  %str(%')%bquote(. ~liu04/bin/myalias; PATH=/home/liu04/bin:/opt/sasprod:/usr/sbin:/etc:/usr/local/bin:/usr/bin:/bin:/usr/dt/bin:/usr/openwin/bin:/usr/ucb:.:/home/liu04/bin/perl;FPATH=/home/liu04/bin;)&rmycmd %str(%')  " ;
    infile pip truncover lrecl=32767;
    length file $32767;
    input file 1-32767;
    myfile=put(translate(file,"&rdlm",byte(12)),&rformat);
    call symput("rpiperesult",trim(compbl(myfile)));
    run;
    %put lmacro=&lmacro;
    %nrstr(%%)sysrput    &lmacro=%nrbquote(&rpiperesult);
endrsubmit;


%if %length(&&&lmacro) %then %let &lmacro=%sysfunc(translate(&&&lmacro,%str( ),%sysfunc(byte(12))));


%if %upcase(&print)=YES %then %put %nrbquote(&&&lmacro);

%exit:;

%mend;

