/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Shiva Bhimreddy, $LastChangedBy:  $
  Creation Date:         25APR2016                       $LastChangedDate:  $
 
  Program Location/Name: $HeadURL: $
 
  Files Created:         None
 
  Program Purpose:       PK Reconciliation of the raw PK dataset into SACQ format.

						 Note: Part of program: pfesacq_pk_recon 

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 


  Macro Output:  PK_CRF Dataset is created in the "/../dm/listings/current" Folder


-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev:  $
  
-----------------------------------------------------------------------------*/


*** Call the Macro that converts the raw Adverse Event EDC dataset into the SACQ format ***;

%macro pfesacq_pk_recon_edc_transform();


    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_PK_RECON_EDC_TRANSOFRM: Start of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;


	%if %sysfunc(exist(download.&inds)) %then %do;

	proc sql noprint;
		select count(*) into:nobs
		from download.&inds;
	quit;

	%if &nobs=0 %then %goto macerr;

	**********************************************************************;
	* Step 1: Find the latest directory date in the DOWNLOAD directory   *;
	**********************************************************************;
	
	data _null_;
		call system("cd &path_dm/datasets/download");
	run;

	filename test pipe 'ls -la';

	data test;
	    length dirline $200;
	    infile test recfm=v lrecl=200 truncover;

	    input dirline $1-200;
	    if substr(dirline,1,1) = 'd';
	    datec = substr(dirline,59,8);
	    if index(datec,'.') or datec = ' ' then delete;
	    date = input(datec,?? yymmdd10.);
	    if date = . then delete;
	    format date date9.;
		count=1;
	run ;

	proc sort data = work.test ;
	  by descending date ;
	run ;
	
	%local curdate prevdate prevdate1;
	
	
	%let curdate = ;
	%let prevdate = ;
	%let prevdate1 = ;

	data _null_ ;
	  set test ;
	  if _n_ = 1 then call symput('curdate',left(trim(datec))) ;
	  else if _n_ = 2 then call symput('prevdate',left(trim(datec))) ;
	  else stop ;
	run ;

	data _null_ ;
	  set test ;
	  if _n_ = 2 then call symput('prevdate1',left(trim(datec))) ;
	run ;

	%put prevdate1 = &prevdate1;

	*** save the current date in the metadata folder ***;

	proc sort data = test;
	    by count date;
	run;

	data test;
		set test;
	    by count date;
		if last.count;
		keep date datec;
	run;

	%if %sysfunc(exist(metadata.rec_pk_meta)) %then %do;

	proc sort data = metadata.rec_pk_meta out=test;
	    by date;
	run;

	data _null_;
		set test;
	    by date;
		if last.date then call symput('prevdate',left(trim(datec)));
	run;

	proc append base=metadata.rec_pk_meta data=test;
	run;

	proc sort data=metadata.rec_pk_meta nodupkey;
		by date;
	run;
													 %end;

	%else %do;

	proc append base=metadata.rec_pk_meta data=test;
	run;

	proc sort data=metadata.rec_pk_meta nodupkey;
		by date;
	run;

	data current;
		attrib STATUS1 length=$7 label='EDC Data State';
		set download.&inds;
		status1='New';
	run;

	%goto ventrans;

		  %end;

	
	%put curdate = &curdate;
	%put prevdate = &prevdate;

	%if &curdate=&prevdate %then %do;
									%let prevdate  = &prevdate1.;
									%put prevdate1 = &prevdate1;
								%end;


	*** Define the previous library to compare the data ***;

	%if %str(&prevdate) ne %str() %then %do;
		libname oldDir "&path_dm1/datasets/download/&prevdate";
	%end;
    %else %do;
        libname oldDir "&path_dm1/datasets/download/draft";
    %end;

	%if %sysfunc(exist(oldDir.&inds)) %then %do;


	%if "&database_type."  = "DATALABS" %then %do; %let keyvar=SCRNID PATEVTKY PATFRMKY EVTORDER EVTFRMKY GRPNAM ROW; %end;
	%if "&database_type."  = "OC"       %then %do; %let keyvar=DOCNUM ACTEVENT SUBJID REPEATSN;                       %end;




	proc sort data=olddir.&inds out=old;
		by &keyvar;
	run;

	proc sort data=download.&inds out=current;
		by &keyvar;
	run;

	libname olddir clear;


	*** Create the STATUS variable ***;

