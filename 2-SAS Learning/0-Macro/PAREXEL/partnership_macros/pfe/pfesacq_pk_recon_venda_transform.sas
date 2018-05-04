/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Shiva Bhimreddy, $LastChangedBy:  $
  Creation Date:         25APR2016                       $LastChangedDate:  $
 
  Program Location/Name: pfesacq_pk_recon_venda_transform.sas $HeadURL: $
 
  Files Created:         None
 
  Program Purpose:       PK Reconciliation of the vendor PK dataset into SACQ format.
 
						 Note: Part of program: pfesacq_pk_recon 

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 

  Macro Output:          PKEDATA dataset is created in the "/unblinded/pfizr&pxl_code./dm/e_data/pk_def" Folder


-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev:  $
  
-----------------------------------------------------------------------------*/


*** Call the Macro that converts the raw Adverse Event EDC dataset into the SACQ format ***;

%macro pfesacq_pk_recon_venda_transform();


    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_PK_RECON_VENDA_TRANSOFRM: Start of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

	libname unblind "&path_listings./current";

	*** Read the input pk central files and create the PK dataset ***;

	%do i=1 %to &apknum;

		*** Import the Input Excel File ***;
	%if &&apkfile&i= %then %do;    
							   %put -----------------------------------------------------------------;
							   %put APKNUM IS ASSIGNED AS &I BUT APKFILE&i IS MISSING OR NOT ASSIGNED;
    						   %put -----------------------------------------------------------------;
							%end;

	%else %do; 

		proc import datafile = "&path_dm./&apkloc./&&apkfile&i...csv"
				out      = pk&i
				dbms     = csv replace;
				getnames = no ;
		run;


		data pk&i;

			attrib  STUDY     length = $200 label = 'Clinical Study'
					SITEID    length = $200 label = 'Center Identifier Within Study'
					SUBJID    length = $200 label = 'Subject ID'
					VISIT     length = $200 label = 'Visit'
					RANDNUM   length = $200 label = 'Randomization Number' 
				    PKTPT     length = $200 label = 'Time Point'
					PKSMPID   length = $200 label = 'Unique PK sample id'
					ACESSION  length = $200 label = 'Accession Number'
					RESULT    length = $200 label = 'Analyte Result'
					INVCOM    length = $200 label = 'Investigator Comment'
					ANALYTE   length = $200 label = 'Analyte' ;

			set pk&i;
			where upcase(var1) not in ('SUBJECT_USER_TEXT_1','STUDY ID','SUBJECT USER TE');

			study    = compress(strip(var1),,'kw');
			siteid   = compress(strip(var2),,'kw');
			subjid   = compress(strip(var3),,'kw');
			randnum  = compress(strip(var4),,'kw');
			if var18 ne '' then pktpt    = compbl(compress(strip(var18),,'kw')||' '||compress(strip(var17),,'kw'));
			pksmpid  = compress(strip(var28),,'kw');
			invcom   = compress(strip(var27),,'kw');

			analyte  = compress(strip(var11),,'kw');

			result   = compress(strip(var20),,'kw');
			acession = compress(strip(var8),,'kw');

		    visit=strip(compbl(compress(strip(var12),,'kw')||' '||compress(strip(var13),,'kw')||' '||compress(strip(var14),,'kw')||' '||compress(strip(var15),,'kw')));
			visit=upcase(visit);
			pktpt=upcase(pktpt);

			keep study siteid subjid visit randnum pktpt pksmpid acession analyte;* invcom result;

		run;

		data unblind.pkadata&i;
			set pk&i;
			keep study siteid subjid visit randnum pktpt pksmpid acession analyte;* invcom result;
		run;

          %end;

	%end;


	data pk;
		set pk1-pk&apknum.;
	run;

	proc sort data=pk;
		by study siteid subjid visit;
	run;

	data unblind.pkadata;
		set pk;
		keep study siteid subjid visit randnum pktpt pksmpid acession analyte;* invcom result;
	run;

	proc datasets library=work nolist;
		delete pk pk1-pk&apknum;
	quit;



    %macend:;
    %put ;
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_PK_RECON_VENDA_TRANSOFRM: End of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_pk_recon_venda_transform;

