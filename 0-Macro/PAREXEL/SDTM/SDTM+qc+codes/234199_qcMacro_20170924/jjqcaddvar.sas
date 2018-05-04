/*-------------------------------------------------------------------------------------
PAREXEL INTERNATIONAL LTD

Sponsor / Protocol No: Janssen Research & Development, LLC / MMY1006
PXL Study Code:        228657

SAS Version:           9.3
Operating System:      UNIX
---------------------------------------------------------------------------------------

Author:                Qingjie Zeng $LastChangedBy: xiaz $
Creation Date:         10Aug2016 / $LastChangedDate: 2017-07-26 03:18:49 -0400 (Wed, 26 Jul 2017) $

Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/macros/jjqcaddvar.sas $

Files Created:         jjqcaddvar.log

Program Purpose:       To add variables for the text exceeding 200 characters

--------------------------------------------------------------------------------------
MODIFICATION HISTORY:  Subversion $Rev: 2 $
-------------------------------------------------------------------------------------*/
/*Start programming*/
%macro addvar(in_data=, in_var=, split=, maxlen=200, out_data=, out_pre=);
/*Flag dataset*/
proc sql noprint;
    select distinct max(length(&in_var)) into :lngth
        from &in_data;
quit;

%if &lngth > &maxlen %then %do;
/*Make the split*/
data &in_data;
    set &in_data(rename=&in_var=_&in_var._);
    %gmModifySplit(var=_&in_var._, width=&maxlen);
run;

/*Number of variables*/
proc sql noprint;
    select cats(max(count(_&in_var._, "&split"))) into :varn
        from &in_data;
quit;

data &out_data;
    set &in_data;
    array vlst{*} $200 &out_pre. &out_pre.1 - &out_pre.&varn;
    do i=1 to %eval(&varn+1);
	    vlst(i)=scan(_&in_var._, i, "&split");
    end;
    drop _&in_var._ i;
run;
%end;
%else %do;
    data &out_data;
        set &in_data(rename=&in_var=_&in_var._);
        length &out_pre $200;
        &out_pre=_&in_var._;
        drop _&in_var._;
    run;
%end;
%mend addvar;
