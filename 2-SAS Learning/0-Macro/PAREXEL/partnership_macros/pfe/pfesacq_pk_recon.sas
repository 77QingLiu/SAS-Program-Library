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
 
  Program Purpose:       PK Reconciliation of the raw PK dataset and the vendor PK data. Calls the other PK Recon 
                         macros which convert the raw PK data into SACQ format and then checks for mismatches and report the 
                         final PK Recon report.
						 13 PK Checks are performed against the PK vendor data as defined in the la bspecifications document and
                         an excel report is genereated with the findings.
 
                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:
 
    Name:                inds
      Allowed Values:    Valid SAS dataset name 
      Default Value:     null
      Description:       SAS Dataset name of the PK EDC dataset 
 
    Name:                study
      Allowed Values:    SAS variable name for the study name in the PK EDC dataset   
      Default Value:     study
      Description:       SAS variable name for the study name in the PK EDC dataset  

    Name:                siteid
      Allowed Values:    SAS variable name for the Site ID in the PK EDC dataset  
      Default Value:     null
      Description:       SAS variable name for the Site ID in the PK EDC dataset

    Name:                subjid
      Allowed Values:    SAS variable name for the Subject ID in the PK EDC dataset   
      Default Value:     subjid
      Description:       SAS variable name for the Subject ID in the PK EDC dataset 

    Name:                visit
      Allowed Values:    SAS variable name for the visit (CPEvent) in the PK EDC dataset  
      Default Value:     cpevent
      Description:       SAS variable name for the visit (CPEvent) in the PK EDC dataset

    Name:                visitdt
      Allowed Values:    SAS variable name for the Visit Date in the PK EDC dataset  
      Default Value:     null
      Description:       SAS variable name for the Visit Date in the PK EDC dataset


    Name:                pnotdone
      Allowed Values:    SAS variable name for the PK Sample Not Done in the PK EDC dataset  
      Default Value:     pksmnd
      Description:       SAS variable name for the PK Sample Not Done in the PK EDC dataset

    Name:                pktpt
      Allowed Values:    SAS variable name for the PK Time Point in the PK EDC dataset  
      Default Value:     null
      Description:       SAS variable name for the PK Time Point in the PK EDC dataset

    Name:                colldate
      Allowed Values:    SAS variable name for the PK Collection Date in the PK EDC dataset  
      Default Value:     null
      Description:       SAS variable name for the PK Collection Date in the PK EDC dataset

    Name:                testtime
      Allowed Values:    SAS variable name for the PK Collection Time in the PK EDC dataset  
      Default Value:     null
      Description:       SAS variable name for the PK Collection Time in the PK EDC dataset

    Name:                pksmpid
      Allowed Values:    SAS variable name for the PK Sample ID in the PK EDC dataset  
      Default Value:     null
      Description:       SAS variable name for the PK Sample ID in the PK EDC dataset

    Name:                invcom
      Allowed Values:    SAS variable name for the Investigator Comment in the PK EDC dataset  
      Default Value:     null
      Description:       SAS variable name for the Investigator Comment in the PK EDC dataset

    Name:                randds
      Allowed Values:    Valid SAS dataset name 
      Default Value:     null
      Description:       SAS Dataset name of the EDC randomization dataset 

    Name:                randsubj
      Allowed Values:    SAS Variable name for SUBJID in the randomization dataset
      Default Value:     null
      Description:       SAS variable name for SUBJID/PTID in the randomization dataset

    Name:                randnum
      Allowed Values:    SAS variable name for randomization number in the randomization dataset
      Default Value:     null
      Description:       SAS variable name for randomization number in the randomization dataset 



  Macro Output:  PK Recon_yymmdd excel report is created in the "/../dm/listings/current" Folder
                 PK Checks_yymmdd excel report is created in the "/../dm/listings/current" Folder


-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev:  $
  
-----------------------------------------------------------------------------*/

