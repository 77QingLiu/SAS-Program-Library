/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / MMY1006
  PXL Study Code:        228657

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Qingjie Zeng $LastChangedBy: xiaz $
  Creation Date:         10Aug2016 / $LastChangedDate: 2017-07-26 03:18:49 -0400 (Wed, 26 Jul 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/macros/jjqcblfl.sas $

  Files Created:         jjqcblfl.log

  Program Purpose:       To derive base flag

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 2 $
-----------------------------------------------------------------------------*/

%macro jjqcblfl(sortvar=);
proc sort data=&domain;by usubjid;run;
proc sort data=qtrans.dm out=dm(keep=usubjid rfstdtc);by usubjid;run;

data &domain;
	merge &domain(in=a) dm;
	by usubjid;
	if a;
run;

data _null;
    length str_new $200.;
    str="&sortvar";
    i=1;
    do until(scan(str,i,', ')='');
        str_new=scan(str,i,', ');
        output;
        i+1;
    end;
run;

/*Check domain have variable --TPT*/
%macro VarExist();
%global result;
%let dsid=%sysfunc(open(&domain));
%if %sysfunc(varnum(&dsid,&domain.TPTNUM)) > 0 %then %let result=1;
%else %let result=0;;
%let rc=%sysfunc(close(&dsid));
%mend VarExist;

/* Usage */
%VarExist;

proc sql;
create table &domain._1 as 
            select a.*,case when index(&domain.DTC,"T") and  index(RFSTDTC,"T") then &domain.DTC 
                                else scan(&domain.DTC,1,"T") 
                    end as &domain.DTC_1, 
                    case when index(&domain.DTC,"T") and  index(RFSTDTC,"T") then RFSTDTC 
                                else scan(RFSTDTC,1,"T") 
                    end as RFSTDTC_1 
                from &domain as a;
quit;

proc sql noprint;
    select cats('a.',str_new,'=','b.',str_new) into :cond separated by ' and '
	from _null;

    create table base as
        select distinct &sortvar, 'Y' as &domain.BLFL 'Baseline Flag' length=1
        from &domain._1(where=(not missing(&domain.ORRES) and (
                       %if &result=1 %then ('' < &domain.DTC_1 < RFSTDTC_1)
                       or ('' < &domain.DTC_1 = RFSTDTC_1 and &domain.TPTNUM<0 );
                       %else '' < &domain.DTC_1 <= RFSTDTC_1;)))
        group by  %if &domain=LB %then STUDYID, USUBJID, LBCAT, LBSPEC, LBMETHOD, &domain.TESTCD;
                  %else %if &domain=XC %then STUDYID, USUBJID, XCSPEC, XCMETHOD, &domain.TESTCD;
                  %else %if &domain=FA %then STUDYID, USUBJID, &domain.OBJ, &domain.TESTCD;
                  %else %if &domain=TR %then STUDYID, USUBJID, &domain.CAT, &domain.SCAT, &domain.METHOD, 
                            &domain.TESTCD;
                  %else STUDYID, USUBJID, &domain.TESTCD; 
        having &domain.DTC=max(&domain.DTC)
        order by &sortvar
        ;

    create table &domain._ as
        select a.*, &domain.BLFL
        from &domain._1 a
        left join
        base b
        on &cond
        order by &sortvar
        ;
quit;
%put &cond.=;
data &domain;
    set &domain._;
run;

%mend jjqcblfl;

