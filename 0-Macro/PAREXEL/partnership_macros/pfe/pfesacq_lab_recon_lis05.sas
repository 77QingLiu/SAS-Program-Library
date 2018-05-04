/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Shiva Bhimreddy, $LastChangedBy:  $
  Creation Date:         03SEP2015                       $LastChangedDate:  $
 
  Program Location/Name: $HeadURL: $
 
  Files Created:         None
 
  Program Purpose:       Creates the LIS05 dataset for missing protocol tests
                         for protocol visits in the Vendor lab dataset.
 
						 Note: Part of program: pfesacq_lab_recon 

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:
 


  Macro Output:          LIS05 dataset in WORK library


-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev:  $
  
-----------------------------------------------------------------------------*/


%macro pfesacq_lab_recon_lis05();


    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_LAB_RECON_LIS05: Start of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

	libname outdir "&path_listings./current";

	%if %sysfunc(exist(outdir.lbedata)) %then %do;

	*** Import the protocol visits document ***;

	proc import datafile = "&path_dm/documents/lab_recon/current/%lowcase(&protocol.) lab recon specs.xls"
	            out      = protvis 
				dbms     = xls replace;
				sheet    = "Test required at Visit";
				getnames = no;
				startrow = 2;
	run;

	data protvis;
		length cpevent $20 lbcat1 $40;
		set protvis;
		cpevent=upcase(compress(a, ,'kw'));
		lbcat1=upcase(compress(c, ,'kw'));
		keep cpevent lbcat1;
	run;

	proc sort data=protvis nodupkey;
		by cpevent lbcat1;
		where cpevent not in (''/*,'UNSCHEDULED'*/) and lbcat1 ne '';
	run;

	proc sql noprint;
		select count(distinct(cpevent)) into:nvis
		from protvis;
	quit;

	%if &nvis>0 %then %do;


	*** Import the protocol tests document ***;

	proc import datafile = "&path_dm/documents/lab_recon/current/%lowcase(&protocol.) lab recon specs.xls"
	            out      = prottest 
				dbms     = xls replace;
				sheet    = "Lab Tests";
				getnames = no;
				startrow = 2;
	run;

	data prottest;
		length lbtstid $20 lbcat $40 lbtest $100 pxcode $30;
		set prottest;
		lbtstid=upcase(compress(d, ,'kw'));
		lbcat=upcase(compress(a, ,'kw'));
		lbtest=upcase(strip(compress(b, ,'kw')));
		pxcode=strip(upcase(compress(put(c,best.), ,'kw')));
		keep lbcat lbtstid pxcode lbtest;
	run;

	proc sort data=prottest nodupkey;
		by lbcat lbtstid pxcode;
		where lbcat ne '' and lbtstid ne '' and pxcode ne '';
	run;

	proc sort data=protvis nodupkey;
		by lbcat1 cpevent;
	run;

	proc sql noprint;
		create table exptest as
		select *
		from  protvis b , prottest c
		where (b.lbcat1=c.lbcat );
	quit;

	proc sort data=outdir.lbedata out=subjid(keep=subjid) nodupkey;
		by subjid;
	run;

	*** Create the dataset with all visits and tests combination ***;

	proc sql noprint;
		create table vistest as
		select *
		from subjid a, exptest b;
	quit;

	proc sort data=vistest;
		by subjid cpevent lbcat lbtstid pxcode;
	run;

	*** Sort the dataset by Test ID, Study, Subject and Visit ***;

	proc sort data=outdir.lbedata out=edata;
		by subjid cpevent lbcat lbtstid pxcode lbtest colldate;
	run;

	data edata;
		set edata;
		cpevent=upcase(cpevent);
		lbcat=upcase(lbcat);
		lbtest=upcase(lbtest);
	run;

	proc sort data=edata;
		by subjid cpevent lbcat lbtstid pxcode lbtest;
	run;

	proc sort data=edata out=select nodupkey;
		by subjid cpevent;
	run;

	data vistest;
		merge vistest(in=a) select(in=b keep=subjid cpevent);
		by subjid cpevent;
		if a and b;   *** to select subject visits that occured ***;
		cpevent=upcase(cpevent);
		lbcat=upcase(lbcat);
		lbtest=upcase(lbtest);
		drop lbcat1;
	run;


	*** Get Unscheduled records ***;

	proc sort data=outdir.lbedata out=uns(rename=(lbcat=lbcat1) keep=lbcat subjid cpevent) nodupkey;
		by subjid cpevent lbcat;
		where index(upcase(cpevent),'UNSCHEDULED')>0;
	run;

	data uns;
		set uns;
		cpevent=upcase(cpevent);
		lbcat1=upcase(lbcat1);
	run;

	data prottest;
		set prottest;
		lbcat=upcase(lbcat);
	run;

	proc sql noprint;
		create table unstest as
		select *
		from  uns b , prottest c
		where (b.lbcat1=c.lbcat );
	quit;

	data vistest;
		set vistest unstest;
		lbtest=upcase(lbtest);
	run;

	proc sort data=vistest nodupkey;
		by subjid cpevent lbcat lbtstid pxcode lbtest;
	run;

	****************************;
	*** Create LIS05 dataset ***;
	****************************;

	data lis05;
		length flag $40;
		merge vistest(in=a) edata(in=b /*drop=lbtest*/);
		by subjid cpevent lbcat lbtstid pxcode lbtest;

		if a=1 and b=0;

		study="&protocol.";


		flagn=5;
		flag='Missing Test';

	run;

	%end;

	%if &nvis=0 %then %do;

	data lis05;
		length flag $40;
		flagn=.;
		flag='';
	run;

	%end;

	proc datasets lib=work;
		delete edata prottest protvis exptest vistest uns unstest subjid select;
	quit;
	run;

	%end;

	%else %do;
    			%put %str(ERR)OR:[PXL]----------------------------------------------------------------;
    			%put %str(ERR)OR:[PXL] PFESACQ_LAB_RECON_LIS05: alert: Dataset LBEDATA does not exist.;
    			%put %str(ERR)OR:[PXL]----------------------------------------------------------------;
		  %end;

    %macend:;
    %put ;
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_LAB_RECON_LIS05: End of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_lab_recon_lis05;


*%pfesacq_lab_recon_lis05;

/*
	proc import datafile = "&path_dm/documents/lab_recon/current/Copy of B5371002_Lab Vendor Transfer_DUMMY.xls"
	            out      = edata.lab_dummy 
				dbms     = xls replace;
				sheet    = "b5371002_lab";
				getnames = yes;
				startrow = 3;
	run;

*/