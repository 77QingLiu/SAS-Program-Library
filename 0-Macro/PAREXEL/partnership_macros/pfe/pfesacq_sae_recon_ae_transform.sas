/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX
  Example Call:          Note: Part of program: pfesacq_sae_recon 
               
                         Call from parent submacro pfesacq_sae_recon.sas:
                         %pfesacq_sae_recon_ae_transform();

-------------------------------------------------------------------------------
 
  Author:                Shiva Bhimreddy, $LastChangedBy: bhimres $
  Creation Date:         12MAY2015                       $LastChangedDate: 2015-10-01 17:22:10 -0400 (Thu, 01 Oct 2015) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfesacq_sae_recon_ae_transform.sas $
 
  Files Created:         None
 
  Program Purpose:       Map raw EDC dataset into Standard sACQ dataset as per sACQ structre
						  and Recon specifications
 
                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:
 

  Macro Output:  AE_CRF dataset is created in the "/../dm/listings/current" Folder


  Macro Dependencies:    Note: Part of program: pfesacq_sae_recon 

                         This is a submacro dependant on calling parent macro: 
                         pfesacq_sae_recon.sas

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2284 $
 1. Shiva Bhimreddy on 18SEP2015: Added code to add RANNDT for cases where empty 
                                  randomization datasets are encountered.
 2. Shiva Bhimreddy on 18SEP2015: Added code to add DEATHDT for cases where empty 
                                  death datasets are encountered.
 
-----------------------------------------------------------------------------*/


