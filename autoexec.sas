*------------------- Macros --------------------;
%let margin    = 0.5in;
%let frame     = hsides;
%let cellwidth = 1in;
%let wstyle    = pubstyle.Arial8;
%let txtwidth  = 99%;

%let path = D:\Qing\0-Macro\SAS-Program-Library;
*------------------- Titles and Footnotes --------------------;
title;
footnote;

*------------------- FileNames --------------------;

*------------------- LibNames --------------------;

*------------------- Options --------------------;
options  noCenter     /* flush left output */
         noDate       /* no date-stamp     */
         DtReset    /* date+time reset   */
         noNumber    /*  no page numbers   */
;
ods noproctitle;
options ls=max ps=100 nofmterr nosymbolgen nodate formdlim=' ' orientation=landscape nonumber;

* macros: autocall: *.sas;
options  MautoSource 
         SASautos = ("&path\Utility" "&path\Parameter Validation" "ODS" SASautos);

options                  /* %*miscellaneous; */
         details         /* %* Proc Contents           ; */
         FormChar =      /* %* no special chars        ; */
                         '-------------------'
         FormDlim = ' '  /* %* no CR/LF for page break ; */
         LineSize = max  /* %* no squeeze output       ; */
         MsgLevel = I    /* %* extra messages displayed; */
         PageSize = max  /* %* no page breaks in *.lst ; */
         ;

*format;
options  compress=yes fmtsearch=(work);

*ODSstyle;
ods path sasuser.pubstyle(update) sashelp.tmplmst(read);
ods escapechar = '~';