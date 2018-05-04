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
 
  Program Purpose:       PK Reconciliation of the EDC and vendor PK dataset and
                         save the reconciliation records in PKRECON dataset.
 
						 Note: Part of program: pfesacq_pk_recon 

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:
 


  Macro Output:          PKARECON dataset is created in the "/unblinded/pfizr&pxl_code./dm/listings/current" Folder


-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev:  $
  
-----------------------------------------------------------------------------*/


*** Call the Macro that converts the raw Adverse Event EDC dataset into the SACQ format ***;

%macro pfesacq_pk_recona_flags();


    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_PK_RECONA_FLAGS: Start of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

	%do i=1 %to &apknum;

	%if %sysfunc(exist(unblind.pk_crf)) and %sysfunc(exist(unblind.pkadata&i)) %then %do;




	********************************************;
	*** Create datasets with PK Recon Flags ***;
	********************************************;

	****************************;
	*** OK, eCRF/Vendor only ***;
	****************************;

	proc sort data=unblind.pk_crf out=edc;
		by study siteid subjid randnum visit pktpt pksmpid;
	run;


	proc sort data=unblind.pkadata&i out=edata nodupkey;
		by study siteid subjid randnum visit pktpt pksmpid;
	run;
	
	data recon0 recon1 recon2;
		length flag $40;
		merge edc  (in=a) 
			  edata(in=b /*rename=(invcom=pk_com)*/ );
		by study siteid subjid randnum visit pktpt pksmpid;

		if a=1 then clinstdy=study;
		if b=1 then vendstdy=study;

		if a=1 then clinsite=siteid;
		if b=1 then vendsite=siteid;

		if a=1 then clinsubj=subjid;
		if b=1 then vendsubj=subjid;

		if a=1 then clinrnum=randnum;
		if b=1 then vendrnum=randnum;

		if a=1 then clinvis=visit;
		if b=1 then vendvis=visit;

		if a=1 then clintpt=pktpt;
		if b=1 then vendtpt=pktpt;

		if a=1 then clinsmpid=pksmpid;
		if b=1 then vendsmpid=pksmpid;

		if (a=1 and b=0) or (a=0 and b=1) then mismatch=1;

		if a=1 and b=1 then do; recon=0; flag = 'OK';  output recon0; end;

		if a=1 and b=0 and upcase(pnotdone) =  'NOT DONE' then do; recon=0; flag = 'OK'; output recon0; end;

		if a=1 and b=0 and upcase(pnotdone) ne 'NOT DONE' then do; recon=1; flag = 'CRF/eCRF only'; output recon1; end;

		if a=0 and b=1 then do; recon=2; flag = 'Vendor only'; output recon2; end;

	run;

	**************************;
	*** Sample ID Mismatch ***;
	**************************;

	proc sort data=unblind.pk_crf out=edc;
		by study siteid subjid randnum visit pktpt;
	run;

	proc sort data=unblind.pkadata&i out=edata nodupkey;
		by study siteid subjid randnum visit pktpt;
	run;
	

	*** Create dataset with Sample ID mismatch Flags ***;
				
	data recon3;
		length flag $40;
		merge edc  (in=a rename=(pksmpid=clinsmpid) ) 
			  edata(in=b rename=(/*invcom=pk_com*/ pksmpid=vendsmpid) );
		by study siteid subjid randnum visit pktpt;

		if (a=1 and b=0) or (a=0 and b=1) then mismatch=1;

		if a=1 then clinstdy=study;
		if b=1 then vendstdy=study;

		if a=1 then clinsite=siteid;
		if b=1 then vendsite=siteid;

		if a=1 then clinsubj=subjid;
		if b=1 then vendsubj=subjid;

		if a=1 then clinrnum=randnum;
		if b=1 then vendrnum=randnum;

		if a=1 then clinvis=visit;
		if b=1 then vendvis=visit;

		if a=1 then clintpt=pktpt;
		if b=1 then vendtpt=pktpt;
		
		if a=1 and b=1 and upcase(clinsmpid) ne upcase(vendsmpid) then do;
															recon=3; flag = 'Sample ID mismatch'; output recon3; 
												                       end;
		
	run;


	*** Delete records which have eCRF only or Vendor only ***;

	proc sort data=recon3;
		by study siteid subjid randnum visit pktpt;
	run;

	proc sort data=recon1;
		by study siteid subjid randnum visit pktpt;
	run;
	data recon1;
		merge recon1(in=a) recon3(in=b);
		by study siteid subjid randnum visit pktpt;
		if a;
		if b=1  then delete;
	run;

	data recon3;
		set recon3;
		if vendsmpid ne '' then pksmpid=vendsmpid;
	run;

	*** Delete records which have Vendor only or Vendor only ***;

	proc sort data=recon2;
		by study siteid subjid randnum visit pktpt;
	run;
	data recon2;
		merge recon2(in=a) recon3(in=b);
		by study siteid subjid randnum visit pktpt;
		if a;
		if b=1  then delete;
	run;

	**************************;
	*** Timepoint Mismatch ***;
	**************************;

	proc sort data=unblind.pk_crf out=edc;
		by study siteid subjid randnum visit pksmpid;
	run;

	proc sort data=unblind.pkadata&i out=edata nodupkey;
		by study siteid subjid randnum visit pksmpid;
	run;
	

	*** Create dataset with Timepoint mismatch Flags ***;
				
	data recon4;
		length flag $40;
		merge edc  (in=a rename=(pktpt=clintpt) ) 
			  edata(in=b rename=(/*invcom=pk_com*/ pktpt=vendtpt) );
		by study siteid subjid randnum visit pksmpid;

		if (a=1 and b=0) or (a=0 and b=1) then mismatch=1;

		if a=1 then clinstdy=study;
		if b=1 then vendstdy=study;

		if a=1 then clinsite=siteid;
		if b=1 then vendsite=siteid;

		if a=1 then clinsubj=subjid;
		if b=1 then vendsubj=subjid;

		if a=1 then clinrnum=randnum;
		if b=1 then vendrnum=randnum;

		if a=1 then clinvis=visit;
		if b=1 then vendvis=visit;

		if a=1 then clinsmpid=pksmpid;
		if b=1 then vendsmpid=pksmpid;
		
		if a=1 and b=1 and upcase(clintpt) ne upcase(vendtpt) then do;
															recon=4; flag = 'Timepoint mismatch'; output recon4; 
												                       end;
		
	run;


	*** Delete records which have eCRF only or Vendor only ***;

	proc sort data=recon4;
		by study siteid subjid randnum visit pksmpid;
	run;

	proc sort data=recon1;
		by study siteid subjid randnum visit pksmpid;
	run;
	data recon1;
		merge recon1(in=a) recon4(in=b);
		by study siteid subjid randnum visit pksmpid;
		if a;
		if b=1  then delete;
	run;

	*** Delete records which have Vendor only or Vendor only ***;

	proc sort data=recon2;
		by study siteid subjid randnum visit pksmpid;
	run;
	data recon2;
		merge recon2(in=a) recon4(in=b);
		by study siteid subjid randnum visit pksmpid;
		if a;
		if b=1  then delete;
	run;



	************************;
	***  Visit Mismatch  ***;
	************************;

	proc sort data=unblind.pk_crf out=edc;
		by study siteid subjid randnum pksmpid pktpt;
	run;

	proc sort data=unblind.pkadata&i out=edata nodupkey;
		by study siteid subjid randnum pksmpid pktpt;
	run;
	

	*** Create dataset with visit mismatch Flags ***;
				
	data recon5;
		length flag $40;
		merge edc  (in=a rename=(visit=clinvis) ) 
			  edata(in=b rename=(/*invcom=pk_com*/ visit=vendvis) );
		by study siteid subjid randnum pksmpid pktpt;

		if (a=1 and b=0) or (a=0 and b=1) then mismatch=1;

		if a=1 then clinstdy=study;
		if b=1 then vendstdy=study;

		if a=1 then clinsite=siteid;
		if b=1 then vendsite=siteid;

		if a=1 then clinsubj=subjid;
		if b=1 then vendsubj=subjid;

		if a=1 then clinrnum=randnum;
		if b=1 then vendrnum=randnum;

		if a=1 then clintpt=pktpt;
		if b=1 then vendtpt=pktpt;

		if a=1 then clinsmpid=pksmpid;
		if b=1 then vendsmpid=pksmpid;
		
		if a=1 and b=1 and upcase(clinvis) ne upcase(vendvis) then do;
															recon=5; flag = 'Visit mismatch'; output recon5; 
												                       end;
		
	run;


	*** Delete records which have eCRF only or Vendor only ***;

	proc sort data=recon5;
		by study siteid subjid randnum pksmpid pktpt;
	run;

	proc sort data=recon1;
		by study siteid subjid randnum pksmpid pktpt;
	run;
	data recon1;
		merge recon1(in=a) recon5(in=b);
		by study siteid subjid randnum pksmpid pktpt;
		if a;
		if b=1  then delete;
	run;

	*** Delete records which have Vendor only or Vendor only ***;

	proc sort data=recon2;
		by study siteid subjid randnum pksmpid pktpt;
	run;
	data recon2;
		merge recon2(in=a) recon5(in=b);
		by study siteid subjid randnum pksmpid pktpt;
		if a;
		if b=1  then delete;
	run;


	***************************************;
	***  Randomization Number Mismatch  ***;
	***************************************;

	proc sort data=unblind.pk_crf out=edc;
		by study siteid subjid visit pksmpid pktpt;
	run;

	proc sort data=unblind.pkadata&i out=edata nodupkey;
		by study siteid subjid visit pksmpid pktpt;
	run;
	

	*** Create dataset with randomization number mismatch Flags ***;
				
	data recon6;
		length flag $40;
		merge edc  (in=a rename=(randnum=clinrnum) ) 
			  edata(in=b rename=(/*invcom=pk_com*/ randnum=vendrnum) );
		by study siteid subjid visit pksmpid pktpt;

		if (a=1 and b=0) or (a=0 and b=1) then mismatch=1;

		if a=1 then clinstdy=study;
		if b=1 then vendstdy=study;

		if a=1 then clinsite=siteid;
		if b=1 then vendsite=siteid;

		if a=1 then clinsubj=subjid;
		if b=1 then vendsubj=subjid;

		if a=1 then clinvis=visit;
		if b=1 then vendvis=visit;

		if a=1 then clintpt=pktpt;
		if b=1 then vendtpt=pktpt;

		if a=1 then clinsmpid=pksmpid;
		if b=1 then vendsmpid=pksmpid;
		
		if a=1 and b=1 and upcase(clinrnum) ne upcase(vendrnum) then do;
															recon=6; flag = 'Randomization Number mismatch'; output recon6; 
												                       end;
		
	run;


	*** Delete records which have eCRF only or Vendor only ***;

	proc sort data=recon6;
		by study siteid subjid visit pksmpid pktpt;
	run;

	proc sort data=recon1;
		by study siteid subjid visit pksmpid pktpt;
	run;
	data recon1;
		merge recon1(in=a) recon6(in=b);
		by study siteid subjid visit pksmpid pktpt;
		if a;
		if b=1  then delete;
	run;

	*** Delete records which have Vendor only or Vendor only ***;

	proc sort data=recon2;
		by study siteid subjid visit pksmpid pktpt;
	run;
	data recon2;
		merge recon2(in=a) recon6(in=b);
		by study siteid subjid visit pksmpid pktpt;
		if a;
		if b=1  then delete;
	run;



	*** Concatenate all Recon datasets ***;

	data pkrecon;
		attrib STATUS length =$7 label = 'Data State';
		set recon0 recon1 recon2 recon3 recon4 recon5 recon6;

		if subjid='' and clinsubj ne '' then subjid=clinsubj;
		if subjid='' and vendsubj ne '' then subjid=vendsubj;
		status2='';

		if      status1 =  ''        and status2 ne ''        then status=status2;
		else if status1 ne ''        and status2 =  ''        then status=status1;
		else if status1 =  'New'     and status2 =  'New'     then status='New';
		else if status1 =  'New'     and status2 =  'Old'     then status='New';
		else if status1 =  'New'     and status2 =  'Changed' then status='New';
		else if status1 =  'Old'     and status2 =  'New'     then status='New';
		else if status1 =  'Old'     and status2 =  'Old'     then status='Old';
		else if status1 =  'Old'     and status2 =  'Changed' then status='Changed';
		else if status1 =  'Changed' and status2 =  'New'     then status='New';
		else if status1 =  'Changed' and status2 =  'Old'     then status='Changed';
		else if status1 =  'Changed' and status2 =  'Changed' then status='Changed';

		*if colldate ne '' and index(colldate,'*')=0 then colldtn = input(colldate,date9.);

		if subjid = '' and clinsubj = '' and vendsubj ='' then delete;

		*format colldtn date9.;

	run;

	proc sort data=pkrecon nodupkey;
		by study clinstdy vendstdy 
		   siteid clinsite vendsite
		   subjid clinsubj vendsubj 
		   visit clinvis vendvis
           pktpt clintpt vendtpt 
           pksmpid clinsmpid vendsmpid
		   /*invcom pk_com*/ recon flag;
	run;

	*%mu_incremental(labrecon);

	data unblind.pkarecon&i;
		set pkrecon;

		if study='' and clinstdy ne '' then study=clinstdy;
		if study='' and vendstdy ne '' then study=vendstdy;

		if siteid='' and clinsite ne '' then siteid=clinsite;
		if siteid='' and vendsite ne '' then siteid=vendsite;

		if subjid='' and clinsubj ne '' then subjid=clinsubj;
		if subjid='' and vendsubj ne '' then subjid=vendsubj;

		if visit='' and clinvis ne '' then visit=clinvis;
		if visit='' and vendvis ne '' then visit=vendvis;
	run;

	proc datasets lib=work;
		delete edc edata recon0 recon1 recon2 recon3 recon4 recon5 recon6 pkrecon edc1 edata1;
	quit;
	run;


	%end;



	%else %do;
    			%put %str(ERR)OR:[PXL]---------------------------------------------------------------------------;
    			%put %str(ERR)OR:[PXL] PFESACQ_PK_RECONC_FLAGS: alert: Dataset PK_CRF or PKADATA&i does not exist.;
    			%put %str(ERR)OR:[PXL]---------------------------------------------------------------------------;
		  %end;

%end;


    %macend:;
    %put ;
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_PK_RECONA_FLAGS: End of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_pk_recona_flags;

