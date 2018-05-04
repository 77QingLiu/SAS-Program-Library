/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 32765LYM1002
  PXL Study Code:        221316

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Allen Zeng $LastChangedBy: $
  Creation Date:         13Nov2014 / $LastChangedDate: $

  Program Location/name: $HeadURL: $

  Files Created:         jjqcvaratt.log

  Program Purpose:       To create attributes for SDTM datasets

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: $
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
        from sponsorp.datadef
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
                  from sponsorp.vardef
                  where DATASET=upcase("&domain") %if &flag^=  %then and VARNAME^="&domain.SEQ";
             )
    order by VARORDER
    ;
quit;
%mend loop;

data _null_;
    set sponsorp.datadef(where=(DATASET=upcase("&domain")));
    call execute('%nrstr(%loop(domain='||cats(DATASET)||'))');
run;
%mend jjqcvaratt;
