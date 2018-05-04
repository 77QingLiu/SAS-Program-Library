/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Shiva Bhimreddy, $LastChangedBy:  $
  Creation Date:         17AUG2015                       $LastChangedDate:  $
 
  Program Location/Name: $HeadURL: $
 
  Files Created:         None
 
  Program Purpose:       Lab Reconciliation of the vendor lab dataset into SACQ format.
 
						 Note: Part of program: pfesacq_lab_recon 

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 

  Macro Output:          LBEDATA dataset is created in the "/../dm/listings/current" Folder


-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev:  $
  
-----------------------------------------------------------------------------*/


*** Call the Macro that converts the raw Adverse Event EDC dataset into the SACQ format ***;

%macro pfesacq_lab_recon_vend_transform();


    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_LAB_RECON_VEND_TRANSOFRM: Start of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

	libname outdir "&path_listings./current";

	%if %sysfunc(exist(edata.lab)) %then %do;

	proc sql noprint;
		select count(*) into:nobs
		from edata.lab;
	quit;

	%if &nobs=0 %then %goto macerr;

	*******************************************************************;
	* Step 1: Find the latest directory date in the EDATA directory   *;
	*******************************************************************;
	
	data _null_;
		call system("cd &path_dm/e_data/datasets");
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

	%if %sysfunc(exist(metadata.rec_vendlab_meta)) %then %do;

	proc sort data = metadata.rec_vendlab_meta out=test;
	    by date;
	run;

	data _null_;
		set test;
	    by date;
		if last.date then call symput('prevdate',left(trim(datec)));
	run;

	proc append base=metadata.rec_vendlab_meta data=test;
	run;

	proc sort data=metadata.rec_vendlab_meta nodupkey;
		by date;
	run;
													 %end;

	%else %do;

	proc append base=metadata.rec_vendlab_meta data=test;
	run;

	proc sort data=metadata.rec_vendlab_meta nodupkey;
		by date;
	run;

	data current;
		attrib STATUS2 length=$7 label='Vendor Data State';
		set edata.lab;
		status2='New';
	run;

	%goto edctrans;

		  %end;

	%put curdate = &curdate;
	%put prevdate = &prevdate;

	%if &curdate=&prevdate %then %do;
									%let prevdate  = &prevdate1.;
									%put prevdate1 = &prevdate1;
								%end;


	*** Define the previous library to compare the data ***;

	%if %str(&prevdate) ne %str() %then %do;
		libname oldDir "&path_dm//e_data/datasets/&prevdate";
	%end;
    %else %do;
        libname oldDir "&path_dm/e_data/datasets/draft";
    %end;

	%if %sysfunc(exist(oldDir.lab)) %then %do;

	proc sort data=olddir.lab out=old ;*nodupkey dupout=dupolb;
		%if "&database_type."  = "DATALABS" %then %do; by SSID ACCNUM TSTID LB_TSTID VISIT COLL_D COLL_T TSTRES;%end;
		%if "&database_type."  = "OC"       %then %do; by SSID LB_TSTID VISIT COLL_D COLL_T TSTRES;%end;
	run;

	proc sort data=edata.lab out=current; 
		%if "&database_type."  = "DATALABS" %then %do; by SSID ACCNUM TSTID LB_TSTID VISIT COLL_D COLL_T TSTRES;%end;
		%if "&database_type."  = "OC"       %then %do; by SSID LB_TSTID VISIT COLL_D COLL_T TSTRES;%end;
	run;

	libname olddir clear;

	*** Create the STATUS variable ***;

	data status;
		attrib STATUS2 length=$7 label='Vendor Data State';
        merge old     (in=old rename=(%if &elbtest=   %then %do;%end; %else %do; &elbtest=oldtest  %end;
									  %if &elbtpt=    %then %do;%end; %else %do; &elbtpt=oldlbtpt  %end;))
              current (in=new rename=(%if &elbtest=   %then %do;%end; %else %do; &elbtest=newtest  %end;
									  %if &elbtpt=    %then %do;%end; %else %do; &elbtpt=newlbtpt  %end;));
		%if "&database_type."  = "DATALABS" %then %do; by SSID ACCNUM TSTID LB_TSTID VISIT COLL_D COLL_T TSTRES;%end;
		%if "&database_type."  = "OC"       %then %do; by SSID LB_TSTID VISIT COLL_D COLL_T TSTRES;%end;

		if old=1 and new=1 then status2="Old";

        %if &elbtest=   %then %do;%end; %else %do; if oldtest  ne newtest  then status2="Changed";%end;
        %if &elbtpt=    %then %do;%end; %else %do; if oldlbtpt ne newlbtpt then status2="Changed";%end;

		if old=0 and new=1 then status2="New";
		if new;

		%if "&database_type."  = "DATALABS" %then %do; keep SSID ACCNUM TSTID LB_TSTID VISIT COLL_D COLL_T TSTRES status2;%end;
		%if "&database_type."  = "OC"       %then %do; keep SSID LB_TSTID VISIT COLL_D COLL_T TSTRES status2;%end;

	
	run;

	data current;
        merge STATUS current;
		%if "&database_type."  = "DATALABS" %then %do; by SSID ACCNUM TSTID LB_TSTID VISIT COLL_D COLL_T TSTRES;%end;
		%if "&database_type."  = "OC"       %then %do; by SSID LB_TSTID VISIT COLL_D COLL_T TSTRES;%end;
	run;

										  %end;

	%else %do;

			data current;
				attrib STATUS2 length=$7 label='Vendor Data State';
				set edata.lab;
				status2='New';
			run;

		  %end;


	%edctrans:;

	*** Read the input demography dataset and Create variables as per the sACQ Specs***;

	data lab1;
		set edata.lab(rename=(%if &ecolldate= %then %do;%end; %else %do;&ecolldate=ecolldate1 %end;
                                   %if &etesttime= %then %do;%end; %else %do;&etesttime=etesttime1 %end;
                                   %if &esubjid= %then %do;%end; %else %do;&esubjid=esubjid1 %end;

						   ));
	run;

	proc contents data=lab1 noprint out=lbcont;
	run;

	data _null_;
		set lbcont;
		where upcase(name)='ECOLLDATE1';
		if type ne . then typec = strip(put(type,best.));
		call symput ("elbdttype", typec);
	run;

	%if &etesttime = %then %do;%end; %else %do;

	data _null_;
		set lbcont;
		where upcase(name)='ETESTTIME1';
		if type ne . then typec = strip(put(type,best.));
		call symput ("elbtmtype", typec);
	run;
	%end;

	data _null_;
		set lbcont;
		where upcase(name)='ESUBJID1';
		if type ne . then typec = strip(put(type,best.));
		call symput ("esubtype", typec);
	run;

	proc sql noprint;
		select count(*) into:visexist
		from lbcont
		where upcase(name)='VISIT';
	quit;


	data lab;

		attrib  STUDY     length = $200 label = 'Clinical Study'
				SITEID    length = $40  label = 'Center Identifier Within Study'
				SUBJID    length = $200 label = 'Subject ID'
				SEX       length = $200 label = 'Gender Code'
				DOB       length = $200 label = 'Date of Birth'
				CPEVENT   length = $20  label = 'CPE Name'
				VISIT     length = $30  label = 'Visit'
				LBCAT     length = $40  label = 'Lab Classification'
				LNOTDONE  length = $30  label = 'Test not done indicator'
				COLLDATE  length = $15  label = 'Collection Date'
				TESTTIME  length = $15  label = 'Collection Time'
				LBTPT     length = $20  label = 'Time Point'
				LABSMPID  length = $20  label = 'Unique lab sample id'
				LBTEST    length = $100 label = 'Laboratory Test Name'
				PXCODE    length = $30  label = 'Pfizer Laboratory Test PXCode'
				LBTSTID   length = $20  label = 'Test Code From Laboratory'
				LABVALUE  length = $200 label = 'Raw textual value of result'
				LABUNITR  length = $30  label = 'Units for raw laboratory test'
				STDVALUE  length = $200 label = 'Standard value of result'
				STDUNIT   length = $30  label = 'Standard Units'
				INVCOM    length = $200 label = 'Investigator Comment';

		set current (
							rename=(&estudy=estudy1  &esubjid=esubjid1 
									%if &visexist = 1 %then %do;visit=evisit1 %end;%else %do;&evisit=evisit1 %end;
									%if &esiteid   = %then %do;%end; %else %do;&esiteid=esiteid1     %end;
									%if &esex = %then %do;%end; %else %do;&esex=esex1        %end;
									%if &edob = %then %do;%end; %else %do;&edob=edob1        %end;
									%if &elbcat    = %then %do;%end; %else %do;&lbcat=elbcat1        %end;
									%if &etesttime = %then %do;%end; %else %do;&etesttime=etesttime1 %end;
									%if &elabsmpid = %then %do;%end; %else %do;&elabsmpid=elabsmpid1 %end;
									%if &elnotdone = %then %do;%end; %else %do;&elnotdone=elnotdone1 %end;
									%if &ecolldate = %then %do;%end; %else %do;&ecolldate=ecolldate1 %end;
									%if &elbtest   = %then %do;%end; %else %do;&elbtest  =elbtest1   %end;
									%if &epxcode   = %then %do;%end; %else %do;&epxcode  =epxcode1   %end;
									%if &elbtstid  = %then %do;%end; %else %do;&elbtstid =elbtstid1  %end;
									%if &elbtpt    = %then %do;%end; %else %do;&elbtpt   =elbtpt1    %end;
									%if &eresult   = %then %do;%end; %else %do;&eresult  =eresult1   %end;
									%if &eresunit  = %then %do;%end; %else %do;&eresunit =eresunit1  %end;
									%if &estdres   = %then %do;%end; %else %do;&estdres  =estdres1   %end;
									%if &estdunit  = %then %do;%end; %else %do;&estdunit =estdunit1  %end;
									%if &einvcom   = %then %do;%end; %else %do;&einvcom  =einvcom11  %end;
                                      ));

		study    = upcase(estudy1);

		%if &esiteid  = %then %do; siteid   = ''; %end; %else %do; siteid   = upcase(esiteid1);  %end;

		%if &esubtype=1 %then %do;subjid   = compress(put(esubjid1,best.),'-|_ ');%end;
		%if &esubtype=2 %then %do;subjid   = compress(esubjid1,'-|_ ');%end;

		
		cpevent  = upcase(evisit1);

		%if &evisit = %then %do; visit = ''; %end; %else %do; visit  = upcase(evisit1);  %end;

		%if &esex  = %then %do; sex = ''; %end; %else %do; sex = upcase(esex1);                %end;
		%if &edob  = %then %do; dob = ''; %end; %else %do;
															*dob = strip(put(edob1,yymmdd10.));
															if     .< edob1 < ((2020-1960)*365) then dob = strip(put(edob1,yymmdd10.));
															else if   edob1 > ((2020-1960)*365) then dob = strip(put(input(strip(put(edob1,best.)),yymmdd8.),yymmdd10.));       

													  %end;

		if sex='M' then sex='MALE';
		if sex='F' then sex='FEMALE';
		if sex='1' then sex='MALE';
		if sex='2' then sex='FEMALE';

		%if &elbcat=    %then %do; lbcat    = ''; %end; %else %do; 
																lbcat = upcase(elbcat1);
																if index(elbcat1,'-')>0 then lbcat = upcase(strip(scan(elbcat1,2,'-')));
																if lbcat = 'CHEMISTRY (LABC)'  then lbcat = 'CHEMISTRY';
																if lbcat = 'HEMATOLOGY (LABH)' then lbcat = 'HEMATOLOGY';
																if lbcat = 'URINALYSIS (LABU)' then lbcat = 'URINALYSIS';
																lbcat=upcase(lbcat);

															  %end;
															 
		%if &elnotdone= %then %do; lnotdone = ''; %end; %else %do; lnotdone = elnotdone1; if lnotdone='1' then lnotdone='NOT DONE'; if lnotdone='2' then lnotdone='DONE'; %end;

		%if &etesttime= %then %do; testtime = ''; %end; %else %do; testtime = strip(put(etesttime1,time8.)); %end;

		%if &einvcom  = %then %do; invcom   = ''; %end; %else %do; invcom   = einvcom11;  %end;
		%if &elbtpt   = %then %do; lbtpt    = ''; %end; %else %do; lbtpt    = strip(elbtpt1);    %end;
		%if &eresult  = %then %do; labvalue = ''; %end; %else %do; labvalue = eresult1;   %end;
		%if &eresunit = %then %do; labunitr = ''; %end; %else %do; labunitr = eresunit1;  %end;
		%if &estdres  = %then %do; stdvalue = ''; %end; %else %do; stdvalue = estdres1;   %end;
		%if &estdunit = %then %do; stdunit  = ''; %end; %else %do; stdunit  = estdunit1;  %end;
		%if &elabsmpid= %then %do; labsmpid = ''; %end; %else %do; labsmpid = upcase(elabsmpid1); %end;
		%if &elbtest  = %then %do; lbtest   = ''; %end; %else %do; lbtest   = upcase(elbtest1);  %end;
		%if &elbtstid = %then %do; lbtstid  = ''; %end; %else %do; lbtstid  = upcase(elbtstid1); %end;
		%if &epxcode  = %then %do; pxcode   = ''; %end; %else %do; pxcode   = strip(upcase(epxcode1));  %end;

		%if       &elbdttype=1 %then %do;
										if     .< ecolldate1 < ((2020-1960)*365) then colldate = strip(put(ecolldate1,date9.));
										else if   ecolldate1 > ((2020-1960)*365) then colldate = strip(put(input(strip(put(ecolldate1,best.)),yymmdd8.),date9.));       

									 %end;
		%else %if &elbdttype=2 %then %do;

							ecolldate1=upcase(compress(ecolldate1,'-_'));
							if indexc(ecolldate1,'ABCDEFGHIJKLMNOPQRSUVWXYZ')>0 and (substr(ecolldate1,1,2) not in ('UN','XX') and substr(ecolldate1,3,3) not in ('UNK','XXX') ) and length(ecolldate1)>=9 then do;
										ecolldaten = input(ecolldate1,date9.);
										if ecolldaten ne . then colldate=strip(put(ecolldaten,date9.));
																						                                                                                               end;
                             else do;
								if length(ecolldate1)=8 then colldate22 = compress(substr(ecolldate1,1,4)||'-'||substr(ecolldate1,5,2)||'-'||substr(ecolldate1,7,2));
								colldate22n=input(colldate22,yymmdd10.);
								colldate=strip(put(colldate22n,date9.));
								if length 4<(ecolldate1)<8 then colldate=strip(ecolldate1);
							 end;
								   %end;
												        

		%if       &elbtmtype=1 %then %do;testtime = strip(put(etesttime1,time8.));%end;
		%else %if &elbtmtype=2 %then %do;
										testtime=etesttime1;
								     %end;



		*** Derive LBCAT ***;
