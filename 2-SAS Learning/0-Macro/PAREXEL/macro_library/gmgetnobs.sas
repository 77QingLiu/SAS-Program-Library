/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        80386

  SAS Version:           9.1.3 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Julius Kusserow $LastChangedBy: kolosod $
  Creation Date:         20MAY2016       $LastChangedDate: 2016-06-06 04:32:52 -0400 (Mon, 06 Jun 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmgetnobs.sas $

  Program Purpose:       The macro %gmGetNObs returns the number of
                         observations in a dataset or view.

                         The macro by default ABORTs if the dataset is not
                         present. This behaviour can be changed using the
                         selectType parameter.

                         It is possible to apply a where clause to the
                         dataset. A sysntax error in the where clause leads to
                         an ABORT.

  Macro Parameters:

    Name:                dataIn
      Allowed Values:    Any valid dataset (or view) name
      Default Value:     REQUIRED
      Description:       The name of a dataset (or view) that should be
                         used for reporting its number of logical observations.


    Name:                where
      Allowed Values:    Any String
      Default Value:     1
      Description:       A where condition to be applied to the dataIn parameter
                         before counting lines.

    Name:                selectType
      Allowed Values:    N|NOTE|E|ERROR|ABORT case insensitive
      Default Value:     ABORT
      Description:       Behaviour of the macro when the dataset to be used
                         is not present.

  Macro Dependencies:    gmMessage (called)
                         gmCheckValueExists (called)
                         gmStart (called)
                         gmEnd (called)

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2279 $
-----------------------------------------------------------------------------*/
%MACRO gmGetNObs( dataIn  =
                , where = 1
                , selectType = ABORT
                );
%TRIM(%LEFT(
  %gmStart( headURL    = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmgetnobs.sas $
          , revision   = $Rev: 2279 $
          )
  /*
   * Declaration of local variables
   */
  %LOCAL gmGetNObs_macroname
         gmGetNObs_dsid
         gmGetNObs_num
         gmGetNObs_rc
         gmGetNObs_syscc
  ;

  %LET gmGetNObs_macroname=&SYSMACRONAME.;

  %gmCheckValueExists( codeLocation = gmGetNObs/dataIn
                     , selectMethod = EXISTS
                     , value        = &dataIn.
  )

  %IF %QSYSFUNC(PRXMATCH(/^\s*(N|NOTE|E|ERROR|ABORT)\s*$/i, %BQUOTE(&selectType.))) = 0 %THEN %DO;
    %gmMessage( codeLocation=&gmGetNObs_macroname./Parameter check
              , linesOut= selectType=%SUPERQ(selectType) macro parameter has an invalid value.
              @ Please choose N or NOTE or E or ERROR or ABORT as values.
              , selectType=ABORT
              );

  %END;

  %IF ~( %SYSFUNC(EXIST(&dataIn.)) OR
         %SYSFUNC(EXIST(&dataIn.,VIEW))
       ) %THEN %DO;
    %gmMessage( codeLocation = &gmGetNObs_macroname./Check dataIn
              , linesOut     = Dataset or View &dataIn. does not
              @ exists. Number of observations can not be determined.
              , selectType   = &selectType.
              )
    -1
  %END;
  %ELSE %DO;
    %LET gmGetNObs_syscc = &syscc.;
    %LET syscc=0;

    /*
     * Get the number of observations in a table, where the number of obs is a stored metadata.
     * Returns -1 if NOBS is not available.
     */
    %LET gmGetNObs_dsid = %SYSFUNC(OPEN(&dataIn.(WHERE=(&where.)),I));
    %LET gmGetNObs_num  = %SYSFUNC(ATTRN(&gmGetNObs_dsid.,NLOBSF));
    %LET gmGetNObs_rc   = %SYSFUNC(CLOSE(&gmGetNObs_dsid.));

    %IF &SYSCC.>0 %THEN %DO;
      %gmMessage( codeLocation=&gmGetNObs_macroname./Post execution check
                , linesOut= After retrieving obs. An Error was detected. Probably the where clause is wrong.
                , selectType=ABORT
                )
    %END;

    %LET syscc=&gmGetNObs_syscc.;

    %gmMessage( codeLocation = &gmGetNObs_macroname./Confirmation Message
              , linesOut     = The dataset or view &dataIn.(WHERE=(&where.)) has &gmGetNObs_num. observations.
              , selectType   = N
              , debugOnly    = 1
              )
      /* Return Value */
      &gmGetNObs_num.
  %END;

  %gmEnd(
    headURL=$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmgetnobs.sas $
  )
))
%MEND gmGetNObs;