%if "&database_type."  = "OC"       %then %do;
	data status;
		attrib STATUS1 length=$7 label='EDC Data State';
        merge old     (in=old rename=(%if &colldate= %then %do;%end; %else %do; &colldate=olddate  %end;
									  %if &testtime= %then %do;%end; %else %do; &testtime=oldtime  %end;
									  %if &pksmpid=  %then %do;%end; %else %do; &pksmpid=oldsmpid  %end;
									  %if &pktpt=    %then %do;%end; %else %do; &pktpt=oldpktpt    %end;
									  %if &visit=    %then %do;%end; %else %do; &visit=oldvisit    %end;))
              current (in=new rename=(%if &colldate= %then %do;%end; %else %do; &colldate=newdate  %end;
									  %if &testtime= %then %do;%end; %else %do; &testtime=newtime  %end;
									  %if &pksmpid=  %then %do;%end; %else %do; &pksmpid=newsmpid  %end;
									  %if &pktpt=    %then %do;%end; %else %do; &pktpt=newpktpt    %end;
									  %if &visit=    %then %do;%end; %else %do; &visit=newvisit    %end;));

		by &keyvar;

		if old=1 and new=1 then status1="Old";

        %if &colldate= %then %do;%end; %else %do; if      old=1 and new=1 and olddate  ne newdate  then status1="Changed";%end;
        %if &testtime= %then %do;%end; %else %do; else if old=1 and new=1 and oldtime  ne newtime  then status1="Changed";%end;
        %if &pksmpid=  %then %do;%end; %else %do; else if old=1 and new=1 and oldsmpid ne newsmpid then status1="Changed";%end;
        %if &pktpt=    %then %do;%end; %else %do; else if old=1 and new=1 and oldpktpt ne newpktpt then status1="Changed";%end;
        %if &visit=    %then %do;%end; %else %do; else if old=1 and new=1 and oldvisit ne newvisit then status1="Changed";%end;

		if old=0 and new=1 then status1="New";

		if new;

		keep &keyvar status1;

	run;

	%end; *** end of OC  ***;

%if "&database_type."  = "DATALABS"       %then %do;
	data status;
		attrib STATUS1 length=$7 label='EDC Data State';
        merge old     (in=old rename=(%if &colldate= %then %do;%end; %else %do; &colldate=olddate  %end;
									  %if &testtime= %then %do;%end; %else %do; &testtime=oldtime  %end;
/*									  %if &pksmpid=  %then %do;%end; %else %do; &pksmpid=oldsmpid  %end;*/
/*									  %if &pktpt=    %then %do;%end; %else %do; &pktpt=oldpktpt    %end;))*/
									  %if &visit=    %then %do;%end; %else %do; &visit=oldvisit    %end;))
              current (in=new rename=(%if &colldate= %then %do;%end; %else %do; &colldate=newdate  %end;
									  %if &testtime= %then %do;%end; %else %do; &testtime=newtime  %end;
/*									  %if &pksmpid=  %then %do;%end; %else %do; &pksmpid=newsmpid  %end;*/
/*									  %if &pktpt=    %then %do;%end; %else %do; &pktpt=newpktpt    %end;));*/
									  %if &visit=    %then %do;%end; %else %do; &visit=newvisit    %end;));

		by &keyvar;

		if old=1 and new=1 then status1="Old";

        %if &colldate= %then %do;%end; %else %do; if      old=1 and new=1 and olddate  ne newdate  then status1="Changed";%end;
        %if &testtime= %then %do;%end; %else %do; else if old=1 and new=1 and oldtime  ne newtime  then status1="Changed";%end;