/*
		if      elbtstid1 in ('RCT474','RCT1','RCT11','RCT12','RCT13','RCT1407','RCT14','RCT15','RCT16',
							 'RCT17','RCT18','RCT183','RCT29','RCT392','RCT4','RCT5','RCT6','SCT3689',
							 'SCT3536','RCT2234','RCT2232','BCT60','CGT283','CGT564','RCT3','RCT30','RCT14') then lbcat = 'CHEMISTRY';

		else if elbtstid1 in ('BAT442') then lbcat = 'FSH';

		else if elbtstid1 in ('HMT40','HMT3','HMT13','HMT7','HMT15','HMT18','HMT19','HMT16','HMT17','HMT96','HMT21','HMT97',
							  'HMT68','HMT69','HMT71','HMT91','HMT8','HMT11','HMT12','HMT9','HMT10','HMT95','HMT20','HMT94',
							  'HMT70','HMT81','HMT54','HMT93','HMT79','HMT51','HMT63','HMT92','HMT56','HMT86','HMT62','HMT67',
							  'HMT66','HMT3074','HMT71','HMT98','HMT82','HMT59','HMT83','HMT60','HMT84','HMT61','HMT85','HMT55',
							  'HMT80','HMT65','HMT64','HMT88','HMT48','HMT74','HMT49','HMT75','HMT53','HMT78','HMT52','HMT77','HMT104'
							  'HMT50','HMT76','HMT87','HMT57','HMT72','HMT90','HMT71','HMT71','HMT58','HMT2','HMT4','HMT100') then lbcat = 'HEMATOLOGY';

		else if elbtstid1 in ('CNT68','CNT350','CNT63','CNT353','CNT70','GET1881') then lbcat = 'HEPATITIS';

		else if elbtstid1 in ('CNT71','SGT4','IMT1855','IMT1856')   then lbcat = 'HIV';


		else if elbtstid1 in ('BAT318')  then lbcat = 'PREGNANCY';

		else if elbtstid1 in ('IMT1442') then lbcat = 'TB';

		else if elbtstid1 in ('ORT9370') then lbcat = 'ANTI-dsDNA ANTIBODY';

		else if elbtstid1 in ('ORT9363') then lbcat = 'BETA-D-GLUCAN';

		else if elbtstid1 in ('UAT3','UAT49','UAT5','UAT17','UAT18','UAT16','UAT6','UAT43','UAT20','UAT69','UAT19','UAT71',
							  'UAT36','UAT44','UAT67','UAT41','UAT21','UAT40','GST51','UAT22','UAT34','UAT39','UAT38','UAT45',
							  'UAT75','UAT76','UAT63','UAT31','UAT30','UAT37','UAT27','UAT33','UAT35','UAT11','UAT46','UAT72',
							  'UAT74','UAT73','UAT23','UAT68','UAT28','UAT70','RCT2410') then lbcat = 'URINALYSIS';


		else if elbtstid1 in ('GST52','GST50','GST53','GST48','GST54','GST196','GST46','GST57','RCT2406','RCT2408','RCT2412',
							  'RCT2414','RCT2416','RCT2420','RCT2422','RCT2424','RCT2426','ORT9021','ORT8968') then lbcat = 'URINE DRUG SCREEN';
*/

	run;


	*** Import the protocol tests document ***;

	proc import datafile = "&path_dm/documents/lab_recon/current/%lowcase(&protocol.) lab recon specs.xls"
	            out      = prottest 
				dbms     = xls replace;
				sheet    = "Lab Tests";
				getnames = no;
				startrow = 2;
	run;

	data prottest;
		attrib LBCAT  length = $40  label = 'Lab Classification'
			   PXCODE length = $30  label = 'Pfizer Laboratory Test PXCode'
		       LBTEST length = $100 label = 'Laboratory Test Name';

		length lbtstid $20 lbtest $100;
		set prottest;
		lbtstid=strip(upcase(compress(d, ,'kw')));
		pxcode=strip(upcase(compress(put(c,best.), ,'kw')));
		lbcat=upcase(compress(a, ,'kw'));
		lbtest=upcase(strip(compress(b, ,'kw')));
		keep lbcat pxcode lbtstid lbtest;
	run;

	proc sort data=prottest nodupkey;
		by pxcode lbtstid lbtest;
		where lbcat ne '' and lbtstid ne '';
	run;

	proc sort data=lab;
		by pxcode lbtstid lbtest;
	run;

	data lab;
		merge lab(in=inlab drop=lbcat %if &elbtest = %then %do; lbtest %end;) prottest;
		by %if &epxcode  = %then %do; %end; %else %do; pxcode %end;
		   %if &elbtstid = %then %do; %end; %else %do; lbtstid %end;
           %if &elbtest  = %then %do; %end; %else %do; lbtest %end; ;
		if inlab;

		if lbcat in ('ANTI-DSDNA ANTIBODY','ANTI- DSDNA ANTIBODY') then lbcat = 'ANTI-DSDNA ANTIBODY';
	run;


