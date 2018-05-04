%macro AHGreportItem(rowN=1,datafile=);
  %local tempdsn;
  %AHGgettempname(tempdsn);
  proc import datafile="&datafile" out=&tempdsn dbms=excel;
  run;

  data _null_;
    set &tempdsn;
    LENGTH TEMPVAR $100;
    TEMPVAR=TRANWRD(TITLE,'#',"@@");
    SHORTN=&rown-(LENGTH(TRIM(TEMPVAR))-LENGTH(TRIM(TITLE)))-1;

    do i=1 to shortn;
     title=trim(title)||' ' ||'# ';
    end;
/*    else */
/*      do;*/
/*      if  substr(reverse(trim(title)),1,1)^='#' then title=trim(title);*/
/*      end;*/

    put 'define ' column $15. '/' grpdis $5. @;

    if order^='' then put ' order=' order $8. @;
    /*8+7=15*/
    else put '               '  @;

    if format^='' then put ' format=' format $10. @;
    /*10+8=18*/
    else put '                  '  @;

    put lcr $6.  @;
    put flow $4.  @;
    put ' width= ' width 2. @;
    if title^='' then put  ' "' title'"' @;
    else put ' '@;
    put ';';

  run;


%mend;