%macro pfesacq_pk_recon(inds       = , 		 /* Name of the EDC PK Dataset */
					    study      = , 		 /* Variable Name of the study name in EDC PK dataset */
						siteid     = ,		 /* Variable Name of the Site ID in EDC PK dataset */
						subjid     = , 		 /* Variable Name of the subject ID in EDC PK dataset */
						visit      = , 		 /* Variable Name of the Visit Name */
						visitdt    = , 		 /* Variable Name of the Visit Date */
						pnotdone   = %str(), /* Variable Name of the PK Sample Not Done */
						pktpt      = %str(), /* Variable Name of the PK Timepoint */
						colldate   = , 		 /* Variable Name of the PK Collection Date */
						testtime   = , 		 /* Variable Name of the PK Collection Time */
						pksmpid    = %str(), /* Variable Name of the PK Sample ID */
						invcom     = , 		 /* Variable Name of the Investigator Comment */

 					    randds     = , /* Name of the raw Randomization Dataset */
                        randsubj   = , /* Variable Name of the subject ID in Randomization dataset */
                        randnum    = , /* Variable Name of the randomization number in the Randomization dataset */

				  		cpkloc     = , /* Location of the Central PK CSV file in the unblinded area */
						cpkfile    = , /* Name of the Central PK CSV file in the unblinded area */

	   				    apknum     = , /* Number of Analytical PK CSV files in the unblinded area */
				  		apkloc     = , /* Location of the Analytical PK CSV file in the unblinded area */
						apkfile1   = , /* Name of the First Analytical PK CSV file in the unblinded area */
						apkfile2   = , /* Name of the Second Analytical PK CSV file in the unblinded area */
						apkfile3   = , /* Name of the Third Analytical PK CSV file in the unblinded area */
						apkfile4   = , /* Name of the Fourth Analytical PK CSV file in the unblinded area */
						apkfile5   =   /* Name of the Fifth Analytical PK CSV file in the unblinded area */

						);

    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_PK_RECON: Start of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;


	*options nomlogic nomprint;

	*** Call the Macro that converts the EDC PK dataset into the SACQ format ***;

	%pfesacq_pk_recon_edc_transform();



	*** Call the Macro that converts the Vendor Central PK dataset into the SACQ format ***;

	%pfesacq_pk_recon_vendc_transform();

	*** Call the Macro that reconciles the EDC and Vendor Central PK dataset and creates the PKRECON dataset ***;

	%pfesacq_pk_reconc_flags();

	*** Call the Macro to create the PK Recon Report ***;

	%pfesacq_pk_reconc_report();



	*** Call the Macro that converts the Vendor Analytical PK dataset into the SACQ format ***;

	%pfesacq_pk_recon_venda_transform();

	*** Call the Macro that reconciles the EDC and Vendor Central PK dataset and creates the PKRECON dataset ***;

	%pfesacq_pk_recona_flags();

	*** Call the Macro to create the PK Recon Report ***;

	%pfesacq_pk_recona_report();



	*** Call the 9 Macros that create the Central PK checks datasets LIS01-LIS09 ***;

	%pfesacq_pk_recon_c_lis();

	*** Call the Macro to create the PK Checks Report ***;

	%pfesacq_pk_recon_c_checks_report();



	*** Call the 9 Macros that create the Analytical PK checks datasets LIS01-LIS09 ***;

	%pfesacq_pk_recon_a_lis();

	*** Call the Macro to create the PK Checks Report ***;

	%pfesacq_pk_recon_a_checks_report();



	options nomlogic nomprint nocenter ls=132 ps=60;

    %macend:;
    %put ;
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_PK_RECON: End of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_pk_recon;


*** Example call of this macro ***;

*** 207757 ***;

*%pfesacq_pk_recon(inds       = pk1qg1,   /* Name of the EDC PK Dataset */
				  study      = study,    /* Variable Name of the study name in EDC PK dataset */
				  siteid     = trialno,  /* Variable Name of the Site ID in EDC PK dataset */
				  subjid     = subjid,   /* Variable Name of the subject ID in EDC PK dataset */
				  visit      = cpevent,  /* Variable Name of the Visit Name */
				  visitdt    = ,         /* Variable Name of the Visit Date */
				  pnotdone   = %str(pksmnd),   /* Variable Name of the PK Sample Not Done */
				  pktpt      = pkptm,    /* Variable Name of the PK Timepoint */
				  colldate   = pkadt,    /* Variable Name of the PK Collection Date */
				  testtime   = pkatm,    /* Variable Name of the PK Collection Time */
				  pksmpid    = pkusmid,  /* Variable Name of the PK Sample ID */
				  invcom     = pkcomc,   /* Variable Name of the Investigator Comment */

 				  randds     = rand,     /* Name of the raw Randomization Dataset */
                  randsubj   = subjid,   /* Variable Name of the subject ID in Randomization dataset */
                  randnum    = randnum,  /* Variable Name of the randomization number in the Randomization dataset */

				  cpkloc     = %str(e_data/quin/current),                  /* Location of the Central PK CSV file in the unblinded area */
				  cpkfile    = %str(a8081007_pf-02341066_plasma_05mar13_inv), /* Name of the Central PK CSV file in the unblinded area */

				  apknum     = 2,                                             /* Number of Analytical PK CSV files in the unblinded area */
				  apkloc     = %str(e_data/covance/20131223),              /* Location of the Analytical PK CSV file in the unblinded area */
				  apkfile1   = %str(a8081007_pf-02341066_plasma_13dec13_dft), /* Name of the First Analytical PK CSV file in the unblinded area */
				  apkfile2   = %str(a8081007_pf-06260182_plasma_13dec13_dft), /* Name of the Second Analytical PK CSV file in the unblinded area */
				  apkfile3   = , /* Name of the Third Analytical PK CSV file in the unblinded area */
				  apkfile4   = , /* Name of the Fourth Analytical PK CSV file in the unblinded area */
				  apkfile5   =   /* Name of the Fifth Analytical PK CSV file in the unblinded area */

				  );


