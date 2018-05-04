/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX
  Example Call:          %pfesacq_sae_recon();

-------------------------------------------------------------------------------
 
  Author:                Shiva Bhimreddy, $LastChangedBy: bhimres $
  Creation Date:         22JUN2015                       $LastChangedDate: 2015-10-01 17:22:10 -0400 (Thu, 01 Oct 2015) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfesacq_sae_recon.sas $
 
  Files Created:         None
 
  Program Purpose:       SAE Reconciliation of the raw EDC dataset and the safety Excel files. Calls the other SAE Recon 
                         macros which convert the raw files into SACQ format and then checks for mismatches and report the 
                         final SAE Recon report.
 
                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:
 
    Name:                indsdm
      Allowed Values:    Valid SAS dataset name 
      Default Value:     null
      Description:       SAS Dataset name of the demography dataset 
 
    Name:                study
      Allowed Values:    SAS variable name for the study name in the demog dataset  
      Default Value:     study
      Description:       SAS variable name for the study name in the demog dataset 

    Name:                subjid
      Allowed Values:    SAS variable name for the Subject ID in the demog dataset  
      Default Value:     subjid
      Description:       SAS variable name for the Subject ID in the demog dataset 

    Name:                sex
      Allowed Values:    SAS variable name for the gender in the demog dataset  
      Default Value:     sex
      Description:       SAS variable name for the gender in the demog dataset 

    Name:                dob
      Allowed Values:    SAS variable name for the Date of Birth in the demog dataset  
      Default Value:     dob
      Description:       SAS variable name for the Date of Birth in the demog dataset 

    Name:                inds
      Allowed Values:    Valid SAS dataset name 
      Default Value:     ae
      Description:       SAS Dataset name of the adverse event dataset 
 
    Name:                lstchgts
      Allowed Values:    Variable name of the Last Updated in the adverse event dataset
      Default Value:     lastupd
      Description:       Variable name of the Last Updated in the adverse event dataset

    Name:                aeser
      Allowed Values:    Variable name of the AE Seriousness in the adverse event dataset 
      Default Value:     aeser
      Description:       Variable name of the AE Seriousness in the adverse event dataset

    Name:                aecaseid
      Allowed Values:    Variable name of the AE Case ID in the adverse event dataset 
      Default Value:     aecase
      Description:       Variable name of the AE Case ID in the adverse event dataset 

    Name:                aeterm
      Allowed Values:    Variable name of the AE verbatim term in the adverse event dataset 
      Default Value:     aeterm_enc_term
      Description:       Variable name of the AE verbatim term in the adverse event dataset

    Name:                aedecd2
      Allowed Values:    Variable name of the AE preferred term in the adverse event dataset
      Default Value:     aeterm_enc_cat4
      Description:       Variable name of the AE preferred term in the adverse event dataset

    Name:                fromdate
      Allowed Values:    Variable name of the AE start date in the adverse event dataset 
      Default Value:     fromdate
      Description:       Variable name of the AE start date in the adverse event dataset

    Name:                todate
      Allowed Values:    Variable name of the AE end date in the adverse event dataset 
      Default Value:     todate
      Description:       Variable name of the AE end date in the adverse event dataset

    Name:                aepres
      Allowed Values:    Variable name of the AE present in the adverse event dataset 
      Default Value:     aepres
      Description:       Variable name of the AE present in the adverse event dataset

    Name:                aercaus
      Allowed Values:    Variable Name of the Reasonable Poss AE Related in the adverse event dataset 
      Default Value:     aercaus
      Description:       Variable Name of the Reasonable Poss AE Related in the adverse event dataset

    Name:                aeacndrv
      Allowed Values:    1 or 0 
      Default Value:     0
      Description:       1 if AESTDRG has to be derived from multiple variables, 0 if values present in single variable

    Name:                acwdrn
      Allowed Values:    Variable name which has withdrawn from study action in the adverse event dataset 
      Default Value:     acwdrn
      Description:       Variable name which has withdrawn from study action in the adverse event dataset

    Name:                acnone
      Allowed Values:    Variable name which has none action taken in the adverse event dataset
      Default Value:     acnone
      Description:       Variable name which has none action taken in the adverse event dataset

    Name:                acother
      Allowed Values:    Variable name which indicates other action taken in the adverse event dataset 
      Default Value:     acother
      Description:       Variable name which indicates other action taken in the adverse event dataset 

    Name:                acred
      Allowed Values:    Variable name which indicates drug reduced action in the adverse event dataset  
      Default Value:     acred
      Description:       Variable name which indicates drug reduced action in the adverse event dataset 

    Name:                actemp
      Allowed Values:    Variable name which indicates drug stopped temporarily in the adverse event dataset  
      Default Value:     actemp
      Description:       Variable name which indicates drug stopped temporarily in the adverse event dataset

    Name:                aestdrg
      Allowed Values:    Variable name of the AE action study drug in the adverse event dataset 
      Default Value:     aestdrg when aeacndrv=0 or null when aeacndrv=1
      Description:       Variable name of the AE action study drug in the adverse event dataset

    Name:                aeacndr1
      Allowed Values:    Variable name of the AE action with respect to drug 1 in the adverse event dataset 
      Default Value:     null
      Description:       Variable name of the AE action with respect to drug 1 in the adverse event dataset

    Name:                aeacndr2
      Allowed Values:    Variable name of the AE action with respect to drug 2 in the adverse event dataset 
      Default Value:     null
      Description:       Variable name of the AE action with respect to drug 2 in the adverse event dataset

    Name:                aeacndr3
      Allowed Values:    Variable name of the AE action with respect to drug 3 in the adverse event dataset 
      Default Value:     null
      Description:       Variable name of the AE action with respect to drug 3 in the adverse event dataset

    Name:                aeacndr4
      Allowed Values:    Variable name of the AE action with respect to drug 4 in the adverse event dataset 
      Default Value:     null
      Description:       Variable name of the AE action with respect to drug 4 in the adverse event dataset

    Name:                aegrade
      Allowed Values:    Variable name of the AE toxicity grade in the adverse event dataset 
      Default Value:     aegrade
      Description:       Variable name of the AE toxicity grade in the adverse event dataset

    Name:                sdrgcaus
      Allowed Values:    Variable name of the Study Drug Cause of AE in the adverse event dataset 
      Default Value:     aegrade
      Description:       Variable name of the Study Drug Cause of AE in the adverse event dataset

    Name:                drg1nam
      Allowed Values:    Variable name of the Drug 1 name in the adverse event dataset 
      Default Value:     null
      Description:       Variable name of the Drug 1 name in the adverse event dataset

    Name:                drg1caus
      Allowed Values:    Variable name of the Causality with respect to Drug 1 name in the adverse event dataset 
      Default Value:     null
      Description:       Variable name of the Causality with respect to Drug 1 name in the adverse event dataset

    Name:                drg2nam
      Allowed Values:    Variable name of the Drug 2 name in the adverse event dataset 
      Default Value:     null
      Description:       Variable name of the Drug 2 name in the adverse event dataset

    Name:                drg2caus
      Allowed Values:    Variable name of the Causality with respect to Drug 2 name in the adverse event dataset 
      Default Value:     null
      Description:       Variable name of the Causality with respect to Drug 2 name in the adverse event dataset

    Name:                drg3nam
      Allowed Values:    Variable name of the Drug 3 name in the adverse event dataset 
      Default Value:     null
      Description:       Variable name of the Drug 3 name in the adverse event dataset

    Name:                drg3caus
      Allowed Values:    Variable name of the Causality with respect to Drug 3 name in the adverse event dataset 
      Default Value:     null
      Description:       Variable name of the Causality with respect to Drug 3 name in the adverse event dataset

    Name:                drg4nam
      Allowed Values:    Variable name of the Drug 4 name in the adverse event dataset 
      Default Value:     null
      Description:       Variable name of the Drug 4 name in the adverse event dataset

    Name:                drg4caus
      Allowed Values:    Variable name of the Causality with respect to Drug 4 name in the adverse event dataset 
      Default Value:     null
      Description:       Variable name of the Causality with respect to Drug 4 name in the adverse event dataset

    Name:                deathds
      Allowed Values:    Valid SAS dataset name 
      Default Value:     null
      Description:       SAS Dataset name of the death event dataset 

    Name:                deathdt
      Allowed Values:    SAS variable name for date of death in the death dataset
      Default Value:     null
      Description:       Variable name for date of death in the death dataset 

    Name:                dthsubid
      Allowed Values:    Valid SAS Variable name for SUBJID in the death dataset
      Default Value:     null
      Description:       Variable name for SUBJID/PTID in the death dataset 

    Name:                randds
      Allowed Values:    Valid SAS dataset name 
      Default Value:     null
      Description:       SAS Dataset name of the randomization dataset 

    Name:                randsubj
      Allowed Values:    Valid SAS Variable name for SUBJID in the randomization dataset
      Default Value:     null
      Description:       Variable name for SUBJID/PTID in the randomization dataset

    Name:                randdt
      Allowed Values:    SAS variable name for date of death in the randomization dataset
      Default Value:     null
      Description:       Variable name for date of death in the randomization dataset 

    Name:                imputept
      Allowed Values:    null or 6
      Default Value:     null
      Description:       6 if the subject id needs to be imputed/modified or null if no imputations/modifications are needed


  Macro Output:  SAE Recon_yymmdd excel report is created in the "/../dm/listings/current" Folder


