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
 
  Program Purpose:       Lab Reconciliation of the EDC and vendor lab dataset and
                         save the reconciliation records in LABRECON dataset.
 
						 Note: Part of program: pfesacq_lab_recon 

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:
 


  Macro Output:          LABRECON dataset is created in the "/../dm/listings/current" Folder


-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev:  $
  
-----------------------------------------------------------------------------*/


*** Call the Macro that converts the raw Adverse Event EDC dataset into the SACQ format ***;

%macro pfesacq_lab_recon_flags();


    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_LAB_RECON_FLAGS: Start of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

	*** Sort the 2 datasets by Study, subject, visit, colldate testtime and lbcat ***;

	%if "&testtime" ne "" %then %do; 
									%let labtime1=testtime;
						 			%end;
	%if "&testtime" =  "" %then %do; 
									%let labtime1=;
						 			%end;

	%if "&lbcat" ne "" %then %do; 
									%let lbcat1=lbcat;
						 			%end;
	%if "&lbcat" =  "" %then %do; 
									%let lbcat1=;
						 			%end;

	%if "&lbtpt" ne "" %then %do; 
									%let lbtpt1=lbtpt;
						 	   %end;
	%if "&lbtpt" =  "" %then %do; 
									%let lbtpt1=;
						 	   %end;


	%if "&labsmpid" ne "" %then %do; 
									%let labsmpid1=labsmpid;
						 	   %end;
	%if "&labsmpid" =  "" %then %do; 
									%let labsmpid1=;
						 	   %end;


	%if %sysfunc(exist(outdir.lb_crf)) and %sysfunc(exist(outdir.lbedata)) %then %do;




	********************************************;
	*** Create datasets with Lab Recon Flags ***;
	********************************************;

	****************************;
	*** OK, eCRF/Vendor only ***;
	****************************;

	proc sort data=outdir.lb_crf out=edc;
		by subjid cpevent colldate &lbcat1 &labtime1 &lbtpt1 &labsmpid1;
	run;


	proc sort data=outdir.lbedata out=edata(drop=lnotdone) nodupkey;
		by subjid cpevent colldate &lbcat1 &labtime1 &lbtpt1 &labsmpid1;
	run;
	
	data recon0 recon1 recon2;
		length flag $40;
		merge edc  (in=a) 
			  edata(in=b rename=(invcom=lab_com) );
		by subjid cpevent colldate &lbcat1 &labtime1 &lbtpt1 &labsmpid1;

		if a=1 then clinstdy=study;
		if b=1 then vendstdy=study;

		if a=1 then clinsubj=subjid;
		if b=1 then vendsubj=subjid;

		if a=1 then clinvis=cpevent;
		if b=1 then vendvis=cpevent;

		if a=1 then clindt=colldate;
		if b=1 then venddt=colldate;

		if a=1 and "&testtime" ne "" then clintm=testtime;
		if b=1 then vendtm=testtime;

		if a=1 then clincat=lbcat;
		if b=1 then vendcat=lbcat;



		%if &lbtpt1 = %then %do;clintpt='';vendtpt='';%end;
		%else %do;
			if a=1 then clintpt=&lbtpt1;
			if b=1 then vendtpt=&lbtpt1;
		      %end;

		if a=1 then clinsmpid=labsmpid;
		if b=1 then vendsmpid=labsmpid;

		if (a=1 and b=0) or (a=0 and b=1) then mismatch=1;

		if a=1 and b=1 then do; recon=0; flag = 'OK';  output recon0; end;

		if a=1 and b=0 and upcase(lnotdone) =  'NOT DONE' then do; recon=0; flag = 'OK'; output recon0; end;

		if a=1 and b=0 and upcase(lnotdone) ne 'NOT DONE' then do; recon=1; flag = 'CRF/eCRF only'; if clincat ne vendcat or clincat='' then classmis='Yes';else classmis='No'; output recon1; end;

		if a=0 and b=1 then do; recon=2; flag = 'Vendor only'; if clincat ne vendcat or vendcat='' then classmis='Yes';else classmis='No';   output recon2; end;

	run;

	**************************;
	*** Date/Time Mismatch ***;
	**************************;

	proc sort data=outdir.lb_crf out=edc;
		by subjid cpevent &lbcat1 &lbtpt1 &labsmpid1 colldate testtime;
	run;

	proc sort data=outdir.lbedata out=edata(drop=lnotdone) nodupkey;
		by subjid cpevent &lbcat1 &lbtpt1 &labsmpid1 colldate testtime;
	run;

	*** Create dataset with date/time mismatch Flags ***;
				
	data recon3;
		length flag $40;
		merge edc  (in=a rename=(colldate=clindt testtime=clintm) ) 
			  edata(in=b rename=(invcom=lab_com colldate=venddt testtime=vendtm) );
		by subjid cpevent &lbcat1 &lbtpt1 &labsmpid1;

		if (a=1 and b=0) or (a=0 and b=1) then mismatch=1;

		if a=1 then clinstdy=study;
		if b=1 then vendstdy=study;

		if a=1 then clinsubj=subjid;
		if b=1 then vendsubj=subjid;

		if a=1 then clinvis=cpevent;
		if b=1 then vendvis=cpevent;

		if a=1 then clincat=lbcat;
		if b=1 then vendcat=lbcat;

		%if &lbtpt1 = %then %do;clintpt='';vendtpt='';%end;
		%else %do;
			if a=1 then clintpt=&lbtpt1;
			if b=1 then vendtpt=&lbtpt1;
		      %end;

		if a=1 then clinsmpid=labsmpid;
		if b=1 then vendsmpid=labsmpid;

		if clinsubj=vendsubj and clinvis=vendvis and clinsmpid=vendsmpid and clincat=vendcat and clintpt=vendtpt and
           ((clindt ne venddt and clindt ne '') or (clintm ne vendtm and clintm ne '') ) then do;
					recon=3; flag = 'Date/Time mismatch'; output recon3; 
																							  end;

	run;

	*** Delete records which have eCRF only or Vendor only ***;

	proc sort data=recon3;
		by subjid cpevent &lbcat1 &lbtpt1 &labsmpid1;
	run;

	proc sort data=recon1;
		by subjid cpevent &lbcat1 &lbtpt1 &labsmpid1;
	run;
	data recon1;
		merge recon1(in=a) recon3(in=b);
		by subjid cpevent &lbcat1 &lbtpt1 &labsmpid1;
		if a;
		if b=1  then delete;
	run;

	proc sort data=recon2;
		by subjid cpevent &lbcat1 &lbtpt1 &labsmpid1;
	run;
	data recon2;
		merge recon2(in=a) recon3(in=b);
		by subjid cpevent &lbcat1 &lbtpt1 &labsmpid1;
		if a;
		if b=1  then delete;
	run;

	*******************************;
	*** Classification Mismatch ***;
	*******************************;