%macro pfesacq_sae_recon_ae_transform();
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_SAE_RECON_AE_TRANSFORM: Start of Submacro;
    %put NOTE:[PXL] PFESACQ_SAE_RECON_AE_TRANSFORM: inds=&inds, 

									                study=&study, subjid=&subjid, aeser=&aeser, aecaseid=&aecaseid, aeterm=&aeterm, aedecd2=&aedecd2, 
                                                    fromdate=&fromdate, todate=&todate,aepres=&aepres,aercaus=&aercaus,aeacndrv=&aeacndrv,acwdrn=&acwdrn,acnone=&acnone,
                                                    acother=&acother, acred=&acred, actemp=&actemp, aestdrg=&aestdrg,aegrade=&aegrade,

                                                    deathds=&deathds, deathdt=&deathdt, dthsubid=&dthsubid, randds=&randds,randsubj=&randsubj,randdt=&randdt;
    %put ---------------------------------------------------------------------;
    %put ;

	%local nobs starttyp stoptyp datalabs nobsrd rdttype dttype aeacntyp aesertyp aestexist nobsd;

	libname outdir "&path_listings./current";


	%if %sysfunc(exist(download.&inds)) %then %do;


	proc sql noprint;
		select count(*) into:nobs
		from download.&inds;
	quit;

	%if &nobs=0 %then %goto macerr;




	*** Read the input adverse dataset and Create variables as per the sACQ Specs***;

	data ae1;
		set download.&inds(rename=(&fromdate=start &todate=stop
                                &aercaus=aercaus22 &study=study11 &subjid=subjid11
                                &aeterm=aeterm11 &aedecd2=aedecd22 &aeser=aeser11
								%if &aepres  =   %then %do;%end;%else %do; &aepres=aepres2   %end;
								%if &aegrade =   %then %do;%end;%else %do; &aegrade=aegrade11  %end;
								%if &lstchgts =  %then %do;%end;%else %do; &lstchgts=lstchgts11  %end;
                                %if &aeacndrv=0  %then %do; %if &aestdrg =   %then %do;%end;%else %do; &aestdrg=aestdrg11  %end; %end; ));
	run;

	proc contents data=ae1 noprint out=aecont;
	run;

	data _null_;
		set aecont;
		where upcase(name)='START';
		typec=strip(put(type,best.));
		call symput ("starttyp", typec);
	run;

	data _null_;
		set aecont;
		where upcase(name)='STOP';
		typec=strip(put(type,best.));
		call symput ("stoptyp",typec);
	run;

	data _null_;
		set aecont;
		where upcase(name)='AESER11';
		typec=strip(put(type,best.));
		call symput ("aesertyp",typec);
	run;

	proc sql noprint;
		select count(*) into:datalabs
		from aecont
		where upcase(name)='DOCNUM';
	quit;

	%if &aeacndrv=0 %then %do;
								
	data _null_;
		set aecont;
		where upcase(name)='AESTDRG11';
		typec=strip(put(type,best.));
		call symput ("aeacntyp", typec);
	run;
	proc sql noprint;
		select count(*) into:aestexist
		from aecont
		where upcase(name)='AESTDRG';
	quit;
	%put &aestexist=;
					      %end;

	data _null_;
		set aecont;
		where upcase(name)='STOP';
		typec=strip(put(type,best.));
		call symput ("stoptyp",typec);
	run;

	%if &drg1nam  =   %then %do;%end;%else %do;
	proc sort data=ae1 out=aetemp nodupkey;
		by &drg1nam;
		where &drg1nam ne "";
	run;

	data _null_;
		set aetemp;
		by &drg1nam;
		if last.&drg1nam then call symput ("drug1",&drg1nam);
	run;

	%end;

	%if &drg2nam  =   %then %do;%end;%else %do;
	proc sort data=ae1 out=aetemp nodupkey;
		by &drg2nam;
		where &drg2nam ne "";
	run;

	data _null_;
		set aetemp;
		by &drg2nam;
		if last.&drg2nam then call symput ("drug2",&drg2nam);
	run;

	%end;

	%if &drg3nam  =   %then %do;%end;%else %do;
	proc sort data=ae1 out=aetemp nodupkey;
		by &drg3nam;
		where &drg3nam ne "";
	run;

	data _null_;
		set aetemp;
		by &drg3nam;
		if last.&drg3nam then call symput ("drug3",&drg3nam);
	run;

	%end;

	%if &drg4nam  =   %then %do;%end;%else %do;
	proc sort data=ae1 out=aetemp nodupkey;
		by &drg4nam;
		where &drg4nam ne "";
	run;

	data _null_;
		set aetemp;
		by &drg4nam;
		if last.&drg4nam then call symput ("drug4",&drg4nam);
	run;

	%end;

	%if &AEACNDR1  =   %then %do;%let drug1=Drug 1;%end;
	%if &AEACNDR2  =   %then %do;%let drug2=Drug 2;%end;
	%if &AEACNDR3  =   %then %do;%let drug3=Drug 3;%end;
	%if &AEACNDR4  =   %then %do;%let drug4=Drug 4;%end;


	%put &drug1=;
	%put &drug2=;
	%put &drug3=;
	%put &drug4=;

	proc sql noprint;
        alter table ae1
        modify  &AECASEID char(20);
	quit;


	data ae; 
		attrib  STUDY    length = $200 label = 'Clinical Study'
				SUBJID   length = $200 label = 'Subject ID'
				%if &datalabs=1 %then %do;
				DOCNUM   length = $200 label = 'Document Number'
									  %end;
				AESER    length = $200 label = 'Seriousness of AE Code' format=$20.
				AECASEID length = $200 label = 'Adverse Event Case Identifier'
				AETERM   length = $200 label = 'AE Investigator Text - Raw - MedDRA'
				AEDECD2  length = $200 label = 'Preferred Term'
				FROMDATE length = $200 label = 'Adverse Event From Date'
				TODATE   length = $200 label = 'Adverse Event To Date'
				AEPRES   length = $200 label = 'AE Still Present'
				AERCAUS  length = $200 label = 'Study Drug Cause of Adverse Event'
				AESTDRG  length = $200 label = 'Action Study Drug Dose'
				AEACNDR1 length = $200 label = "Action Taken with &drug1"
				AEACNDR2 length = $200 label = "Action Taken with &drug2"
				AEACNDR3 length = $200 label = "Action Taken with &drug3"
				AEACNDR4 length = $200 label = "Action Taken with &drug4"
				LSTCHGTS length = $200 label = 'Data Modification Timestamp'
				AEGRADE  length = $200 label = 'CTC AE Grade Studies Collecting NCI-CTC'
				SDRGCAUS length = $200 label = 'Study Drug Cause of Adverse Event'
				DRG1NAM  length = $200 label = 'Drug 1 Name'
				DRG1CAUS length = $200 label = 'Drug 1 Causality'
				DRG2NAM  length = $200 label = 'Drug 2 Name'
				DRG2CAUS length = $200 label = 'Drug 2 Causality' 
				DRG3NAM  length = $200 label = 'Drug 3 Name'
				DRG3CAUS length = $200 label = 'Drug 3 Causality'
				DRG4NAM  length = $200 label = 'Drug 4 Name'
				DRG4CAUS length = $200 label = 'Drug 4 Causality' ;

		set ae1 (%if &aestexist=1 %then %do; drop=aestdrg %end;);
		study    = study11;
		subjid   = compress(subjid11,'-|_ ');

		if length(subjid11)<8 or index(subjid11,'-|_ ')>0 then dirty=1;

		studytest="&protocol.";

		%if &aeacndr1  =   %then %do;aeacndr1='';%end;%else %do;  aeacndr1=&aeacndr1; %end; 
		%if &aeacndr2  =   %then %do;aeacndr2='';%end;%else %do;  aeacndr2=&aeacndr2; %end; 
		%if &aeacndr3  =   %then %do;aeacndr3='';%end;%else %do;  aeacndr3=&aeacndr3; %end; 
		%if &aeacndr4  =   %then %do;aeacndr4='';%end;%else %do;  aeacndr4=&aeacndr4; %end; 
		%if &drg1nam   =   %then %do;drg1nam ='';%end;%else %do;  drg1nam=&drg1nam; %end; 
		%if &drg2nam   =   %then %do;drg2nam ='';%end;%else %do;  drg2nam=&drg2nam; %end; 
		%if &drg3nam   =   %then %do;drg3nam ='';%end;%else %do;  drg3nam=&drg3nam; %end; 
		%if &drg4nam   =   %then %do;drg4nam ='';%end;%else %do;  drg4nam=&drg4nam; %end; 
		%if &drg1caus  =   %then %do;drg1caus='';%end;%else %do;  drg1caus=&drg1caus; %end; 
		%if &drg2caus  =   %then %do;drg2caus='';%end;%else %do;  drg2caus=&drg2caus; %end; 
		%if &drg3caus  =   %then %do;drg3caus='';%end;%else %do;  drg3caus=&drg3caus; %end; 
		%if &drg4caus  =   %then %do;drg4caus='';%end;%else %do;  drg4caus=&drg4caus; %end; 


		if length(subjid11)<8 and studytest in ('B1771007','B1831001','B1831005','B1831006') then dirty=.;

		%if &aesertyp=1 %then %do;
				if      aeser11=1 then aeser='YES';
				else if aeser11=2 then aeser='NO';
				else if aeser11=3 then aeser='UNKNOWN';
				else if aeser11=4 then aeser='NOT APPLICABLE';
				else if aeser11=5 then aeser='NOT DONE';
		                      %end;

		%else %if &aesertyp=2 %then %do;
				if      upcase(aeser11) in ('1','Y','YES') then aeser='YES';
				else if upcase(aeser11) in ('2','N','NO')  then aeser='NO';
				else if upcase(aeser11) in ('3')           then aeser='UNKNOWN';
				else if upcase(aeser11) in ('4')           then aeser='NOT APPLICABLE';
				else if upcase(aeser11) in ('5')           then aeser='NOT DONE';

									%end;
		aecaseid = &aecaseid; 
		aeterm   = upcase(aeterm11);
		if      index(aedecd22,'-')>0 and index(scan(upcase(aedecd22),1,'-'),'ABCDEFGHIJKLMNOPQRSTUVWXYZ')=0 then aedecd2  = strip(upcase(scan(aedecd22,2,'-')));
		else if index(aedecd22,'-')>0 and index(scan(upcase(aedecd22),1,'-'),'ABCDEFGHIJKLMNOPQRSTUVWXYZ')>0 then aedecd2  = strip(upcase(aedecd22));
		else if index(aedecd22,'-')=0                                                                        then aedecd2  = strip(upcase(aedecd22));

		%if &lstchgts =  %then %do;lstchgts='';%end;%else %do; lstchgts = strip(upcase(put(datepart(lstchgts11),date11.)));  %end;
		

		*aepres   = aepres2;
		*if      upcase(aepres) in ('1','Y','YES') then aepres='Not Rec/Not Res';
		*else if upcase(aepres) in ('2','N','NO')  then aepres='Recovered/Resolved';
		*else if upcase(aepres) in ('3')           then aepres='Unknown';
		*else if upcase(aepres) in ('4')           then aepres='Not Applicable';
		*else if upcase(aepres) in ('5')           then aepres='Not Done';
		*else aepres='';
		*aepres   = upcase(aepres);

		%if &aepres  =   %then %do;aepres='';%end;%else %do;   

		if      upcase(aepres2) in ('2','N','NO','RECOVERED/RESOLVED','RECOVERED/RESOLVED WITH SEQUEL','RECOVERED','RECOVERED WITH SEQUELAE') then aepres='NO';
		else if upcase(aepres2) in ('1','Y','YES','NOT RECOVERED/NOT RESOLVED','RECOVERING/RESOLVING','NOT REC/NOT RES','ONGOING','RESOLVING/IMPORVING') then aepres='YES';
		else if upcase(aepres2) in ('UNKNOWN') then aepres ='UNKNOWN';
		else if upcase(aepres2) in ('DEATH','FATAL') then aepres ='DEATH';
		else if indexw(upcase(aepres2),'NOT')>0 then aepres='YES';

		                                                   %end;


		aercaus  = aercaus22;
		*if      upcase(aercaus) in ('1','Y','YES') then aercaus='RELATED';
		*else if upcase(aercaus) in ('2','N','NO')  then aercaus='UNRELATED';
		*else if upcase(aercaus) in ('3')           then aercaus='UNKNOWN';
		*else if upcase(aercaus) in ('4')           then aercaus='NOT APPLICABLE';
		*else if upcase(aercaus) in ('5')           then aercaus='NOT DONE';
		*else aercaus='';

		if      upcase(aercaus) in ('1','Y') then aercaus='YES';
		else if upcase(aercaus) in ('2','N') then aercaus='NO';
		else if upcase(aercaus) in ('3')     then aercaus='UNKNOWN';
		else if upcase(aercaus) in ('4')     then aercaus='NOT APPLICABLE';
		else if upcase(aercaus) in ('5')     then aercaus='NOT DONE';
		*else aercaus='';

		%if &sdrgcaus  =   %then %do;sdrgcaus='';%end;%else %do;  sdrgcaus=&sdrgcaus; %end; 

		%if &aegrade =   %then %do;aegrade='';%end;
		%else %do;   
		aegrade  = compbl(aegrade11);
		if aegrade='1' then aegrade='GRADE 1';
		if aegrade='2' then aegrade='GRADE 2';
		if aegrade='3' then aegrade='GRADE 3';
		if aegrade='4' then aegrade='GRADE 4';
		if aegrade='5' then aegrade='GRADE 5';
			 %end;
		%if &starttyp=2 %then %do;
										start22=compress(upcase(start),'_');
										if substr(start22,1,3)='UNK' then start22=compress('UN'||substr(start22,4) );

										if substr(start22,1,2) in ('UN','XX') or substr(start22,3,3) in ('UNK','XXX') then dirty=2;

										*if indexc(start22,'ABCDEFGHIJKLMNOPQRSUVWXYZ')>0 and (substr(start22,1,2) not in ('UN','XX') and substr(start22,3,3) not in ('UNK','XXX') ) and length(start22)>=9 then do;
										if indexc(start22,'ABCDEFGHIJKLMNOPQRSUVWXYZ')>0  or length(start22)=11then do;
																							*startn = input(start22,date9.);
																							*start  = compress(put(startn,yymmdd10.),'-');
																							aestday =compress(substr(start22,1,2));
																							aestmon1=compress(substr(start22,4,3));
																							aestyr  =compress(substr(start22,8,4));

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

																							if upcase(aestday)  in ('-','--','UN','UNK','XX','XXX')        then aestday='--';
																							if upcase(aestmon1) in ('-','--','---','UN','UNK','XX','XXX')  then aestmon='---';
																							if upcase(aestyr)   in ('-','--','----','UN','UNK','XX','XXX') then aestyr='----';
																							
																							if      aestyr ne '' and aestmon ne '' and aestday ne '' then fromdate=compress(aestyr||'-'||aestmon||'-'||aestday);
																							else if aestyr ne '' and aestmon ne '' and aestday =  '' then fromdate=compress(aestyr||'-'||aestmon);
																							else if aestyr ne '' and aestmon =  '' and aestday ne '' then fromdate=compress(aestyr||'----'||aestday);
																							else if aestyr ne '' and aestmon =  '' and aestday =  '' then fromdate=compress(aestyr);
																							else if aestyr =  '' and aestmon ne '' and aestday ne '' then fromdate=compress('-----'||aestmon||'-'||aestday);
																							else if aestyr =  '' and aestmon ne '' and aestday =  '' then fromdate=compress('--'||aestmon||'--');
																							else if aestyr =  '' and aestmon =  '' and aestday ne '' then fromdate=compress('----'||aestday);

																							*if aestyr='----' and aestmon='---' and aestday='--' then fromdate='';
																							if start22 in ('UN-UN-UN','UNK','UN') then fromdate='----------';
																						   end;

										else if indexc(start22,'ABCDEFGHIJKLMNOPQRSUVWXYZ')=0 then do;
																							aestyr  =compress(substr(start22,1,4));
																							aestmon =compress(substr(start22,5,2));
																							aestday =compress(substr(start22,7,2));

																							if upcase(aestday)  in ('-','--','UN','UNK','XX','XXX')        then aestday='--';
																							if upcase(aestmon1) in ('-','--','---','UN','UNK','XX','XXX')  then aestmon='---';
																							if upcase(aestyr)   in ('-','--','----','UN','UNK','XX','XXX') then aestyr='----';

																							if aestyr ne '' and aestmon ne '' and aestday ne '' then fromdate=compress(aestyr||'-'||aestmon||'-'||aestday);
																							if aestyr ne '' and aestmon ne '' and aestday =  '' then fromdate=compress(aestyr||'-'||aestmon);
																							if aestyr ne '' and aestmon =  '' and aestday =  '' then fromdate=compress(aestyr);

																							if length(fromdate)=4 then fromdate=compress(fromdate||'------');
																							if length(fromdate)=7 then fromdate=compress(fromdate||'---');

																                                   end;

										if fromdate ne '' and length(fromdate)<10 then dirty=2;
										*if length(fromdate)<10 then fromdate='';

							%end;

		%else %do;
				if start ne . then fromdate = strip(put(start,yymmdd10.));
			  %end;

		%if &stoptyp=2 %then %do;
										stop22=compress(upcase(stop),'_');
										if substr(stop22,1,3)='UNK' then stop22=compress('UN'||substr(stop22,4) );

										if substr(stop22,1,2) in ('UN','XX') or substr(stop22,3,3) in ('UNK','XXX') then dirty=3;

										*if indexc(stop22,'ABCDEFGHIJKLMNOPQRSUVWXYZ')>0 and (substr(stop22,1,2) not in ('UN','XX') and substr(stop22,3,3) not in ('UNK','XXX') ) and length(stop22)>=9 then do;
										if indexc(stop22,'ABCDEFGHIJKLMNOPQRSUVWXYZ')>0 or length(stop22)=11 then do;
																							*stopn = input(stop22,date9.);
																							*stop  = compress(put(stopn,yymmdd10.),'-');
																							aeenday =compress(substr(stop22,1,2));
																							aeenmon1=compress(substr(stop22,4,3));
																							aeenyr  =compress(substr(stop22,8,4));

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
																							if upcase(aeenmon1) in ('-','--','---','UN','UNK')  then aeenmon='---';
																							if upcase(aeenyr)   in ('-','--','----','UN','UNK') then aeenyr='----';

																							if      aeenyr ne '' and aeenmon ne '' and aeenday ne '' then todate=compress(aeenyr||'-'||aeenmon||'-'||aeenday);
																							else if aeenyr ne '' and aeenmon ne '' and aeenday =  '' then todate=compress(aeenyr||'-'||aeenmon);
																							else if aeenyr ne '' and aeenmon =  '' and aeenday =  '' then todate=compress(aeenyr);
																							else if aeenyr =  '' and aeenmon ne '' and aeenday ne '' then todate=compress('--'||aeenmon||'-'||aeenday);
																							else if aeenyr =  '' and aeenmon ne '' and aeenday =  '' then todate=compress('--'||aeenmon||'--');
																							else if aeenyr =  '' and aeenmon =  '' and aeenday ne '' then todate=compress('----'||aeenday);

																							*if aeenyr='----' and aeenmon='---' and aeenday='--' then todate='';
																							if stop22 in ('UN-UN-UN','UNK','UN') then todate='----------';

																						     end;
										else if indexc(stop22,'ABCDEFGHIJKLMNOPQRSUVWXYZ')=0 then do;

																							aeenyr  =compress(substr(stop22,1,4));
																							aeenmon =compress(substr(stop22,5,2));
																							aeenday =compress(substr(stop22,7,2));

																							if upcase(aeenday)  in ('-','--','UN','UNK')        then aeenday='--';
																							if upcase(aeenmon1) in ('-','--','---','UN','UNK')  then aeenmon='---';
																							if upcase(aeenyr)   in ('-','--','----','UN','UNK') then aeenyr='----';

																							if aeenyr ne '' and aeenmon ne '' and aeenday ne '' then todate=compress(aeenyr||'-'||aeenmon||'-'||aeenday);
																							if aeenyr ne '' and aeenmon ne '' and aeenday =  '' then todate=compress(aeenyr||'-'||aeenmon);
																							if aeenyr ne '' and aeenmon =  '' and aeenday =  '' then todate=compress(aeenyr);

																							if length(todate)=4 then todate=compress(todate||'------');
																							if length(todate)=7 then todate=compress(todate||'---');

																								  end;
										if todate ne '' and length(todate)<10 then dirty=3;
										*if length(todate)<10 then todate='';
							%end;

		%else %do;
				if stop ne . then todate   = strip(put(stop,yymmdd10.));
			  %end;


		%if &aeacndrv = 1 %then %do;
					%if &acwdrn  = %then %do;%end; %else %do; if upcase(&acwdrn)  in ('1','Yes','Y','YES') then aestdrg = 'PERMANENTLY DISCONTINUED';%end;
					%if &actemp  = %then %do;%end; %else %do; if upcase(&actemp)  in ('1','Yes','Y','YES') then aestdrg = 'STOPPED TEMPORARILY';%end;
					%if &acred   = %then %do;%end; %else %do; if upcase(&acred)   in ('1','Yes','Y','YES') then aestdrg = 'REDUCED';%end;
					%if &acother = %then %do;%end; %else %do; if upcase(&acother) in ('1','Yes','Y','YES') then aestdrg = 'OTHER';%end;
					%if &acnone  = %then %do;%end; %else %do; if upcase(&acnone)  in ('1','Yes','Y','YES') then aestdrg = 'NO ACTION TAKEN';%end;
						  		%end;

		%else %if &aeacndrv = 0 %then %do;

					%if &aeacntyp=2 %then %do;
										aestdrg  = upcase(aestdrg11);
										if upcase(aestdrg11) = 'STOPPED TEMP'         then aestdrg='STOPPED TEMPORARILY';
										if upcase(aestdrg11) = 'PERM DISCONT'         then aestdrg='PERMANENTLY DISCONTINUED';
										if upcase(aestdrg11) = 'INFUS RATE REDUCED'   then aestdrg='INFUSION RATE REDUCED';
										if upcase(aestdrg11) = 'STOP TEMP AND REDUCE' then aestdrg='BOTH STOPPED TEMPORARILY AND REDUCED';

										if upcase(aestdrg11) ='STOPPED TEMPORARIL' then aestdrg='STOPPED TEMPORARILY';
										if upcase(aestdrg11) ='PERMANENTLY DISCON' then aestdrg='PERMANENTLY DISCONTINUED';

										if aestdrg11 = '0' then aestdrg='NO ACTION TAKEN';
										if aestdrg11 = '1' then aestdrg='INCREASED';
										if aestdrg11 = '2' then aestdrg='REDUCED';
										if aestdrg11 = '3' then aestdrg='STOPPED TEMPORARILY';
										if aestdrg11 = '4' then aestdrg='PERMANENTLY DISCONTINUED';
										if aestdrg11 = '5' then aestdrg='INFUSION RATE REDUCED';
										if aestdrg11 = '6' then aestdrg='BOTH STOPPED TEMPORARILY AND REDUCED';
                             			  %end;

					%else %if &aeacntyp=1 %then %do;
								if aestdrg11 = 0 then aestdrg='NO ACTION TAKEN';
								if aestdrg11 = 1 then aestdrg='INCREASED';
								if aestdrg11 = 2 then aestdrg='REDUCED';
								if aestdrg11 = 3 then aestdrg='STOPPED TEMPORARILY';
								if aestdrg11 = 4 then aestdrg='PERMANENTLY DISCONTINUED';
								if aestdrg11 = 5 then aestdrg='INFUSION RATE REDUCED';
								if aestdrg11 = 6 then aestdrg='BOTH STOPPED TEMPORARILY AND REDUCED';
                             			         %end;
						 			  %end;


			%if &aeacndrv = 0 and &aestdrg  = %then %do;aestdrg='';%end;

		keep study subjid aeser aecaseid lstchgts aeterm aedecd2 fromdate todate aepres aercaus aestdrg aegrade 	dirty subjid11 start stop
             drg1nam drg2nam drg3nam drg4nam drg1caus drg2caus drg3caus drg4caus sdrgcaus aeacndr1 aeacndr2 aeacndr3 aeacndr4
             %if &datalabs=1 %then %do; docnum; %end;			    
			 ;
	run;

	*** Randomization Date ***;


		%if %sysfunc(exist(download.&randds)) %then %do;
						proc sql noprint;
							select count(*) into:nobsrd
							from download.&randds;
						quit;

						%if &nobsrd=0 %then %do;
												%put %str(WARN)ING:[PXL] --------------------------------------------------------------------------------------------;
												%put %str(WARN)ING:[PXL] PFESACQ_SAE_RECON_AE_TRANSFORM: The randomization dataset &randds has zero (0) observations.;
												%put %str(WARN)ING:[PXL] --------------------------------------------------------------------------------------------;

												data ae;
													set ae(in=a); 
													length randdt $200;
													label randdt= 'Randomization Date';
													randdt = '';
												run;

											%end;

						%else %do;
							data rnd1;
								set download.&randds(rename=(&randsubj=subjid111 &randdt=randdt111));
							run;

							proc contents data=rnd1 noprint out=rndcont;
							run;

							data _null_;
								set rndcont;
								where upcase(name)=upcase("randdt111");
								typec=strip(put(type,best.));
								call symput ("rdttype", typec);
							run;

							data rand;
									attrib  RANDDTC  length = $200 label = 'Randomization Date'
									RANDDT   length = $200 label = 'Randomization Date'
									SUBJID   length = $200 label = 'Subject ID';
								set rnd1;

								%if &rdttype=1 %then %do;rdt111  = randdt111;%end;

								%if &rdttype=2 %then %do;
								if upcase(randdt111)='NULL' then randdt111='';
								randt22=compress(upcase(randdt111),'-_');
								if indexc(randt22,'ABCDEFGHIJKLMNOPQRSUVWXYZ')>0 and (substr(randt22,1,2) not in ('UN','XX') and substr(randt22,3,3) not in ('UNK','XXX') ) and length(randt22)>=9 then do;
										rdt111 = input(randt22,date9.);
																						                                                                                     end;
                             	else do;
									if randdt111 ne '' then rdt111  = input(compress(substr(randdt111,1,4)||'-'||substr(randdt111,5,2)||'-'||substr(randdt111,7,2)),yymmdd10.);
							 	end;

							 					%end;

								if rdt111 ne . then randdtc=strip(put(rdt111,yymmdd10.));

								subjid = compress(subjid111,'-|_ ');
								randdt = randdtc;
								if length(randdt)<10 then randdt='';
								keep subjid randdt;
							run;

							proc sort data=rand nodupkey;
								by subjid;
							run;

							proc sort data=ae;
								by subjid;
							run;

							data ae;
								merge ae(in=a) rand; 
								by subjid;
								if a;
							run;
							  %end;
		                                            %end;


		%else %if %sysfunc(exist(random.&randds)) %then %do;
					proc sql noprint;
						select count(*) into:nobsrd
						from random.&randds;
					quit;

					%if &nobsrd=0 %then %do;
											%put %str(WARN)ING:[PXL] --------------------------------------------------------------------------------------------;
											%put %str(WARN)ING:[PXL] PFESACQ_SAE_RECON_AE_TRANSFORM: The randomization dataset &randds has zero (0) observations.;
											%put %str(WARN)ING:[PXL] --------------------------------------------------------------------------------------------;

												data ae;
													set ae(in=a); 
													length randdt $200;
													label randdt= 'Randomization Date';
													randdt = '';
												run;

									    %end;

					%else %do;
						data rnd1;
							set random.&randds(rename=(&randsubj=subjid111 &randdt=randdt111));
						run;

						proc contents data=rnd1 noprint out=rndcont;
						run;

						data _null_;
							set rndcont;
							where upcase(name)=upcase("randdt111");
							typec=strip(put(type,best.));
							call symput ("rdttype", typec);
						run;

						data rand;
								attrib  RANDDTC  length = $200 label = 'Randomization Date'
								RANDDT   length = $200 label = 'Randomization Date'
								SUBJID   length = $200 label = 'Subject ID';
							set rnd1;

							%if &rdttype=1 %then %do;rdt111  = randdt111;%end;

							%if &rdttype=2 %then %do;
								if upcase(randdt111)='NULL' then randdt111='';
								randt22=compress(upcase(randdt111),'-_');
								if indexc(randt22,'ABCDEFGHIJKLMNOPQRSUVWXYZ')>0 and (substr(randt22,1,2) not in ('UN','XX') and substr(randt22,3,3) not in ('UNK','XXX') ) and length(randt22)>=9 then do;
										rdt111 = input(randt22,date9.);
																						                                                                                     end;
                             	else do;
									if randdt111 ne '' then rdt111  = input(compress(substr(randdt111,1,4)||'-'||substr(randdt111,5,2)||'-'||substr(randdt111,7,2)),yymmdd10.);
							 		 end;

							 					%end;

							if rdt111 ne . then randdtc=strip(put(rdt111,yymmdd10.));

							subjid = compress(subjid111,'-|_ ');
							randdt = randdtc;
							if length(randdt)<10 then randdt='';
							keep subjid randdt;
						run;

						proc sort data=rand nodupkey;
							by subjid;
						run;

						proc sort data=ae;
							by subjid;
						run;

						data ae;
							merge ae(in=a) rand; 
							by subjid;
							if a;
						run;
							%end;
			  										  %end;

		%else %do;
    			%put %str(WARN)ING:[PXL]-------------------------------------------------------------------------------------;
    			%put %str(WARN)ING:[PXL] PFESACQ_SAE_RECON_AE_TRANSFORM: alert: Randomization Dataset &RANDDS does not exist.;
    			%put %str(WARN)ING:[PXL]-------------------------------------------------------------------------------------;



				data ae;
					set ae(in=a); 
					length randdt $200;
					label randdt= 'Randomization Date';
					randdt = '';
				run;


		%end;

	run;




	*** Death Date ***;

	%if %sysfunc(exist(download.&deathds)) %then %do;
					proc sql noprint;
						select count(*) into:nobsdth
						from download.&deathds;
					quit;

					%if &nobsdth=0 %then %do;
											%put %str(WARN)ING:[PXL] ----------------------------------------------------------------------------;
											%put %str(WARN)ING:[PXL] PFESACQ_SAE_RECON_AE_TRANSFORM: The death dataset has zero (0) observations.;
											%put %str(WARN)ING:[PXL] ----------------------------------------------------------------------------;


											data ae;
												set ae; 
												length deathdt $200;
												label deathdt= 'Date of Death';
												deathdt = '';
											run;
										 %end;

					%else %do;
						data dth1;
							set download.&deathds;
							rename &dthsubid = dthsubid &deathdt=deathdt11;
						run;

						proc contents data=dth1 noprint out=dthcont;
						run;

						data _null_;
							set dthcont;
							where upcase(name)=upcase("DEATHDT11");
							typec=strip(put(type,best.));
							call symput ("dttype", typec);
						run;

						data death;
							attrib  DEATHDT  length = $200 label = 'Date of Death'
							SUBJID   length = $200  label = 'Subject ID';
						set dth1;
						%if &dttype=1 %then %do;deathdt111  = deathdt11;%end;
						%if &dttype=2 %then %do;

							deathdt11=compress(upcase(deathdt11),'-_');
							if indexc(deathdt11,'ABCDEFGHIJKLMNOPQRSUVWXYZ')>0 and (substr(deathdt11,1,2) not in ('UN','XX') and substr(deathdt11,3,3) not in ('UNK','XXX') ) and length(deathdt11)>=9 then do;
										deathdt111 = input(deathdt11,date9.);
																						                                                                                     end;
                             else do;
								if length(deathdt11)>=8 then deathdt111  = input(compress(substr(deathdt11,1,4)||'-'||substr(deathdt11,5,2)||'-'||substr(deathdt11,7,2)),yymmdd10.);
							 end;

						*if      deathdt11 ne '' and length(deathdt11)>=10 then deathdt111  = input(compress(substr(deathdt11,1,4)||'-'||substr(deathdt11,5,2)||'-'||substr(deathdt11,7,2)),yymmdd10.);
						*else if deathdt11 ne '' and length(deathdt11) =6  then deathdt     = compress(substr(deathdt11,1,4)||'-'||substr(deathdt11,5,2) );
						*else if deathdt11 ne '' and length(deathdt11) =4  then deathdt     = deathdt11;

											%end;

							if deathdt111 ne . then deathdt=strip(put(deathdt111,yymmdd10.));
							if length(deathdt)<10 then deathdt='';

							subjid   = compress(dthsubid,'-|_ ');
							format deathdt111 yymmdd10.;
						run;

						proc sort data=death nodupkey;
							by subjid;
						run;

						proc sort data=ae;
							by subjid;
						run;

						data ae;
							merge ae(in=a) death(keep=subjid deathdt); 
							by subjid;
							if a;
						run;
					        %end;   *** end of nobs>1 ***;
											    %end;  *** end of if dataset exists ***;

	%if %sysfunc(exist(download.&deathds)) %then %do;;%end;

	%else %do;
    			%put %str(WARN)ING:[PXL]------------------------------------------------------------------------------;
    			%put %str(WARN)ING:[PXL] PFESACQ_SAE_RECON_AE_TRANSFORM: alert: Death Dataset &deathds does not exist.;
    			%put %str(WARN)ING:[PXL]------------------------------------------------------------------------------;

	proc sort data=ae;
		by subjid;
	run;

	%put &deathds=;

	data ae;
		set ae; 
		length deathdt $200;
		label deathdt= 'Date of Death';
		deathdt = '';
	run;

	      %end;



	%let create_dated_dir = Y ;
	%mu_create_dated_dir(type=listings) ;

	data outdir.ae_crf;
		set ae;
		drop dirty subjid11 start stop;
	run;

	*************************;
	*** Report Dirty Data ***;
	*************************;
