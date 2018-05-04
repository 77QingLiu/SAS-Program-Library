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
 
  Program Purpose:       Lab Reconciliation of the raw lab dataset and the vendor lab data. Calls the other Lab Recon 
                         macros which convert the raw lab data into SACQ format and then checks for mismatches and report the 
                         final Lab Recon report.
						 8 Lab Checks are performed against the lab vendor data as defined in the la bspecifications document and
                         an excel report is genereated with the findings.
 
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
      Allowed Values:    SAS variable name for the Gender in the demog dataset  
      Default Value:     subjid
      Description:       SAS variable name for the Gender in the demog dataset 

    Name:                dob
      Allowed Values:    SAS variable name for the Date of Birth in the demog dataset  
      Default Value:     subjid
      Description:       SAS variable name for the Date of Birth in the demog dataset



    Name:                inds
      Allowed Values:    Valid SAS dataset name 
      Default Value:     null
      Description:       SAS Dataset name of the lab EDC dataset 

    Name:                siteid
      Allowed Values:    SAS variable name for the Site ID in the lab EDC dataset  
      Default Value:     null
      Description:       SAS variable name for the Site ID in the lab EDC dataset

    Name:                formname
      Allowed Values:    String of the Form names for Lab data  
      Default Value:     null
      Description:       String of the Form names for Lab data for datalab studies. (example: %str("LABD02_1","LABD02_2","LABD02_3") )

    Name:                cpevent
      Allowed Values:    SAS variable name for the CPEvent (visit) in the lab EDC dataset  
      Default Value:     null
      Description:       SAS variable name for the CPEvent (visit) in the lab EDC dataset

    Name:                visit
      Allowed Values:    SAS variable name for the visit number in the lab EDC dataset  
      Default Value:     null
      Description:       SAS variable name for the visit number in the lab EDC dataset

    Name:                lbcat
      Allowed Values:    SAS variable name for the Lab Category in the lab EDC dataset  
      Default Value:     null
      Description:       SAS variable name for the Lab Category in the lab EDC dataset

    Name:                lnotdone
      Allowed Values:    SAS variable name for the Lab Not Done in the lab EDC dataset  
      Default Value:     null
      Description:       SAS variable name for the Lab Not Done in the lab EDC dataset

    Name:                colldate
      Allowed Values:    SAS variable name for the Lab Collection Date in the lab EDC dataset  
      Default Value:     null
      Description:       SAS variable name for the Lab Collection Date in the lab EDC dataset

    Name:                visitdt
      Allowed Values:    SAS variable name for the Visit Date in the lab EDC dataset  
      Default Value:     null
      Description:       SAS variable name for the Visit Date in the lab EDC dataset

    Name:                testtime
      Allowed Values:    SAS variable name for the Lab Collection Time in the lab EDC dataset  
      Default Value:     null
      Description:       SAS variable name for the Lab Collection Time in the lab EDC dataset

    Name:                labsmpid
      Allowed Values:    SAS variable name for the Lab Sample ID in the lab EDC dataset  
      Default Value:     null
      Description:       SAS variable name for the Lab Sample ID in the lab EDC dataset

    Name:                lbtpt
      Allowed Values:    SAS variable name for the Lab Time Point in the lab EDC dataset  
      Default Value:     null
      Description:       SAS variable name for the Lab Time Point in the lab EDC dataset

    Name:                invcom
      Allowed Values:    SAS variable name for the Investigator Comment in the lab EDC dataset  
      Default Value:     null
      Description:       SAS variable name for the Investigator Comment in the lab EDC dataset


  Macro Output:  Lab Recon_yymmdd excel report is created in the "/../dm/listings/current" Folder
                 Lab Checks_yymmdd excel report is created in the "/../dm/listings/current" Folder


-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev:  $
  
-----------------------------------------------------------------------------*/

