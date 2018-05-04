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
%macro AHGtotnumMeta(cutoff=,offset=);
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
%AHGrpipe( %str(getdateoffset.pl --offset &offset),mycutoff,print=no);
%let cutoff=&mycutoff;
%end;
%local mystring;
%AHGrpipe( %str(echo $(totandnum &root3 &cutOff)),rcrpipe,print=no);
%let mystring=&rcrpipe;
%AHGrpipe( %str(echo $(dsnlist &root3 &cutOff)),rcrpipe,print=no);
%let mystring=&mystring &rcrpipe;

%AHGrpipe( %str(totanddesc &root3 > ~/temp/desc.txt),q,print=no);
%AHGrdown
            (
             filename=desc.txt,
             rpath=&userhome/temp,
	         locpath=&projectpath\analysis
); 
option xsync ;


data totnum;
    format totnum $200. ordstr $50. star $4. desc $200.;
    do i=1 to %AHGcount(&mystring,dlm=@);
    totnum=scan("&mystring",i,'@');
    tot=scan(totnum,1,' '); 
    star=scan(totnum,3,' '); 
    tabnum=upcase(left(scan(totnum,2,' ')));
    desc=left(scan(totnum,2,'#'));
    tabnum=substr(tabnum,1,1)||'.'||substr(tabnum,2) ;
    ordstr='';
    do j=1 to 10;
        item=scan(tabnum,j,'.');
        /*put tabnum= j= item=;*/
        if '0'<scan(tabnum,j,'.') <'99' then item=put(input(scan(tabnum,j,'.'),best.),z2.) ;
        else  item=scan(tabnum,j,'.');
        ordstr=trim(ordstr)||'.'||item;
    end;
    substr(tabnum,2,1)='';
    tabnum=compress(tabnum);
    output  ;
    end;
run;    
proc sort;
    by ordstr;
run;

data _null_;
    set totnum;
    file "&projectpath\analysis\totnum.txt";
    by ordstr;
    put tabnum $30.  tot $50. star $4.;
run;


%mend;