-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2284 $
  
-----------------------------------------------------------------------------*/

%macro pfesacq_sae_recon(indsdm     = , /* Name of the raw Demographics dataset */
						 study      = , /* Variable Name of the study name */
						 subjid     = , /* Variable Name of the subject ID */
						 sex        = , /* Variable Name of the gender */
						 dob        = , /* Variable Name of the date of birth */

						 inds       = , /* Name of the raw Adverse Events Dataset */
						 lstchgts   = ,           /* Variable Name of the AE Last Updated Date */
						 aeser      = , /* Variable Name of the AE Seriousness */
						 aecaseid   = , /* Variable Name of the AE Case ID */
						 aeterm     = , /* Variable Name of the AE Verbatim Term */
						 aedecd2    = , /* Variable Name of the AE Preferred Term */
						 fromdate   = , /* Variable Name of the AE Start Date */
						 todate     = , /* Variable Name of the AE End Date */
						 aepres     = , /* Variable Name of the AE Present */
						 aercaus    = , /* Variable Name of the Reasonable Poss AE Related */
						 aeacndrv   = , /* AE Action Derivation indicator */
						 acwdrn     = , /* Variable Name of the AE Action - withdrawn */
						 acnone     = , /* Variable Name of the AE Action - none */
						 acother    = , /* Variable Name of the AE Action - other */
						 acred      = , /* Variable Name of the AE Action - dose reduced */
						 actemp     = , /* Variable Name of the AE Action - temporarily stopped */
						 aestdrg    = , /* Variable Name of the AE Action (non derived) */
						 aeacndr1   = , /* Variable Name of the AE Action taken with XXXX 1 */
						 aeacndr2   = , /* Variable Name of the AE Action taken with XXXX 2 */
						 aeacndr3   = , /* Variable Name of the AE Action taken with XXXX 3 */
						 aeacndr4   = , /* Variable Name of the AE Action taken with XXXX 4 */

						 aegrade    = , /* Variable Name of the AE Grade */
						 sdrgcaus   = , /* Variable Name of Study Drug Cause of AE */
						 drg1nam    = , /* Variable Name of Drug Name 1 */
						 drg1caus   = , /* Variable Name of Drug Name 1 Causality */
						 drg2nam    = , /* Variable Name of Drug Name 2 */
						 drg2caus   = , /* Variable Name of Drug Name 2 Causality */
						 drg3nam    = , /* Variable Name of Drug Name 3 */
						 drg3caus   = , /* Variable Name of Drug Name 3 Causality */
						 drg4nam    = , /* Variable Name of Drug Name 4 */
						 drg4caus   = , /* Variable Name of Drug Name 4 Causality */

					     deathds    = , /* Name of the raw Death Dataset */
						 deathdt    = , /* Variable Name of the Death Date */
						 dthsubid   = , /* Variable Name of the subject ID in Death dataset */
 					     randds     = , /* Name of the raw Randomization Dataset */
                         randsubj   = , /* Variable Name of the subject ID in Randomization dataset */
                         randdt     = , /* Variable Name of the randomization date in the Randomization dataset */



						 imputept   =   /* Indicator for Imputation of subject id variable */

						);

    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_SAE_RECON: Start of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;


