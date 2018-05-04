/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership

  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------

  Author:                Allwyn Dsouza, $LastChangedBy: dsouzaal $
  Creation Date:         28SEP2015      $LastChangedDate: 2016-06-10 06:24:47 -0400 (Fri, 10 Jun 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfesacq_ecg_recon_edc_transform.sas $

  Files Created:         <project>/dm/listings/current/eg_crf.sas7bdat

  Program Purpose:       ECG Reconciliation of the raw dataset into SACQ format

                         Note: Part of program: pfesacq_ecg_recon

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.

                         This macro has been validated for use only in PAREXEL's
                         working environment.

  Macro Parameters:      NA

  Macro Dependencies:    NA

-------------------------------------------------------------------------------
 MODIFICATION HISTORY: Subversion $Rev: 2296 $
-----------------------------------------------------------------------------*/

%macro pfesacq_ecg_recon_edc_transform;
	
	%put ;
    %put NOTE:[PXL] ----------------------------------------------------------;
    %put NOTE:[PXL] &sysmacroname: Start of Submacro;
    %put NOTE:[PXL] ----------------------------------------------------------;
    %put ;

    %if not %sysfunc(exist(download.&inds)) %then %do ;
		%put ;
	    %put NOTE:[PXL] ------------------------------------------------------------------------;
	    %put %str(ERR)OR:[PXL] &sysmacroname: alert: Dataset &inds. does not exist.;
	    %put NOTE:[PXL] ------------------------------------------------------------------------;
		%put ;
		%let l_error = 1;
		%goto macend;
	%end ;

    proc sql noprint;
        select count(*) into:nobs
        from download.&inds;
    quit;

    %if &nobs=0 %then %do ;
		%put ;
	    %put NOTE:[PXL] -----------------------------------------------------------------------;
	    %put %str(ERR)OR:[PXL] &sysmacroname: The input dataset &inds. has zero (0) observations.;
	    %put NOTE:[PXL] -----------------------------------------------------------------------;
		%put ;
		%let l_error = 1;
		%goto macend;
	%end ;

	* ---------------------------------------------------------------------;
    * Check if all required macro parameters were passed ;
    * ---------------------------------------------------------------------;

	%local _list_macvars_req _list_macvars_req_miss i _macvar ;
	%let _list_macvars_req = study siteid subjid cpevent colldate;
	%let _list_macvars_req_miss = ;
	%let i = 1 ;

	%do %while (%scan(&_list_macvars_req., &i, %str( )) ne %str()) ;
        %let _macvar = %scan(&_list_macvars_req., &i, %str( )) ;
        %if %bquote(&&&_macvar.) = %str() %then %do;
			%let _list_macvars_req_miss = &_list_macvars_req_miss. %left(&_macvar.) ;
			%let l_error = 1 ;
        %end ;
        %let i = %eval(&i. + 1);
    %end ;

	%if &l_error = 1 %then %do;
		%put ;
	    %put NOTE:[PXL] -----------------------------------------------------------------------;
	    %put %str(ERR)OR:[PXL] &sysmacroname: Rrequired macro parameters are missing - &_list_macvars_req_miss.;
	    %put NOTE:[PXL] -----------------------------------------------------------------------;
		%put ;
		%goto macend;
	%end ;

	* ---------------------------------------------------------------------;
    * Check if parameter COLLDATE is same as paramter VISITDT ;
    * ---------------------------------------------------------------------;
	
	data _null_ ;
		if compress(upcase("&colldate.")) = compress(upcase("&visitdt.")) then
			call symput('l_error','1');
	run;

	%if &l_error. = 1 %then %do;
		%put ;
	    %put NOTE:[PXL] -----------------------------------------------------------------------;
	    %put %str(ERR)OR:[PXL] &sysmacroname: Macro parameters COLLDATE and VISITDT cannot be same;
	    %put NOTE:[PXL] -----------------------------------------------------------------------;
		%put ;
		%goto macend;
	%end ;

	* ---------------------------------------------------------------------;
    * Parameter sanity checks ;
    * ---------------------------------------------------------------------;

	%if %upcase(&database_type.) = OC %then %do;

		data _null_ ;
			length var $200 ;
			do var = "&inds.","&study.","&siteid.","&subjid.","&cpevent.","&visitdt.","&egnd.","&colldate.","&egacttmf.","&egtpd.","&egcom.","&egintp.";
				if indexc(var,"/,") > 0 then call symput('l_error','1');
			end;
		run;

		%if &l_error. = 1 %then %do;
			%put ;
			%put NOTE:[PXL] -----------------------------------------------------------------------;
		    %put %str(ERR)OR:[PXL] &sysmacroname: No parameter can contain ',' and '/' for OC Study;
		    %put NOTE:[PXL] -----------------------------------------------------------------------;
			%put ;

			%goto macend;
		%end ;
	%end ;
	
	data _null_ ;
		length var $200 ;
		do var = "&inds.","&study.","&siteid.","&subjid.","&cpevent.","&visitdt.";
			if indexc(var,"/,") > 0 then call symput('l_error','1');
		end ;
	run;

	%if &l_error. = 1 %then %do;
		%put ;
		%put NOTE:[PXL] -----------------------------------------------------------------------;
	    %put %str(ERR)OR:[PXL] &sysmacroname: The following parameters cannot contain ',' and '/';
		%put %str(ERR)OR:[PXL]  - INDS STUDY SITEID SUBJID CPEVENT VISITDT ;
	    %put NOTE:[PXL] -----------------------------------------------------------------------;
		%put ;

		%goto macend;
	%end ;

	data _null_ ;
		
		if index("&egnd.","/") > 0 or index("&colldate.","/") > 0 or index("&egtpd.","/") > 0 
			or index("&egcom.","/") > 0 or index("&egacttmf.","/") > 0 or index("&egintp.","/") > 0 then do ;
			count = 0
				+ (index("&colldate.","/") > 0) + (missing(strip("&colldate.")))
				+ (index("&egacttmf.","/") > 0) + (missing(strip("&egacttmf.")))
				+ (index("&egtpd.","/") > 0)    + (missing(strip("&egtpd.")))  
				+ (index("&egcom.","/") > 0)    + (missing(strip("&egcom.")))
				+ (index("&egintp.","/") > 0)   + (missing(strip("&egintp.")))
				+ (index("&egnd.","/") > 0)     + (missing(strip("&egnd."))) ;
				
			if count < 5 then call symput('l_error','1');
		end ;
		
	run;

	%if &l_error. = 1 %then %do;
		%put ;
		%put NOTE:[PXL] -----------------------------------------------------------------------;
	    %put %str(ERR)OR:[PXL] &sysmacroname: All/None of the following parameters can contain GRPNAM/;
		%put %str(ERR)OR:[PXL]  - EGND COLLDATE EGACTTMF EGTPD EGINTP EGCOM;
	    %put NOTE:[PXL] -----------------------------------------------------------------------;
		%put ;

		%goto macend;
	%end ;

	data _null_ ;
		length var $200 ;
		do var = "&egnd.", "&colldate.", "&egtpd.", "&egcom.";
			if not missing(var) then do ;
				i=1;
				do while (strip(scan(var,i,",")) ne "") ;
					p1 = strip(scan(var,i,","));
					p2 = strip(scan(p1 ,2,"/"));
					if not missing(p2) then do ;
						p3 = countw(strip(compbl(p2))," ");
						if p3 ne 1 then call symput('l_error','1');
					end ;
					i = i + 1;
				end ;
			end ;
		end ;
	run;

	%if &l_error. = 1 %then %do;
	    %put NOTE:[PXL] -----------------------------------------------------------------------;
	    %put %str(ERR)OR:[PXL] &sysmacroname: The following parameters can specify only 1 variable per GRPNAM;
		%put %str(ERR)OR:[PXL]  - EGND COLLDATE EGTPD EGCOM;
	    %put NOTE:[PXL] -----------------------------------------------------------------------;
		%put ;

		%goto macend;
	%end ;

	* ---------------------------------------------------------------------;
    * Generate normalised list of macro parameters with {GRPNAM} for DATALABS ;
	* ---------------------------------------------------------------------;

	proc contents data = download.&inds. out = _edc_rawmeta noprint ;
	run ;

	%if %upcase(&database_type.) = DATALABS %then %do;
		
		* ---------------------------------------------------------------------;
	    * Store macro parameters in dataset, one row per GRPNAM per VARIABLE ;
		* ---------------------------------------------------------------------;

		data _edc_grpnam (keep = grpnam grpvar macvar varord);
			
			length grpnam $200 grpvar $200 macvar $200 grpitm $200 ;
			
			grpnam = '';
			grpvar = '';
			grpitm = '';
			macvar = '';
			varord = 0;
			
			%macro _split_grp_vars(var=);

			&var. = upcase(compbl(compress(strip("&&&var."),,'kw'))) ;

			if index(&var.,',') > 0 then do;
				i = 1 ;
				do while (scan(&var.,i,',') ne '') ;
					macvar = strip(upcase("&var."));
					grpitm = strip(scan(&var.,i,',')) ;

					grpnam = strip(scan(grpitm,1,'/')) ;

					j = 1 ;
					do while (strip(scan(strip(scan(grpitm,2,'/')),j,' ')) ne '');
						grpvar = strip(scan(strip(scan(grpitm,2,'/')),j,' ')) ;
						varord = i * 100 + j;
						j = j + 1 ;
						output ;
					end ;
					
					i = i + 1 ;
				end ;
			end ;
			else if index(&var.,'/') > 0 then do;
				macvar = strip(upcase("&var."));
				grpnam = strip(scan(&var.,1,'/')) ;
				
				j = 1 ;
				do while (strip(scan(strip(scan(&var.,2,'/')),j,' ')) ne '');
					grpvar = strip(scan(strip(scan(&var.,2,'/')),j,' ')) ;
					varord = j;
					j = j + 1 ;
					output ;
				end ;
				
				output ;
			end ;
			else if index(strip(compbl(&var.)),' ') > 0 then do;
				macvar = strip(upcase("&var."));
				grpnam = '' ;
				
				j = 1 ;
				do while (strip(scan(&var.,j,' ')) ne '');
					grpvar = strip(scan(&var.,j,' ')) ;
					varord = j;
					j = j + 1 ;
					output ;
				end ;
				
				output ;
			end ;
			else if not missing(&var.) then do;
				macvar = strip(upcase("&var."));
				grpnam = '' ;
				grpvar = strip(&var.);
				varord = 1;
				output ;
			end ;

			%mend _split_grp_vars;

			%_split_grp_vars (var = colldate);
			%_split_grp_vars (var = egacttmf);
			%_split_grp_vars (var = egtpd);
			%_split_grp_vars (var = egnd);
			%_split_grp_vars (var = egintp);
			%_split_grp_vars (var = egcom);

		run;

		data _edc_grpnam;
			set _edc_grpnam;
			if index(upcase(grpnam),"_T") > 0 then _s_t = 1 ;
			else if index(upcase(grpnam),"_S") > 0 then _s_t = 2 ;
			else _s_t = 3 ;
		run;

		* ---------------------------------------------------------------------;
	    * Check if invalid Variables names are passed ;
		* ---------------------------------------------------------------------;
		
		data _edc_allvars ;
			set _edc_grpnam end=eof;
			if not eof and not missing(grpvar) then output ;
			else do ;
				output ;
				do grpvar = "&study.","&siteid.","&subjid.","&cpevent.","&visitdt." ;
					output ;
				end ;
			end;
		run;
		
		%local _edc_invgrpnam;
		%let _edc_invgrpnam = ;
		proc sql noprint ;
			select grpvar into: _edc_invgrpnam separated by ' '
			from _edc_allvars
			where upcase(grpvar) not in (
				select upcase(name) from _edc_rawmeta
			);
		quit ;

		%if &_edc_invgrpnam. ne %then %do;
			%let l_error = 1 ;
			%put ;
		    %put NOTE:[PXL] -----------------------------------------------------------------------;
		    %put %str(ERR)OR:[PXL] &sysmacroname: The following variables were not found in download.&inds.;
			%put %str(ERR)OR:[PXL] > &_edc_invgrpnam. ;
		    %put NOTE:[PXL] -----------------------------------------------------------------------;
			%put ;

			%goto macend;
		%end ;
		
		* ---------------------------------------------------------------------;
	    * Check if the macro parameters passed to COLLDATE, EGACTTMF, EGTPD, EGND ;
		* had GRPNAM specified in the form of {GRPNAM} / VAR1 VAR2 VAR3 VARN ;
		* If not, skip _S and _T reconcilliation ;
		* ---------------------------------------------------------------------;
		
		%local grpnam_recon_needed;
		%let grpnam_recon_needed=;
		data _null_ ;
			set _edc_grpnam ;
			where not missing(grpnam);
			if _n_ = 1 then call symput('grpnam_recon_needed','1');
			stop;
		run;

		* ---------------------------------------------------------------------;
	    * Store list of unique variables per macro variable ;
		* ---------------------------------------------------------------------;
		
		%local egacttmfs colldates egtpds egnds egcoms egintps;
		%let egacttmfs=;
		%let colldates=;
		%let egtpds=;
		%let egnds=;
		%let egintps=;
		%let egcoms=;

		* Keep one dataset variable per macro variable ;
		* Preference given to variables listed under _T then _S and 
		* then the order in which it was specified by the user;

		proc sort data = _edc_grpnam out = _edc_macvars (keep = macvar grpvar varord _s_t) nodupkey ;
			by macvar grpvar _s_t varord;
		run ;		

		data _edc_macvars ;
			set _edc_macvars ;
			by macvar grpvar _s_t varord;
			if first.grpvar ;
		run ;

		* Sort the dataset variables as per priority mentioned above ;
		* and create macro variables in that order for use in COALESCE();

		proc sort data = _edc_macvars ;
			by macvar _s_t varord grpvar ;
		run ;

		data _edc_macvars ;
			set _edc_macvars ;
			by macvar _s_t varord grpvar;

			length grpvars $200 ;
			retain grpvars ;

			if first.macvar then grpvars = '';

			grpvars = strip(compbl(strip(grpvars) || ' ' || strip(grpvar))) ;

			if last.macvar then do;
				call symputx(compress(lowcase(strip(macvar)) || 's'), strip(grpvars));
				output ;
			end ;
		run;
		
		%put ;
		%put NOTE:[PXL] ----------------------------------------------------------;
	    %put NOTE:[PXL] Normalised unique list of variables passed to the macro:;
	    %put NOTE:[PXL] colldates = &colldates.;
		%put NOTE:[PXL] egacttmfs = &egacttmfs.;
		%put NOTE:[PXL] egintps = &egintps.;
		%put NOTE:[PXL] egtpds = &egtpds.;
		%put NOTE:[PXL] egnds = &egnds.;
		%put NOTE:[PXL] egcoms = &egcoms.;
		%put NOTE:[PXL] ----------------------------------------------------------;
		%put ;

		* ---------------------------------------------------------------------;
		* Macro variables EGINTP and EGACTTMF must have same number of variables;
		* ---------------------------------------------------------------------;
		
		%if %str(&egacttmfs.) ne %str() and %str(&egintps.) ne %str() %then %do;
			%if %sysfunc(countw("&egacttmfs.", ' ')) ne %sysfunc(countw("&egintps.", ' ')) %then %do;

				%let l_error = 1 ;
			    %put NOTE:[PXL] -----------------------------------------------------------------------;
			    %put %str(ERR)OR:[PXL] &sysmacroname: Macro variables EGINTP and EGACTTMF must have same number of variables;
			    %put NOTE:[PXL] -----------------------------------------------------------------------;
				%put ;

				%goto macend;
			%end;
		%end ;

	%end ;
	%else %if &database_type. = OC %then %do ;
		
		* ---------------------------------------------------------------------;
	    * Check if invalid Variables names are passed ;
		* ---------------------------------------------------------------------;

		data _edc_allvars ;
			length grpvar $200;			
			do grpvar = "&study.","&siteid.","&subjid.","&cpevent.","&visitdt.","&egnd.","&colldate.","&egacttmf.","&egtpd.","&egcom.","&egintp." ;
				output ;
			end ;
		run;
		
		%local _edc_invgrpnam;
		%let _edc_invgrpnam = ;

		proc sql noprint ;
			select grpvar into: _edc_invgrpnam separated by ' '
			from _edc_allvars
			where upcase(grpvar) not in (
				select upcase(name) from _edc_rawmeta
			);
		quit ;

		%if &_edc_invgrpnam. ne %then %do;
			%let l_error = 1 ;
		    %put %NOTE:[PXL] -----------------------------------------------------------------------;
		    %put %str(ERR)OR:[PXL] &sysmacroname: The following variables were not found in download.&inds.;
			%put %str(ERR)OR:[PXL] &_edc_invgrpnam. ;
		    %put NOTE:[PXL] -----------------------------------------------------------------------;
			%put ;

			%goto macend;
		%end ;

	%end ;
	
    * ---------------------------------------------------------------------;
    * Find the latest directory date in the DOWNLOAD directory ;
    * ---------------------------------------------------------------------;

    data _null_;
		call system("cd &path_dm/datasets/download");
    run;

    filename test pipe 'ls -la';

    data _edc_dir;
        length dirline $200;
        infile test recfm=v lrecl=200 truncover;

        input dirline $1-200;
        if substr(dirline,1,1) = 'd';
        datec = substr(dirline,59,8);
        if index(datec,'.') or datec = ' ' then delete;
        date = input(datec,?? yymmdd10.);
        if date = . then delete;
        format date date9.;
    run ;

    proc sort data = work._edc_dir ;
      by descending date ;
    run ;

    %local curdate prevdate ;

    %let curdate = ;
    %let prevdate = ;

    data _edc_dir (keep = date datec) ;
        set _edc_dir;
        if _n_ = 1 then do ;
			call symputx('curdate',datec) ;
			output;
		end ;
        else if _n_ = 2 then call symputx('prevdate',datec) ;
        else stop;
    run ;
	
	%put NOTE:[PXL] ----------------------------------------------------------;
    %put NOTE:[PXL] Current snapshot date (EDC/CRF) = &curdate. ;
    %put NOTE:[PXL] Previous snapshot date (EDC/CRF) = &prevdate. ;
	%put NOTE:[PXL] ----------------------------------------------------------;
	%put ;

    *** save the current date in the metadata folder ***;

    %if %sysfunc(exist(metadata.rec_ecg_meta)) %then %do;

        proc sort data = metadata.rec_ecg_meta ;
            by date;
        run;

        proc append base=metadata.rec_ecg_meta data=_edc_dir;
        run;

        proc sort data=metadata.rec_ecg_meta nodupkey;
            by date;
        run;

    %end;
    %else %do;

        data metadata.rec_ecg_meta ;
			set _edc_dir;
        run;

        data _edc_current;
            attrib STATUS1 length=$7 label='EDC Data State';
            set download.&inds;
            status1='New';
        run;

        %goto nooldnew;

    %end;
	
	* ---------------------------------------------------------------------;
    * Define the previous library to compare the data ;
	* ---------------------------------------------------------------------;

    %if &prevdate. ne %then %do;
        libname oldDir "&path_dm/datasets/download/&prevdate.";
    %end;
    %else %do;
        libname oldDir "&path_dm/datasets/download/draft";
    %end;

    %if %sysfunc(exist(olddir.&inds.)) %then %do;

        %if %upcase(&database_type.) = DATALABS %then %do;
            %let keyvar=SCRNID PATEVTKY PATFRMKY EVTORDER EVTFRMKY GRPNAM ROW;
        %end;
        %else %if %upcase(&database_type.) = OC %then %do;
            %let keyvar=SUBJID ACTEVENT DOCNUM QUALIFYV REPEATSN;
        %end;

        proc sort data=olddir.&inds. out=_edc_old;
            by &keyvar. ;
        run;

        proc sort data=download.&inds. out=_edc_current;
            by &keyvar. ;
        run;

        libname olddir clear;

        *** Create the STATUS variable ***;

		%if %upcase(&database_type.) = OC %then %do;

	        data  _edc_status (keep = &keyvar. status1);
	            attrib status1 length=$7 label='EDC Data State';
	            merge
		            _edc_old (in=old rename=(
		                %if %str(&cpevent.)  ne %str() %then %do; &cpevent.  = _old_&cpevent.  %end;
						%if %str(&colldate.) ne %str() %then %do; &colldate. = _old_&colldate. %end;
		                %if %str(&egacttmf.) ne %str() %then %do; &egacttmf. = _old_&egacttmf. %end;
						%if %str(&egintp.)   ne %str() %then %do; &egintp.   = _old_&egintp.   %end;
		                %if %str(&egtpd.)    ne %str() %then %do; &egtpd.    = _old_&egtpd.    %end;))
		            _edc_current (in=new) ;
	            by &keyvar. ;
	            if new;

				if old = 0 then do ;
					status1="New";
				end ;
	            else if old = 1 then do ;

					status1 = 'Old' ;

					%if %str(&cpevent.) ne %str() %then %do;
		                if _old_&cpevent. ne &cpevent. then status1 = "Changed";
		            %end;
					%if %str(&colldate.) ne %str() %then %do;
		                if _old_&colldate. ne &colldate. then status1 = "Changed";
		            %end;
		            %if %str(&egacttmf.) ne %str() %then %do;
		                if _old_&egacttmf. ne &egacttmf. then status1 = "Changed";
		            %end;
					%if %str(&egintp.) ne %str() %then %do;
		                *if _old_&egintp. ne &egintp. then status1 = "Changed";
		            %end;
		            %if %str(&egtpd.) ne %str() %then %do;
		                if _old_&egtpd. ne &egtpd. then status1 = "Changed";
		            %end;
				end ;
	            
	        run;

		%end ;
		%else %if %upcase(&database_type.) = DATALABS %then %do;
			
			proc datasets library = work memtype=data nolist;
				modify _edc_old ;

				%if %str(&cpevent.) ne %str() %then %do;
					rename &cpevent. = _old_&cpevent. ; 
				%end;

				%if %str(&colldates.) ne %str() %then %do;
					%let k = 1 ;
					%do %while (%scan(&colldates.,&k.,%str( )) ne %str());
						rename %scan(&colldates.,&k.,%str( )) = _old_%scan(&colldates.,&k.,%str( )) ;
						%let k = %eval(&k. + 1);
					%end;
				%end;

				%if %str(&egacttmfs.) ne %str() %then %do;
					%let k = 1 ;
					%do %while (%scan(&egacttmfs.,&k.,%str( )) ne %str());
						rename %scan(&egacttmfs.,&k.,%str( )) = _old_%scan(&egacttmfs.,&k.,%str( )) ;
						%let k = %eval(&k. + 1);
					%end;
				%end;

				%if %str(&egintps.) ne %str() %then %do;
					%let k = 1 ;
					%do %while (%scan(&egintps.,&k.,%str( )) ne %str());
						rename %scan(&egintps.,&k.,%str( )) = _old_%scan(&egintps.,&k.,%str( )) ;
						%let k = %eval(&k. + 1);
					%end;
				%end;

				%if %str(&egtpds.) ne %str() %then %do;
					%let k = 1 ;
					%do %while (%scan(&egtpds.,&k.,%str( )) ne %str());
						rename %scan(&egtpds.,&k.,%str( )) = _old_%scan(&egtpds.,&k.,%str( )) ;
						%let k = %eval(&k. + 1);
					%end;
				%end;
			run;
			quit ;

	        data  _edc_status (keep = &keyvar. status1);
	            attrib status1 length=$7 label='EDC Data State';
	            merge _edc_old (in=old) _edc_current (in=new) ;
	            by &keyvar. ;
	            if new;
				
				if old = 0 then do ;
					status1="New";
				end ;
	            else if old = 1 then do ;

					status1 = 'Old' ;

					%if %str(&cpevent.) ne %str() %then %do;
		                if _old_&cpevent. ne &cpevent. then status1="Changed";
		            %end;

					%if %str(&colldates.) ne %str() %then %do;
						%let k = 1 ;
						%do %while (%scan(&colldates.,&k,%str( )) ne %str());
							if _old_%scan(&colldates.,&k,%str( )) ne %scan(&colldates.,&k,%str( )) then status1="Changed";
							%let k = %eval(&k. + 1);
						%end;
					%end;

					%if %str(&egacttmfs.) ne %str() %then %do;
						%let k = 1 ;
						%do %while (%scan(&egacttmfs.,&k,%str( )) ne %str());
							if _old_%scan(&egacttmfs.,&k,%str( )) ne %scan(&egacttmfs.,&k,%str( )) then status1="Changed";
							%let k = %eval(&k. + 1);
						%end;
					%end;

					%if %str(&egintps.) ne %str() %then %do;
						%let k = 1 ;
						%do %while (%scan(&egintps.,&k,%str( )) ne %str());
							*if _old_%scan(&egintps.,&k,%str( )) ne %scan(&egintps.,&k,%str( )) then status1="Changed";
							%let k = %eval(&k. + 1);
						%end;
					%end;

					%if %str(&egtpds.) ne %str() %then %do;
						%let k = 1 ;
						%do %while (%scan(&egtpds.,&k,%str( )) ne %str());
							if _old_%scan(&egtpds.,&k,%str( )) ne %scan(&egtpds.,&k,%str( )) then status1="Changed";
							%let k = %eval(&k. + 1);
						%end;
					%end;
				end ;       
	            
	        run;
		%end ;

        data _edc_current;
            merge _edc_status _edc_current;
            by &keyvar. ;
        run;

    %end;
    %else %do;

        data _edc_current;
            attrib status1 length=$7 label='EDC Data State';
            set download.&inds;
            status1='New';
        run;

    %end;

    %nooldnew:;
	
	%if %upcase(&database_type.) = DATALABS %then %do;

		* ---------------------------------------------------------------------;
	    * RECONCILE _S and _T records for DATALABS ;
		* ---------------------------------------------------------------------;
		
		%if &grpnam_recon_needed. = %then %goto nogrprec;;
		
		* ---------------------------------------------------------------------;
	    * It is possible to have COLLDATE passed without {GRPNAM} and the other;
		* two parameters EGACTTMF and EGTPD with {GRPNAM};
		* Any combination is possible with above three parameters ;
		* In such a case, add the variables passed without {GRPNAM} against ;
		* each unique value of {GRPNAM} ;
		* ---------------------------------------------------------------------;

		proc sort data = _edc_grpnam (keep = grpnam) out = _edc_grpnam_unq nodupkey ;
			by grpnam ;
			where not missing(grpnam);
		run ;

		proc sql noprint ;
			create table _edc_grpnam_all as
			select coalesce(a.grpnam,b.grpnam) as grpnam, a.grpvar, a.macvar
			from work._edc_grpnam a
			left join work._edc_grpnam_unq b
			on a.grpnam = '' ;
		quit ;

		* ---------------------------------------------------------------------;
	    * Only unique values are required ;
		* ---------------------------------------------------------------------;

		proc sort data = _edc_grpnam_all (keep = grpnam grpvar) nodupkey ;
			by grpnam grpvar ;
		run ;

		* ---------------------------------------------------------------------;
	    * Create list of all variables per {GRPNAM} ;
		* ---------------------------------------------------------------------;

		data _edc_grpnam_all ;
			set _edc_grpnam_all ;
			by grpnam ;
			length grpvars $200 ;
			retain grpvars ;

			if first.grpnam then grpvars = '';

			grpvars = compbl(strip(grpvars) || ' ' || strip(grpvar)) ;

			if last.grpnam then output ;
		run;

		%local grpnam_n;
		%let grpnam_n = 0;

		data _null_ ;
			set _edc_grpnam_all end=eof;

			call symput('grpnam_' || strip(put(_N_,best.)), strip(grpnam));
			call symput('grpvars_' || strip(put(_N_,best.)), strip(grpvars));

			if eof then call symput('grpnam_n', strip(put(_N_,best.)));
		run ;

		* ---------------------------------------------------------------------;
	    * Split _edc_current dataset for each GRPNAM keeping only respective vars ;
		* ---------------------------------------------------------------------;
		
		%local k _grpnam_t_hasset _edc_obscount _edc_subcount;
		
		proc contents data = _edc_current (keep = status1) out = _edc_obscount (keep = nobs) noprint ;
		run ;

		%let _edc_obscount = 0;
		data _null_;
			set _edc_obscount;
			call symputx('_edc_obscount',nobs);
		run;
		
		%do k = 1 %to &grpnam_n. ;
			
			data _edc_current_&k. (keep = &study. &siteid. &subjid. &cpevent. &visitdt.
										  grpnam patid patfrmky status1 &&grpvars_&k..);
				set _edc_current ;
				where upcase(strip(grpnam)) = upcase(strip("&&grpnam_&k..")) ;
			run;

			proc contents data = _edc_current_&k. (keep = status1) out = _edc_subcount (keep = nobs) noprint ;
			run ;
			
			%let _edc_subcount = 0;
			data _null_;
				set _edc_subcount;
				call symputx('_edc_subcount',nobs);
			run;
			
			%if &_edc_subcount. = 0 %then %do ;
				%put NOTE:[PXL] ----------------------------------------------------------;
			    %put %str(WARN)ING:[PXL] GRPNAM = %left(%trim(&&grpnam_&k..)) not found in EDC dataaset ;
				%put NOTE:[PXL] ----------------------------------------------------------;
				%put ;
			%end;

			%let _edc_obscount = %eval(&_edc_obscount. - &_edc_subcount.) ;
			
		%end ;
		
		%if &_edc_obscount. > 0 %then %do ;
			%put NOTE:[PXL] ----------------------------------------------------------;
		    %put %str(WARN)ING:[PXL] %left(%trim(&_edc_obscount.)) records dropped as corresponding GRPNAM values were not passed to the macro ;
			%put NOTE:[PXL] ----------------------------------------------------------;
			%put ;
		%end;
		
		* ---------------------------------------------------------------------;
		* Append all _S datasets ;
		* Append all _T datasets ;
		* Append all datasets that do not contain _S and _T in GRPNAM ;
		* ---------------------------------------------------------------------;

		data _edc_empty ;
			stop;
		run ;
		
		data _edc_current_s ;
			set _edc_empty 
				%do k = 1 %to &grpnam_n. ;
					%if (%index(&&grpnam_&k.. ,%str(_S)) > 0) %then %do ;
						_edc_current_&k.
					%end ;
				%end ;
			;
		run ;

		data _edc_current_t ;
			set _edc_empty 
				%do k = 1 %to &grpnam_n. ;
					%if (%index(&&grpnam_&k.. ,%str(_T)) > 0) %then %do ;
						_edc_current_&k.
					%end ;
				%end ;
			;
		run ;

		data _edc_current_other ;
			set _edc_empty 
				%do k = 1 %to &grpnam_n. ;
					%if (%index(&&grpnam_&k.. ,%str(_S)) = 0 and %index(&&grpnam_&k.. ,%str(_T)) = 0) %then %do ;
						_edc_current_&k.
					%end ;
				%end ;
			;
		run ;

		* ---------------------------------------------------------------------;
	    * The _S dataset should be present as a bare minimum ;
		* If _OTHER has observations then set the dataset with 0 OBS to the _S dataset ;
		* ---------------------------------------------------------------------;

		proc contents data = _edc_current_other out = _edc_current_other_meta (keep = nobs) noprint ;
		run ;

		%local _edc_grpnam_oth ;
		%let _edc_grpnam_oth=0;

		data _null_ ;
			set _edc_current_other_meta;
			if _n_ = 1 then call symputx ('_edc_grpnam_oth',nobs);
		run;

		%if &_edc_grpnam_oth. > 0 %then %do ;
			
			%put ;
			%put NOTE:[PXL] ----------------------------------------------------------;
		    %put %str(WARN)ING:[PXL] %left(%trim(&_edc_grpnam_oth.)) records dropped as corresponding GRPNAM values do not contain _S or _T ;
			%put NOTE:[PXL] ----------------------------------------------------------;
			%put ;

			data _edc_current_s ;
				set _edc_current_s _edc_current_other (where = (0));
			run ;

		%end ;

		* ---------------------------------------------------------------------;
	    * _edc_current_new = MERGE _S and _T datasets if _T has metadata/data ;
		* Else _edc_current_NEW = SET _S dataset ;
		* ---------------------------------------------------------------------;

		%let _grpnam_t_hasset = 0;

		%do k = 1 %to &grpnam_n. ;
			%if (%index(&&grpnam_&k.. ,%str(_T)) > 0) %then %do ;
				%let _grpnam_t_hasset = 1;
			%end;
		%end ;

		%if &_grpnam_t_hasset. = 1 %then %do ;
			
			proc sort data = _edc_current_s ;
				by patid patfrmky ;
			run ;

			proc sort data = _edc_current_t ;
				by patid patfrmky ;
			run ;

			data _edc_current ;
				merge _edc_current_s _edc_current_t ;
				by patid patfrmky ;
			run ;

		%end ;
		%else %do ;
			
			proc sort data = _edc_current_s out = _edc_current ;
				by patid patfrmky ;
			run ;

		%end ;

		* ---------------------------------------------------------------------;
	    * If multiple variables were passed to macro variable then combine ;
		* Do not consider EGACTTMF and EGINTP here since they would be triplicates;
		* ---------------------------------------------------------------------;
		
		%macro _edc_coalesce_vars (var=);

			%if &&&var.s. ne %then %do ;

				proc contents data = _edc_current (keep = &&&var.s.) out = _edc_egmeta noprint;
	    		run;
		
				%local coalesce_vars _var_type;
	    		
			    data _null_;
			        set _edc_egmeta;
					if _n_ = 1 ;
					call symput('coalesce_vars', tranwrd(strip(compbl("&&&var.s.")),' ',','));
			        call symput('_var_type', strip(put(type,best.)));
				run ;

				data _edc_current (drop = &&&var.s.);
					set _edc_current ;
					%if &_var_type. = 1 %then %do ;
						_&var._cm = coalesce(&coalesce_vars.) ;
					%end;
					%else %if &_var_type. = 2 %then %do ;
						_&var._cm = coalescec(&coalesce_vars.) ;
					%end ;

					/*
					%local itm;
					%let itm = 1;
					%do %while (%scan(&&&var.s.,&itm.,%str( )) ne %str()) ;
						
						if not missing(%scan(&&&var.s.,&itm.,%str( ))) then do ;
							_&var._cm = %scan(&&&var.s.,&itm.,%str( )) ;
							drop %scan(&&&var.s.,&itm.,%str( )) ;
						end ;
						

						%let itm = %eval(&itm. + 1) ;
					%end ;
					*/
					
				run;

				%let &var. = _&var._cm;

			%end ;

		%mend _edc_coalesce_vars;

		%_edc_coalesce_vars(var = colldate);
		%_edc_coalesce_vars(var = egnd);
		%_edc_coalesce_vars(var = egtpd);
		%_edc_coalesce_vars(var = egcom);
	
		%if &egacttmfs. ne %then %do ;

			* ---------------------------------------------------------------------;
			* CASE WHEN GRPNAM RECONCILIATION WAS REQUIRED ;
		    * If multiple EGACTTMF variables were passed then split records per time;
			* as they are triplicate values. 
			* New time variable is __TIME_TR ;
			* ---------------------------------------------------------------------;

			data _edc_current (drop = &egacttmfs. _non_missing_vars);
				set _edc_current ;

				_non_missing_vars = 0 ;

				%let itm = 1;
				%do %while (%scan(&egacttmfs.,&itm.,%str( )) ne %str()) ;
					
					if not missing(%scan(&egacttmfs.,&itm.,%str( ))) then do ;
						_time_tr = %scan(&egacttmfs.,&itm.,%str( )) ;

						%if &egintps. ne %then %do ;
							_intp_tr = %scan(&egintps.,&itm.,%str( )) ;
						%end ;

						_non_missing_vars = _non_missing_vars + 1 ;
						output ;
					end ;					

					%let itm = %eval(&itm. + 1) ;
				%end ;

				if _non_missing_vars = 0 then do;
					call missing(_time_tr) ;
					call missing(_intp_tr) ;
					output ;
				end ;
			run;

			%let egacttmf=_time_tr;
			%let egintp=_intp_tr;

		%end ;

		* ---------------------------------------------------------------------;
	    * End of GRPNAM Reconcilliation ;
		* ---------------------------------------------------------------------;

		%nogrprec:;
		
		%if %index(%str(&egacttmf.),%str( )) > 0 %then %do ;

			* ---------------------------------------------------------------------;
			* CASE WHEN GRPNAM RECONCILIATION WAS NOT REQUIRED ;
		    * If multiple EGACTTMF variables were passed then split records per time;
			* as they are triplicate values. 
			* New time variable is __TIME ;
			* ---------------------------------------------------------------------;

			data _edc_current (drop = &egacttmf. _non_missing_vars);
				set _edc_current ;

				_non_missing_vars = 0;

				%let itm = 1;
				%do %while (%scan(&egacttmf.,&itm.,%str( )) ne %str()) ;
					
					if not missing(%scan(&egacttmf.,&itm.,%str( ))) then do ;
						__time = %scan(&egacttmf.,&itm.,%str( )) ;
						%if %index(%str(&egintp.),%str( )) > 0 %then %do ;
							__intp = %scan(&egintp.,&itm.,%str( )) ;
						%end;
						_non_missing_vars = _non_missing_vars + 1;
						output ;	
					end ;

					%let itm = %eval(&itm. + 1) ;
				%end ;

				if _non_missing_vars = 0 then do;
					call missing(__time) ;
					call missing(__intp) ;
					output ;
				end ;
			run;

			%let egacttmf=__time;
			%let egintp=__intp;

		%end ;
		
    %end;
	
	* ---------------------------------------------------------------------;
    * Check for variable types ;
	* ---------------------------------------------------------------------;
	
	proc contents data = _edc_current out = _edc_egmeta noprint;
    run;
	
	%local egdttype egtmtype visdttyp egintptyp cpetype;
    
    %let egdttype=;
	%let egtmtype=;
	%let visdttyp=;
	%let egintptyp=;
	%let cpetype=;
    
    data _null_;
        set _edc_egmeta;

        if      upcase(name) = upcase(strip("&colldate.")) then call symputx ("egdttype",  type);
		else if upcase(name) = upcase(strip("&visitdt."))  then call symputx ("visdttyp",  type);
		else if upcase(name) = upcase(strip("&egacttmf.")) then call symputx ("egtmtype",  type);
		else if upcase(name) = upcase(strip("&egintp."))   then call symputx ("egintptyp", type);
		else if upcase(name) = upcase(strip("&cpevent."))  then call symputx ("cpetype",   type);
    run;

    data _edc_ecg (drop = __:);
        attrib  
			STUDY     length = $15  label = 'Clinical Study'
            SITEID    length = $4   label = 'Center Identifier Within Study'
            SUBJID    length = $8   label = 'Subject ID'
            CPEVENT   length = $20  label = 'CPE Name'
            EGND      length = $20  label = 'Not Done'
            VISITDT   length = $15  label = 'Visit Date'
            COLLDATE  length = $15  label = 'Collection Date'
            EGACTTMF  length = $15  label = 'ECG Actual Time Char'
            EGTPD     length = $30  label = 'Planned Time Post Dose'
			EGCOM     length = $200 label = 'ECG Comments'
			EGINTP    length = $50  label = 'Normal or Abnormal Status'
		;
        set _edc_current (
			keep = &study. &siteid. &subjid. &cpevent. &colldate. &visitdt. &egacttmf. &egnd. &egtpd. &egcom. &egintp. status1
            rename =(&study. = __&study. &siteid. = __&siteid. &subjid. = __&subjid.
            %if &cpevent.  ne %then %do; &cpevent.  = __&cpevent.  %end;
            %if &colldate. ne %then %do; &colldate. = __&colldate. %end;
            %if &visitdt.  ne %then %do; &visitdt.  = __&visitdt.  %end;
			%if &egacttmf. ne %then %do; &egacttmf. = __&egacttmf. %end;
            %if &egtpd.    ne %then %do; &egtpd.    = __&egtpd.    %end;
			%if &egnd.     ne %then %do; &egnd.     = __&egnd.     %end;
            %if &egcom.    ne %then %do; &egcom.    = __&egcom.    %end;
			%if &egintp.   ne %then %do; &egintp.   = __&egintp.   %end;
		));

		study    = upcase(__&study.);
		siteid   = upcase(__&siteid.);
		subjid   = compress(__&subjid.,'-|_ ');

		* Derive CPEVENT;
		
		%if &cpetype. = 1 %then %do;
			cpevent = strip(put(__&cpevent.,best.));
		%end;
		%else %if &cpetype. = 2 %then %do;
			cpevent = upcase(strip(__&cpevent.));
		%end;
		
		* Derive EGND ;

		%if &egnd. = %then %do;
			egnd = '';
		%end ;
        %else %do;
			egnd = strip(__&egnd.) ;
            if egnd = '1' then egnd = 'NOT DONE';
            else if egnd = '2' then egnd = 'DONE';
        %end;

		* Derive EGCOM ;

        %if &egcom. = %then %do;
			egcom = '' ;
		%end;
		%else %do;
			egcom = strip(__&egcom.);
		%end;

		* Derive EGTPD ;

        %if &egtpd = %then %do;
			egtpd = '';
		%end;
		%else %do;
			egtpd = upcase(__&egtpd.);
		%end;
		
		* Derive EGACTTMF ;

        %if &egacttmf= %then %do;
			egacttmf = '';
		%end;
        %else %do;
            %if &egtmtype=1 %then %do;
				egacttmf = strip(put(__&egacttmf.,time8.));
			%end;
            %else %if &egtmtype=2 %then %do;

				* Strip out AM from time;
				* Replace '-' with ':' ;
                egacttmf = tranwrd(tranwrd(upcase(__&egacttmf.),'AM',''),'-',':');

				* Before stripping out PM from time, check if HH is in 24 hour clock. If not, add 12 hours to time ;
				if (index(egacttmf,'PM')>0) then do ;
					__hh = input(scan(egacttmf,1,':'),best.);
					if 0 <= __hh <= 11 then do;
						__newtime = tranwrd(put(__hh + 12,2.) || substr(egacttmf,index(egacttmf,':')),'PM','');
						put 'NOTE:[PXL] Adding 12 hours and removing PM from time value EGACTTMF = ' egacttmf ' New value = ' __newtime ;
						egacttmf = __newtime ;
					end ;
				end ;

				* Make partial time missing ;
				* If length of character time is less than 4 then set to missing ;
                if index(upcase(egacttmf),'X')>0 or length(egacttmf) in (1 2 3) then egacttmf='';

				if length(egacttmf) = 5 then egacttmf = compress(egacttmf || ":00");

				* If character time is present in the form of 1445 or 0359 then insert ':' in between ;
				if compress(egacttmf,,'kd')=compress(egacttmf) and length(egacttmf) = 4 then 
					egacttmf = compress(substr(egacttmf,1,2) || ":" || substr(egacttmf,3,2) || ':00');

				* If character time is present in the form of 144501 or 035922 then insert ':' in between ;
				if compress(egacttmf,,'kd')=compress(egacttmf) and length(egacttmf) = 6 then 
					egacttmf = compress(substr(egacttmf,1,2) || ":" || substr(egacttmf,3,2) || ":" || substr(egacttmf,5,2));

            %end;
		%end;

        * Derive COLLDATE ;

        %if &egdttype=1 %then %do;
			colldate = strip(put(__&colldate.,date9.));
		%end;
        %else %if &egdttype=2 %then %do;

	        __&colldate.=upcase(compress(__&colldate.,'-_'));
	        if indexc(__&colldate.,'ABCDEFGHIJKLMNOPQRSUVWXYZ')>0 and (substr(__&colldate.,1,2) not in ('UN','XX')
                and substr(__&colldate.,3,3) not in ('UNK','XXX') ) and length(__&colldate.)>=9 then do;
                colldaten = input(__&colldate.,date9.);
                if colldaten ne . then colldate=strip(put(colldaten,date9.));
	        end;
	     	else do;
	            if length(__&colldate.)=8 then
                    colldate22 =
                    compress(substr(__&colldate.,1,4)||'-'||substr(__&colldate.,5,2)||'-'||substr(__&colldate.,7,2));
	            colldate22n=input(colldate22,yymmdd10.);
	            colldate=strip(put(colldate22n,date9.));
	         end;
		%end;

        if length(colldate)<9 then colldate='';

        * Derive VISITDT ;

        %if &visitdt = %then %do;
			visitdt='';
		%end;
		%else %do;

            %if &visdttyp=1 %then %do;
				visitdt = strip(put(__&visitdt.,date9.));
			%end;
            %else %if &visdttyp=2 %then %do;

	            __&visitdt.=upcase(compress(__&visitdt.,'-_'));
	            if indexc(__&visitdt.,'ABCDEFGHIJKLMNOPQRSUVWXYZ')>0 and (substr(__&visitdt.,1,2) not in ('UN','XX')
					and substr(__&visitdt.,3,3) not in ('UNK','XXX') ) and length(__&visitdt.)>=9 then do;
	                	visitdtn = input(__&visitdt.,date9.);
						if visitdtn ne . then visitdt=strip(put(visitdtn,date9.));
	            end;
	     		else do;
	                if length(__&visitdt.)=8 then
	                visitdt22 = compress(substr(__&visitdt.,1,4)||'-'||substr(__&visitdt.,5,2)||'-'||substr(__&visitdt.,7,2));
	                visitdt22n=input(visitdt22,yymmdd10.);
	                visitdt=strip(put(visitdt22n,date9.));
				end;
			%end;

			if length(visitdt)<9 then visitdt='';
		%end;

		* DERIVE EGINTP ;
		%if &egintp. = %then %do ;
			egintp = "" ;
		%end ;
		%else %if &egintptyp. = 1 %then %do ;
			if __&egintp. = 1 then egintp = "NORMAL";
			else if __&egintp. = 2 then egintp = "ABNORMAL, NOT CLINICALLY SIGNIFICANT";
			else if __&egintp. = 3 then egintp = "ABNORMAL, CLINICALLY SIGNIFICANT";
			else if __&egintp. = 4 then egintp = "UNEVALUABLE";
		%end ;
		%else %if &egintptyp. = 2 %then %do ;
			if __&egintp. = "1" then egintp = "NORMAL";
			else if __&egintp. = "2" then egintp = "ABNORMAL, NOT CLINICALLY SIGNIFICANT";
			else if __&egintp. = "3" then egintp = "ABNORMAL, CLINICALLY SIGNIFICANT";
			else if __&egintp. = "4" then egintp = "UNEVALUABLE";
			else egintp = upcase(strip(__&egintp.));
		%end ;

    run;

	%pfesacq_sae_recon_dem_transform();

	%if %sysfunc(exist(outdir.dm_crf)) %then %do;
		
		proc sort data = _edc_ecg;
			by study subjid;
		run;

		data outdir.dm_crf (drop = _:);
			set outdir.dm_crf (rename = (study = _study subjid = _subjid sex = _sex dob = _dob));
			attrib
				STUDY  length = $15  label = 'Clinical Study'
	            SUBJID length = $8   label = 'Subject ID'
				SEX    length = $20  label = 'Gender Code'
				DOB    length = $15  label = 'Date of Birth';
			
			study = _study;
			subjid = _subjid;
			sex = _sex;
			dob = _dob;
		run;

		proc sort data = outdir.dm_crf;
			by study subjid;
		run;

		data _edc_ecg;
			merge _edc_ecg (in=a) outdir.dm_crf;
			by study subjid;
			if a;
		run;
	%end;
	%else %do;
		data _edc_ecg;
			set _edc_ecg;
			attrib SEX  length = $20 label = 'Gender Code'
				   DOB  length = $15 label = 'Date of Birth';
			sex='';
			dob='';
		run;
	%end;

	* ---------------------------------------------------------------------;
	* Map Visits to the EDC equivalent if provided in study specs ;
	* Map Timepoints to the value specified in study specs ;
	* ---------------------------------------------------------------------;
	
	%if %sysfunc(fileexist("&path_dm./documents/ecg_recon/current/%lowcase(&protocol.) ecg recon specs.xls")) %then %do;

		proc import datafile = "&path_dm./documents/ecg_recon/current/%lowcase(&protocol.) ecg recon specs.xls"
		            out      = _edc_tptmap
					dbms     = xls replace;
					sheet    = "Expected Timepoints";
					getnames = no;
					startrow = 2;
		run;

		%local atype ctype;
		%let atype=;
		%let ctype=;

		proc contents data = _edc_tptmap (keep = a c) out = _edc_tptmap_meta noprint;
		run;

		data _null_;
			set _edc_tptmap_meta (keep = name type);
			if upcase(name) = "A" then call symputx('atype',type);
			else if upcase(name) = "C" then call symputx('ctype',type);
		run;

		data _edc_tptmap (keep = source target );
			set _edc_tptmap ;
			where not (missing(a) and missing(c));

			length source target $200;
			
			%if &atype. = 1 %then %do;
				source = strip(put(a,best.));
			%end;
			%else %if &atype. = 2 %then %do;
				source = upcase(strip(a));
			%end;

			%if &ctype. = 1 %then %do;
				target = strip(put(c,best.));
			%end;
			%else %if &ctype. = 2 %then %do;
				target = upcase(strip(c));
			%end;
			
		run;

		proc sort data = _edc_tptmap nodupkey ;
			by source;
		run;

		proc sql noprint;
			create table _edc_ecgtpt as
			select a.*, b.target
			from work._edc_ecg a
			left join work._edc_tptmap b
			on compress(upcase(strip(a.egtpd)),,'kw') = compress(upcase(strip(b.source)),,'kw') ;
		quit ;

		data _edc_ecg ;
			set _edc_ecgtpt ;
			
			if not missing(target) then egtpd = strip(upcase(target));
			drop target;
		run;

	%end;

	* ---------------------------------------------------------------------;
	* Write final dataset to permanent library;
	* ---------------------------------------------------------------------;

	%local _final_vars;
	%let _final_vars = STUDY SITEID SUBJID CPEVENT VISITDT COLLDATE EGACTTMF EGTPD EGND EGCOM EGINTP SEX DOB STATUS1;

    proc sort data = _edc_ecg (keep = &_final_vars.);
		by study siteid subjid cpevent colldate egacttmf;
    run;
	
    data outdir.eg_crf;
		retain &_final_vars. ;
		set _edc_ecg;
		keep &_final_vars.;
    run;

	* ---------------------------------------------------------------------;
	* House-keeping;
	* ---------------------------------------------------------------------;

    proc datasets library=work memtype=data nolist;
		delete _edc_:;
    quit;
    
    %macend:;
    %put ;
    %put NOTE:[PXL] ----------------------------------------------------------;
    %put NOTE:[PXL] &sysmacroname: End of Submacro;
    %put NOTE:[PXL] ----------------------------------------------------------;
    %put ;

%mend pfesacq_ecg_recon_edc_transform;