%macro pfesacq_lab_recon(indsdm     = , /* Name of the raw Demographics dataset */
						 study      = , /* Variable Name of the study name in EDC dataset */
						 subjid     = , /* Variable Name of the subject ID in EDC dataset */
						 sex        = , /* Variable Name of the gender */
						 dob        = , /* Variable Name of the date of birth */

						 inds       = , /* Name of the EDC Lab Dataset */
						 siteid     = , /* Variable Name of the Site ID */
						 formname   = , /* String of the form name values to check if its a central lab record for datalabs studies */
	 					 cpevent    = , /* Variable Name of the CPEvent*/
						 visit      = , /* Variable Name of the Visit Name */
						 lbcat      = , /* Variable Name of the Lab Category or Classification */
						 lnotdone   = , /* Variable Name of the Lab Not Done */
						 colldate   = , /* Variable Name of the Lab Collection Date */
						 visitdt    = , /* Variable Name of the Visit Date */
						 testtime   = , /* Variable Name of the Lab Collection Time */
						 labsmpid   = , /* Variable Name of the Lab Sample ID */
						 lbtpt      = , /* Variable Name of the Lab Time Point */
						 invcom     =   /* Variable Name of the Investigator Comment */

						);

    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_LAB_RECON: Start of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

	%local _list_macvars ;

	%let _list_macvars = 
		estudy      /* Variable Name of the Study Name in vendor Lab Dataset */
		esiteid     /* Variable Name of the Site ID in vendor Lab Dataset  */
		esubjid     /* Variable Name of the Subject ID in vendor Lab Dataset */
		esex        /* Variable Name of the Subject gender in vendor Lab Dataset */
		edob        /* Variable Name of the Subject Date of Birth in vendor Lab Dataset */
		evisit      /* Variable Name of the Visit Name in vendor Lab Dataset */
		elbcat      /* Variable Name of the Lab Category or Classification in vendor Lab Dataset */
		elbtest     /* Variable Name of the Lab Test Name in vendor Lab Dataset */
		epxcode     /* Variable Name of the PXCode in vendor Lab Dataset */
		elbtstid    /* Variable Name of the Lab Test ID in vendor Lab Dataset */
		eresult     /* Variable Name of the Lab Result in vendor Lab Dataset */
		eresunit    /* Variable Name of the Lab Unit in vendor Lab Dataset */
		estdres     /* Variable Name of the Lab Standard result in vendor Lab Dataset */
		estdunit    /* Variable Name of the Lab Standard Unit in vendor Lab Dataset */
		elnotdone   /* Variable Name of the Lab Not Done in vendor Lab Dataset */
		ecolldate   /* Variable Name of the Lab Collection Date in vendor Lab Dataset */
		etesttime   /* Variable Name of the Lab Collection Time in vendor Lab Dataset */
		elbtpt      /* Variable Name of the Lab Time Point in vendor Lab Dataset */
		elbtpth     /* Variable Name of the Lab Time Point (Hours) in vendor Lab Dataset */
		elbtptm     /* Variable Name of the Lab Time Point (Minutes) in vendor Lab Dataset */
		elabsmpid   /* Variable Name of the Lab Sample ID in vendor Lab Dataset */
		einvcom     /* Variable Name of the Investigator Comment in vendor Lab Dataset */
	    ;

	%let _list_macvars = %cmpres(&_list_macvars) ;
	%local &_list_macvars ;

	*** Call the Macro that creates macro variables for Vendor Lab dataset variables ***;

	%pfesacq_lab_recon_vend_macvars() ;

	*** Call the Macro that converts the EDC Lab dataset into the SACQ format ***;

	%pfesacq_lab_recon_edc_transform();

	*** Call the Macro that converts the Vendor Lab dataset into the SACQ format ***;

	%pfesacq_lab_recon_vend_transform();

	*** Call the Macro that reconciles the EDC and Vendor Lab dataset and creates the LABRECON dataset ***;

	%pfesacq_lab_recon_flags();

	*** Call the Macro to create the Lab Recon Report ***;

	%pfesacq_lab_recon_report();

	*** Call the 8 Macros that create the lab checks datasets LIS01-LIS08 ***;

	%pfesacq_lab_recon_lis01();
	%pfesacq_lab_recon_lis02();
	%pfesacq_lab_recon_lis03();
	%pfesacq_lab_recon_lis04();
	%pfesacq_lab_recon_lis05();
	%pfesacq_lab_recon_lis06();
	%pfesacq_lab_recon_lis07();
	%pfesacq_lab_recon_lis08();
	%pfesacq_lab_recon_lis09();
	%pfesacq_lab_recon_lis10();
	%pfesacq_lab_recon_lis11();

	*** Call the Macro to create the Lab Checks Report ***;

	%pfesacq_lab_recon_checks_report();

	options nomlogic nomprint nocenter ls=132 ps=60;

    %macend:;
    %put ;
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_LAB_RECON: End of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_lab_recon;


*** Example call of this macro ***;

*** 212396 ***;

%pfesacq_lab_recon( indsdm      = demog,    /* Name of the raw Demographics dataset */
				    study       = studynam, /* Variable Name of the study name in EDC dataset */
				    subjid      = scrnid,   /* Variable Name of the subject ID in EDC dataset */
				    sex         = sex,      /* Variable Name of the gender */
				    dob         = dobf,     /* Variable Name of the date of birth */						

					inds        = lab_safe, /* Name of the EDC Lab Dataset */
				    siteid      = siteid,   /* Variable Name of the Site ID */
				    formname    = %str("LABD02_1","LABD02_2","LABD02_3","LABD02_4","LABD02_5","LABD02_6","LABD02_8","LABD02_10","LABD02_11"),   /* String of the form name values to check if its a central lab record for datalabs studies */
					cpevent     = evtnam,   /* Variable Name of the CPEvent*/
				    visit       = evtorder, /* Variable Name of the Visit Name */
				    lbcat       = formlbl,  /* Variable Name of the Lab category or classification */
				    lnotdone    = lbnd,     /* Variable Name of the Lab Not Done */
				    colldate    = lbdt,     /* Variable Name of the Lab Collection Date */
				   	visitdt     = evtdt,    /* Variable Name of the Visit Date */
				    testtime    = ,         /* Variable Name of the Lab Collection Time */
   				    lbtpt       = ,         /* Variable Name of the Lab Time Point */
				    labsmpid    = lbusmid,  /* Variable Name of the Lab Sample ID */
				    invcom      = invcom    /* Variable Name of the Invesitgator Comment */


					);