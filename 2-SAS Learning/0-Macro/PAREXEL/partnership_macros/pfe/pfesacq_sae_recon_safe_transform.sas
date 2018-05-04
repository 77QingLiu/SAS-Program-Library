/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX
  Example Call:          Note: Part of program: pfesacq_sae_recon 
               
                         Call from parent submacro pfesacq_map_scrf_process_ds.sas:
                         %pfesacq_sae_recon_safe_transform(infile=,startrow=,outdir=,outds=);

-------------------------------------------------------------------------------
 
  Author:                Shiva Bhimreddy, $LastChangedBy: bhimres $
  Creation Date:         05MAY2015                       $LastChangedDate: 2016-06-06 12:49:04 -0400 (Mon, 06 Jun 2016) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfesacq_sae_recon_safe_transform.sas $
 
  Files Created:         None
 
  Program Purpose:       Map raw safety database Excel files and transform them into
						 standard structure as per the Recon specs
 
                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:


  Macro Dependencies:    Note: Part of program: pfesacq_sae_recon 
					     Important: Please save an XLS version of the CSV file to use this macro.

                         This is a submacro dependant on calling parent macro: 
                         pfesacq_sae_recon.sas

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2325 $
  
-----------------------------------------------------------------------------*/

%macro pfesacq_sae_recon_safe_transform();
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_SAE_RECON_SAFE_TRANSFORM: Start of Submacro;
    %put NOTE:[PXL] PFESACQ_SAE_RECON_SAFE_TRANSFORM: imputept=&imputept;
    %put ---------------------------------------------------------------------;
    %put ;


libname outdir "&path_listings./current";
%let infile = %str(&path_dm./documents/sae_recon/current/%lowcase(&protocol.)_safety_listing.xls);

	*** Import the Input Excel File ***;

	proc import datafile = "&infile."
				out      = safety1
				dbms     = xls replace;
				startrow = 9;
				getnames = no ;
				sheet    = "Full Case Listing";
	run;


*** Read the input adverse dataset and Create variables as per the sACQ Specs***;

	data demo;

		attrib  STUDY   length = $200 label = 'Clinical Study'
				SUBJID  length = $200 label = 'Subject ID'
				SEX     length = $200 label = 'Gender Code'
				DOB     length = $200 label = 'Date of Birth';

		set safety1;

		study  = upcase(g);

		%if &imputept=6 %then %do;
			if index(h,'|')>0 then subjid = scan(h,2,'-|');
			else subjid = compress(h,'-|_ ');
			if substr(h,1,1)='|' then subjid = scan(h,1,'|');
			if length(strip(subjid))=4 then subjid=compress('00'||subjid);
			if length(strip(subjid))=5 then subjid=compress('0'||subjid);
			if length(strip(subjid))=8 then subjid=compress('0'||substr(subjid,4,5));
							  %end;
		%else %do;
				subjid=compress(h,'-|_ ');
			  %end;

		sex    = k;

		*** Derive DOB ***;
		brstday =scan(i,1,'-');
		brstmon1=scan(i,2,'-');
		brstyr  =scan(i,3,'-');

		if brstmon1='JAN' then brstmon='01';
		if brstmon1='FEB' then brstmon='02';
		if brstmon1='MAR' then brstmon='03';
		if brstmon1='APR' then brstmon='04';
		if brstmon1='MAY' then brstmon='05';
		if brstmon1='JUN' then brstmon='06';
		if brstmon1='JUL' then brstmon='07';
		if brstmon1='AUG' then brstmon='08';
		if brstmon1='SEP' then brstmon='09';
		if brstmon1='OCT' then brstmon='10';
		if brstmon1='NOV' then brstmon='11';
		if brstmon1='DEC' then brstmon='12';

		if      brstyr ne '' and brstmon ne '' and brstday ne '' then dob=compress(brstyr||'-'||brstmon||'-'||brstday);
		else if brstyr ne '' and brstmon ne '' and brstday =  '' then dob=compress(brstyr||'-'||brstmon);
		else if brstyr ne '' and brstmon =  '' and brstday =  '' then dob=compress(brstyr);

		if study='' and subjid='' and sex='' and dob='' then delete;
		if dob='' and i ne '' then dob=i;
		*if length(dob)<10 then dob='';

	run;

	proc sort data=demo nodupkey;
		by study subjid;
	run;

	data outdir.dmsafety;
		set demo;
		keep study subjid sex dob;
	run;



	data ae; 

		attrib  STUDY    length = $200 label = 'Clinical Study'
				SUBJID   length = $200 label = 'Subject ID'
				AESER    length = $200 label = 'Seriousness of AE Code'
				AECASEID length = $200 label = 'Adverse Event Case Identifier'
				AETERM   length = $200 label = 'AE Investigator Text - Raw - MedDRA'
				AEDECD2  length = $200 label = 'Preferred Term'
				FROMDATE length = $200 label = 'Adverse Event From Date'
				TODATE   length = $200 label = 'Adverse Event To Date'
				AEPRES   length = $200 label = 'AE Still Present'
				AERCAUS  length = $200 label = 'Study Drug Cause of Adverse Event'
				AESTDRG  length = $200 label = 'Action Study Drug Dose'
				AEGRADE  length = $200 label = 'CTC AE Grade Studies Collecting NCI-CTC'
			    DEATHDT  length = $200 label = 'Date of Death'
				LSAFEDT  length = $200 label = 'Latest Safety Date'
				TRADENAM length = $200 label = 'Suspect Trade (Generic) Name'
			    INVALCAS length = $200 label = 'Invalid Case Reason in SAFETY DB' 
 
