
%macro AHGkill(dsns,
                dsetlist=_all_ ,   /* list of the SAS datasets to be deleted from the     */
                                   /*   LIBKILL library - if want all datasets deleted    */
                                   /*   from the WORK library then leave the default      */
                                   /*   value for DSETLIST                                */
               libkill= work      /* set the name of the library in which files are to   */
                                   /*   be killed                                         */
               )
               ;

     /* determine if the parameter conditions have been satisfied                         */
     /*   (DSETLIST eq _ALL_ only if LIBKILL eq WORK)                                     */


     %local killerror i;
     %if %AHGblank(&dsns) %then
           %do;

                proc datasets library=work kill memtype=data;

           %end;
     %else 
       %do i=1 %to %AHGcount(&dsns);
       %local dsn lib;
       %let dsn=%scan(&dsns,&i,%str( ));
       %if not %index(&dsn,.) %then %let dsn=work.&dsn;
       %let lib=%scan(&dsn,1);
       %let dsn=%scan(&dsn,2);
       proc datasets library=&lib memtype=data;
                     delete &dsn;
       run;
       quit;
       %end;

%mend  ;