*** Call the Macro that converts the raw Adverse Event EDC dataset into the SACQ format ***;

%pfesacq_sae_recon_ae_transform();

*** Call the Macro that converts the raw Denographics EDC dataset into the SACQ format ***;

%pfesacq_sae_recon_dem_transform();

*** Call the Macro that converts the raw safety excel file into the SACQ format ***;

%pfesacq_sae_recon_safe_transform();

*** Call the Macro to create the DMCHECK1 Dataset with study mismatches ***;

%pfesacq_sae_recon_dem_check1();

*** Call the Macro to create the DMCHECK2 Dataset with subject mismatches ***;

%pfesacq_sae_recon_dem_check2();

*** Call the Macro to create the DMCHECK3 Dataset with DOB mismatches ***;

%pfesacq_sae_recon_dem_check3();

*** Call the Macro to create the DMCHECK4 Dataset with Gender mismatches ***;

%pfesacq_sae_recon_dem_check4();

*** Call the Macro to create the AECHECK1 Dataset with AE Seriousness mismatches ***;

%pfesacq_sae_recon_ae_check1();

*** Call the Macro to create the AECHECK2 Dataset with AE Case ID mismatches ***;

%pfesacq_sae_recon_ae_check2();

*** Call the Macro to create the AECHECK3 Dataset with AE Verbatime Term mismatches ***;