;

		set safety1;

		study    = g;

		%if &imputept=6 %then %do;
			if index(h,'|')>0 then subjid = scan(h,2,'-|');
			else subjid = compress(h,'-|_ ');
			if substr(h,1,1)='|' then subjid = scan(h,1,'|');
			if length(strip(subjid))=4 then subjid=compress('00'||subjid);
			if length(strip(subjid))=5 then subjid=compress('0'||subjid);
			if length(strip(subjid))=8 then subjid=compress('0'||substr(subjid,4,5));
							  %end;
		%else %do; 
				subjid=compress(h,'-|_ ');
			  %end;

		aecaseid = a; 
		aeterm   = upcase(o);
		aedecd2  = upcase(q);
		lsafedt  = upcase(e);
		tradenam = upcase(af);
		*aestdrg  = t;

		*aepres   = u;
		if      upcase(u) in ('RECOVERED/RESOLVED','RECOVERED/RESOLVED WITH SEQUEL','RECOVERED','RECOVERED WITH SEQUALAE') then aepres='NO';
		else if upcase(u) in ('NOT RECOVERED/NOT RESOLVED','RECOVERING/RESOLVING','NOT REC/NOT RES','ONGOING','RESOLVING/IMPROVING') then aepres='YES';
		else if upcase(u) in ('UNKNOWN') then aepres ='UNKNOWN';
		else if indexw(upcase(u),'NOT')>0 then aepres='YES';
		else if upcase(u) in ('DEATH','FATAL') then aepres ='DEATH';

		aercaus  = s;
		if      upcase(aercaus) in ('1','Y','RELATED') then aercaus='YES';
		else if upcase(aercaus) in ('2','N','NOT RELATED','UNRELATED') then aercaus='NO';
		else if upcase(aercaus) in ('3')           then aercaus='UNKNOWN';
		else if upcase(aercaus) in ('4','N/A')     then aercaus='NOT APPLICABLE';
		else if upcase(aercaus) in ('5','NO DATA') then aercaus='NOT DONE';
		*else aercaus='';

		aegrade  = aj;
		invalcas = ak;

		if substr(v,1,2) ne '--' then do;
										if v ne '' and length(v)>=10 then deathdtn  = input(compress(v,'-'),date9.);
										if deathdtn ne . then deathdt=strip(put(deathdtn,yymmdd10.));
							     end;
		else if substr(v,1,2) = '--' then do;
									dthyr=substr(v,8,4);
									dthmn=substr(v,4,3);
										if dthmn='JAN' then dthmn1='01';
										if dthmn='FEB' then dthmn1='02';
										if dthmn='MAR' then dthmn1='03';
										if dthmn='APR' then dthmn1='04';
										if dthmn='MAY' then dthmn1='05';
										if dthmn='JUN' then dthmn1='06';
										if dthmn='JUL' then dthmn1='07';
										if dthmn='AUG' then dthmn1='08';
										if dthmn='SEP' then dthmn1='09';
										if dthmn='OCT' then dthmn1='10';
										if dthmn='NOV' then dthmn1='11';
										if dthmn='DEC' then dthmn1='12';
									deathdt=strip(dthyr||'-'||dthmn1);
							     end;

		*** Derive FROMDATE ***;
		m=upcase(m);
		m=tranwrd(m,'UNK','UN');								 	
		aestday =substr(m,1,2);
		aestmon1=substr(m,4,3);
		aestyr  =substr(m,8);

		if aestmon1='JAN' then aestmon='01';
		if aestmon1='FEB' then aestmon='02';
		if aestmon1='MAR' then aestmon='03';
		if aestmon1='APR' then aestmon='04';
		if aestmon1='MAY' then aestmon='05';
		if aestmon1='JUN' then aestmon='06';
		if aestmon1='JUL' then aestmon='07';
		if aestmon1='AUG' then aestmon='08';
		if aestmon1='SEP' then aestmon='09';
		if aestmon1='OCT' then aestmon='10';
		if aestmon1='NOV' then aestmon='11';
		if aestmon1='DEC' then aestmon='12';

		if upcase(aestday)  in ('-','--','UN','UNK')        then aestday='--';
		if upcase(aestmon1) in ('-','--','---','UN','UNK') then aestmon='---';
		if upcase(aestyr)   in ('-','--','----','UN','UNK') then aestyr='----';

		if      aestyr ne '' and aestmon ne '' and aestday ne '' then fromdate=compress(aestyr||'-'||aestmon||'-'||aestday);
		else if aestyr ne '' and aestmon ne '' and aestday =  '' then fromdate=compress(aestyr||'-'||aestmon);
		else if aestyr ne '' and aestmon =  '' and aestday ne '' then fromdate=compress(aestyr||'----'||aestday);
		else if aestyr ne '' and aestmon =  '' and aestday =  '' then fromdate=compress(aestyr);
		else if aestyr =  '' and aestmon ne '' and aestday ne '' then fromdate=compress('-----'||aestmon||'-'||aestday);
		else if aestyr =  '' and aestmon ne '' and aestday =  '' then fromdate=compress('--'||aestmon||'--');
		else if aestyr =  '' and aestmon =  '' and aestday ne '' then fromdate=compress('----'||aestday);

		*** Derive TODATE ***;
		n=upcase(n);
		n=tranwrd(n,'UNK','UN');								 	
		aeenday =substr(n,1,2);
		aeenmon1=substr(n,4,3);
		aeenyr  =substr(n,8);
		if aeenmon1='JAN' then aeenmon='01';
		if aeenmon1='FEB' then aeenmon='02';
		if aeenmon1='MAR' then aeenmon='03';
		if aeenmon1='APR' then aeenmon='04';
		if aeenmon1='MAY' then aeenmon='05';
		if aeenmon1='JUN' then aeenmon='06';
		if aeenmon1='JUL' then aeenmon='07';
		if aeenmon1='AUG' then aeenmon='08';
		if aeenmon1='SEP' then aeenmon='09';
		if aeenmon1='OCT' then aeenmon='10';
		if aeenmon1='NOV' then aeenmon='11';
		if aeenmon1='DEC' then aeenmon='12';

		if upcase(aeenday)  in ('-','--','UN','UNK')        then aeenday='--';
		if upcase(aeenmon1) in ('-','--','---','UN','UNK') then aeenmon='---';
		if upcase(aeenyr)   in ('-','--','----','UN','UNK') then aeenyr='----';

		if      aeenyr ne '' and aeenmon ne '' and aeenday ne '' then todate=compress(aeenyr||'-'||aeenmon||'-'||aeenday);
		else if aeenyr ne '' and aeenmon ne '' and aeenday =  '' then todate=compress(aeenyr||'-'||aeenmon);
		else if aeenyr ne '' and aeenmon =  '' and aeenday =  '' then todate=compress(aeenyr);
		else if aeenyr =  '' and aeenmon ne '' and aeenday ne '' then todate=compress('--'||aeenmon||'-'||aeenday);
		else if aeenyr =  '' and aeenmon ne '' and aeenday =  '' then todate=compress('--'||aeenmon||'--');
		else if aeenyr =  '' and aeenmon =  '' and aeenday ne '' then todate=compress('----'||aeenday);


		if upcase(r)='SERIOUS' then aeser = 'YES';
		*else aeser='NO';


		if      upcase(t) ='TEMPORARILY WITHDRAWN' then aestdrg='STOPPED TEMPORARILY';
		else if upcase(t) ='PERMANENTLY WITHDRAWN' then aestdrg='PERMANENTLY DISCONTINUED';
		else if upcase(t) ='DOSE REDUCED'          then aestdrg='REDUCED';
		else if upcase(t) ='DOSE INCREASED'        then aestdrg='INCREASED';
		else if upcase(t) ='DOSE NOT CHANGED'      then aestdrg='NO ACTION TAKEN';
		else aestdrg=upcase(t);

		*if length(fromdate)<10 then fromdate='';
		*if length(todate)  <10 then todate='';
		*if length(deathdt) <10 then deathdt='';


		if study='' and subjid='' and aeser='' and aecaseid='' and aeterm='' and aedecd2='' and fromdate='' and todate='' and
		   aepres='' and aercaus='' and aestdrg='' and aegrade='' and invalcas='' and deathdt='' then delete;


	run;


	data outdir.aesafety;
		set ae;
		*where upcase(aeser) in ('YES','Y','SERIOUS');
		keep study subjid aeser aecaseid aeterm aedecd2 lsafedt tradenam fromdate todate aepres aercaus aestdrg aegrade invalcas deathdt;
	run;

	proc datasets library=work nolist;
		delete safety1 ae demo;
	quit;



    %macend:;
    %put ;
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_SAE_RECON_SAFE_TRANSFORM: End of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_sae_recon_safe_transform;