/*
	proc sort data=outdir.lb_crf out=edc;
		by subjid cpevent colldate &labtime1 &lbtpt1 &labsmpid1 &lbcat1;
		where lnotdone ne 'NOT DONE';
	run;

	proc sort data=outdir.lbedata out=edata(drop=lnotdone) nodupkey;
		by subjid cpevent colldate &labtime1 &lbtpt1 &labsmpid1 &lbcat1 ;*invcom;
		*where lbcat ne '';
	run;

	*** Create dataset with classification mismatch Flags ***;
			
	data edc1 edata1;
		merge edc  (in=a  ) 
			  edata(in=b rename=(invcom=lab_com ) );
		by subjid cpevent colldate &labtime1 &lbtpt1 &labsmpid1 &lbcat1;

		if a and b then delete;

		if (a=1 and b=0) or (a=0 and b=1) then mismatch=1;

		if a=1 then clinstdy=study;
		if b=1 then vendstdy=study;

		if a=1 then clinsubj=subjid;
		if b=1 then vendsubj=subjid;

		if a=1 then clinvis=cpevent;
		if b=1 then vendvis=cpevent;

		if a=1 then clindt=colldate;
		if b=1 then venddt=colldate;


		%if &labtime1 = %then %do;clintm='';vendtm=testtime;%end; %else %do;
			if a=1 then clintm=&labtime1;
			if b=1 then vendtm=&labtime1;
								              %end;

		%if &lbtpt1 = %then %do;clintpt='';vendtpt='';%end;
		%else %do;
			if a=1 then clintpt=&lbtpt1;
			if b=1 then vendtpt=&lbtpt1;
		      %end;

		if a=1 then clinsmpid=labsmpid;
		if b=1 then vendsmpid=labsmpid;

		if a=1 then clincat=lbcat;
		if b=1 then vendcat=lbcat;

		if a=1 and b=0 then output edc1;
		if a=0 and b=1 then output edata1;

		*if a=1 or b=1 then output recon4;

	run;

	data recon4;
		length flag $40;
		merge edc1  (in=a drop=vendcat vendsmpid venddt vendvis vendsubj vendstdy) 
			  edata1(in=b drop=clincat clinsmpid clindt clinvis clinsubj clinstdy);
		by subjid cpevent colldate &labtime1 &lbtpt1 &labsmpid1;
		if clincat ne '' and vendcat ne '';
		if a and b;
		recon=4;
		flag = 'Classification mismatch';
	run;


	*** Delete records which have eCRF only or Vendor only ***;

	proc sort data=recon4;
		by subjid cpevent colldate &labtime1 &lbtpt1 &labsmpid1 &lbcat1;
	run;

	proc sort data=recon1;
		by subjid cpevent colldate &labtime1 &lbtpt1 &labsmpid1 &lbcat1;
	run;
	data recon1;
		merge recon1(in=a) recon4(in=b);
		by subjid cpevent colldate &labtime1 &lbtpt1 &labsmpid1 &lbcat1;
		if a;
		if b=1  then delete;
	run;

	proc sort data=recon2;
		by subjid cpevent colldate &labtime1 &lbtpt1 &labsmpid1 &lbcat1;
	run;
	data recon2;
		merge recon2(in=a) recon4(in=b);
		by subjid cpevent colldate &labtime1 &lbtpt1 &labsmpid1 &lbcat1;
		if a;
		if b=1  then delete;
	run;
*/
	**************************;
	*** Sample ID Mismatch ***;
	**************************;

	proc sort data=outdir.lb_crf out=edc;
		by subjid cpevent colldate &labtime1 &lbtpt1 &lbcat1;
	run;

	proc sort data=outdir.lbedata out=edata(drop=lnotdone) nodupkey;
		by subjid cpevent colldate &labtime1 &lbtpt1 &lbcat1 &labsmpid1;
	run;

	*** Create dataset with visit mismatch Flags ***;
				
	data recon5;
		length flag $40;
		merge edc  (in=a rename=(labsmpid=clinsmpid) ) 
			  edata(in=b rename=(invcom=lab_com labsmpid=vendsmpid) );
		by subjid cpevent colldate &labtime1 &lbtpt1 &lbcat1;

		if (a=1 and b=0) or (a=0 and b=1) then mismatch=1;

		if a=1 then clinstdy=study;
		if b=1 then vendstdy=study;

		if a=1 then clinsubj=subjid;
		if b=1 then vendsubj=subjid;

		if a=1 then clinvis=cpevent;
		if b=1 then vendvis=cpevent;

		if a=1 then clincat=lbcat;
		if b=1 then vendcat=lbcat;

		if a=1 then clindt=colldate;
		if b=1 then venddt=colldate;

		%if &labtime1 = %then %do;clintm='';vendtm=testtime;%end; %else %do;
			if a=1 then clintm=&labtime1;
			if b=1 then vendtm=&labtime1;
								              %end;

		%if &lbtpt1 = %then %do;clintpt='';vendtpt='';%end;
		%else %do;
			if a=1 then clintpt=&lbtpt1;
			if b=1 then vendtpt=&lbtpt1;
		      %end;

		if a then labsmpid=upcase(clinsmpid);
		if b then labsmpid=upcase(vendsmpid);
		if a and b then labsmpid=upcase(clinsmpid);

		
		if clinsubj=vendsubj and clinvis=vendvis and upcase(clinsmpid) ne upcase(vendsmpid) and ("&labsmpid" ne "" ) and clincat=vendcat and clintpt=vendtpt and
            clindt=venddt and ((clintm=vendtm and clintm ne '') or clintm='') then do;
					recon=5; flag = 'Sample ID mismatch'; output recon5; 
												                                  end;
		
	run;


	*** Delete records which have eCRF only or Vendor only ***;

	proc sort data=recon5;
		by subjid cpevent colldate &labtime1 &lbtpt1 &lbcat1 labsmpid;
	run;

	proc sort data=recon1;
		by subjid cpevent colldate &labtime1 &lbtpt1 &lbcat1 labsmpid;
	run;
	data recon1;
		merge recon1(in=a) recon5(in=b);
		by subjid cpevent colldate &labtime1 &lbtpt1 &lbcat1 labsmpid;
		if a;
		if b=1  then delete;
	run;

	data recon5;
		set recon5;
		if vendsmpid ne '' then labsmpid=vendsmpid;
	run;

	proc sort data=recon2;
		by subjid cpevent colldate &labtime1 &lbtpt1 &lbcat1 labsmpid;
	run;
	data recon2;
		merge recon2(in=a) recon5(in=b);
		by subjid cpevent colldate &labtime1 &lbtpt1 &lbcat1 labsmpid;
		if a;
		if b=1  then delete;
	run;


	**********************;
	*** Visit Mismatch ***;
	**********************;

	proc sort data=outdir.lb_crf out=edc;
		by subjid colldate &labtime1 &lbtpt1 &lbcat1 &labsmpid1 cpevent;
	run;

	proc sort data=outdir.lbedata out=edata(drop=lnotdone) nodupkey;
		by subjid colldate &labtime1 &lbtpt1 &lbcat1 &labsmpid1 cpevent;
	run;

	*** Create dataset with visit mismatch Flags ***;
				
	%if "&database_type."  = "DATALABS" %then %do;
	data recon6;
		length flag $40;
		merge edc  (in=a rename=(cpevent=clinvis) ) 
			  edata(in=b rename=(invcom=lab_com cpevent=vendvis) );
		by subjid colldate &labtime1 &lbtpt1 &lbcat1 &labsmpid1;

		if (a=1 and b=0) or (a=0 and b=1) then mismatch=1;

		if a=1 then clinstdy=study;
		if b=1 then vendstdy=study;

		if a=1 then clinsubj=subjid;
		if b=1 then vendsubj=subjid;

		if a=1 then clincat=lbcat;
		if b=1 then vendcat=lbcat;

		if a=1 then clindt=colldate;
		if b=1 then venddt=colldate;

		%if &labtime1 = %then %do;clintm='';vendtm=testtime;%end; %else %do;
			if a=1 then clintm=&labtime1;
			if b=1 then vendtm=&labtime1;
								              %end;

		%if &lbtpt1 = %then %do;clintpt='';vendtpt='';%end;
		%else %do;
			if a=1 then clintpt=&lbtpt1;
			if b=1 then vendtpt=&lbtpt1;
		      %end;

		if a=1 then clinsmpid=labsmpid;
		if b=1 then vendsmpid=labsmpid;


		if clinsubj=vendsubj and clinvis ne vendvis and clinvis ne '' and clinsmpid=vendsmpid and clincat=vendcat and clintpt=vendtpt and
            clindt=venddt and ((clintm=vendtm and clintm ne '') or clintm='') then do;
					recon=6; flag = 'Visit mismatch'; output recon6; 
												                                  end;

	run;

										      %end;

	%if "&database_type."  = "OC" %then %do;


	data edc1 edata1;
		merge edc  (in=a ) 
			  edata(in=b rename=(invcom=lab_com) );
		by subjid colldate &labtime1 &lbtpt1 &lbcat1 &labsmpid1 cpevent;

		if (a=1 and b=0) or (a=0 and b=1) then mismatch=1;

		if a=1 then clinstdy=study;
		if b=1 then vendstdy=study;

		if a=1 and b=0 then output edc1;
		if a=0 and b=1 then output edata1;

		if a=1 then clinsubj=subjid;
		if b=1 then vendsubj=subjid;

		if a=1 then clincat=lbcat;
		if b=1 then vendcat=lbcat;

		if a=1 then clinvis=cpevent;
		if b=1 then vendvis=cpevent;

		if a=1 then clindt=colldate;
		if b=1 then venddt=colldate;

		%if &labtime1 = %then %do;clintm='';vendtm=testtime;%end; %else %do;
			if a=1 then clintm=&labtime1;
			if b=1 then vendtm=&labtime1;
								              %end;

		%if &lbtpt1 = %then %do;clintpt='';vendtpt='';%end;
		%else %do;
			if a=1 then clintpt=&lbtpt1;
			if b=1 then vendtpt=&lbtpt1;
		      %end;

		if a=1 then clinsmpid=labsmpid;
		if b=1 then vendsmpid=labsmpid;

