/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: BMS / BMS Partnership
  PXL Study Code:

  SAS Version:           9.2 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Sergey Krivtsov $LastChangedBy: iglar $
  Creation Date:         24APR2015       $LastChangedDate: 2016-02-26 03:53:12 -0500 (Fri, 26 Feb 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/bms/bmsaesort.sas $

  Files Created:         N/A

  Program Purpose:       Sorts the bmsFreq results as appropriate.

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.

                         This macro has been validated for use only in PAREXEL's
                         working environment.

  Macro Parameters:

    Name:                SORT_DATAIN
      Default Value:     REQUIRED
      Description:       Name of input dataset.

    Name:                SORT_DATAOUT
      Default Value:     REQUIRED
      Description:       Name of output dataset.

    Name:                SORT_BYVARS
      Description:       List of by variables.

    Name:                SORT_VARS
      Default Value:     REQUIRED
      Description:       Variables for sorting.

    Name:                SORT_TYPE
      Default Value:     REQUIRED
      Description:       Type of sorting: by alphabet or by frequency. Could be alph or freq.

    Name:                SORT_ORDER
      Default Value:     REQUIRED
      Description:       Order of sorting: descending or ascending. Could be desc or asce.

    Name:                SORT_COLUMN
      Default Value:     REQUIRED
      Description:       Column name for frequency sorting.

    Name:                SORT_SUFFIX
      Description:       Suffix for sort_column variable.


  Macro Dependencies:    gmMessage (called)
                         #gmStart (called)
                         #gmEnd (called)
-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 1874 $
-----------------------------------------------------------------------------*/

%macro bmsaesort(
                  SORT_DATAIN = ,
                 SORT_DATAOUT = ,
                  SORT_BYVARS = ,
                    SORT_VARS = ,
                    SORT_TYPE = ,
                   SORT_ORDER = ,
                  SORT_COLUMN = ,
                  SORT_SUFFIX =
                );

  %gmStart( headURL  = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/bms/bmsaesort.sas $
          , revision = $Rev: 1874 $
          ,checkMinSasVersion = 9.2
          );


    %*checks before macro execution;;

    %if %length(&SORT_VARS.) lt 1 %then
        %gmMessage(codelocation=%str(bmsaesort.sas),
                    linesout=Empty parameter SORT_VARS,
                    selectType=ABORT);

    %*if numbers of variables to sort, sort types and sort orders are not equal, then ABORT;;
    %if %sysFunc(countW(%str(&SORT_VARS.))) ne %sysFunc(countW(%str(&SORT_TYPE.))) or
        %sysFunc(countW(%str(&SORT_VARS.))) ne %sysFunc(countW(%str(&SORT_ORDER.))) %then %do;
        %gmMessage(codeLocation = %str(bmsaesort.sas),
                       linesOut = %str(Numbers of variables to sort, sort types and sort orders should be equal.),
                     selectType = ABORT);
    %end;

    *if sort type is other than freq/alph, then ABORT;
    %if ^%sysFunc(prxMatch(%str(/^(freq|alph|\s)+$/i), %str(&SORT_TYPE.))) %then %do;
        %put &SORT_TYPE.;
        %gmMessage(codeLocation = %str(bmsaesort.sas),
                       linesOut = %str(Sort type should be in (freq, alph)),
                     selectType = ABORT);
    %end;

    %*if sort order is other than asce/desc, then ABORT;;
    %if ^%sysFunc(prxMatch(%str(/^(asce|desc|\s)+$/i), %str(&SORT_ORDER.))) %then %do;
        %gmMessage(codeLocation = %str(bmsaesort/checks),
                       linesOut = %str(Sort order should be in (asce, desc)),
                     selectType = ABORT);
    %end;

    %*if at least one sort type is freq and column is not specified, then ABORT;;
    %if %sysFunc(prxMatch(%str(/freq/i), %str(&SORT_TYPE))) and &SORT_COLUMN. eq %str() %then %do;
        %gmMessage(codeLocation = %str(bmsaesort.sas),
                       linesOut = %str(Freq specified in sort type, but sort column is not specified.),
                     selectType = ABORT);
    %end;

    /*if no freq type specified but sort column is specified, then put NOTE;
    %if ^%sysFunc(prxMatch(%str(/freq/i), %str(&SORT_TYPE))) and &SORT_COLUMN. ne %str() %then %do;
        %gmMessage(codeLocation = %str(bmsaesort.sas),
                       linesOut = %str(No freq type specified. SORT_COLUMN value will be ignored.),
                     selectType = NOTE);
    %end;*/

    %let _sortMissing = ;
    %let _sortArgument = ;
    %let _sortGrpx = ;
    %let _col = &SORT_COLUMN.&SORT_SUFFIX.;
    %let _sortBy = &SORT_BYVARS.;

    %*count sort arguments and types;;
    %let i = 1;

    %do %while(%length(%scan(&SORT_VARS., &i.)) gt 0);

        %let _var&i. = %lowcase(%scan(&SORT_VARS., &i.));
        %let _typ&i. = %lowcase(%scan(&SORT_TYPE., &i.));
        %let _ord&i. = %lowcase(%scan(&SORT_ORDER., &i.));

        %let i = %eval(&i. + 1);

    %end;


    %*number of arguments;;
    %let _num = %eval(&i. - 1);

    %*determine last variable of by group;;
    %if &_sortBy. eq %str() %then %do;
        %let _lastBy = ;
    %end;
    %else %do;
        %let _lastBy = %scan(&_sortBy., -1);
    %end;

    %*assigned sort arguments and create missing value detectors;;
    %do i = 1 %to &_num.;

        %*macro variable to create missing value indicator;;
        %let _sortMissing = %str(&_sortMissing. if missing(&&_var&i..) then _missingAeSort_&&_var&i.. = 0;
                                           else if %str(&&_var&i..) ne "UNASSIGNED" then _missingAeSort_&&_var&i.. = 1;
                                           else if %str(&&_var&i..) eq "UNASSIGNED" then _missingAeSort_&&_var&i.. = 2;
                                );

        %let dsid  = %sysfunc(open(&SORT_DATAIN., i));
        %let check_exists_var = %sysfunc(varnum(&dsid., _freq_n_&&_var&i.._&_col.));
        %let dsidc = %sysFunc(close(&dsid.));
        %if &check_exists_var. eq 0 and &&_typ&i.. = freq %then %do;
        %gmMessage(codelocation=%str(bmsaesort.sas),
                   linesout=Variable _freq_n_&&_var&i.._&_col. does not exist in input dataset &SORT_DATAIN. Check that correct column is used for sorting.,
                   selectType=ABORT);
        %end;

        %*macro variable for sort by argument;;
        %if &&_typ&i.. eq freq %then %do;
            %if &&_ord&i.. eq asce %then %do;
                %let _clause = _missingAeSort_&&_var&i.. _freq_n_&&_var&i.._&_col. &&_var&i..;
            %end;
            %else %if &&_ord&i.. eq desc %then %do;
                %let _clause = _missingAeSort_&&_var&i.. descending _freq_n_&&_var&i.._&_col. &&_var&i..;
            %end;
        %end;
        %else %if &&_typ&i.. eq alph %then %do;
            %if &&_ord&i.. eq asce %then %do;
                %let _clause = _missingAeSort_&&_var&i.. &&_var&i..;
            %end;
            %else %if &&_ord&i.. eq desc %then %do;
                %let _clause = _missingAeSort_&&_var&i.. descending &&_var&i..;
            %end;
        %end;

        %*result is here after last iteration;;
        %let _sortArgument = &_sortArgument. &_clause.;

        %*macro variable for grpxsort variables;;
        %if &i. eq 1 %then %do;
            %if &_lastBy. eq  %then %do;
                %let _clause = %str(if _N_ eq 1 then do; grpxSort1 = 0; end;);
            %end;
            %else %if &_lastBy. ne %then %do;
                %let _clause = %str(if first.&_lastBy. then do; grpxSort1 = 0; end;);
            %end;

            %let _sortGrpx = &_sortGrpx. &_clause.;
        %end;

        %if &i. ne &_num. %then %do;
            %let j = %eval(&i. + 1);
            %let _clause = %str(if first.&&_var&i.. then do; grpxSort&i. = grpxSort&i. + 1; grpxSort&j. = 0; end;);
        %end;
        %else %if &i. eq &_num. %then %do;
            %let _clause = %str(if first.&&_var&i.. then do; grpxSort&i. = grpxSort&i. + 1; end;);
        %end;

        %*result is here after last iteration;;
        %let _sortGrpx = &_sortGrpx. &_clause.;

    %end;

    %*create missing value indicators;;
    data _bmsAeSortMissing;
        set &SORT_DATAIN;
        &_sortMissing.;
    run;

    %*applied the sorting as requested;;
    proc sort data = _bmsAeSortMissing
               out = _bmsAeSortSorted;
        by &_sortBy. &_sortArgument.;
    run;

    %*create grpxSort variables and write the output dataset;;

    data &SORT_DATAOUT;

        length
            %do i = 1 %to &_num.;
                grpxSort&i.
            %end;
            8.;

        retain
            %do i = 1 %to &_num.;
                grpxSort&i.
            %end;
            ;

        set _bmsAeSortSorted;
        by &_sortBy. &_sortArgument.;
        &_sortGrpx.;
    run;

    %*delete temporary datasets;;

    proc datasets nolist lib = work
                     memtype = data;
                     delete _bmsAeSort:;
    run;
    quit;


    %gmEnd(headURL  = $    $);


%mend bmsaesort;
