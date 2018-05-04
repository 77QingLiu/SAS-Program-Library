/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership

  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------

  Author:                Allwyn Dsouza $LastChangedBy: dsouzaal $
  Creation Date:         29NOV2015     $LastChangedDate: 2016-06-10 06:24:47 -0400 (Fri, 10 Jun 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfesacq_ecg_recon.sas $

  Files Created:         None

  Program Purpose:       ECG Reconciliation of the raw ECG dataset and the vendor ECG data. Calls the other ECG Recon
                         macros which convert the raw ECG data into SACQ format and then checks for mismatches
                         and report the final ECG Recon report.

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.

                         This macro has been validated for use only in PAREXEL's
                         working environment.

  Macro Parameters:

    Name:                indsdm
      Allowed Values:    Valid SAS dataset name of Demography dataset
      Default Value:     null
      Description:       Valid SAS dataset name of Demography dataset

    Name:                sex
      Allowed Values:    SAS variable name for patient gender in the Demography dataset
      Default Value:     null
      Description:       SAS variable name for patient gender in the Demography dataset

    Name:                dob
      Allowed Values:    SAS variable name for patient date of birth in the Demography dataset
      Default Value:     null
      Description:       SAS variable name for patient date of birth in the Demography dataset



    Name:                inds
      Allowed Values:    Valid SAS dataset name
      Default Value:     null
      Description:       SAS Dataset name of the EDC ECG dataset

    Name:                study
      Allowed Values:    SAS variable name for the study name in the ECG EDC dataset
      Default Value:     null
      Description:       SAS variable name for the study name in the ECG EDC dataset

    Name:                siteid
      Allowed Values:    SAS variable name for the Site ID in the ECG EDC dataset
      Default Value:     null
      Description:       SAS variable name for the Site ID in the ECG EDC dataset

    Name:                subjid
      Allowed Values:    SAS variable name for the Subject ID in the demog dataset
      Default Value:     null
      Description:       SAS variable name for the Subject ID in the demog dataset

    Name:                cpevent
      Allowed Values:    SAS variable name for the CPEvent (visit) in the ECG EDC dataset
      Default Value:     null
      Description:       SAS variable name for the CPEvent (visit) in the ECG EDC dataset

    Name:                egnd
      Allowed Values:    SAS variable name for the ECG Not Done in the ECG EDC dataset
      Default Value:     null
      Description:       SAS variable name for the ECG Not Done in the ECG EDC dataset

    Name:                colldate
      Allowed Values:    SAS variable name for the ECG Collection Date in the ECG EDC dataset
      Default Value:     null
      Description:       SAS variable name for the ECG Collection Date in the ECG EDC dataset

    Name:                visitdt
      Allowed Values:    SAS variable name for the Visit Date in the ECG EDC dataset
      Default Value:     null
      Description:       SAS variable name for the Visit Date in the ECG EDC dataset

    Name:                egacttmf
      Allowed Values:    SAS variable name for the ECG Collection Time in the ECG EDC dataset
      Default Value:     null
      Description:       SAS variable name for the ECG Collection Time in the ECG EDC dataset

    Name:                egtpd
      Allowed Values:    SAS variable name for the ECG Time Point in the ECG EDC dataset
      Default Value:     null
      Description:       SAS variable name for the ECG Time Point in the ECG EDC dataset

    Name:                egintp
      Allowed Values:    SAS variable name for the ECG Interpretation in the ECG EDC dataset
      Default Value:     null
      Description:       SAS variable name for the ECG Interpretation in the ECG EDC dataset

    Name:                egcom
      Allowed Values:    SAS variable name for the Investigator Comment in the ECG EDC dataset
      Default Value:     null
      Description:       SAS variable name for the Investigator Comment in the ECG EDC dataset

  Macro Output:  ECG_Recon_yymmdd excel report is created in the "/../dm/listings/current" Folder

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2296 $

-----------------------------------------------------------------------------*/

%macro pfesacq_ecg_recon(
	indsdm   = , /* Name of the EDC Demog Dataset */
	sex      = , /* Variable Name of the Gender */
	dob      = , /* Variable Name of the Date of birth */

	inds     = , /* Name of the EDC ECG Dataset */
	study	 = , /* Variable Name of the study name in EDC dataset */
	siteid   = , /* Variable Name of the Site ID */
	subjid	 = , /* Variable Name of the subject ID in EDC dataset */
	cpevent  = , /* Variable Name of the CPEvent */
	colldate = , /* Variable Name of the ECG Collection Date */
	visitdt  = , /* Variable Name of the Visit Date */
	egacttmf = , /* Variable Name of the ECG Collection Time */
	egtpd    = , /* Variable Name of the ECG Time Point */
	egintp   = , /* Variable Name of the ECG Interpretation */
	egnd     = , /* Variable Name of the ECG Not Done */
	egcom    =   /* Variable Name of the Investigator Comment */
	);
	
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put NOTE:[PXL] &sysmacroname.: Start of Submacro;
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put ;

	* ---------------------------------------------------------------------;
	* Initialise : ;
	* 	L_ERROR as boolean flag to store user/data-related error ;
	*	Create Dated Directory and set OUTDIR library reference ;
	* ---------------------------------------------------------------------;

	%local l_error;
	%let l_error = 0 ;
	
	%let create_dated_dir = Y ;
	%mu_create_dated_dir(type=listings) ;

	libname outdir "&path_listings./current";
	
	* ---------------------------------------------------------------------;
	* Call macro that converts the EDC ECG dataset to SACQ format ;
	* ---------------------------------------------------------------------;

	%pfesacq_ecg_recon_edc_transform;

	%if &l_error. = 1 %then %do; %goto mainend ; %end ;
	
	* ---------------------------------------------------------------------;
	* Call macro that converts the Vendor ECG dataset to SACQ format ;
	* ---------------------------------------------------------------------;
	
	%local _list_venmacvars ;
	%let _list_venmacvars = estudy esiteid esubjid ecpevent ecolldate eegacttmf eegtpd eegtest eegorres eegintp eegcom esex edob ;

	%local &_list_venmacvars. ;

	%pfesacq_ecg_recon_vend_transform;
	
	%if &l_error. = 1 %then %do; %goto mainend ; %end;
	
	* ---------------------------------------------------------------------;
	* Call individual listing macros and export listing to excel;
	* ---------------------------------------------------------------------;

	%pfesacq_ecg_recon_lis01;
	%pfesacq_ecg_recon_lis02;
	%pfesacq_ecg_recon_lis03;
	%pfesacq_ecg_recon_lis04;
	%pfesacq_ecg_recon_lis05;
	%pfesacq_ecg_recon_lis06;
	%pfesacq_ecg_recon_lis07;
	%pfesacq_ecg_recon_lis08;
	%pfesacq_ecg_recon_lis09;
	
	* ---------------------------------------------------------------------;
	* Call macro that reconciles the EDC ECG and Vendor ECG datasets and ;
	* creates the ECGRECON dataset ;
	* ---------------------------------------------------------------------;

	%pfesacq_ecg_recon_flags;

	%if &l_error. = 1 %then %do; %goto mainend ; %end ;

	* ---------------------------------------------------------------------;
	* Call macro to create the ECG Recon Report ;
	* ---------------------------------------------------------------------;

	%pfesacq_ecg_recon_report;

	%if &l_error. = 1 %then %do; %goto mainend ; %end ;

	* ---------------------------------------------------------------------;
	* Housekeeping and End ;
	* ---------------------------------------------------------------------;
	
	%mainend:;

	libname outdir clear;
	
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put NOTE:[PXL] &sysmacroname.: End of macro;
    %put NOTE:[PXL] ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_ecg_recon;