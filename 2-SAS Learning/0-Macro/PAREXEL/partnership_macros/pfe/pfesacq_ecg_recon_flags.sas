/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Allwyn Dsouza $LastChangedBy: dsouzaal $
  Creation Date:         29NOV2015     $LastChangedDate: 2016-06-10 06:24:47 -0400 (Fri, 10 Jun 2016) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfesacq_ecg_recon_flags.sas $
 
  Files Created:         None
 
  Program Purpose:       ECG Reconciliation of the EDC and vendor ECG dataset and
                         save the reconciliation records in ECGRECON dataset.
 
						 Note: Part of program: pfesacq_ecg_recon 

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:      NA

  Macro Output:          ECGRECON dataset is created in the "/../dm/listings/current" Folder


-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2296 $
  
-----------------------------------------------------------------------------*/

%macro pfesacq_ecg_recon_flags;
	
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_ECG_RECON_FLAGS: Start of Submacro;
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put ;

	* ---------------------------------------------------;
	* If source datasets do not exist then exit ;
	* ---------------------------------------------------;
	
	%if not %sysfunc(exist(outdir.eg_crf)) or not %sysfunc(exist(outdir.egedata)) %then %goto macdne;

	%macro _remove_matched_keys(dsin=,key=,dsref=) ;
		
		proc sql noprint ;
			create table _&dsin. as
			select distinct a.*
			from 	work.&dsin. a
			where	&key. not in (select &key. from &dsref.) ;
		quit ;

		proc datasets lib = work nolist ;
			delete &dsin. ;
			change _&dsin. = &dsin. ;
		quit ;

	%mend _remove_matched_keys;

	* ---------------------------------------------------;
	* Read source EDC and EDATA datasets into WORK ;
	* Create unique KEY variable = _N_ to control process;
	* ---------------------------------------------------;
	
	data edc ;
		set outdir.eg_crf ;
		key = _n_ ;
	run ;

	data edata ;
		set outdir.egedata ;
		VEND_KEY = _n_ ;
		rename study = VEND_STUDY
			siteid = VEND_SITEID
			subjid = VEND_SUBJID
			cpevent = VEND_CPEVENT
			egtpd = VEND_EGTPD
			colldate = VEND_COLLDATE
			egacttmf = VEND_EGACTTMF
			sex = VEND_SEX
			dob = VEND_DOB
			egintp = VEND_INTP
			egcom = VEND_EGCOM;
	run ;

	* ---------------------------------------------------;
	* Merge by all keys and keep perfect match ;
	* ---------------------------------------------------;

	proc sql noprint ;

		create table recon1 as
		select distinct a.*, b.*,
				"Ok" as flag
		from	work.edc a,
		        work.edata b		
		where a.subjid = b.vend_subjid 
			and a.cpevent = b.vend_cpevent
			%if %str(&egtpd.) ne %str() %then %do ;
				and a.egtpd = b.vend_egtpd 
			%end ;
			and a.colldate = b.vend_colldate 
			%if %str(&egacttmf.) ne %str() %then %do ;
				and input(a.egacttmf,time5.) = input(b.vend_egacttmf,time5.)
			%end ;
			;
	quit ;

	%_remove_matched_keys(dsin=edc,key=key,dsref=recon1) ;
	%_remove_matched_keys(dsin=edata,key=vend_key,dsref=recon1) ;
	
	* ---------------------------------------------------;
	* Merge where SUBJID, VISIT, TPT and DATE match but TIME does not;
	* Triplicate time within date will give cartesian product ;
	* Hence create key in EDC and VEND datasets to merge on ;
	* ---------------------------------------------------;

	%local _edc_key _vend_key _lastvar;
	%let _edc_key = subjid cpevent ;
	%if %str(&egtpd.) ne %str() %then %do ;
		%let _edc_key = &_edc_key. egtpd ;
	%end ;
	%let _edc_key = &_edc_key. colldate;
	%if %str(&egacttmf.) ne %str() %then %do ;
		%let _edc_key = &_edc_key. egacttmf;
	%end ;
	
	%let _vend_key = vend_subjid vend_cpevent ;
	%if &egtpd. ne %then %do ;
		%let _vend_key = &_vend_key vend_egtpd;
	%end ;
	%let _vend_key = &_vend_key vend_colldate;
	%if %str(&egacttmf.) ne %str() %then %do ;
		%let _vend_key = &_vend_key vend_egacttmf ;
	%end ;
	
	%let _lastvar = colldate ;	

	proc sort data = edc ;
		by &_edc_key. ;
	run;

	data edc ;
		set edc ;
		by &_edc_key. ;
		retain _tmp_key 0 ;
		if first.&_lastvar. then _tmp_key = 0 ;
		_tmp_key = _tmp_key + 1 ;
	run;

	proc sort data = edata ;
		by &_vend_key. ;
	run;

	data edata ;
		set edata ;
		by &_vend_key. ;
		retain _tmp_key2 0 ;
		if first.vend_&_lastvar. then _tmp_key2 = 0 ;
		_tmp_key2 = _tmp_key2 + 1 ;
	run;

	proc sql noprint ;
		create table recon2_1 as
		select distinct a.*, b.*,
				"Date/Time mismatch" as flag
		from	work.edc a
		full join work.edata b
		on a._tmp_key = b._tmp_key2
		where a.subjid = b.vend_subjid 
			and a.cpevent = b.vend_cpevent 
			%if &egtpd. ne %then %do ;
				and a.egtpd = b.vend_egtpd 
			%end ;
			and a.colldate = b.vend_colldate
			;
	quit ;

	%_remove_matched_keys(dsin=edc,key=key,dsref=recon2_1) ;
	%_remove_matched_keys(dsin=edata,key=vend_key,dsref=recon2_1) ;

	data edc (drop = _tmp_key);
		set edc ;
	run ;

	data edata (drop = _tmp_key2) ;
		set edata ;
	run ;

	* ---------------------------------------------------;
	* Merge where SUBJID, VISIT, TPT, TIME but DATE does not;
	* Triplicate time within date will give cartesian product ;
	* Hence create key in EDC and VEND datasets to merge on ;
	* ---------------------------------------------------;

	proc sql noprint ;
		create table recon2_2 as
		select distinct a.*, b.*,
				"Date/Time mismatch" as flag
		from	work.edc a, 
				work.edata b
		where a.subjid = b.vend_subjid 
			and a.cpevent = b.vend_cpevent 
			%if %str(&egtpd.) ne %str() %then %do ;
				and a.egtpd = b.vend_egtpd 
			%end ;
			%if %str(&egacttmf.) ne %str() %then %do ;
				and input(a.egacttmf,time5.) = input(b.vend_egacttmf,time5.)
			%end ;
			;
	quit ;

	%_remove_matched_keys(dsin=edc,key=key,dsref=recon2_2) ;
	%_remove_matched_keys(dsin=edata,key=vend_key,dsref=recon2_2) ;

	* ---------------------------------------------------;
	* Merge where SUBJID, VISIT, TPT but both DATE and TIME do not ;
	* Triplicate time within date will give cartesian product ;
	* Hence create key in EDC and VEND datasets to merge on ;
	* ---------------------------------------------------;

	%if &egtpd. ne %then %do ;
		%let _lastvar = egtpd ; 
	%end ;
	%else %do ;
		%let _lastvar = cpevent ;
	%end ;
	
	proc sort data = edc ;
		by &_edc_key. ;
	run;

	data edc ;
		set edc ;
		by &_edc_key. ;
		retain _tmp_key 0 ;
		if first.&_lastvar. then _tmp_key = 0 ;
		_tmp_key = _tmp_key + 1 ;
	run;

	proc sort data = edata ;
		by &_vend_key. ;
	run;

	data edata ;
		set edata ;
		by &_vend_key. ;
		retain _tmp_key2 0 ;
		if first.vend_&_lastvar. then _tmp_key2 = 0 ;
		_tmp_key2 = _tmp_key2 + 1 ;
	run;
	
	proc sql noprint ;
		create table recon2_3 as
		select distinct a.*, b.*,
				"Date/Time mismatch" as flag
		from	work.edc a
		full join work.edata b
		on a._tmp_key = b._tmp_key2
		where a.subjid = b.vend_subjid 
			and a.cpevent = b.vend_cpevent 
			%if %str(&egtpd.) ne %str() %then %do ;
				and a.egtpd = b.vend_egtpd 
			%end ;
			;
	quit ;

	%_remove_matched_keys(dsin=edc,key=key,dsref=recon2_3) ;
	%_remove_matched_keys(dsin=edata,key=vend_key,dsref=recon2_3) ;

	data edc (drop = _tmp_key);
		set edc ;
	run ;

	data edata (drop = _tmp_key2) ;
		set edata ;
	run ;
	
	* ---------------------------------------------------;
	* SUBJID, CPEVENT and DATE-TIME match but TPT does not;
	* ---------------------------------------------------;

	proc sql noprint ;
	
		create table recon3 as
		select distinct a.*, b.*,
				"Timepoint mismatch" as flag
		from	work.edc a,
		        work.edata b
		where a.subjid = b.vend_subjid 
			and a.cpevent = b.vend_cpevent
			and a.colldate = b.vend_colldate
			%if %str(&egacttmf.) ne %str() %then %do ;
				and input(a.egacttmf,time5.) = input(b.vend_egacttmf,time5.)
			%end ;
		;
	quit ;

	%_remove_matched_keys(dsin=edc,key=key,dsref=recon3) ;
	%_remove_matched_keys(dsin=edata,key=vend_key,dsref=recon3) ;

	* ---------------------------------------------------;
	* SUBJID, TPT, DATE, TIME match but VISIT does not;
	* ---------------------------------------------------;

	proc sql noprint ;
	
		create table recon4 as
		select distinct a.*, b.*,
				"Visit mismatch" as flag
		from	work.edc a,
		        work.edata b
		where a.subjid = b.vend_subjid 
			%if %str(&egtpd.) ne %str() %then %do ;
				and a.egtpd = b.vend_egtpd 
			%end ;
			and a.colldate = b.vend_colldate
			%if %str(&egacttmf.) ne %str() %then %do ;
				and input(a.egacttmf,time5.) = input(b.vend_egacttmf,time5.)
			%end ;
		;
	quit ;

	%_remove_matched_keys(dsin=edc,key=key,dsref=recon4) ;
	%_remove_matched_keys(dsin=edata,key=vend_key,dsref=recon4) ;

	* ---------------------------------------------------;
	* Drop merged records from source datasets;
	* Re-merge using one key less than the previous step;
	* ---------------------------------------------------;
	
	proc sql noprint ;

		create table recon5 as
		select distinct a.*,
				"CRF/eCRF only" as flag
		from work.edc a ;
	
		create table recon6 as
		select distinct a.*,
				"Vendor Only" as flag
		from work.edata a ;
	quit ;

	* ---------------------------------------------------;
	* Append all matched datasets ;
	* ---------------------------------------------------;

	data ecgrecon ;
		length flag $40;
		set recon1 recon2_1 recon2_2 recon2_3 recon3 recon4 recon5 recon6 ;
	run ;  

	data ecgrecon ;
		set ecgrecon;
		if missing(study) then study = upcase(strip("&protocol")) ;
		if missing(subjid) then subjid = vend_subjid ;
		siteid = substr(strip(subjid),1,4);

		if egnd = "NOT DONE" and flag = "CRF/eCRF only" then flag = "Ok" ;
		
		length status $20 ;
		if status1 = "New" or status2 = "New" then status = "New" ;
		else if status1 = "Changed" or status2 = "Changed" then status = "Changed" ;
		else if status1 = "Old" or status2 = "Old" then status = "Old" ;
		else if missing(status1) then status = status2 ;
		else if missing(status2) then status = status1 ;

		format colldtn date9. ;
		if not missing(colldate) then colldtn = input(colldate,date9.) ;

	run ;

	* ---------------------------------------------------;
	* Sort and write to permanent library ;
	* ---------------------------------------------------;

	proc sort data = ecgrecon out = outdir.ecgrecon ;
		by subjid colldtn cpevent egtpd colldate egacttmf ;
	run ;

	* ---------------------------------------------------;
	* House keeping ;
	* ---------------------------------------------------;

	proc datasets lib = work memtype = data nolist;
		delete recon1 recon2: recon3 recon4 recon5 recon6 ecgrecon edc edata;
	quit;

	%goto macend;

	%macdne:;
	%let l_error = 1 ;
	%put ;
    %put NOTE:[PXL] --------------------------------------------------------------------------;
    %put %str(ERR)OR:[PXL] PFESACQ_ECG_RECON_FLAGS: ALERT: Dataset EG_CRF or EGEDATA does not exist.;
    %put NOTE:[PXL] --------------------------------------------------------------------------;
	%put ;

    %macend:;

    %put ;
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_ECG_RECON_FLAGS: End of Submacro;
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_ecg_recon_flags;