/*
		if clinsubj=vendsubj and clinvis ne vendvis and clinvis ne '' and clinsmpid=vendsmpid and clinsmpid ne '' and clincat=vendcat and clincat ne '' and clintpt=vendtpt and
            clindt=venddt and ((clintm=vendtm and clintm ne '') or clintm='') then do;
					recon=6; flag = 'Visit mismatch'; output recon6; 
											                                  end;
*/	
	run;



	data recon6;
		length flag $40;
		merge edc1  (in=a drop=vendcat vendsmpid venddt vendcat vendsubj vendstdy) 
			  edata1(in=b drop=clincat clinsmpid clindt clincat clinsubj clinstdy);
		by subjid colldate &labtime1 &lbtpt1 &lbcat1 &labsmpid1 cpevent;
		if clinvis ne '' and vendvis ne '';
		recon=6;
		flag = 'Visit mismatch';
	run;

										%end;

	*** Delete records which have eCRF only or Vendor only ***;

	proc sort data=recon6;
		by subjid colldate &labtime1 &lbtpt1 &lbcat1 &labsmpid1;
	run;

	proc sort data=recon1;
		by subjid colldate &labtime1 &lbtpt1 &lbcat1 &labsmpid1;
	run;
	data recon1;
		merge recon1(in=a) recon6(in=b);
		by subjid colldate &labtime1 &lbtpt1 &lbcat1 &labsmpid1;
		if a;
		if b=1  then delete;
	run;

	proc sort data=recon2;
		by subjid colldate &labtime1 &lbtpt1 &lbcat1 &labsmpid1;
	run;
	data recon2;
		merge recon2(in=a) recon6(in=b);
		by subjid colldate &labtime1 &lbtpt1 &lbcat1 &labsmpid1;
		if a;
		if b=1  then delete;
	run;


	**************************;
	*** Timepoint Mismatch ***;
	**************************;

	%if &lbtpt =  %then %do; 
							data recon7;
								recon=.;
							run;
						%end;

	%else %do;

	proc sort data=outdir.lb_crf out=edc;
		by subjid colldate cpevent &labtime1 &lbcat1 &labsmpid1 &lbtpt1;
	run;

	proc sort data=outdir.lbedata out=edata(drop=lnotdone) nodupkey;
		by subjid colldate cpevent &labtime1 &lbcat1 &labsmpid1 &lbtpt1;
	run;

	*** Create dataset with timepoint mismatch Flags ***;
				
	%if "&database_type."  = "DATALABS" %then %do;

	data recon7;
		length flag $40;
		merge edc  (in=a rename=(lbtpt=clintpt) ) 
			  edata(in=b rename=(invcom=lab_com lbtpt=vendtpt) );
		by subjid colldate cpevent &labtime1 &lbcat1 &labsmpid1;

		if (a=1 and b=0) or (a=0 and b=1) then mismatch=1;

		if a=1 then clinstdy=study;
		if b=1 then vendstdy=study;

		if a=1 then clinsubj=subjid;
		if b=1 then vendsubj=subjid;

		if a=1 then clincat=lbcat;
		if b=1 then vendcat=lbcat;

		if a=1 then clinvis=cpevent;
		if b=1 then vendvis=cpevent;

		if a=1 then clindt=colldate;
		if b=1 then venddt=colldate;

		%if &labtime1 = %then %do;clintm='';vendtm=testtime;%end; %else %do;
			if a=1 then clintm=&labtime1;
			if b=1 then vendtm=&labtime1;
								              %end;

		if a=1 then clinsmpid=labsmpid;
		if b=1 then vendsmpid=labsmpid;


		if clinsubj=vendsubj and clinvis=vendvis and clinsmpid=vendsmpid and clincat=vendcat and clintpt ne vendtpt and clintpt ne '' and
            clindt=venddt and ((clintm=vendtm and clintm ne '') or clintm='') then do;
					recon=7; flag = 'Timepoint mismatch'; output recon7; 
												                                  end;

	run;

										      %end;

	%if "&database_type."  = "OC" %then %do;


	data edc1 edata1;
		merge edc  (in=a ) 
			  edata(in=b rename=(invcom=lab_com) );
		by subjid colldate cpevent &labtime1 &lbcat1 &labsmpid1 &lbtpt1;

		if (a=1 and b=0) or (a=0 and b=1) then mismatch=1;

		if a=1 then clinstdy=study;
		if b=1 then vendstdy=study;

		if a=1 and b=0 then output edc1;
		if a=0 and b=1 then output edata1;

		if a=1 then clinsubj=subjid;
		if b=1 then vendsubj=subjid;

		if a=1 then clincat=lbcat;
		if b=1 then vendcat=lbcat;

		if a=1 then clinvis=cpevent;
		if b=1 then vendvis=cpevent;

		if a=1 then clindt=colldate;
		if b=1 then venddt=colldate;

		%if &labtime1 = %then %do;clintm='';vendtm=testtime;%end; %else %do;
			if a=1 then clintm=&labtime1;
			if b=1 then vendtm=&labtime1;
								              %end;

		%if &lbtpt1 = %then %do;clintpt='';vendtpt='';%end;
		%else %do;
			if a=1 then clintpt=&lbtpt1;
			if b=1 then vendtpt=&lbtpt1;
		      %end;

		if a=1 then clinsmpid=labsmpid;
		if b=1 then vendsmpid=labsmpid;

	run;


	data recon7;
		length flag $40;
		merge edc1  (in=a drop=vendcat vendsmpid venddt vendcat) 
			  edata1(in=b drop=clincat clinsmpid clindt clincat);
		by subjid colldate &labtime1 &lbtpt1 &lbcat1 &labsmpid1 cpevent;
		if clintpt ne '' and vendtpt ne '';
		recon=7;
		flag = 'Timepoint mismatch';
	run;

										%end;

	*** Delete records which have eCRF only or Vendor only ***;

	proc sort data=recon7;
		by subjid colldate &labtime1 cpevent &lbcat1 &labsmpid1;
	run;

	proc sort data=recon1;
		by subjid colldate &labtime1 cpevent &lbcat1 &labsmpid1;
	run;
	data recon1;
		merge recon1(in=a) recon7(in=b);
		by subjid colldate &labtime1 cpevent &lbcat1 &labsmpid1;
		if a;
		if b=1  then delete;
	run;

	proc sort data=recon2;
		by subjid colldate &labtime1 &lbtpt1 &lbcat1 &labsmpid1;
	run;
	data recon2;
		merge recon2(in=a) recon7(in=b);
		by subjid colldate &labtime1 cpevent &lbcat1 &labsmpid1;
		if a;
		if b=1  then delete;
	run;

	%end;


	*** Concatenate all Reocn datasets ***;

	data labrecon;
		attrib STATUS length =$7 label = 'Data State';
		set recon0 recon1 recon2 recon3 /*recon4*/ recon5 recon6 recon7 (where=(recon ne .));

		if classmis='' then classmis='No';

		if subjid='' and clinsubj ne '' then subjid=clinsubj;
		if subjid='' and vendsubj ne '' then subjid=vendsubj;

		if cpevent='' and clinvis ne '' then cpevent=clinvis;
		if cpevent='' and vendvis ne '' then cpevent=vendvis;

		if lbcat='' and clincat ne '' then lbcat=clincat;
		if lbcat='' and vendcat ne '' then lbcat=vendcat;

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

		if subjid = '' and clinsubj ne '' then subjid=clinsubj;
		if subjid = '' and vendsubj ne '' then subjid=vendsubj;

		if colldate = '' and clindt ne '' then colldate=clindt;
		if colldate = '' and venddt ne '' then colldate=venddt;

		if cpevent = '' and clinvis ne '' then cpevent=clinvis;
		if cpevent = '' and vendvis ne '' then cpevent=vendvis;

		if lbcat = '' and clincat ne '' then lbcat=clincat;
		if lbcat = '' and vendcat ne '' then lbcat=vendcat;

		if colldate ne '' and index(colldate,'*')=0 then colldtn = input(colldate,date9.);

		if subjid = '' and clinsubj = '' and vendsubj ='' then delete;

		format colldtn date9.;

	run;

	proc sort data=labrecon nodupkey;
		by study clinstdy vendstdy 
		   subjid clinsubj vendsubj colldtn
		   colldate clindt venddt
		   cpevent clinvis vendvis
		   lbcat clincat vendcat
		   testtime clintm vendtm
           lnotdone clintpt clinsmpid invcom
           vendtpt vendsmpid lab_com recon flag siteid;
	run;

	*%mu_incremental(labrecon);

	proc sort data=labrecon;
		by study subjid colldtn lbcat cpevent testtime
		   clinstdy vendstdy 
		   clinsubj vendsubj 
		   clindt venddt
		   clinvis vendvis
		   clincat vendcat
		   clintm vendtm
           lnotdone clintpt clinsmpid invcom
           vendtpt vendsmpid lab_com siteid recon flag;
	run;

	data outdir.labrecon;
		set labrecon;
	run;

	proc datasets lib=work;
		delete edc edata recon0 recon1 recon2 recon3 recon4 recon5 recon6 recon7 labrecon edc1 edata1;
	quit;
	run;


	%end;


	%else %do;
    			%put %str(ERR)OR:[PXL]--------------------------------------------------------------------------;
    			%put %str(ERR)OR:[PXL] PFESACQ_LAB_RECON_FLAGS: alert: Dataset LB_CRF or LBEDATA does not exist.;
    			%put %str(ERR)OR:[PXL]--------------------------------------------------------------------------;
		  %end;



    %macend:;
    %put ;
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_LAB_RECON_FLAGS: End of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_lab_recon_flags;



