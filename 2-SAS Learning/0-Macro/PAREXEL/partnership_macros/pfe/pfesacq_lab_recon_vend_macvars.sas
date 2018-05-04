/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership

  SAS Version:           9.2 and above
  Operating System:      UNIX
  Example Call:          %pfesacq_lab_recon_vend_macvars(...macro parameters...);

-------------------------------------------------------------------------------

  Author:                Allwyn Dsouza $LastChangedBy: $
  Creation Date:         13NOV2015  $LastChangedDate:  $

  Program Location/Name: $HeadURL: $

  Files Created:         None

  Program Purpose:       Create macro variables for Vendor Lab dataset variables

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.

                         This macro has been validated for use only in PAREXEL's
                         working environment.

  Macro Output:          NA. Only assigns values to Vendor Lab macro variables

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev:  $
-----------------------------------------------------------------------------*/

%macro pfesacq_lab_recon_vend_macvars() ;

     %if %sysfunc(exist(edata.lab)) %then %do;

     	proc sql noprint;
     		select count(*) into:nobs
     		from edata.lab;
     	quit;

     	%if &nobs=0 %then %goto macerr;


        * Initialise each macro variable as blank ;

        %local i;
        %let i = 1 ;

        %do %while (%scan(&_list_macvars, &i, %str( )) ne %str()) ;
                %let _macvar = %scan(&_list_macvars, &i, %str( )) ;
                %let &_macvar = ;
                %let i = %eval(&i + 1);
        %end ;

        * Read Vendor lab dataset;

        proc contents data = edata.lab
            out = _vend_meta (keep = name) noprint ;
        run ;

        * Search for dataset variables and create macro variables ;
        * Following macro parameters are not handled - esiteid, elbcat, elnotdone;

        data _null_ ;
            set _vend_meta ;
            name = upcase(strip(name)) ;

            if name in ("STUDY")   then call symput('estudy',   name);
            if name in ("SSID")    then call symput('esubjid',  name);
            if name in ("GENDER")  then call symput('esex',     name);
            if name in ("DOB")     then call symput('edob',     name);
            if name in ("VISIT")   then call symput('evisit',   name);
            if name in ("LBTEST")  then call symput('elbtest',  name);
            if name in ("LBPTM")   then call symput('elbtpt',   name);
            if name in ("TPD_H")   then call symput('elbtpth',  name);
            if name in ("TPD_M")   then call symput('elbtptm',  name);
            if name in ("PREFRES") then call symput('estdres',  name);
            if name in ("PREFUNT") then call symput('estdunit', name);
            if name in ("LAB_COM") then call symput('einvcom',  name);

            if name in ("TSTID" "PFE_TSTID", "PXCODE")      then call symput('epxcode',   name);
            if name in ("LB_TSTID", "LBTSTID")              then call symput('elbtstid',  name);
            if name in ("TSTRES", "LVALUE")                 then call symput('eresult',   name);
            if name in ("TSTUNT", "TSTRES_UNT", "LBUNIT")       then call symput('eresunit',  name);
            if name in ("COLL_D", "LBDT")                   then call symput('ecolldate', name);
            if name in ("COLL_T", "LBACTTM")                then call symput('etesttime', name);
            if name in ("ACCNUM", "ACCESSION", "LBUSMID")   then call symput('elabsmpid', name);

        run ;

        * List all macro variables created ;

        %put --------------------------------------------------- ;
        %put - Macro variables created from Vendor LAB dataset - ;
        %put --------------------------------------------------- ;

        %let i = 1 ;

        %do %while (%scan(&_list_macvars., &i, %str( )) ne %str()) ;
                %let _macvar = %scan(&_list_macvars., &i, %str( )) ;
                %put &_macvar. = &&&_macvar.;
                %let i = %eval(&i. + 1);
        %end ;

        %put --------------------------------------------------- ;
        %put - End - ;
        %put --------------------------------------------------- ;

        * Check if any required macro variable is not created ;

        %local _list_macvars_req ;
        %let _list_macvars_req = estudy /*LABID*/ elabsmpid esubjid evisit
                        ecolldate etesttime elbtpt elbtpth elbtptm epxcode elbtstid
                        eresult eresunit estdres estdunit einvcom ;

        %put --------------------------------------------------- ;
        %put - Required macro variables could not be derived   - ;
        %put --------------------------------------------------- ;

        %let i = 1 ;

        %do %while (%scan(&_list_macvars_req., &i, %str( )) ne %str()) ;
                %let _macvar = %scan(&_list_macvars_req., &i, %str( )) ;
                %if %str(&&&_macvar.) = %str() %then %do;
                        %put &_macvar. = &&&_macvar.;
                %end ;
                %let i = %eval(&i. + 1);
        %end ;

        proc datasets library=work nolist;
        		delete _vend_meta ;
        	quit;

   %end;

   	%else %do;
       			%put %str(ERR)OR:[PXL]------------------------------------------------------------------------;
       			%put %str(ERR)OR:[PXL] PFESACQ_LAB_RECON_VEND_MACVARS: alert: Dataset LAB does not exist.;
       			%put %str(ERR)OR:[PXL]------------------------------------------------------------------------;
   		  %end;


   	%goto macend;
   	%macerr:;
   	%put %str(ERR)OR:[PXL] -------------------------------------------------------------------------------------;
   	%put %str(ERR)OR:[PXL] PFESACQ_LAB_RECON_VEND_MACVARS: The input dataset LAB has zero (0) observations.;
   	%put %str(ERR)OR:[PXL] -------------------------------------------------------------------------------------;



       %macend:;





        %put --------------------------------------------------- ;
        %put - End - ;
        %put --------------------------------------------------- ;

%mend pfesacq_lab_recon_vend_macvars;