/*
	data dm;
		attrib  STUDY   length = $15 label = 'Clinical Study'
				SUBJID  length = $8  label = 'Subject ID'
				SEX     length = $20 label = 'Gender Code'
				DOB     length = $15 label = 'Date of Birth'
				CPEVENT length = $20 label = 'CPE Name';

		set lab (rename=(
						));

	run;
	
	proc sort data=dm nodupkey;
		by study subjid sex dob cpevent;
	run;	

	data outdir.dmedata;
		set dm;
		keep study subjid sex dob cpevent;*siteid;
	run;
*/

	proc sort data=lab;
		by study subjid siteid visit colldate testtime;
		where subjid ne '';
	run;

	*** Add SITEID from LB_CRF ***;

	%if %sysfunc(exist(outdir.lb_crf)) %then %do;

	proc sort data=outdir.lb_crf out=siteid(keep=study siteid subjid) nodupkey;
		by study subjid siteid;
	run;

	data lab;
		merge lab(in=a drop=siteid) siteid;
		by study subjid;
		if a;
		lbcat=upcase(lbcat);
	run;

	%end;

	proc sort data=lab;
		by study siteid subjid visit colldate testtime;
	run;

	data outdir.lbedata;
		set lab;
		keep study siteid subjid sex dob cpevent lbcat lbtest pxcode lbtstid labvalue labunitr stdvalue stdunit lbtpt lnotdone labsmpid colldate testtime invcom status2;
	run;

	proc datasets library=work nolist;
		delete status current test lab lab1 lbcont old prottest siteid;* dm;
	quit;


	%end;

	%else %do;
    			%put %str(ERR)OR:[PXL]------------------------------------------------------------------------;
    			%put %str(ERR)OR:[PXL] PFESACQ_LAB_RECON_VEND_TRANSOFRM: alert: Dataset LAB does not exist.;
    			%put %str(ERR)OR:[PXL]------------------------------------------------------------------------;
		  %end;


	%goto macend;
	%macerr:;
	%put %str(ERR)OR:[PXL] -------------------------------------------------------------------------------------;
	%put %str(ERR)OR:[PXL] PFESACQ_LAB_RECON_VEND_TRANSOFRM: The input dataset LAB has zero (0) observations.;
	%put %str(ERR)OR:[PXL] -------------------------------------------------------------------------------------;



    %macend:;
    %put ;
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_LAB_RECON_VEND_TRANSOFRM: End of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_lab_recon_vend_transform;


/*

	libname outdir "&path_listings./current";


	proc import datafile = "&path_dm/documents/lab_recon/current/B5371002_Lab Vendor Transfer_DUMMY1.xls"
	            out      = edata.lab_dummy2 
				dbms     = xls replace;
				getnames = yes;
				startrow = 2;
	run;
*/