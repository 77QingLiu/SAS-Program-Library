/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 61610588LUC1001
  PXL Study Code:        227857

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Chase Liu $LastChangedBy: liur2 $
  Creation Date:         18Aug2016 / $LastChangedDate: 2016-05-10 05:09:34 -0400 (Tue, 10 May 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS228775_STATS/transfer/qcprog/macros/jjqcblfl.sas $

  Files Created:         jjqcblfl.log

  Program Purpose:       To derive base flag

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 31 $
-----------------------------------------------------------------------------*/

%macro jjqcblfl(in_data  =&domain.,
                out_data =&domain.,
                DTC      =,
                ExtraVar =,
                keepVar  =)/minoperator;
    /* Add BLFL Flag per group variable */
          %if &domain  ^=LB and &domain^=TR and &domain ^=TU and &domain^=FA and &domain^=XC %then %let GroupVar= STUDYID, USUBJID, &domain.TESTCD; 
    %else %if &domain   =TR %then %let GroupVar=STUDYID, USUBJID, &domain.CAT, &domain.SCAT, &domain.TESTCD;
    %else %if &domain   =LB %then %let GroupVar=STUDYID, USUBJID, LBCAT, LBSPEC, LBMETHOD, &domain.TESTCD;
    %else %if &domain   =XC %then %let GroupVar=STUDYID, USUBJID, XCMETHOD, &domain.TESTCD, XCORRES;   
    %else %if &domain   =TU %then %let GroupVar=STUDYID, USUBJID, TUCAT, TUMETHOD, TUTESTCD;              
    %else %let GroupVar =STUDYID, USUBJID, FAOBJ, FATESTCD;

    %if %length(&keepVar) = 0 %then %let keepVar = &GroupVar;
    %else %let keepVar = &GroupVar ,&keepVar ;

    /*Check domain have variable --TPT*/
    %global result;
    %let dsid=%sysfunc(open(&in_data));
    %if %sysfunc(varnum(&dsid,&in_data.TPTNUM)) > 0 %then %let result=1;
    %else %let result=0;;
    %let rc=%sysfunc(close(&dsid));


    /* Derive baseline flag based on original key*/
    proc sql;
        create table &in_data._BLFL as 
            select a.*, b.RFSTDTC,
               case when index(&domain.DTC,"T") and  index(b.RFSTDTC,"T") then &domain.DTC 
                        else scan(&domain.DTC,1,"T") end as &domain.DTC_1, 
                   case when index(&domain.DTC,"T") and  index(b.RFSTDTC,"T") then b.RFSTDTC 
                        else scan(b.RFSTDTC,1,"T") end as RFSTDTC_1 
            from &in_data as a left join qtrans.dm as b 
            on a.USUBJID=b.USUBJID;

        create table base as
            select *, 'Y' as &domain.BLFL 'Baseline Flag' length=1
            from &in_data._BLFL(where=(not missing(&domain.ORRES) and (
                           %if &result=1 %then ('' < &domain.DTC_1 < RFSTDTC_1) or ('' < &domain.DTC_1 = RFSTDTC_1 and &domain.TPTNUM<0 );
                           %else '' < &domain.DTC_1 <= RFSTDTC_1;)))
            group by &GroupVar
            having &DTC=max(&DTC)
            order by &GroupVar;
    quit;

    /* Derive baseline flag based on extral key*/
    %let GroupVar_ = %sysfunc(prxchange(%bquote(s/,/ /),-1,%bquote(&GroupVar)));
    %if &ExtraVar ne %then %do;
    %let last      = %scan(%bquote(&GroupVar),-1,str(,));
    proc sort data=base;by &GroupVar_ &ExtraVar;run;
    data base_extra;
        set base;
        by &GroupVar_ &ExtraVar;
        if last.&last. then output;
    run;
    %end;

    /* Check if exists duplicate baseline flag */
    proc sql;
        create table check as 
            select &keepVar from (select *, count(*) as count from base group by &GroupVar %if &ExtraVar ne %then ,&ExtraVar;)
            where count>1
            order by &GroupVar;
    quit;
    data _null_;
        set check;
        put "WARNING: Duplicate baseline flag, Please add extral variable";
    run;

    /* Update baseline flag */
    proc contents data=&in_data out=var_names;run;
    proc sql noprint;
        select cats('a.',name,'=','b.',name) into: var_names separated by ' and '
        from var_names;

        create table &out_data as 
        select a.*, b.&domain.BLFL
        from &in_data as a left join %if &ExtraVar ne %then base_extra;%else base; as b
        on &var_names;
    quit;

%mend jjqcblfl;