/*        %if &pksmpid=  %then %do;%end; %else %do; else if old=1 and new=1 and oldsmpid ne newsmpid then status1="Changed";%end;*/
/*        %if &pktpt=    %then %do;%end; %else %do; else if old=1 and new=1 and oldpktpt ne newpktpt then status1="Changed";%end;*/
        %if &visit=    %then %do;%end; %else %do; else if old=1 and new=1 and oldvisit ne newvisit then status1="Changed";%end;

		if old=0 and new=1 then status1="New";

		if new;

		keep &keyvar status1;

	run;

	%end; *** end of DATALABS  ***;


	data current;
        merge STATUS current;
		by &keyvar;
	run;

										  %end;

	%else %do;

			data current;
				attrib STATUS1 length=$7 label='EDC Data State';
				set download.&inds;
				status1='New';
			run;

		  %end;


	%ventrans:;

	*** Read the input demography dataset and Create variables as per the sACQ Specs***;

	data pk1;
		set download.&inds(rename=(&colldate=colldate1));
	run;

	proc contents data=pk1 noprint out=pkcont;
	run;

	data _null_;
		set pkcont;
		where upcase(name)='COLLDATE1';
		if type ne . then typec = strip(put(type,best.));
		call symput ("pkdttype", typec);
	run;

	%if &testtime = %then %do;%end; %else %do;

	data pk1;
		set download.&inds(rename=(&testtime=testtime1));
	run;

	proc contents data=pk1 noprint out=pkcont;
	run;

	data _null_;
		set pkcont;
		where upcase(name)='TESTTIME1';
		if type ne . then typec = strip(put(type,best.));
		call symput ("pktmtype", typec);
	run;
	%end;

	proc sql noprint;
		select count(*) into:visexist
		from pkcont
		where upcase(name)='VISIT';
		select count(*) into:colldateexist
		from pkcont
		where upcase(name)='COLLDATE';
		select count(*) into:pknd2ex
		from pkcont
		where upcase(name)='PKSMND2';
		select count(*) into:pknd3ex
		from pkcont
		where upcase(name)='PKSMND3';
	quit;

	%if &visitdt = %then %do;;%end; %else %do; 

			data pk2;
				set download.&inds (rename=(&visitdt=visitdt1));
			run;

			proc contents data=pk2 out=pkcont2 noprint;
			run;

			data _null_;
				set pkcont2;
				where upcase(name)='VISITDT1';
				if type ne . then typec = strip(put(type,best.));
				call symput ("visdttyp", typec);
			run;

										  %end;

data current;
	set current;
	%if &colldateexist = 1 and &visitdt=colldate %then %do; visitdt1=colldate;  %end;
	%if &colldateexist = 1 %then %do; rename colldate=colldate2; %end;
run;

data _edc_current;
	set current;
