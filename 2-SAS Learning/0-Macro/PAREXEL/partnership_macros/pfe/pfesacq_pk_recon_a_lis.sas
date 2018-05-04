/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Shiva Bhimreddy, $LastChangedBy:  $
  Creation Date:         27APR2016                       $LastChangedDate:  $
 
  Program Location/Name: pfesacq_pk_recon_a_lis.sas $HeadURL: $
 
  Files Created:         None
 
  Program Purpose:       Creates the LIS datasets as per the specifications.
 
						 Note: Part of program: pfesacq_pk_recon 

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:
 


  Macro Output:          LIS02 dataset in WORK library


-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev:  $
  
-----------------------------------------------------------------------------*/



%macro pfesacq_pk_recon_a_lis();

    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_PK_RECON_A_LIS: Start of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

	%if %sysfunc(exist(unblind.pkadata)) %then %do;


	****************************;
	*** Create LIS01 dataset ***;
	****************************;

	*** Sort the dataset by Study, Subject and Visit ***;

	proc sort data=unblind.pkadata out=edata(keep=study siteid subjid visit) nodupkey;
		by study siteid subjid visit;
	run;

	data lis01;
		length flag $60;
		set edata;

		if upcase(study) ne upcase("&protocol.");

		flagn=1;
		flag='Invalid Study ID';

	run;


	****************************;
	*** Create LIS02 dataset ***;
	****************************;

	*** Sort the dataset by Study, Subject ***;

	proc sort data=unblind.pkadata out=edata nodupkey;
		by study siteid subjid;
	run;

	proc sort data=unblind.pk_crf out=crfdata nodupkey;
		by study siteid subjid;
	run;

	data lis02;
		length flag $60;
		merge edata(in=a) crfdata(in=b);
		by study siteid subjid;
		if a=0 or b=0;

		if b=1 and upcase(pnotdone)in ('','NOT DONE') then delete;

		if a=1 then source='Vendor';
		if b=1 then source='CRF';
		flagn=2;
		flag='Missing Subject';

	run;

	****************************;
	*** Create LIS03 dataset ***;
	****************************;

	*** Import the protocol visits document ***;

	proc import datafile = "&path_dm/documents/pk_recon/%lowcase(&protocol.) pk visit schedule.xls"
	            out      = protvis (rename=(b=visit))
				dbms     = xls replace;
				sheet    = "Expected Visits";
				getnames = no;
				startrow = 2;
	run;

	data protvis;
		set protvis;
		visit=upcase(compress(strip(visit),,'kw'));
	run;

	proc sort data=protvis;
		by visit;
	run;

	proc sort data=unblind.pkadata out=edata;
		by visit;
	run;

	data lis03;
		length flag $60;
		merge edata(in=aa) protvis(in=b);
		by visit;

		if b=0;

		flagn=3;
		flag='Invalid Visit';

	run;

	****************************;
	*** Create LIS04 dataset ***;
	****************************;

	data lis04a;
		length flag $60;
		merge edata(in=aa) protvis(in=b);
		by visit;

		if b=1 and (aa=0 or study='' or siteid='' or subjid='' or visit='' or pktpt='' or pksmpid='');
		source='Vendor';
		flagn=4;
		flag='Missing PK Data for Study Visit';

	run;

	proc sort data=unblind.pk_crf out=crfdata;
		by visit;
	run;

	data lis04b;
		length flag $60;
		merge crfdata(in=aa) protvis(in=b);
		by visit;

		if b=1 and (aa=0 or study='' or siteid='' or subjid='' or visit='' or pktpt='' or pksmpid='');
		
		if aa=1 and upcase(pnotdone)in ('','NOT DONE') then delete;

		source='CRF';
		flagn=4;
		flag='Missing PK Data for Study Visit';

	run;

	data lis04;
		set lis04a lis04b;

		if index(upcase(visit),'UNPLANNED')>0 or index(upcase(visit),'UNSCHEDULED')>0 then delete;
	run;

	proc sort data=lis04;
		by study siteid subjid;
	run;

	****************************;
	*** Create LIS05 dataset ***;
	****************************;
/*
	proc sort data=unblind.pk_crf out=crfdata nodupkey dupout=crfdata1;
		by study siteid subjid visit colldate testtime pksmpid pktpt;
	run;

	data lis05;
		length flag $60;
		set crfdata1;

		if visit ne '' or colldate ne '' or pktpt ne '';

		flagn=5;
		flag='Duplicate Fields on eCRF';

	run;
*/
	****************************;
	*** Create LIS06 dataset ***;
	****************************;

	proc sort data=unblind.pkadata out=edata nodupkey dupout=edata1;
		by acession;
		where acession ne '';
	run;

	proc sort data=unblind.pkadata out=edata nodupkey dupout=edata2;
		by subjid acession;
		where acession ne '';
	run;

	data lis06;
		length flag $60;
		set edata1 edata2;

		flagn=6;
		flag='Duplicate Accession Number';

	run;


	****************************;
	*** Create LIS07 dataset ***;
	****************************;

	proc sort data=unblind.pkadata out=edata nodupkey dupout=edata1;
		by study siteid subjid visit analyte pktpt pksmpid acession;
	run;

	data lis07;
		length flag $60;
		set edata1;

		flagn=7;
		flag='Duplicated Record on Vendor';

	run;

	****************************;
	*** Create LIS08 dataset ***;
	****************************;

	proc sort data=unblind.pkadata out=edata nodupkey;
		by study randnum subjid;
		where randnum ne '';
	run;

	proc sort data=edata nodupkey dupout=edata1;
		by study randnum;
	run;

	data lis08;
		length flag $60;
		set edata1;

		flagn=8;
		flag='Duplicate Randomization Number on Vendor';

	run;


	****************************;
	*** Create LIS09 dataset ***;
	****************************;

	proc sort data=unblind.pkadata out=edata nodupkey dupout=edata1;
		by study siteid subjid /*visit*/ analyte pksmpid;
	run;
/*
	proc sort data=edata nodupkey dupout=edata1;
		by study siteid subjid visit analyte;
	run;
*/
	proc sort data=unblind.pk_crf out=crfdata nodupkey dupout=crfdata1;
		by study siteid subjid /*visit*/ pksmpid;
	run;
/*
	proc sort data=crfdata nodupkey dupout=crfdata1;
		by study siteid subjid visit;
	run;
*/
	data lis09;
		length flag $60;
		set edata1(in=edata) crfdata1(in=crfdata);

		if edata   then source='Vendor';
		if crfdata then source='CRF';

		if pksmpid ne '';

		flagn=9;
		flag='Sample ID not Unique';

	run;


	*** Concatenate all 12 data sets with lab checks results ***;

	data unblind.pkchecka;
		set lis01 lis02 lis03 lis04 /*lis05*/ lis06 lis07 lis08 lis09;;
	run;


	proc datasets lib=work;
		delete edata edata1 crfdata crfdata1 protvis lis04a lis04b
               lis01 lis02 lis03 lis04 /*lis05*/ lis06 lis07 lis08 lis09;
	quit;
	run;


	%end;

	%else %do;
    			%put %str(ERR)OR:[PXL]-------------------------------------------------------------;
    			%put %str(ERR)OR:[PXL] PFESACQ_PK_RECON_A_LIS: alert: Dataset PKADATA does not exist.;
    			%put %str(ERR)OR:[PXL]-------------------------------------------------------------;
		  %end;


    %macend:;
    %put ;
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_PK_RECON_A_LIS: End of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_pk_recon_a_lis;





