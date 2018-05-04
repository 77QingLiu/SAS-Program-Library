
%macro AHGkill(dsetlist = _all_ ,   /* list of the SAS datasets to be deleted from the     */
                                   /*   LIBKILL library - if want all datasets deleted    */
                                   /*   from the WORK library then leave the default      */
                                   /*   value for DSETLIST                                */
               libkill= work      /* set the name of the library in which files are to   */
                                   /*   be killed                                         */
               )
               ;

     /* determine if the parameter conditions have been satisfied                         */
     /*   (DSETLIST eq _ALL_ only if LIBKILL eq WORK)                                     */

     %let killerror = 0;

     %if %lowcase(&dsetlist) eq _all_ and %lowcase(&libkill) ne work %then %do;
          %put ERROR: DSETLIST parameter can only be _ALL_ if LIBKILL parameter is WORK (DSETLIST = &dsetlist LIBKILL = &libkill);
          %let killerror = 1;
     %end;

     %if &killerror eq 1 %then %goto killend;
     %if &dsetlist eq _all_ %then %do;

          proc datasets library=work kill memtype=data;

     %end;
     %else
     %if &dsetlist ne %then %do;

          proc datasets library=&libkill memtype=data;
               delete &dsetlist;

     %end;

     run;
     quit;

     %AHGkillend:

%mend  ;

