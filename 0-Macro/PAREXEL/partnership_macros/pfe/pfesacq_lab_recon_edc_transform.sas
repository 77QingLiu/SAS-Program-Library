/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Shiva Bhimreddy, $LastChangedBy:  $
  Creation Date:         12AUG2015                       $LastChangedDate:  $
 
  Program Location/Name: $HeadURL: $
 
  Files Created:         None
 
  Program Purpose:       Lab Reconciliation of the raw lab dataset into SACQ format.

						 Note: Part of program: pfesacq_lab_recon 

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 


  Macro Output:  LB_CRF Dataset is created in the "/../dm/listings/current" Folder


-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev:  $
  
-----------------------------------------------------------------------------*/


*** Call the Macro that converts the raw Adverse Event EDC dataset into the SACQ format ***;

%macro pfesacq_lab_recon_edc_transform();


    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_LAB_RECON_EDC_TRANSOFRM: Start of Submacro;
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

	%if %sysfunc(exist(metadata.rec_lab_meta)) %then %do;

	proc sort data = metadata.rec_lab_meta out=test;
	    by date;
	run;

	data _null_;
		set test;
	    by date;
		if last.date then call symput('prevdate',left(trim(datec)));
	run;

	proc append base=metadata.rec_lab_meta data=test;
	run;

	proc sort data=metadata.rec_lab_meta nodupkey;
		by date;
	run;
													 %end;

	%else %do;

	proc append base=metadata.rec_lab_meta data=test;
	run;

	proc sort data=metadata.rec_lab_meta nodupkey;
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
		libname oldDir "&path_dm/datasets/download/&prevdate";
	%end;
    %else %do;
        libname oldDir "&path_dm/datasets/download/draft";
    %end;

	%if %sysfunc(exist(oldDir.&inds)) %then %do;


	%if "&database_type."  = "DATALABS" %then %do; %let keyvar=SCRNID PATEVTKY PATFRMKY EVTORDER EVTFRMKY GRPNAM ROW; %end;
	%if "&database_type."  = "OC"       %then %do; %let keyvar=DOCNUM ACTEVENT SUBJID;                                %end;




	proc sort data=olddir.&inds out=old;
		by &keyvar;
	run;

	proc sort data=download.&inds out=current;
		by &keyvar;
	run;

	libname olddir clear;


	*** Create the STATUS variable ***;

	data status;
		attrib STATUS1 length=$7 label='EDC Data State';
        merge old     (in=old rename=(%if &colldate= %then %do;%end; %else %do; &colldate=olddate  %end;
									  %if &lbcat=    %then %do;%end; %else %do; &lbcat=oldlbcat    %end;
									  %if &labsmpid= %then %do;%end; %else %do; &labsmpid=oldsmpid %end;
									  %if &lbtpt=    %then %do;%end; %else %do; &lbtpt=oldlbtpt    %end;))
              current (in=new rename=(%if &colldate= %then %do;%end; %else %do; &colldate=newdate  %end;
									  %if &lbcat=    %then %do;%end; %else %do; &lbcat=newlbcat    %end;
									  %if &labsmpid= %then %do;%end; %else %do; &labsmpid=newsmpid %end;
									  %if &lbtpt=    %then %do;%end; %else %do; &lbtpt=newlbtpt    %end;));
		by &keyvar;

		if old=1 and new=1 then status1="Old";

        %if &colldate= %then %do;%end; %else %do; if      old=1 and new=1 and olddate  ne newdate  then status1="Changed";%end;
        %if &lbcat=    %then %do;%end; %else %do; else if old=1 and new=1 and oldlbcat ne newlbcat then status1="Changed";%end;
        %if &labsmpid= %then %do;%end; %else %do; else if old=1 and new=1 and oldsmpid ne newsmpid then status1="Changed";%end;
        %if &lbtpt=    %then %do;%end; %else %do; else if old=1 and new=1 and oldlbtpt ne newlbtpt then status1="Changed";%end;

		if old=0 and new=1 then status1="New";

		if new;

		keep &keyvar status1;

	run;

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

	data lab1;
		set download.&inds(rename=(&colldate=colldate1));
	run;

	proc contents data=lab1 noprint out=lbcont;
	run;

	data _null_;
		set lbcont;
		where upcase(name)='COLLDATE1';
		if type ne . then typec = strip(put(type,best.));
		call symput ("lbdttype", typec);
	run;

	%if &testtime = %then %do;%end; %else %do;

	data lab1;
		set download.&inds(rename=(&testtime=testtime1));
	run;

	proc contents data=lab1 noprint out=lbcont;
	run;

	data _null_;
		set lbcont;
		where upcase(name)='TESTTIME1';
		if type ne . then typec = strip(put(type,best.));
		call symput ("lbtmtype", typec);
	run;
	%end;

	proc sql noprint;
		select count(*) into:visexist
		from lbcont
		where upcase(name)='VISIT';
		select count(*) into:lbnd2ex
		from lbcont
		where upcase(name)='LBND2';
		select count(*) into:lbnd3ex
		from lbcont
		where upcase(name)='LBND3';
	quit;

	%if &visitdt = %then %do;;%end; %else %do; 

			data lb2;
				set download.&inds (rename=(&visitdt=visitdt1));
			run;

			proc contents data=lb2 out=lbcont2 noprint;
			run;

			data _null_;
				set lbcont2;
				where upcase(name)='VISITDT1';
				if type ne . then typec = strip(put(type,best.));
				call symput ("visdttyp", typec);
			run;

										  %end;

	*** define the macro to check if a variable exists ***;

	%macro varexist(ds=,var=,result=);
		%local rc dsid;
		%let dsid=%sysfunc(open(&ds));
		%if %sysfunc(varnum(&dsid,&var)) >0 %then %do;
		       											%let &result=1;
			                                      %end;
		%else %do;
		       		%let &result=0;
			  %end;
		%let rc=%sysfunc(close(%dsid));
		%put Variable &var exists=&result;
	%mend varexist;

	*%varexist(ds=&inds,var=visit,result=visexist);


	data lab;

		attrib  STUDY     length = $200 label = 'Clinical Study'
				SITEID    length = $40  label = 'Center Identifier Within Study'
				SUBJID    length = $200 label = 'Subject ID'
				CPEVENT   length = $20  label = 'CPE Name'
				VISIT     length = $30  label = 'Visit'
				LBCAT     length = $40  label = 'Lab Classification'
				LNOTDONE  length = $30  label = 'Test not done indicator'
				VISITDT   length = $15  label = 'Visit Date'
				COLLDATE  length = $15  label = 'Collection Date'
				TESTTIME  length = $15  label = 'Collection Time'
				LBTPT     length = $20  label = 'Time Point'
				LABSMPID  length = $20  label = 'Unique lab sample id'
				INVCOM    length = $200 label = 'Investigator Comment';

		set current (%if &visexist = 1 %then %do;/*drop=visit*/ %end;
							rename=(&study=study1 &subjid=subjid1 &cpevent=cpevent1 
									%if &siteid  = %then %do;%end; %else %do; &siteid=siteid1     %end;
									%if &visit   = %then %do;%end; %else %do; &visit=visit1       %end;
									%if &lbcat   = %then %do;%end; %else %do; &lbcat=lbcat1       %end;
									%if &testtime= %then %do;%end; %else %do; &testtime=testtime1 %end;
									%if &labsmpid= %then %do;%end; %else %do; &labsmpid=labsmpid1 %end;
									%if &lnotdone= %then %do;%end; %else %do; &lnotdone=lnotdone1 %end;
									%if &colldate= %then %do;%end; %else %do; &colldate=colldate1 %end;
									%if &visitdt = %then %do;%end; %else %do; &visitdt=visitdt1   %end;
									%if &lbtpt   = %then %do;%end; %else %do; &lbtpt=lbtpt1       %end;
									%if &invcom  = %then %do;%end; %else %do; &invcom  =invcom11  %end;
                                      ));


		*** Select only central lab records for Datalabs studies ***;
		%if "&database_type."  = "DATALABS" %then %do;
												*clab1=scan(grpnam,2,'_');
												*clab2=scan(grpnam,3,'_');
												*if clab1='S1' or clab2='S1' then clab='Y';
												*if clab = 'Y' and (&lbnum='') ;  

												if upcase(formnam) in (&formname.); 
		                                	 %end;

		study    = upcase(study1);
		subjid   = compress(subjid1,'-|_ ');
		cpevent  = upcase(cpevent1);

		%if &lbcat=    %then %do; lbcat    = ''; %end; %else %do; 
																lbcat = upcase(lbcat1);
																if index(lbcat1,'-')>0 then lbcat = upcase(strip(scan(lbcat1,2,'-')));
																if lbcat = 'CHEMISTRY (LABC)'  then lbcat = 'CHEMISTRY';
																if lbcat = 'HEMATOLOGY (LABH)' then lbcat = 'HEMATOLOGY';
																if lbcat = 'URINALYSIS (LABU)' then lbcat = 'URINALYSIS';
																if lbcat = 'SERUM PREGNANCY (HCG)' then lbcat = 'PREGNANCY';
																if lbcat = 'QUANTIFERON TB GOLD' then lbcat = 'TB';
																if lbcat = 'HIV AB 1/AB' then lbcat = 'HIV';

																if index(upcase(lbcat1), 'ANTI-dsDNA ANTIBODY')>0 then lbcat = 'ANTI-DSDNA ANTIBODY';
																if lbcat1 = 'LABORATORY DATA - ANTI-dsDNA ANTIBODY' then lbcat = 'ANTI-DSDNA ANTIBODY';
																if lbcat1 = 'CENTRAL LABORATORY DATA - ANTI-dsDNA ANTIBODY' then lbcat = 'ANTI-DSDNA ANTIBODY';

																if index(upcase(lbcat1),'BETA-D-GLUCAN')>0 then lbcat = 'BETA-D-GLUCAN';
																if lbcat1 = 'CENTRAL LABORATORY DATA - BETA-D-GLUCAN' then lbcat = 'BETA-D-GLUCAN';
																if lbcat1 = 'LABORATORY DATA - BETA-D-GLUCAN' then lbcat = 'BETA-D-GLUCAN';

															  %end;
		%if &lnotdone= %then %do; lnotdone = ''; %end; %else %do;
																%if &lbnd2ex=1 and &lbnd3ex=1 %then %do;lnotdone = compress(lnotdone1||lbnd2||lbnd3); %end;
																%if &lbnd2ex=1 and &lbnd3ex=0 %then %do;lnotdone = compress(lnotdone1||lbnd2); %end;
																%if &lbnd2ex=0 and &lbnd3ex=0 %then %do;lnotdone = compress(lnotdone1); %end;

																if lnotdone='1' then lnotdone='NOT DONE';
																if lnotdone='2' then lnotdone='DONE';
																if lnotdone='NOTDONE' then lnotdone='NOT DONE';
															 %end;

		%if &siteid= %then %do; siteid = ''; %end; %else %do; siteid = upcase(siteid1); %end;
		%if &visit = %then %do; visit  = ''; %end; %else %do; visit  = strip(upcase(tranwrd(visit1,'VISIT',''))); %end;

		%if &labsmpid= %then %do; labsmpid = ''; %end; %else %do; labsmpid = upcase(labsmpid1); %end;
		%if &invcom  = %then %do; invcom   = ''; %end; %else %do; invcom   = invcom11;  %end;
		%if &lbtpt   = %then %do; lbtpt    = ''; %end; %else %do; lbtpt    = strip(lbtpt1);  %end;

		%if &testtime= %then %do; testtime = ''; %end; 
		%else %do; 
				%if       &lbtmtype=1 %then %do;testtime = strip(put(testtime1,time5.));%end;
				%if       &lbtmtype=2 %then %do;
												testtime2=testtime1;
												testtime1=compress(upcase(testtime1),'AMPM');
												testtime = tranwrd(testtime1,'-',':');
												if index(testtime2,'PM')>0 then testtime=strip(put(input(testtime1,time5.)+(12*60*60),time5.));
												if index(upcase(testtime),'X')>0 or length(testtime) in (1 2 3) then testtime='';
											%end;
			 %end;

		*** Collection Date ***;

		%if       &lbdttype=1 %then %do;colldate = strip(put(colldate1,date9.));%end;
		%else %if &lbdttype=2 %then %do;

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
	lbcat=upcase(lbcat);

	run;

	proc sort data=lab;
		by study subjid;
	run;

	*** Call the Macro that converts the raw Denographics EDC dataset into the SACQ format ***;

	%let create_dated_dir = Y ;
	%mu_create_dated_dir(type=listings) ;

	libname outdir "&path_listings./current";

	%pfesacq_sae_recon_dem_transform();


	%if %sysfunc(exist(outdir.dm_crf)) %then %do;

												data lab;
													merge lab(in=a) outdir.dm_crf;
													by study subjid;
													if a;
												run;

											  %end;

	%else %do;

				data lab;
					attrib SEX  length = $200 label = 'Gender Code'
						   DOB  length = $200 label = 'Date of Birth';
					set lab(in=a);
					sex='';
					dob='';
				run;

	%end;

	proc sort data=lab;
		by study siteid subjid visit colldate testtime;
	run;

	data outdir.lb_crf;
		set lab;
		keep study siteid subjid sex dob cpevent visitdt visit lbcat lbtpt lnotdone labsmpid colldate testtime invcom status1;
	run;

	proc datasets library=work nolist;
		delete status current test lab lab1 lb2 lbcont lbcont2 old;
	quit;

	%end;

	%else %do;
    			%put %str(ERR)OR:[PXL]------------------------------------------------------------------------;
    			%put %str(ERR)OR:[PXL] PFESACQ_LAB_RECON_EDC_TRANSOFRM: alert: Dataset &inds does not exist.;
    			%put %str(ERR)OR:[PXL]------------------------------------------------------------------------;
		  %end;


	%goto macend;
	%macerr:;
	%put %str(ERR)OR:[PXL] -------------------------------------------------------------------------------------;
	%put %str(ERR)OR:[PXL] PFESACQ_LAB_RECON_EDC_TRANSOFRM: The input dataset &inds has zero (0) observations.;
	%put %str(ERR)OR:[PXL] -------------------------------------------------------------------------------------;



    %macend:;
    %put ;
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_LAB_RECON_EDC_TRANSOFRM: End of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_lab_recon_edc_transform;






