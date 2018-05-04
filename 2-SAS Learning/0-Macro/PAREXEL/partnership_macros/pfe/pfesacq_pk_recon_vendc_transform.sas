/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Shiva Bhimreddy, $LastChangedBy:  $
  Creation Date:         25APR2016                       $LastChangedDate:  $
 
  Program Location/Name: pfesacq_pk_recon_vendc_transform.sas  $HeadURL: $
 
  Files Created:         None
 
  Program Purpose:       PK Reconciliation of the vendor PK dataset into SACQ format.
 
						 Note: Part of program: pfesacq_pk_recon 

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 

  Macro Output:          PKCDATA dataset is created in the "/unblinded/pfizr&pxl_code./dm/e_data/pk_def" Folder


-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev:  $
  
-----------------------------------------------------------------------------*/


*** Call the Macro that converts the raw Adverse Event EDC dataset into the SACQ format ***;

%macro pfesacq_pk_recon_vendc_transform();


    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_PK_RECON_VENDC_TRANSOFRM: Start of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

	libname unblind "&path_listings./current";

	*** Read the input pk central file dataset and Create variables as per the sACQ Specs***;

	%let infile = %str(&path_dm./&cpkloc./&cpkfile..csv);

	*** Import the Input Excel File ***;

	proc import datafile = "&infile."
				out      = pk1
				dbms     = csv replace;
				getnames = no ;
				guessingrows = 1000000;
	run;


	data pk;

		attrib  STUDY     length = $200 label = 'Clinical Study'
				SITEID    length = $200 label = 'Center Identifier Within Study'
				SUBJID    length = $200 label = 'Subject ID'
				VISIT     length = $200 label = 'Visit'
				RANDNUM   length = $200 label = 'Randomization Number' 
			    PKTPT     length = $200 label = 'Time Point'
				PKSMPID   length = $200 label = 'Unique PK sample id'
				INVCOM    length = $200 label = 'Investigator Comment'
/*				RESULT    length = $200 label = 'Analyte Result'*/
				ACESSION  length = $200 label = 'Accession Number'

			 ;

		set pk1;
		where upcase(var1) not in ('SUBJECT_USER_TEXT_1','STUDY ID','SUBJECT USER TE');

		if anyalpha(var4)>0 or upcase(var4)='SUBJECT' then delete;

		study    = compress(strip(var1),,'kw');
		siteid   = compress(strip(var2),,'kw');
		subjid   = compress(strip(var3),,'kw');
		randnum  = compress(strip(var4),,'kw');
		if var18 ne '' then pktpt    = compbl(compress(strip(var18),,'kw')||' '||compress(strip(var17),,'kw'));
		pksmpid  = compress(strip(var28),,'kw');
		invcom   = compress(strip(var25),,'kw');

		*result   = strip(var20);
		acession = compress(strip(var8),,'kw');

		visit=strip(compbl(compress(strip(var12),,'kw')||' '||compress(strip(var13),,'kw')||' '||compress(strip(var14),,'kw')||' '||compress(strip(var15),,'kw')));
		visit=upcase(visit);
		pktpt=upcase(pktpt);

	run;


	data unblind.pkcdata;
		set pk;
		keep study siteid subjid visit randnum pktpt pksmpid invcom /*result*/ acession;
	run;

	proc datasets library=work nolist;
		delete pk pk1;
	quit;


    %macend:;
    %put ;
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_PK_RECON_VENDC_TRANSOFRM: End of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_pk_recon_vendc_transform;

