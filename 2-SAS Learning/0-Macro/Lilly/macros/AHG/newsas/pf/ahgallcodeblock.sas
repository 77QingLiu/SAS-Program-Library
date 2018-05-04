/* -------------------------------------------------------------------
                          PDS System Module
   -------------------------------------------------------------------
   $Source: /home/liu04/macros/RCS/allcodeblock.sas,v $
   $Revision: 1.4 $
   $Name:  $
   $Author: liu04 $
   $Locker:  $
   $State: Exp $
   $Purpose    :

   $Assumptions:

   $Inputs     :

   $Outputs    :

   $Called by  :
   $Calls to   :

   $Usage notes:

   $System archet: UNIX

   -------------------------------------------------------------------
                          Modification History
   -------------------------------------------------------------------
   $Log: allcodeblock.sas,v $
   Revision 1.4  2010/07/29 08:34:49  liu04
   basename

   Revision 1.3  2010/07/29 08:29:37  liu04
   left macro func

   Revision 1.2  2010/07/29 08:09:16  liu04
   remove dir

   Revision 1.1  2010/07/29 07:30:53  liu04
   lowcase name

   Revision 1.1  2010/07/29 06:38:27  liu04
   draft version




 -------------------------------------------------------------------
*/

%macro AHGallcodeblock(dir);
%if %AHGwinorunix=WIN %then
    %do;
    %AHGpipe(%str(dir %AHGaddslash(&dir)*.sas /b) );
    %AHGpm(rcpipe);
    %local i j allfile;
    %let allfile=copy ;
    %do i =1 %to %AHGcount(&rcpipe);
        %local myfile&i;
        %AHGgettempfilename(myfile&i);

        %put &&myfile&i;
        %put %sysfunc(left(%upcase(%sysfunc(reverse(%qscan(&rcpipe,&i))))));
        %if %SUBSTR(%upcase(%sysfunc(reverse(%qscan(&rcpipe,&i,%str( ))))),1,4)=SAS. %then
        %do;
        %let j=%eval(&j+1);
        %AHGFilterCode(%AHGaddslash(&dir)%qscan(&rcpipe,&i,%str( )),putTo=&&myfile&i);
        %if &j=1 %then %let allfile =&allfile   &&myfile&i;
        %if &j>1 %then %let allfile =&allfile %str(+) &&myfile&i;
        %end;
    %end;

    %let allfile =&allfile %AHGaddslash(%AHGtempdir)&SYSMACRONAME..log ;
    %AHGpipe(%str(&allfile));

    %end;

%if %AHGwinorunix=UNIX %then
    %do;
    %AHGpipe(%str(cd %AHGaddslash(&dir); ls *.sas ));
    %AHGpm(rcpipe);
    %local i j allfile;
    %let allfile=cat  ;
    %do i =1 %to %AHGcount(&rcpipe);
        %local myfile&i;
        %AHGgettempfilename(myfile&i);

        %put &&myfile&i;
        %put %sysfunc(left(%upcase(%sysfunc(reverse(%qscan(&rcpipe,&i))))));
        %if %SUBSTR(%upcase(%sysfunc(reverse(%qscan(&rcpipe,&i,%str( ))))),1,4)=SAS. %then
        %do;
        %let j=%eval(&j+1);
        %AHGFilterCode(%AHGaddslash(&dir)%qscan(&rcpipe,&i,%str( )),putTo=&&myfile&i);
        %let allfile =&allfile   &&myfile&i;
        %end;
    %end;

    %let allfile =&allfile >%AHGaddslash(%AHGtempdir)&SYSMACRONAME..log ;
    %AHGpipe(%str(&allfile));
    %end;
%mend;