%pfesacq_sae_recon_ae_check3();

*** Call the Macro to create the AECHECK4 Dataset with AE Preferred Term mismatches ***;

%pfesacq_sae_recon_ae_check4();

*** Call the Macro to create the AECHECK5 Dataset with AE Seriousness mismatches ***;

%pfesacq_sae_recon_ae_check5();

*** Call the Macro to create the AECHECK6 Dataset with AE Start Date mismatches ***;

%pfesacq_sae_recon_ae_check6();

*** Call the Macro to create the AECHECK7 Dataset with AE Stop Date mismatches ***;

%pfesacq_sae_recon_ae_check7();

*** Call the Macro to create the AECHECK8 Dataset with AE Causality mismatches ***;

%pfesacq_sae_recon_ae_check8();

*** Call the Macro to create the AECHECK9 Dataset with AE Action mismatches ***;

%pfesacq_sae_recon_ae_check9();

*** Call the Macro to create the AECHECK10 Dataset with matched records and CRF/Safe only records ***;

%pfesacq_sae_recon_ae_check10();

*** Call the Macro to create the AECHECK11 Dataset with AE Death Date ***;

%pfesacq_sae_recon_ae_check11();

*** Call the Macro to create the AECHECK12 Dataset with multiple mismatches and CRF/Safe only records ***;

%pfesacq_sae_recon_ae_check12();



*** Call the Macro to create the SAE Recon Report ***;

%pfesacq_sae_recon_report();







    %macend:;
    %put ;
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_SAE_RECON_AE_TRANSFORM: End of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_sae_recon;


*** Example call of this macro ***;

*** 208309 ***;

*%pfesacq_sae_recon(indsdm     = demog,
     				study      = studynam,
     				subjid     = scrnid,
     				sex        = sex,
     				dob        = dob,
     				inds       = adverse,
     				aeser      = aeser,
     				aecaseid   = aecaseid,
     				aeterm     = aeterm,
     				aedecd2    = aeterm_enc_term,
     				fromdate   = fromdt,
     				todate     = todate1,
     				aepres     = aepres,
     				aercaus    = aercaus,


     				aeacndrv   = 1,
     				acwdrn     = acwdrn,
     				acnone     = acnone,
     				acother    = acother,
     				acred      = ,
     				actemp     = ,
     				aestdrg    = ,
	 				aeacndr1   = aest1tr, /* Variable Name of the AE Action taken with XXXX 1 */
	 				aeacndr2   = aest2tr, /* Variable Name of the AE Action taken with XXXX 2 */
	 				aeacndr3   = , 	   /* Variable Name of the AE Action taken with XXXX 3 */
	 				aeacndr4   = ,        /* Variable Name of the AE Action taken with XXXX 4 */
     				aegrade    = aegrade,
	 				sdrgcaus   = aercaus, /* Variable Name of Study Drug Cause of AE */
	 				drg1nam    = aecs1nm, /* Variable Name of Drug Name 1 */
	 				drg1caus   = aecs1tr, /* Variable Name of Drug Name 1 Causality */
	 				drg2nam    = aecs2nm, /* Variable Name of Drug Name 2 */
	 				drg2caus   = aecs2tr, /* Variable Name of Drug Name 2 Causality */
	 				drg3nam    = ,  	   /* Variable Name of Drug Name 1 */
	 				drg3caus   = , 	   /* Variable Name of Drug Name 1 Causality */
	 				drg4nam    = , 	   /* Variable Name of Drug Name 2 */
	 				drg4caus   = ,		   /* Variable Name of Drug Name 2 Causality */

				    deathds    = death,
				    deathdt    = srvddt,
				    dthsubid   = scrnid,
				    randds     = random,
				    randsubj   = scrnid,
				    randdt     = randdt,
				    imputept   =

     );

*** 216611 ***;

*%pfesacq_sae_recon (	 indsdm     = demg,
						 study      = studynam,
						 subjid     = scrnid,
						 sex        = sex,
						 dob        = dob,

						 inds       = adve,
						 lstchgts   = lstupd,           /* Variable Name of the AE Last Updated Date */
						 aeser      = aeser,
						 aecaseid   = aecase,
						 aeterm     = aeterm,
						 aedecd2    = aeterm_enc_term,
						 fromdate   = fromdat,
						 todate     = todate,
						 aepres     = aepres,
						 aercaus    = aercaus,
						 aeacndrv   = 1,
						 acwdrn     = acwdrn,
						 acnone     = acnone,
						 acother    = acother,
						 acred      = ,
						 actemp     = ,
						 aestdrg    = ,
						 aegrade    = aegrade,

					     deathds    = srv,
						 deathdt    = evtdt,
						 dthsubid   = scrnid,

 					     randds     = rand,
                         randsubj   = scrnid,
                         randdt     = randdt, 

						 imputept   =
					);



