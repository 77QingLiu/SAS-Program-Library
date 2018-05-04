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
* macros: autocall: *.sas;
options  MautoSource 
         SASautos = ('D:\Qing\0-Macro\Own' SASautos);

options                  /* %*miscellaneous; */
         details         /* %* Proc Contents           ; */
         FormChar =      /* %* no special chars        ; */
                         '-------------------'
         FormDlim = ' '  /* %* no CR/LF for page break ; */
         LineSize = max  /* %* no squeeze output       ; */
         MsgLevel = I    /* %* extra messages displayed; */
         PageSize = max  /* %* no page breaks in *.lst ; */
         ;

*------------------- Macros --------------------;