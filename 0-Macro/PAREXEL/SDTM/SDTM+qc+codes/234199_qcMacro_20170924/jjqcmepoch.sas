/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 54767414MMY1006
  PXL Study Code:        228657

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Allen Zeng $LastChangedBy: xiaz $
  Creation Date:         11Oct2014 / $LastChangedDate: 2017-07-26 03:18:49 -0400 (Wed, 26 Jul 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/macros/jjqcmepoch.sas $

  Files Created:         jjqcmepoch.log

  Program Purpose:       To derive epoch in each domain.

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 2 $
-----------------------------------------------------------------------------*/

%macro jjqcmepoch(in_data=, in_date=);

/*Check domain have variable VISIT*/
%macro VarExist(ds, var);
%global result;
%let dsid=%sysfunc(open(&ds));
%if %sysfunc(varnum(&dsid,&var)) > 0 %then %let result=1;
%else %let result=0;;
%put &result;
%let rc=%sysfunc(close(&dsid));
%mend VarExist;

/* Usage */
%VarExist(&in_data, VISIT);

data &in_data;
    if _n_=1 then do;
        length USUBJID EPOCH_ $40 SESTDTC SEENDTC $19;
        dcl hash h(dataset:'qtrans.se(rename=EPOCH=EPOCH_)', multidata: 'y');
        h.definekey('USUBJID');
        h.definedata('USUBJID', 'EPOCH_', 'SESTDTC', 'SEENDTC');
        h.definedone();
        call missing(EPOCH_, SESTDTC, SEENDTC);
    end;
    set &in_data;
    attrib EPOCH  length = $40  Label = "Epoch";
    rc=h.find();
    do while(rc=0);
    	if not (lengthn(sestdtc)>10 and lengthn(&in_date)>10) then do;
            if "" < scan(SESTDTC, 1, 'T') <= scan(&in_date, 1, 'T') and prxmatch('/SCREENING/', cats(EPOCH_)) then EPOCH="SCREENING";
            if "" < scan(SESTDTC, 1, 'T') <= scan(&in_date, 1, 'T') and prxmatch('/^TREATMENT/', cats(EPOCH_)) then EPOCH="TREATMENT";
            if "" < scan(SESTDTC, 1, 'T') < scan(&in_date, 1, 'T') and prxmatch('/^FOLLOW/', cats(EPOCH_)) then EPOCH="FOLLOW-UP";
    	end;
    	if lengthn(sestdtc)>10 and lengthn(&in_date)>10 then do;
    	    if "" <SESTDTC <= &in_date and prxmatch('/SCREENING/', cats(EPOCH_)) then EPOCH="SCREENING";
            if "" < SESTDTC <= &in_date and prxmatch('/^TREATMENT/', cats(EPOCH_)) then EPOCH="TREATMENT";
            if "" < SESTDTC< &in_date and prxmatch('/^FOLLOW/', cats(EPOCH_)) then EPOCH="FOLLOW-UP";
    	end;
    	if not missing(&in_date) and missing(epoch) then EPOCH="SCREENING";
		rc=h.find_next();
	end;
        
       %if &result=1 %then %do;
            if missing(EPOCH) then do;
                if prxmatch('/SCREENING/', VISIT) then EPOCH="SCREENING";
                else if prxmatch('/END OF TREATMENT/', VISIT) then EPOCH="TREATMENT";
				else if prxmatch('/FOLLOW-UP/',VISIT) then EPOCH="FOLLOW-UP";
                else if ^ missing(VISIT) then EPOCH="TREATMENT";
            end;
        %end;

run;
%mend jjqcmepoch;