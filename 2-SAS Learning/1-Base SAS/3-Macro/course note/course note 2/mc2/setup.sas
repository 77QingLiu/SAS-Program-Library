
/*++++++++++++++++++++++++++++++++++++++++++++*/
/* STUDENTS: DO NOT EXECUTE THIS PROGRAM! */
/*++++++++++++++++++++++++++++++++++++++++++++*/

/*++++++++++++++++++++++++++++++++++++++++++++*/
/* EXIT AND EXECUTE THE CRE8DATA.SAS PROGRAM */
/* TO SETUP YOUR COURSE DATA ENVIRONMENT     */ 
/*++++++++++++++++++++++++++++++++++++++++++++*/

/*++++++++++++++++++++++++++++++++++++++++++++*/
/* WARNING: DO NOT ALTER CODE BELOW THIS LINE */
/*++++++++++++++++++++++++++++++++++++++++++++*/


%macro setup(pgmname);
   %global path rawdata;
   %local fileref rc did didc;
   %let rc=%sysfunc(filename(fileref,&path));
   %let did=%sysfunc(dopen(&fileref));
   %if &did=0 %then 
      %do;
         %put ERROR:  The location you specified for PATH= is &path..;
         %put ERROR-  This location does not exist.;
         %put ERROR-  Please create this location first before attempting to create the data.;
         %return;
      %end;

data _null_;
%if &sysscp=WIN %then %do;
   file "&path\libname.sas" ;
%end;

%else %if %index(*HP*AI*SU*LI*,*%substr(&sysscp,1,2)*) %then
%do;
   file "&path/libname.sas";
%end;

%else %if %index(*OS*VM*,*%substr(&sysscp,1,2)*) %then
%do;
   file "&path..sascode(libname)";
%end;

put;
put "%nrstr(%let path=)&path;";
put;
put 'libname orion '  '"' "&path" '"' ';';
put;
%if &sysscp=WIN %then
%do;
   libname ORION "&path";
   %let rawdata=&path\;
   %include "&path\&pgmname..sas";
%end;
%else %if %index(*HP*AI*SU*LI*,*%substr(&sysscp,1,2)*) %then
%do;
   libname ORION "&path";
   %let rawdata=&path/;
   %include "&path/&pgmname..sas";
%end;
%else %if %index(*OS*VM*,*%substr(&sysscp,1,2)*) %then
%do;
   libname ORION "&path..sasdata" DISP=(NEW,CATLG,CATLG);
   %let rawdata=&path..rawdata; 
   %include "&path..sascode(&pgmname)";
%end;
run;
%mend setup;

%setup(m299d00)
