/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership

  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------

  Author:                Allwyn Dsouza $LastChangedBy: dsouzaal $
  Creation Date:         29NOV2015     $LastChangedDate: 2016-06-10 06:24:47 -0400 (Fri, 10 Jun 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfesacq_ecg_recon_vend_transform.sas $

  Files Created:         None

  Program Purpose:       ECG Reconciliation of the vendor ecg dataset into SACQ format.

                         Note: Part of program: pfesacq_ecg_recon

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.

                         This macro has been validated for use only in PAREXEL's
                         working environment.

  Macro Output:          EGEDATA dataset is created in the "/../dm/listings/current" Folder

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2296 $

-----------------------------------------------------------------------------*/

%macro pfesacq_ecg_recon_vend_transform;
	
	%put NOTE:[PXL] ---------------------------------------------------------------------;
	%put NOTE:[PXL] &sysmacroname.: Start of Submacro;
	%put NOTE:[PXL] ---------------------------------------------------------------------;
	%put ;

	%local einds;
	%let einds = ecg ;

    %if not %sysfunc(exist(edata.&einds)) %then %goto macdne;

    proc sql noprint;
        select count(*) into:nobs
        from edata.&einds.;
    quit;

    %if &nobs. = 0 %then %goto mac0obs;

	* -----------------------------------------------------------------;
    * Assign macro variables for dataset variable placeholders ;
    * -----------------------------------------------------------------;

	%local i _macvar;
	
	%let i = 1 ;
	%do %while (%scan(&_list_venmacvars., &i., %str( )) ne %str()) ;
        %let _macvar = %scan(&_list_venmacvars., &i., %str( )) ;
        %let &_macvar = ;
        %let i = %eval(&i. + 1);
    %end ;
	
	proc contents data = edata.&einds. out = _vend_meta noprint ;
	run ;
	
	data _null_ ;
		set _vend_meta ;
		name = upcase(strip(name)) ;

		if      name in ("PROTOCOL"          , "STUDYID" ) then call symputx ('estudy'   ,name) ;
		else if name in ("CENTER"            , "SITEID"  ) then call symputx ('esiteid'  ,name) ;
		else if name in ("SUBJECT"           , "USUBJID" ) then call symputx ('esubjid'  ,name) ;
		else if name in ("CPE"               , "VISIT"   ) then call symputx ('ecpevent' ,name) ;
		else if name in ("TEST_DATE"         , "EGDTC"   ) then call symputx ('ecolldate',name) ;
		else if name in ("TEST_TIME"                     ) then call symputx ('eegacttmf',name) ;
		else if name in ("TPD"               , "EGTPT"   ) then call symputx ('eegtpd'   ,name) ;
		else if name in ("COMMENT"           , "COVAL"   ) then call symputx ('eegcom'   ,name) ;
		else if name in ("MEASUREMENT_TYPE"  , "EGTEST"  ) then call symputx ('eegtest'  ,name) ;
		else if name in ("MEASUREMENT_RESULT", "EGORRES" ) then call symputx ('eegorres' ,name) ;
		else if name in ("BRTHDTC"                       ) then call symputx ('edob'     ,name) ;
		else if name in ("SEX"                           ) then call symputx ('esex'     ,name) ;
		else if name in ("STATUS_INTP"                   ) then call symputx ('eegintp'  ,name) ;
		
	run ;
	
	* -----------------------------------------------------------------;
	* Write Vendor macro variables to LOG ;
	* -----------------------------------------------------------------;

	%put NOTE:[PXL] -----------------------------------------------------------------;
    %put NOTE:[PXL] Macro variables created from Vendor ECG dataset ;
    %put NOTE:[PXL] -----------------------------------------------------------------;

    %let i = 1 ;

    %do %while (%scan(&_list_venmacvars., &i, %str( )) ne %str()) ;
        %let _macvar = %scan(&_list_venmacvars., &i, %str( )) ;
        %put NOTE:[PXL] &_macvar. = &&&_macvar.;
        %let i = %eval(&i. + 1);
    %end ;
	%put ;

	* -----------------------------------------------------------------;
    * Check if all required macro parameters were derived ;
    * -----------------------------------------------------------------;

	%local _list_venmacvars_req _list_venmacvars_req_miss ;
	%let _list_venmacvars_req = estudy esiteid esubjid ecpevent ecolldate;
	%let _list_venmacvars_req_miss = ;
	%let i = 1 ;

	%do %while (%scan(&_list_venmacvars_req., &i, %str( )) ne %str()) ;
        %let _macvar = %scan(&_list_venmacvars_req., &i, %str( )) ;
        %if %str(&&&_macvar.) = %str() %then %do;
			%let _list_venmacvars_req_miss = &_list_venmacvars_req_miss. %left(&_macvar.) ;
			%let l_error = 1 ;
        %end ;
        %let i = %eval(&i. + 1);
    %end ;

	%if &l_error. = 1 %then %goto macerr;

    * -----------------------------------------------------------------;
    * Find the latest directory date in the EDATA directory ;
    * -----------------------------------------------------------------;

    data _null_;
        call system("cd &path_dm./e_data/datasets");
    run;

    filename fref_dir pipe 'ls -la';

    data _vend_dir;
        length dirline $200;
        infile fref_dir recfm=v lrecl=200 truncover;

        input dirline $1-200;
        if substr(dirline,1,1) = 'd';
        datec = substr(dirline,59,8);
        if index(datec,'.') or datec = ' ' then delete;
        date = input(datec,?? yymmdd10.);
        if date = . then delete;
        format date date9.;
    run ;

    proc sort data = work._vend_dir ;
      	by descending date ;
    run ;

	%local curdate prevdate ;

	%let curdate = ;
	%let prevdate = ;

	data _vend_dir (keep = date datec) ;
		set _vend_dir ;
		if _n_ = 1 then do ;
			call symput('curdate',left(trim(datec))) ;
			output;
		end ;
		else if _n_ = 2 then call symput('prevdate',left(trim(datec))) ;
		else stop ;
	run ;

    %if %sysfunc(exist(metadata.rec_vendecg_meta)) %then %do;

        proc sort data = metadata.rec_vendecg_meta ;
            by date;
        run;

        proc append base=metadata.rec_vendecg_meta data = _vend_dir;
        run;

        proc sort data=metadata.rec_vendecg_meta nodupkey;
            by date;
        run;

    %end;
    %else %do;

        proc append base=metadata.rec_vendecg_meta data=_vend_dir;
        run;

        proc sort data=metadata.rec_vendecg_meta nodupkey;
			by date;
        run;

        data _vend_current;
            attrib STATUS2 length=$7 label='Vendor Data State';
            set edata.&einds;
            status2='New';
        run;

        %goto edctrans;

    %end;

    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put NOTE:[PXL] Current snapshot date (Vendor) = &curdate. ;
    %put NOTE:[PXL] Previous snapshot date (Vendor) = &prevdate. ;
	%put NOTE:[PXL] ---------------------------------------------------------------------;
	%put ;
	
	* ---------------------------------------------------------------------;
    * Define the previous library to compare the data ;
	* ---------------------------------------------------------------------;

    %if %str(&prevdate) ne %str() %then %do;
		libname olddir "&path_dm./e_data/datasets/&prevdate.";
    %end;
    %else %do;
		libname olddir "&path_dm./e_data/datasets/draft";
    %end;

	* ---------------------------------------------------------------------;
	* Merge Old and Current datasets to check for changes and new records ;
	* ---------------------------------------------------------------------;

    %local _sort_key;
    %let _sort_key = %cmpres(&esiteid. &esubjid. &ecolldate. &eegacttmf. &eegtest.) ;

	%put NOTE:[PXL] ---------------------------------------------------------------------;
	%put NOTE:[PXL] Sort key to merge OLD and CURRENT datasets = &_sort_key. ;
	%put NOTE:[PXL] ---------------------------------------------------------------------;
    %put ;

	%if %sysfunc(exist(olddir.&einds.)) %then %do;

        proc sort data=olddir.&einds. out=_vend_old nodupkey ;
			by &_sort_key.;
        run;

        proc sort data=edata.&einds. out=_vend_current ;
			by &_sort_key.;
        run;

		data _vend_current ;
			set _vend_current;
			unique_id = _n_ ;
		run;
		
        *** Create the STATUS variable ***;

        data _vend_status (keep = &_sort_key. unique_id status2);
			attrib STATUS2 length=$7 label='Vendor Data State';
        	merge
                _vend_old (in = old rename=(
					%if %str(&ecpevent.) ne %str() %then %do; &ecpevent. = oldcpe   %end;
					%if %str(&eegtpd.)   ne %str() %then %do; &eegtpd.   = oldegtpd %end;
                ))
                _vend_current (in=new rename=(
					%if %str(&ecpevent.) ne %str() %then %do; &ecpevent. = newcpe   %end;
                    %if %str(&eegtpd.)   ne %str() %then %do; &eegtpd.   = newegtpd %end;
                ));
            by &_sort_key. ;
			unique_id = _n_ ;
            if new;

            if old=1 then do ;
				status2="Old";
	    		%if %str(&ecpevent.) ne %str() %then %do;
					if oldcpe   ne newcpe   then status2="Changed";
	            %end;
				%if %str(&eegtpd.) ne %str() %then %do;
					if oldegtpd ne newegtpd then status2="Changed";
	            %end;
			end ;
			else status2="New";

        run;

        data _vend_current;
            merge _vend_status _vend_current;
            by unique_id ;
			drop unique_id ;
        run;

	%end;
	%else %do;

        data _vend_current;
            attrib status2 length=$7 label='Vendor Data State';
            set edata.&einds;
            status2='New';
        run;

	%end;

	libname olddir clear;

    %edctrans:;
	
	* ---------------------------------------------------------------------;
	* Check if a DATE-TIME variable exists in '&ECOLLDATE' ;
	* ---------------------------------------------------------------------;
	
	proc contents data=edata.&einds. out = _vend_egmeta noprint;
    run;
	
	%local vend_datetime ;
	%let vend_datetime = ;
	%let eegdttype=;

	%if %str(&ecolldate.) ne %str() %then %do;

	    data _null_;
	        set _vend_egmeta;
	        where upcase(name) = upcase(strip("&ecolldate."));
	        call symputx ("eegdttype", type);
			if index(upcase(name),"DTC") > 0 then call symputx ('vend_datetime',"Y") ;
	    run;
		
	%end ;

	* ---------------------------------------------------------------------;
	* If DATE-TIME variable is present in '&ECOLLDATE' ;
	* then split into DATE AND TIME into '&ECOLLDATE' and '&EEGACTTMF' ;
	* ---------------------------------------------------------------------;

	%if %str(&vend_datetime.) = %str(Y) %then %do ;

		data _vend_ecg ;
			set edata.&einds. ;
			
			if not missing (&ecolldate.) then do ;
				%if &eegdttype. = 1 %then %do ;
					_colldate = put(datepart(&ecolldate.),is8601da.) ;
					_colltime = put(timepart(&ecolldate.),time8.) ;
				%end ;
				%else %if &eegdttype. = 2 %then %do ;
					_colldate = scan(upcase(&ecolldate.),1,"T") ;
					_colltime = scan(upcase(&ecolldate.),2,"T") ;
				%end ;
			end ;
		run ;

		proc contents data = _vend_ecg out = _vend_egmeta noprint ;
		run;

		data _vend_current ;
			set _vend_current;

			if not missing (&ecolldate.) then do ;
				%if &eegdttype. = 1 %then %do ;
					_colldate = put(datepart(&ecolldate.),is8601da.) ;
					_colltime = put(timepart(&ecolldate.),time8.) ;
				%end ;
				%else %if &eegdttype. = 2 %then %do ;
					_colldate = scan(upcase(&ecolldate.),1,"T") ;
					_colltime = scan(upcase(&ecolldate.),2,"T") ;
				%end ;
			end ;
		run ;

		%let ecolldate = _colldate ;
		%let eegacttmf = _colltime ;
		
	%end ;

	* ---------------------------------------------------------------------;
	* Check if individual variables are numeric or character ;
	* ---------------------------------------------------------------------;

	%local esubtype esiteidtype eegtmtype eegdttype ecpetype rectypeexist edobtype esextype eegintptype eegorrestyp;
	%let esubtype=;
	%let esiteidtype=;
	%let eegtmtype=;
	%let eegdttype=;
	%let ecpetype=;
	%let rectypeexist=;
	%let edobtype=;
	%let esextype=;
	%let eegintptype=;
	%let eegorrestyp=;

    data _null_;
        set _vend_egmeta;
        if      upcase(name) = upcase(strip("&esubjid"))    then call symputx ("esubtype",    type);
		else if upcase(name) = upcase(strip("&esiteid"))    then call symputx ("esiteidtype", type);
		else if upcase(name) = upcase(strip("&eegacttmf"))  then call symputx ("eegtmtype",   type);
		else if upcase(name) = upcase(strip("&ecolldate"))  then call symputx ("eegdttype",   type);
		else if upcase(name) = upcase(strip("&ecpevent"))   then call symputx ("ecpetype",    type);
		else if upcase(name) = upcase(strip("&esex"))       then call symputx ("esextype",    type);
		else if upcase(name) = upcase(strip("&edob"))       then call symputx ("edobtype",    type);
		else if upcase(name) = upcase(strip("&eegintp"))    then call symputx ("eegintptype", type);
		else if upcase(name) = upcase(strip("&eegorres"))   then call symputx ("eegorrestyp", type);
		else if upcase(name) = "RECORD_TYPE"                then call symputx ("rectypeexist","Y" );
    run;

	%put NOTE:[PXL] -----------------------------------------------------------------;
	%put NOTE:[PXL] - METADATA IDENTIFIERS - ;
	%put NOTE:[PXL] -----------------------------------------------------------------;
	%put NOTE:[PXL] esiteidtype=&esiteidtype.;
	%put NOTE:[PXL] esubtype=&esubtype.;
	%put NOTE:[PXL] ecpetype=&ecpetype.;
	%put NOTE:[PXL] eegtmtype=&eegtmtype.;
	%put NOTE:[PXL] eegdttype=&eegdttype.;
	%put NOTE:[PXL] esextype=&esextype.;
	%put NOTE:[PXL] edobtype=&edobtype.;
	%put NOTE:[PXL] eegintptype=&eegintptype.;
	%put NOTE:[PXL] eegorrestyp=&eegorrestyp.;
	%put NOTE:[PXL] rectypeexist=&rectypeexist.;
	%put NOTE:[PXL] -----------------------------------------------------------------;
	%put ;

	* ---------------------------------------------------------------------;
	* Prepare to create final dataset ;
	* ---------------------------------------------------------------------;
	
    data _vend_ecg ;
        attrib
            STUDY     length = $15  label = 'Clinical Study'
            SITEID    length = $4   label = 'Center Identifier Within Study'
            SUBJID    length = $8   label = 'Subject ID'
            CPEVENT   length = $20  label = 'CPE Name'
            COLLDATE  length = $15  label = 'Collection Date'
            EGACTTMF  length = $15  label = 'ECG Actual Time Char'
            EGTPD     length = $30  label = 'Planned Time Post Dose'
            EGCOM     length = $200 label = 'ECG Comments'
			SEX       length = $20  label = 'Gender Code'
			DOB       length = $15  label = 'Date of Birth'
			EGINTP    length = $50 label = 'Normal or Abnormal Status' ;
        set _vend_current (rename=(
            %if &estudy.    ne %then %do; &estudy.    = __&estudy.    %end;
			%if &esiteid.   ne %then %do; &esiteid.   = __&esiteid.   %end;
			%if &esubjid.   ne %then %do; &esubjid.   = __&esubjid.   %end;
            %if &ecpevent.  ne %then %do; &ecpevent.  = __&ecpevent.  %end;
            %if &ecolldate. ne %then %do; &ecolldate. = __&ecolldate. %end;
			%if &eegacttmf. ne %then %do; &eegacttmf. = __&eegacttmf. %end;
            %if &eegtpd.    ne %then %do; &eegtpd.    = __&eegtpd.    %end;
			%if &eegcom.    ne %then %do; &eegcom.    = __&eegcom.    %end;
			%if &esex.      ne %then %do; &esex.      = __&esex.      %end;
			%if &edob.      ne %then %do; &edob.      = __&edob.      %end;
			%if &eegintp.   ne %then %do; &eegintp.   = __&eegintp.   %end;
        ));

		* STUDY ;
		
		%if %upcase(&estudy.) = %str(STUDYID) %then %do ;
        	study = upcase(__&estudy.);
		%end ;
		%else %if %upcase(&estudy.) = %str(PROTOCOL) %then %do ;
			study = upcase(compress(project || __&estudy.));
		%end ;

		* SUBJID ;
		
        %if &esubtype. = 1 %then %do;
			subjid = compress(put(__&esubjid.,best.),'-|_ ');
		%end;
        %else %if &esubtype. = 2 %then %do;
			subjid = compress(__&esubjid.,'-|_ ');
        %end;

		* SITEID ;
		
		%if &esiteidtype. = 1 %then %do;
			siteid = compress(put(__&esiteid.,best.));
		%end;
        %else %if &esiteidtype. = 2 %then %do;
			siteid = upcase(compress(__&esiteid.));
        %end;
		%else %do ;
			siteid = '';
		%end ;

		if strip(siteid) = "" and length(subjid) = 8 then siteid = substr(strip(subjid),1,4);
		
		* CPEVENT ;
		
		%if &ecpetype. = %then %do ;
			cpevent = '';
		%end ;
		%else %if &ecpetype. = 1 %then %do;
			cpevent = strip(put(__&ecpevent.,best.));
		%end;
		%else %if &ecpetype. = 2 %then %do;
			cpevent = upcase(__&ecpevent.);
		%end;


		* EGCOM ;

        %if &eegcom.  = %then %do;
			egcom = '';
		%end;
		%else %do;
			egcom = strip(__&eegcom.);
		%end;

		* EGTPD ;

        %if &eegtpd.  = %then %do;
			egtpd = '';
		%end;
		%else %do;
			egtpd = strip(upcase(__&eegtpd.));
		%end;

		* COLLDATE ;

        %if &eegdttype=1 %then %do;
			if . < __&ecolldate. < ((2020-1960)*365) then
				colldate = strip(put(__&ecolldate.,date9.));
			else if __&ecolldate. > ((2020-1960)*365) then
				colldate = strip(put(input(strip(put(__&ecolldate.,best.)),yymmdd8.),date9.));
        %end;
        %else %if &eegdttype=2 %then %do;

            __&ecolldate.=upcase(compress(__&ecolldate.,'-_'));
            if indexc(__&ecolldate.,'ABCDEFGHIJKLMNOPQRSUVWXYZ')>0
                and (substr(__&ecolldate.,1,2) not in ('UN','XX')
                and substr(__&ecolldate.,3,3) not in ('UNK','XXX') )
                and length(__&ecolldate.)>=9 then do;
	                ecolldaten = input(__&ecolldate.,date9.);
	                if ecolldaten ne . then colldate=strip(put(ecolldaten,date9.));
            end;
            else do;
                if length(__&ecolldate.)=8 then colldate22 =
         			compress(substr(__&ecolldate.,1,4)||'-'||substr(__&ecolldate.,5,2)||'-'||substr(__&ecolldate.,7,2));
                colldate22n=input(colldate22,yymmdd10.);
                colldate=strip(put(colldate22n,date9.));
                if 4<length(__&ecolldate.)<8 then colldate=strip(__&ecolldate.);
            end;
        %end;

		* EGACTTMF ;
		
		egacttmf = "" ;
        %if &eegtmtype=1 %then %do;
			egacttmf = strip(put(__&eegacttmf.,time8.));
		%end;
        %else %if &eegtmtype=2 %then %do;
			egacttmf=compress(__&eegacttmf.);	
        %end;
		if length(egacttmf) = 4 then egacttmf = compress('0' || egacttmf);
		if length(egacttmf) = 5 then egacttmf = compress(egacttmf || ':00');
		if length(compress(egacttmf)) = 7 then egacttmf = compress("0" || egacttmf);


		* DOB ;

        %if &edob. = %then %do;
			dob = '';
		%end;
		%else %do;
			%if &edobtype. = 1 %then %do ;
				if not missing(__&edob.) then dob = strip(put(__&edob.,is8601da.));
			%end;
			%else %if &edobtype. = 2 %then %do ;
				if not missing(__&edob.) then do ;
					if indexc(__&edob.,'ABCDEFGHIJKLMNOPQRSUVWXYZ')>0 then dob = put(input(__&edob.,date9.),is8601da.);
					else dob = put(input(__&edob.,yymmdd10.),is8601da.);
				end;
			%end;
		%end;

		* SEX ;

        %if &esex. = %then %do;
			sex = '';
		%end;
		%else %do;
			%if &esextype. = 1 %then %do ;
				sex = strip(put(__&esex.,best.)) ;
			%end;
			%else %if &esextype. = 2 %then %do ;
				sex = upcase(strip(__&esex.));
			%end;

			if strip(sex) in ("1", "M") then sex = "MALE";
			else if strip(sex) in ("2", "F") then sex = "FEMALE";
		%end;
		
		* EGINTP ;

        %if &eegintp. = %then %do;
			egintp = '';
		%end;
		%else %do;
			%if &eegintptype. = 1 %then %do ;
				egintp = strip(put(__&eegintp.,best.));
			%end;
			%else %if &eegintptype. = 2 %then %do ;
				egintp = upcase(strip(__&eegintp.));
			%end;
		%end;

    run;
	
	* ---------------------------------------------------------------------;
	* If siteid is missing then derive from SUBJID;
	* ---------------------------------------------------------------------;

	%if %str(&rectypeexist.) = %str(Y) %then %do ;
		data _vend_ecg ;
			set _vend_ecg ;
			if upcase(record_type) = "H" then delete;
		run ;
	%end ;

	* ---------------------------------------------------------------------;
	* Map Visits to the EDC equivalent if provided in study specs ;
	* Map Timepoints to the value specified in study specs ;
	* ---------------------------------------------------------------------;
	
	%if %sysfunc(fileexist("&path_dm./documents/ecg_recon/current/%lowcase(&protocol.) ecg recon specs.xls")) %then %do;

		proc import datafile = "&path_dm./documents/ecg_recon/current/%lowcase(&protocol.) ecg recon specs.xls"
		            out      = _vend_vismap
					dbms     = xls replace;
					sheet    = "Expected Visits";
					getnames = no;
					startrow = 2;
		run;

		%local atype btype ctype;
		%let atype=;
		%let btype=;
		%let ctype=;

		proc contents data = _vend_vismap (keep = a b) out = _vend_vismap_meta noprint;
		run;

		data _null_;
			set _vend_vismap_meta (keep = name type);
			if upcase(name) = "A" then call symputx('atype',type);
			else if upcase(name) = "B" then call symputx('btype',type);
		run;
		
		data _vend_vismap (keep = source target );
			set _vend_vismap ;
			where not (missing(a) and missing(b));

			length source target $200;
			
			%if &btype. = 1 %then %do;
				source = strip(put(b,best.));
			%end;
			%else %if &btype. = 2 %then %do;
				source = upcase(strip(b));
			%end;
			
			%if &atype. = 1 %then %do;
				target = strip(put(a,best.));
			%end;
			%else %if &atype. = 2 %then %do;
				target = upcase(strip(a));
			%end;
		run;

		proc sort data = _vend_vismap nodupkey ;
			by source;
		run;

		proc sql noprint;
			create table _vend_ecgvis as
			select a.*, b.target
			from work._vend_ecg a
			left join work._vend_vismap b
			on compress(upcase(strip(a.cpevent)),,'kw') = compress(upcase(strip(b.source)),,'kw') ;
		quit ;
		
		data _vend_ecg ;
			set _vend_ecgvis ;
			
			if not missing(target) then cpevent = strip(upcase(target));
			drop target;
		run;
		
		proc import datafile = "&path_dm./documents/ecg_recon/current/%lowcase(&protocol.) ecg recon specs.xls"
		            out      = _vend_tptmap
					dbms     = xls replace;
					sheet    = "Expected Timepoints";
					getnames = no;
					startrow = 2;
		run;

		%let atype=;
		%let btype=;
		%let ctype=;

		proc contents data = _vend_tptmap (keep = b c) out = _vend_tptmap_meta noprint;
		run;

		data _null_;
			set _vend_tptmap_meta (keep = name type);
			if upcase(name) = "B" then call symputx('btype',type);
			else if upcase(name) = "C" then call symputx('ctype',type);
		run;
		
		data _vend_tptmap (keep = source target );
			set _vend_tptmap ;
			where not (missing(a) and missing(b));
			
			length source target $200;
			
			%if &btype. = 1 %then %do;
				source = strip(put(b,best.));
			%end;
			%else %if &btype. = 2 %then %do;
				source = upcase(strip(b));
			%end;

			%if &ctype. = 1 %then %do;
				target = strip(put(c,best.));
			%end;
			%else %if &ctype. = 2 %then %do;
				target = upcase(strip(c));
			%end;
		run;

		proc sort data = _vend_tptmap nodupkey ;
			by source;
		run;

		proc sql noprint;
			create table _vend_ecgtpt as
			select a.*, b.target
			from work._vend_ecg a
			left join work._vend_tptmap b
			on compress(upcase(strip(a.egtpd)),,'kw') = compress(upcase(strip(b.source)),,'kw') ;
		quit ;

		data _vend_ecg ;
			set _vend_ecgtpt ;
			
			if not missing(target) then egtpd = strip(upcase(target));
			drop target;
		run;

	%end;

	* ---------------------------------------------------------------------;
	* If ECG Interpretation is not present as a variable but as a row then ;
	* merge it back ;
	* Do this only if - 
	*    there is no variable for ECG Interpretation AND ;
	*    there is a variable for EGTEST with value 'OVERALL STATEMENT'
	*    there is a character variable available for EGORRES with char values
	* ---------------------------------------------------------------------;

	%if %str(&eegintp.) = %str() and %str(&eegtest.) ne %str() and %str(&eegorres.) ne %str() and %str(&eegorrestyp.) = %str(2) %then %do ;

		proc sort data = _vend_ecg out = _vend_egintp (keep = study siteid subjid cpevent colldate egtpd egacttmf &eegorres.) nodupkey;
			by study siteid subjid cpevent colldate egtpd egacttmf;
			where upcase(strip(&eegtest.)) = "OVERALL STATEMENT" and indexc(upcase(&eegorres.),'ABCDEFGHIJKLMNOPQRSTUVWXYZ') > 0 and not missing(&eegorres.);
		run;

		data _null_ ;
			set _vend_egintp ;
			if _n_ = 1 then do;
				call symputx('eegintp','egintp');
				stop;
			end;
		run ;

		proc sort data = _vend_ecg (drop = &eegorres.);
			by study siteid subjid cpevent colldate egtpd egacttmf;
		run ;

		data _vend_ecg (drop = &eegorres.);
			merge _vend_ecg (in=a) _vend_egintp ;
			by study siteid subjid cpevent colldate egtpd egacttmf;
			if a ;
			if missing(egintp) then egintp = strip(upcase(&eegorres.));
		run;

	%end ;

	* ---------------------------------------------------------------------;
	* Prepare to write final dataset;
	* Save intermediate dataset with EGTEST variable to be used for Listing 8;
	* ---------------------------------------------------------------------;
	
	%local _final_vars;
	%let _final_vars = STUDY SITEID SUBJID CPEVENT COLLDATE EGACTTMF EGTPD EGINTP EGCOM SEX DOB STATUS2;
	
	data lis08_raw (keep = &_final_vars. egtest);
		set _vend_ecg ;
		
		%if &eegtest. ne %then %do;
			egtest = &eegtest.;
		%end;
		%else %do;
			egtest = '';
		%end;
	run;

	* ---------------------------------------------------------------------;
	* Write final dataset to permanent library;
	* ---------------------------------------------------------------------;
	
	proc sort data = _vend_ecg ;
		by &_final_vars. ;
	run;
	
	data outdir.egedata (keep = &_final_vars.);
		retain &_final_vars. ;
		set _vend_ecg (keep = &_final_vars.) ;
		by &_final_vars. ;
		if last.egtpd ;
	run;

	* ---------------------------------------------------------------------;
	* House-keeping;
	* ---------------------------------------------------------------------;

	proc datasets library=work nolist;
		delete _vend_:;
	quit;

	* ---------------------------------------------------------------------;
	* Error handling;
	* ---------------------------------------------------------------------;
	
	%goto macend;
	
	%macdne:;
	%let l_error = 1 ;
	%put ;
    %put NOTE:[PXL] ------------------------------------------------------------------------;
    %put %str(ERR)OR:[PXL] &sysmacroname.: alert: Dataset &einds does not exist.;
    %put NOTE:[PXL] ------------------------------------------------------------------------;
	%put ;
	%goto macend;

	%mac0obs:;
	%let l_error = 1 ;
	%put ;
	%put NOTE:[PXL] -------------------------------------------------------------------------------------;
	%put %str(ERR)OR:[PXL] &sysmacroname.: The input dataset &einds has zero (0) observations.;
	%put NOTE:[PXL] -------------------------------------------------------------------------------------;
	%put ;
	%goto macend;

	%macerr:;
	%let l_error = 1 ;
	%put ;
    %put NOTE:[PXL] -----------------------------------------------------------------------;
    %put %str(ERR)OR:[PXL] &sysmacroname.: Required macro parameters are missing. <&_list_venmacvars_req_miss.>;
    %put NOTE:[PXL] -----------------------------------------------------------------------;
	%put ;
	%goto macend;

    %macend:;
    %put ;
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put NOTE:[PXL] &sysmacroname.: End of Submacro;
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_ecg_recon_vend_transform;