*** 207758 ***;

*%pfesacq_pk_recon(inds       = pk1qg1,   /* Name of the EDC PK Dataset */
				  study      = study,    /* Variable Name of the study name in EDC PK dataset */
				  siteid     = trialno,  /* Variable Name of the Site ID in EDC PK dataset */
				  subjid     = subjid,   /* Variable Name of the subject ID in EDC PK dataset */
				  visit      = cpevent,  /* Variable Name of the Visit Name */
				  visitdt    = ,         /* Variable Name of the Visit Date */
				  pnotdone   = pksmnd,   /* Variable Name of the PK Sample Not Done */
				  pktpt      = pkptm,    /* Variable Name of the PK Timepoint */
				  colldate   = pkadt,    /* Variable Name of the PK Collection Date */
				  testtime   = pkatm,    /* Variable Name of the PK Collection Time */
				  pksmpid    = pkusmid,  /* Variable Name of the PK Sample ID */
				  invcom     = pkcomc,   /* Variable Name of the Investigator Comment */

 				  randds     = rand,     /* Name of the raw Randomization Dataset */
                  randsubj   = subjid,   /* Variable Name of the subject ID in Randomization dataset */
                  randnum    = randnum,  /* Variable Name of the randomization number in the Randomization dataset */

				  cpkloc     = %str(e_data/quin/current),                  /* Location of the Central PK CSV file in the unblinded area */
				  cpkfile    = %str(a8081005_pf-02341066_plasma_05mar13_inv), /* Name of the Central PK CSV file in the unblinded area */

				  apknum     = 2,                                             /* Number of Analytical PK CSV files in the unblinded area */
				  apkloc     = %str(e_data/cova/20131223),              /* Location of the Analytical PK CSV file in the unblinded area */
				  apkfile1   = %str(a8081005_pf-02341066_plasma_18dec13_dft), /* Name of the First Analytical PK CSV file in the unblinded area */
				  apkfile2   = %str(a8081005_pf-06260182_plasma_18dec13_dft), /* Name of the Second Analytical PK CSV file in the unblinded area */
				  apkfile3   = , /* Name of the Third Analytical PK CSV file in the unblinded area */
				  apkfile4   = , /* Name of the Fourth Analytical PK CSV file in the unblinded area */
				  apkfile5   =   /* Name of the Fifth Analytical PK CSV file in the unblinded area */

				  );



*** 208309 ***;

