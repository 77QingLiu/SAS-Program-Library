/*-------------------------------------------------------------------------------------
PAREXEL INTERNATIONAL LTD

Sponsor / Protocol No: Janssen Research & Development, LLC / PCI-32765LYM1002
PXL Study Code:        221316

SAS Version:           9.3
Operating System:      UNIX
---------------------------------------------------------------------------------------

Author:                Allen Zeng $LastChangedBy: liuc5 $
Creation Date:         13Nov2014 / $LastChangedDate: 2016-08-29 03:54:05 -0400 (Mon, 29 Aug 2016) $

Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/macros/jjqcaddvar.sas $

Files Created:         jjqcaddvar.log

Program Purpose:       To add variables for the text exceeding 200 characters

--------------------------------------------------------------------------------------
MODIFICATION HISTORY:  Subversion $Rev: 42 $
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