*** 205792 ***;

*%pfesacq_sae_recon (	 indsdm     = demo,
						 study      = study,
						 subjid     = subjid,
						 sex        = sex,
						 dob        = birthd,

						 inds       = aemaem,
						 lstchgts   = lstupd,           /* Variable Name of the AE Last Updated Date */
						 aeser      = fsaeyn,
						 aecaseid   = aecase,
						 aeterm     = aeterm,
						 aedecd2    = aedecd2,
						 fromdate   = startd,
						 todate     = stopd,
						 aepres     = indicyn,
						 aercaus    = relats,
						 aeacndrv   = 1,
						 acwdrn     = atstop,
						 acnone     = atnone,
						 acother    = atothr,
						 acred      = atrduc,
						 actemp     = attemp,
						 aestdrg    = ,
						 aegrade    = toxgr,

						 deathds    = dth,
						 deathdt    = colldate,
						 dthsubid   = subjid,

					     randds     = rand,
                         randsubj   = subjid,
                         randdt     = randd, 

						 imputept   = 6
					);


*** 207756 ***;

*%pfesacq_sae_recon (	 indsdm     = de_1,
						 study      = study,
						 subjid     = subjid,
						 sex        = sex,
						 dob        = dob,

						 inds       = ae_bqg1,
						 lstchgts   = lstupd,           /* Variable Name of the AE Last Updated Date */
						 aeser      = aeser,
						 aecaseid   = aecase,
						 aeterm     = aeterm,
						 aedecd2    = aedecd2,
						 fromdate   = fromdat,
						 todate     = stopdat,
						 aepres     = aepres,
						 aercaus    = aercaus,
						 aeacndrv   = 0,
						 acwdrn     = ,
						 acnone     = ,
						 acother    = ,
						 acred      = ,
						 actemp     = ,
						 aestdrg    = aest1tr,
						 aegrade    = aegrade,

						 deathds    = srv2,
						 deathdt    = srvddt,
						 dthsubid   = subjid,

						 randds     = rand,
                         randsubj   = subjid,
                         randdt     = randdt, 

						 imputept   = 
					);


*** 206425 ***;

*%pfesacq_sae_recon (	 indsdm     = de_1,
						 study      = study,
						 subjid     = subjid,
						 sex        = sex,
						 dob        = dob,

						 inds       = ae_a,
						 lstchgts   = lstupd,           /* Variable Name of the AE Last Updated Date */
						 aeser      = aeser,
						 aecaseid   = aecase,
						 aeterm     = aeterm,
						 aedecd2    = aedecd2,
						 fromdate   = fromdat,
						 todate     = stopdat,
						 aepres     = aepres,
						 aercaus    = aercaus,
						 aeacndrv   = 0,
						 acwdrn     = ,
						 acnone     = ,
						 acother    = ,
						 acred      = ,
						 actemp     = ,
						 aestdrg    = aestdrg,
						 aegrade    = aegrade,

					     deathds    = sb_3,
					     deathdt    = dieddat,
						 dthsubid   = subjid,

						 randds     = rand,
                         randsubj   = subjid,
                         randdt     = randdt , 

						 imputept   = 
					);

*** 207611 ***;

*%pfesacq_sae_recon (	 indsdm     = dm,
						 study      = studynam,
						 subjid     = scrnid,
						 sex        = sex,
						 dob        = dob,

						 inds       = ae,
						 lstchgts   = lstupd,           /* Variable Name of the AE Last Updated Date */
						 aeser      = aeser,
						 aecaseid   = aecaseid,
						 aeterm     = aeterm,
						 aedecd2    = aeterm_enc_term,
						 fromdate   = fromdate,
						 todate     = todate,
						 aepres     = aepres,
						 aercaus    = aercaus,
						 aeacndrv   = 0,
						 acwdrn     = ,
						 acnone     = ,
						 acother    = ,
						 acred      = ,
						 actemp     = ,
						 aestdrg    = aestdrg,
						 aegrade    = aegrade,

						 deathds    = sbsm,
						 deathdt    = dieddate,
						 dthsubid   = scrnid,

						 randds     = rand,
                         randsubj   = scrnid,
                         randdt     = randdt, 

						 imputept   = 
					);