/*

	proc sort data=outdir.lb_crf out=edc;
		by subjid cpevent colldate   labsmpid lbcat;
		where lnotdone ne 'NOT DONE';
	run;

	proc sort data=outdir.lbedata out=edata(drop=lnotdone) nodupkey;
		by subjid cpevent colldate  labsmpid lbcat ;*invcom;
		*where lbcat ne '';
	run;

data edata;
	set edata;
if subjid='10111001' and lbcat='TB' then lbcat='TB1';
run;

	*** Create dataset with classification mismatch Flags ***;
			
	data edc1 edata1;
		merge edc  (in=a  ) 
			  edata(in=b rename=(invcom=lab_com ) );
		by subjid cpevent colldate labsmpid lbcat;

		if a and b then delete;

		if (a=1 and b=0) or (a=0 and b=1) then mismatch=1;

		if a=1 then clinstdy=study;
		if b=1 then vendstdy=study;

		if a=1 then clinsubj=subjid;
		if b=1 then vendsubj=subjid;

		if a=1 then clinvis=cpevent;
		if b=1 then vendvis=cpevent;

		if a=1 then clindt=colldate;
		if b=1 then venddt=colldate;


	clintm='';vendtm=testtime;
	clintpt='';vendtpt='';

		if a=1 then clinsmpid=labsmpid;
		if b=1 then vendsmpid=labsmpid;

		if a=1 then clincat=lbcat;
		if b=1 then vendcat=lbcat;

		if a=1 and b=0 then output edc1;
		if a=0 and b=1 then output edata1;

	run;

	proc sort data=edc1;
		by subjid cpevent colldate labsmpid lbcat;
	run;

	proc sort data=edata1 nodupkey;
		by subjid cpevent colldate labsmpid lbcat ;*invcom;
	run;

	data recon4;
		length flag $40;
		merge edc1  (in=a drop=vendcat vendsmpid venddt vendvis vendsubj vendstdy where=(clincat ne '')) 
			  edata1(in=b drop=clincat clinsmpid clindt clinvis clinsubj clinstdy where=(vendcat ne ''));
		by subjid cpevent colldate labsmpid lbcat;
		if a =0 or b=0;
		recon=4;
		flag = 'Classification mismatch';
	run;

*/