/*
	data aedirty;
		length flag $50;
		set ae;
		where dirty ne .;
		if dirty=1 then flag='Dirty Data – Patient ID     ';
		if dirty=2 then flag='Dirty Data – Onset Date';
		if dirty=3 then flag='Dirty Data – Resolution Date';
	run;

	proc sql noprint;
		select count(*) into:nobsd
		from aedirty;
	quit;

	%if %eval(&nobsd) > 0 %then %do; 

		ODS TAGSETS.EXCELXP
		file="&path_listings./current/&protocol._SAE Dirty Data_&rundate..xls"
		STYLE=Printer
		OPTIONS ( 
					Orientation = 'landscape'
					FitToPage = 'yes'
					Pages_FitWidth = '1'
					Pages_FitHeight = '100' 
					autofit_height='YES'
					Autofilter = 'All'
					Frozen_Headers='Yes'
					Absolute_Column_Width='25, 10, 10'
  					sheet_name='SAE Dirty Data'
				);

		proc report data=aedirty nowd style(header)=[background=lightskyblue foreground=black fontweight=bold fontsize=11pt];

			column  flag subjid11 start stop;

			define	flag      / "Flag"            display  flow style(header) = {background=white  foreground=black}; 
			define	subjid11  / "Patient ID"      display  flow style(header) = {background=white  foreground=black}; 
			define	start     / "Onset Date"      display  flow style(header) = {background=white  foreground=black}; 
			define	stop      / "Resolution Date" display  flow style(header) = {background=white  foreground=black}; 

		run;

		ods tagsets.excelxp close;


		ods listing; 

								%end;
*/
	***********************************;
	*** End of dirty data reporting ***;
	***********************************;

	proc datasets library=work nolist;
		delete ae ae1 aecont death dth1 dthcont rand rnd1 rndcont;* aedirty;
	quit;

	%end;

	%else %do;
    			%put %str(ERR)OR:[PXL]---------------------------------------------------------------------;
    			%put %str(ERR)OR:[PXL] PFESACQ_SAE_RECON_AE_TRANSFORM: alert: Dataset &inds does not exist.;
    			%put %str(ERR)OR:[PXL]---------------------------------------------------------------------;
		  %end;

	%goto macend;
	%macerr:;
	%put %str(ERR)OR:[PXL] ----------------------------------------------------------------------------------;
	%put %str(ERR)OR:[PXL] PFESACQ_SAE_RECON_AE_TRANSFORM: The input dataset &inds has zero (0) observations.;
	%put %str(ERR)OR:[PXL] ----------------------------------------------------------------------------------;

	%goto macend;
	%macerr2:;
	%put %str(ERR)OR:[PXL] --------------------------------------------------------------------------------------------;
	%put %str(ERR)OR:[PXL] PFESACQ_SAE_RECON_AE_TRANSFORM: The randomization dataset &randds has zero (0) observations.;
	%put %str(ERR)OR:[PXL] --------------------------------------------------------------------------------------------;

	%goto macend;

    %macend:;
    %put ;
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_SAE_RECON_AE_TRANSFORM: End of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_sae_recon_ae_transform;

