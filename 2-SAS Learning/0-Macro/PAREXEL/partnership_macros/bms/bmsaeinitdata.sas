/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: BMS / BMS Partnership
  PXL Study Code:

  SAS Version:           9.2 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Roman Igla      $LastChangedBy: iglar $
  Creation Date:         24APR2015       $LastChangedDate: 2016-02-26 03:53:12 -0500 (Fri, 26 Feb 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/bms/bmsaeinitdata.sas $

  Files Created:         N/A

  Program Purpose:       Macro bmsAeInitData initializes the macro-variables used in bmsAeX001-bmsAeX012 macros.
                         If the macro-variables in the call of those macros are empty (default) then the values are
                         taken either set to defaults or taken from the global macro-variables defined in setup.
                         The list of macro-variables that and initialized in this macro: dataIn, trtNum, trtName,
                         aeBodSys, aeDecod, aeToxGrN, subjIdVar, popIn, popTrtNum, popTrtName, popFlag.
                         See discussions for more details.

                         This macro is PAREXEL’s intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL’s senior management.

                         This macro has been validated for use only in PAREXELs
                         working environment.

  Macro Parameters:

    Name:                BMS_AE_INPUT_VARS
      Default Value:     REQUIRED
      Description:       List of macro-variables to be initialized


  Macro Dependencies:    gmStart (called)
                         #gmEnd (called)

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 1874 $
-----------------------------------------------------------------------------*/



%macro BMSAEINITDATA(BMS_AE_INPUT_VARS=);

  %gmStart( headURL  = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/bms/bmsaeinitdata.sas $
          , revision = $Rev: 1874 $
          , checkMinSasVersion = 9.2
          );

    %*input variables will be assigned in parent macro: BMS_AE_INPUT_VARS;;
    %local i BMS_AE_MACRO_VARIABLE
           DEV_DATAIN
           DEV_TRTNUM
           DEV_TRTNAME
           DEV_AEBODSYS
           DEV_AEDECOD
           DEV_AETOXGRN
           DEV_SUBJIDVAR
           DEV_POPIN
           DEV_POPTRTNUM
           DEV_POPTRTNAME
           DEV_POPFLAG;


    %*Set Dev variables according to data structure;;

    %let DEV_DATAIN    = Analysis.Adae;
    %let DEV_TRTNUM    = TrtAN;
    %let DEV_TRTNAME   = TrtA;
    %let DEV_AEBODSYS  = AeBodSys;
    %let DEV_AEDECOD   = AeDecod;
    %let DEV_AETOXGRN  = AeToxGrN;
    %let DEV_SUBJIDVAR = USubjId;
    %let DEV_POPIN     = Analysis.Adsl;
    %let DEV_POPTRTNUM = Trt01AN;
    %let DEV_POPTRTNAME= Trt01A;
    %let DEV_POPFLAG   = %quote(SafFl eq "Y");

    %*Assign macro variables for %BmsFreq() below;;
    %let i = 1;
    %do %while(%length(%scan(&BMS_AE_INPUT_VARS., &i.)) gt 0);

        %let BMS_AE_MACRO_VARIABLE = %scan(&BMS_AE_INPUT_VARS., &i.);
        %let i = %eval(&i. + 1);

        %if %str(&&&BMS_AE_MACRO_VARIABLE..) eq %str() %then %do;
            %let &BMS_AE_MACRO_VARIABLE. = %upcase(&&DEV_&BMS_AE_MACRO_VARIABLE..);
            %if %symExist(BMSAE_&BMS_AE_MACRO_VARIABLE.) %then %do;
                %if %str(&&BMSAE_&BMS_AE_MACRO_VARIABLE..) ne %str() %then %do;
                    %let &BMS_AE_MACRO_VARIABLE. = &&BMSAE_&BMS_AE_MACRO_VARIABLE..;
                %end;
            %end;
        %end;

    %end;

    %gmEnd(headURL  = $    $);


%mend BMSAEINITDATA;