*%pfesacq_pk_recon(inds       = pk,       /* Name of the EDC PK Dataset */
				  study      = studynam, /* Variable Name of the study name in EDC PK dataset */
				  siteid     = siteid,   /* Variable Name of the Site ID in EDC PK dataset */
				  subjid     = scrnid,   /* Variable Name of the subject ID in EDC PK dataset */
				  visit      = evtlbl,   /* Variable Name of the Visit Name */
				  visitdt    = evtdt,    /* Variable Name of the Visit Date */
				  pnotdone   = %str(PKCT01_T1 /pksmnd,
                            	    PKCT01A_T1/pksmnd,
 								    PKCT01U_T1/pksmnd,
								    PKCT01_S1 /pknd,
                            	    PKCT01A_S1/pknd,
 								    PKCT01U_S1/pknd
								    ),   /* Variable Name of the PK Sample Not Done */
				  pktpt      = %str(PKCT01_T1 /pkptm pkptm1,
                            	    PKCT01A_T1/pkptm pkptm1,
 								    PKCT01U_T1/pkptm pkptm1,
								    PKCT01_S1 /pkptm pkptm1,
                            	    PKCT01A_S1/pkptm pkptm1,
 								    PKCT01U_S1/pkptm pkptm1
								    ),   /* Variable Name of the PK Timepoint */
				  colldate   = pkadt,    /* Variable Name of the PK Collection Date */
				  testtime   = pkatm,    /* Variable Name of the PK Collection Time */
				  pksmpid    = %str(PKCT01_T1 /pkusmid pkusmid1 pkusmid2,
									PKCT01A_T1/pkusmid pkusmid1 pkusmid2,
 								    PKCT01U_T1/pkusmid pkusmid1 pkusmid2,
								    PKCT01_S1 /pkusmid pkusmid1 pkusmid2,
                            	    PKCT01A_S1/pkusmid pkusmid1 pkusmid2,
 								    PKCT01U_S1/pkusmid pkusmid1 pkusmid2
								    ),  /* Variable Name of the PK Sample ID */
				  invcom     = pkcomc,   /* Variable Name of the Investigator Comment */

 				  randds     = random,   /* Name of the raw Randomization Dataset */
                  randsubj   = scrnid,   /* Variable Name of the subject ID in Randomization dataset */
                  randnum    = randnum,  /* Variable Name of the randomization number in the Randomization dataset */

				  cpkloc     = %str(e_data/quin),                          /* Location of the Central PK CSV file in the unblinded area */
				  cpkfile    = %str(a5481008_pd-332991_plasma_16mar16_cum),   /* Name of the Central PK CSV file in the unblinded area */

				  apknum     = 1,                                             /* Number of Analytical PK CSV files in the unblinded area */
				  apkloc     = %str(e_data/ppd),              /* Location of the Analytical PK CSV file in the unblinded area */
				  apkfile1   = %str(a5481008_pd-0332991_plasma_29mar16_fnl_rev4), /* Name of the First Analytical PK CSV file in the unblinded area */
				  apkfile2   = %str(), /* Name of the Second Analytical PK CSV file in the unblinded area */
				  apkfile3   = , /* Name of the Third Analytical PK CSV file in the unblinded area */
				  apkfile4   = , /* Name of the Fourth Analytical PK CSV file in the unblinded area */
				  apkfile5   =   /* Name of the Fifth Analytical PK CSV file in the unblinded area */

				  );


*** 208469 ***;

*%pfesacq_pk_recon(inds       = pk,       /* Name of the EDC PK Dataset */
				  study      = studynam, /* Variable Name of the study name in EDC PK dataset */
				  siteid     = siteid,   /* Variable Name of the Site ID in EDC PK dataset */
				  subjid     = scrnid,   /* Variable Name of the subject ID in EDC PK dataset */
				  visit      = evtlbl,   /* Variable Name of the Visit Name */
				  visitdt    = evtdt,    /* Variable Name of the Visit Date */
				  pnotdone   = pknd,     /* Variable Name of the PK Sample Not Done */
				  pktpt      = pktime,   /* Variable Name of the PK Timepoint */
				  colldate   = pkadt,    /* Variable Name of the PK Collection Date */
				  testtime   = pkatmh,   /* Variable Name of the PK Collection Time */
				  pksmpid    = %str(PK_T1 /pkusmid1 pkusmid2 pkusmid3,
									PKU_T1/pkusmid1 pkusmid2 pkusmid3,
								    PKS_S1/pkusmid1 pkusmid2 pkusmid3
								    ), /* Variable Name of the PK Sample ID */
				  invcom     = pkcomc,   /* Variable Name of the Investigator Comment */

 				  randds     = rand,     /* Name of the raw Randomization Dataset */
                  randsubj   = scrnid,   /* Variable Name of the subject ID in Randomization dataset */
                  randnum    = randnum,  /* Variable Name of the randomization number in the Randomization dataset */

				  cpkloc     = %str(e_data/covance/20160414),                          /* Location of the Central PK CSV file in the unblinded area */
				  cpkfile    = %str(cl_a0081042_pregabalin_plasma_14apr16_inv),   /* Name of the Central PK CSV file in the unblinded area */

				  apknum     = 0,                                             /* Number of Analytical PK CSV files in the unblinded area */
				  apkloc     = %str(e_data/),              /* Location of the Analytical PK CSV file in the unblinded area */
				  apkfile1   = %str(), /* Name of the First Analytical PK CSV file in the unblinded area */
				  apkfile2   = %str(), /* Name of the Second Analytical PK CSV file in the unblinded area */
				  apkfile3   = , /* Name of the Third Analytical PK CSV file in the unblinded area */
				  apkfile4   = , /* Name of the Fourth Analytical PK CSV file in the unblinded area */
				  apkfile5   =   /* Name of the Fifth Analytical PK CSV file in the unblinded area */

				  );