run;




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

			%_split_grp_vars (var = pnotdone);
			%_split_grp_vars (var = pktpt);
			%_split_grp_vars (var = pksmpid);

		run;

		data _edc_grpnam;
			set _edc_grpnam;
			if index(upcase(grpnam),"_T") > 0 then _s_t = 1 ;
			else if index(upcase(grpnam),"_S") > 0 then _s_t = 2 ;
			else _s_t = 3 ;
		run;

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
		
		%local pnotdones pktpts pksmpids;

		%let pnotdones=;
		%let pktpts=;
		%let pksmpids=;


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
		%put NOTE:[PXL] pnotdones = &pnotdones.;
		%put NOTE:[PXL] pktpts    = &pktpts.;
		%put NOTE:[PXL] pksmpids  = &pksmpids.;
		%put NOTE:[PXL] ----------------------------------------------------------;
		%put ;



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
			
			data _edc_current_&k. (keep = &study. &siteid. &subjid. &visit. &visitdt. &colldate. &testtime. &invcom.
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

		%_edc_coalesce_vars(var = pnotdone);
		%_edc_coalesce_vars(var = pktpt);
		%_edc_coalesce_vars(var = pksmpid);


		* ---------------------------------------------------------------------;
	    * End of GRPNAM Reconcilliation ;
		* ---------------------------------------------------------------------;

		%nogrprec:;

	%end ;   *** end of datalabs processing ***;



	data pk;

		attrib  STUDY     length = $200. label = 'Clinical Study'
				SITEID    length = $200. label = 'Center Identifier Within Study'
				SUBJID    length = $200. label = 'Subject ID'
				VISIT     length = $200. label = 'Visit'
				VISITDT   length = $200 label = 'Visit Date'
			/*	DCMNAME   length = $50  label = 'Form Name'*/
				PNOTDONE  length = $200. label = 'Sample not done indicator'
				PKTPT     length = $200. label = 'Time Point'
				COLLDATE  length = $200. label = 'Collection Date'
				TESTTIME  length = $200. label = 'Collection Time'
				PKSMPID   length = $200. label = 'Unique PK sample id'
				INVCOM    length = $200. label = 'Investigator Comment';

		set _edc_current (%if &visexist = 1 %then %do; drop=visit %end;
							rename=(&study=study1 &subjid=subjid1 /*&cpevent=cpevent1*/ /*%if &colldateexist = 1 %then %do; colldate=colldate1 %end;*/
									%if &siteid  = %then %do;%end; %else %do; &siteid=siteid1     %end;
									%if &visit   = %then %do;%end; %else %do; &visit=visit1       %end;
									%if &testtime= %then %do;%end; %else %do; &testtime=testtime1 %end;
									%if &pksmpid = %then %do;%end; %else %do; &pksmpid=__&pksmpid.   %end;
%if %upcase(&database_type.) = DATALABS %then %do;
												%if &pnotdone= %then %do;%end; %else %do; &pnotdone=__&pnotdone. %end;
											  %end;
/*									%if &dcmname = %then %do;%end; %else %do; &dcmname=dcmname1   %end;*/
									%if &colldate= %then %do;%end; %else %do; &colldate=colldate1 %end;
									%if &visitdt = %then %do;%end; %else %do; %if &colldateexist = 1 and &visitdt=colldate %then %do; %end;%else %do;&visitdt=visitdt1  %end;%end;
									%if &pktpt   = %then %do;%end; %else %do; &pktpt=__&pktpt.    %end;
									%if &invcom  = %then %do;%end; %else %do; &invcom  =invcom11  %end;
                                      ));



		study    = upcase(study1);
		subjid   = compress(subjid1,'-|_ ');

		%if &siteid  = %then %do; siteid   = ''; %end; %else %do; siteid   = upcase(siteid1); %end;
		%if &visit   = %then %do; visit    = ''; %end; %else %do; visit    = upcase(strip(visit1)); %end;
		%if &pksmpid = %then %do; pksmpid  = ''; %end; %else %do; pksmpid  = strip(__&pksmpid.);if pksmpid='.' then pksmpid='';%end;
		%if &invcom  = %then %do; invcom   = ''; %end; %else %do; invcom   = invcom11;  %end;
		%if &pktpt   = %then %do; pktpt    = ''; %end; %else %do; pktpt    = upcase(strip(__&pktpt.));  %end;
/*		%if &dcmname = %then %do; dcmname  = ''; %end; %else %do; dcmname  = strip(dcmname1);  %end;*/


		%if &pnotdone= %then %do; pnotdone = ''; %end; %else %do;
																
																%if %upcase(&database_type.) = DATALABS %then %do;pnotdone=strip(__&pnotdone.);%end;
																%if %upcase(&database_type.) = OC %then %do;pnotdone=upcase(compress(catx('',&pnotdone)));;%end;
																if pnotdone='1' then pnotdone='NOT DONE';
																if pnotdone='2' then pnotdone='DONE';
																if pnotdone='NOTDONE' then pnotdone='NOT DONE';
															 %end;



		%if &testtime= %then %do; testtime = ''; %end; 
		%else %do; 
				%if       &pktmtype=1 %then %do;testtime = strip(put(testtime1,time5.));%end;
				%if       &pktmtype=2 %then %do;
												testtime2=testtime1;
												testtime1=compress(upcase(testtime1),'AMPM');
												testtime = tranwrd(testtime1,'-',':');
												if index(testtime2,'PM')>0 then testtime=strip(put(input(testtime1,time5.)+(12*60*60),time5.));
												if index(upcase(testtime),'X')>0 or length(testtime) in (1 2 3) then testtime='';
											%end;
			 %end;
		if length(testtime)=3 then testtime=compress('0'||testtime);
		if length(testtime)=4 then testtime=compress(substr(testtime,1,2)||':'||substr(testtime,3,2) );

		*** Collection Date ***;

		%if       &pkdttype=1 %then %do;colldate = strip(put(colldate1,date9.));%end;
		%else %if &pkdttype=2 %then %do;

							colldate1=upcase(compress(colldate1,'-_'));
							if indexc(colldate1,'ABCDEFGHIJKLMNOPQRSUVWXYZ')>0 and (substr(colldate1,1,2) not in ('UN','XX') and substr(colldate1,3,3) not in ('UNK','XXX') ) and length(colldate1)>=9 then do;
										colldaten = input(colldate1,date9.);
										if colldaten ne . then colldate=strip(put(colldaten,date9.));
																						                                                                                               end;
                             else do;
								if length(colldate1)=8 then colldate22 = compress(substr(colldate1,1,4)||'-'||substr(colldate1,5,2)||'-'||substr(colldate1,7,2));
								colldate22n=input(colldate22,yymmdd10.);
								colldate=strip(put(colldate22n,date9.));
							 end;
								   %end;
												        

		if length(colldate)<9 then colldate='';

		*** Visit Date ***;

		%if &visitdt = %then %do;visitdt='';%end; %else %do; 


			%if       &visdttyp=1 %then %do;visitdt = strip(put(visitdt1,date9.));%end;
			%else %if &visdttyp=2 %then %do;

							visitdt1=upcase(compress(visitdt1,'-_'));
							if indexc(visitdt1,'ABCDEFGHIJKLMNOPQRSUVWXYZ')>0 and (substr(visitdt1,1,2) not in ('UN','XX') and substr(visitdt1,3,3) not in ('UNK','XXX') ) and length(visitdt1)>=9 then do;
										visitdtn = input(visitdt1,date9.);
										if visitdtn ne . then visitdt=strip(put(visitdtn,date9.));
																						                                                                                               end;
                             else do;
								if length(visitdt1)=8 then visitdt22 = compress(substr(visitdt1,1,4)||'-'||substr(visitdt1,5,2)||'-'||substr(visitdt1,7,2));
								visitdt22n=input(visitdt22,yymmdd10.);
								visitdt=strip(put(visitdt22n,date9.));

							 end;
								   %end;
												        

			if length(visitdt)<9 then visitdt='';
											%end;

	run;


	proc sort data=pk;
		by study siteid subjid visit colldate testtime;
	run;


	*** Randomization Number ***;

	%if %sysfunc(exist(download.&randds))=0 and %sysfunc(exist(random.&randds))=0  %then %do;   *** if no rand dataset exists in both libraries ***;

							data pk;
								length randnum $200.;
								set pk; 
								randnum='';
								label randnum= 'Randomization Number';
							run;

		  %end;

		%if %sysfunc(exist(download.&randds)) %then %do;
						proc sql noprint;
							select count(*) into:nobsrd
							from download.&randds;
						quit;

						%if &nobsrd=0 %then %do;
												%put %str(WARN)ING:[PXL] --------------------------------------------------------------------------------------------;
												%put %str(WARN)ING:[PXL] PFESACQ_PK_RECON_EDC_TRANSFORM: The randomization dataset &randds has zero (0) observations.;
												%put %str(WARN)ING:[PXL] --------------------------------------------------------------------------------------------;

												data pk;
													set pk; 
													length randnum $200.;
													label randnum= 'Randomization Number';
													randnum = '';
												run;

											%end;

						%else %do;
							data rnd1;
								set download.&randds(rename=(&randsubj=subjid111 &randnum=randnum111));
							run;

							proc contents data=rnd1 noprint out=rndcont;
							run;

							data _null_;
								set rndcont;
								where upcase(name)=upcase("randnum111");
								typec=strip(put(type,best.));
								call symput ("rnumtype", typec);
							run;

							data rand;
									attrib  RANDNUM  length = $200. label = 'Randomization Number'
									        SUBJID   length = $200. label = 'Subject ID';
								set rnd1;

								%if &rnumtype=2 %then %do;randnum  = randnum111;%end;

								%if &rnumtype=1 %then %do;randnum  = strip(put(randnum111,best.));%end;

								subjid = compress(subjid111,'-|_ ');
								keep subjid randnum;
							run;

							proc sort data=rand nodupkey;
								by subjid;
							run;

							proc sort data=pk;
								by subjid;
							run;

							data pk;
								merge pk(in=a) rand; 
								by subjid;
								if a;
							run;
							  %end;
		                                            %end; *** end of rand dataset processing in the download library ***;


		 %if %sysfunc(exist(random.&randds)) %then %do;
					proc sql noprint;
						select count(*) into:nobsrd
						from random.&randds;
					quit;

					%if &nobsrd=0 %then %do;
											%put %str(WARN)ING:[PXL] --------------------------------------------------------------------------------------------;
											%put %str(WARN)ING:[PXL] PFESACQ_SAE_RECON_AE_TRANSFORM: The randomization dataset &randds has zero (0) observations.;
											%put %str(WARN)ING:[PXL] --------------------------------------------------------------------------------------------;

												data pk;
													set pk; 
													length randnum $200.;
													label randnum= 'Randomization Number';
													randnum = '';
												run;

									    %end;

					%else %do;

							data rnd1;
								set random.&randds(rename=(&randsubj=subjid111 &randnum=randnum111));
							run;

							proc contents data=rnd1 noprint out=rndcont;
							run;

							data _null_;
								set rndcont;
								where upcase(name)=upcase("randnum111");
								typec=strip(put(type,best.));
								call symput ("rnumtype", typec);
							run;

							data rand;
									attrib  RANDNUM  length = $200. label = 'Randomization Number'
									        SUBJID   length = $200. label = 'Subject ID';
								set rnd1;

								%if &rnumtype=2 %then %do;randnum  = randnum111;%end;

								%if &rnumtype=1 %then %do;randnum  = strip(put(randnum111,best.));%end;

								subjid = compress(subjid111,'-|_ ');
								keep subjid randnum;
							run;

							proc sort data=rand nodupkey;
								by subjid;
							run;

							proc sort data=pk;
								by subjid;
							run;

							data pk;
								merge pk(in=a) rand; 
								by subjid;
								if a;
							run;
					%end;


			  										  %end;   *** end of rand dataset processing in the random library ***;




	%let create_dated_dir = Y ;
	%mu_create_dated_dir(type=listings) ;



	*** Modify the VISIT variable as per the specs to match with the vendor visits ***;

	proc import datafile = "&path_dm/documents/pk_recon/%lowcase(&protocol.) pk visit schedule.xls"
	            out      = protvis (rename=(a=visit b=visit11))
				dbms     = xls replace;
				sheet    = "Expected Visits";
				getnames = no;
				startrow = 2;
	run;

	data protvis;
		set protvis;
		visit=upcase(visit);
		visit=compress(strip(visit),,'kw');
		visit11=upcase(compress(strip(visit11),,'kw'));
	run;

	proc sort data=protvis nodupkey;
		by visit;
	run;

	proc sort data=pk;
		by visit;
	run;

	data pk;
		format visit $200.;
		merge pk(in=a) protvis(in=b);
		by visit;
		if a;
		if visit11 ne '' then visit=visit11;
	run;


	*** Modify the PKTPT variable as per the specs to match with the vendor time points ***;

	proc import datafile = "&path_dm/documents/pk_recon/%lowcase(&protocol.) pk visit schedule.xls"
	            out      = prottpt (rename=(b=pktpt11))
				dbms     = xls replace;
				sheet    = "Timepoints";
				mixed    = yes;
				getnames = no;
				startrow = 2;
	run;

	data prottpt;
		set prottpt;
		pktpt=strip(a);
		pktpt=upcase(pktpt);
		pktpt=compress(strip(pktpt),,'kw');
		pktpt11=upcase(compress(strip(pktpt11),,'kw'));
	run;

	proc sort data=prottpt nodupkey;
		by pktpt;
	run;

	proc sort data=pk;
		by pktpt;
	run;

	data pk;
		merge pk(in=pk) prottpt(in=b);
		by pktpt;
		if pk;
		if pktpt11 ne '' then pktpt=pktpt11;
	run;


	*libname outdir "&path_listings./current";
	*libname unblind "/unblinded/pfizr&pxl_code./dm/listings/current";
	libname unblind "&path_listings./current";


	proc sort data=pk;
		by study siteid subjid visit colldate testtime;
	run;

	data unblind.pk_crf;
		set pk;
		keep study siteid subjid visitdt visit /*dcmname*/ pktpt pnotdone pksmpid colldate testtime invcom status1 randnum;
	run;

	proc datasets library=work nolist;
		delete status current test pk pk1 pk2 pkcont pkcont2 old rand rnd1 prottpt protvis rndcont _edc_:;
	run;
	quit;

	%end;

	%else %do;
    			%put %str(ERR)OR:[PXL]------------------------------------------------------------------------;
    			%put %str(ERR)OR:[PXL] PFESACQ_PK_RECON_EDC_TRANSOFRM: alert: Dataset &inds does not exist.;
    			%put %str(ERR)OR:[PXL]------------------------------------------------------------------------;
		  %end;


	%goto macend;
	%macerr:;
	%put %str(ERR)OR:[PXL] -------------------------------------------------------------------------------------;
	%put %str(ERR)OR:[PXL] PFESACQ_PK_RECON_EDC_TRANSOFRM: The input dataset &inds has zero (0) observations.;
	%put %str(ERR)OR:[PXL] -------------------------------------------------------------------------------------;



    %macend:;
    %put ;
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_PK_RECON_EDC_TRANSOFRM: End of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_pk_recon_edc_transform;






