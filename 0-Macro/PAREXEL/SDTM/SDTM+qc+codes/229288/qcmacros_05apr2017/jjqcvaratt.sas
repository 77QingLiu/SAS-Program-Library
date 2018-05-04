/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 32765LYM1002
  PXL Study Code:        221316

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Allen Zeng $LastChangedBy: liuc5 $
  Creation Date:         13Nov2014 / $LastChangedDate: 2016-08-29 03:54:05 -0400 (Mon, 29 Aug 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/macros/jjqcvaratt.sas $

  Files Created:         jjqcvaratt.log

  Program Purpose:       To create attributes for SDTM datasets

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 42 $
-----------------------------------------------------------------------------*/

/*Variable attributes*/
%macro jjqcvaratt(domain=,flag=);

%global &domain._varatt_
        &domain._varlst_
        &domain._keyvar_
        &domain._dlabel_;

/*Creating macro variables*/
%macro loop(domain=);
proc sql noprint;
    select translate(KEYS,"",",")
         , DSLABEL
        into :&domain._keyvar_
            ,:&domain._dlabel_
        from qmeta.datadef
        where DATASET="&domain"
    ;

    select cats(VARNAME)||' '||"label"||'='||'"'||cats(VARLABEL)||'"'||' '||"length"||'='||cats(LNGTH_)
         , VARNAME
        into :&domain._varatt_ separated by ' '
            ,:&domain._varlst_ separated by ' '
        from (select *, case when prxmatch('/(integer)/',DATATYPE)                        then cats(LNGTH)
                             when prxmatch('/(float)/',DATATYPE) and input(LNGTH,best.)>8  then '8'
                             when prxmatch('/(float)/',DATATYPE) and input(LNGTH,best.)<=8 then cats(LNGTH)
                             else cats('$',LNGTH)
                        end as LNGTH_
                  from qmeta.vardef
                  where DATASET=upcase("&domain") %if &flag^=  %then and VARNAME^="&domain.SEQ";
             )
    order by VARORDER
    ;
quit;
%mend loop;

data _null_;
    set qmeta.datadef(where=(DATASET=upcase("&domain")));
    call execute('%nrstr(%loop(domain='||cats(DATASET)||'))');
run;
%mend jjqcvaratt;
