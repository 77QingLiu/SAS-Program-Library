/* -------------------------------------------------------------------
                          CDARS System Module
   -------------------------------------------------------------------
   $Source: /home/liu04/macros/RCS/qcdocen.sas,v $
   $Revision: 1.1 $
   $Author: liu04 $
   $Locker:  $
   $State: Exp $

   $Purpose:

   $Assumptions:

   $Inputs:
   $Outputs:

   $Called by: template.sasdrvr
   $Calls to:

   $Usage notes: Comment header items that end with a trailing '$'
                 are automatically populated by RCS.  The remaining
                 items must be maintained by the developer.

                 DESCRIPTION OF ITEMS

                 Source: The fullname and path of the RCS file.
                 Revision: The RCS version number this file is at.
                 Author: The username of the last person to modify
                         this file.
                 Locker: Which username has this revision reserved?
                 State: Possible future use.  devel, test or prod.

                 Purpose: What does this module do?
                 Assumptions: What needs to exist for this module
                              to fulfill its purpose?
                 Inputs: Data, lookup files, macros variables.
                 Outputs: Data, report, logs, listings.

                 Called by: Which SAS modules call this module?
                 Calls to: Which SAS modules does this module call?

                 Usage notes: Any hints on how to use this module.
                 System archet: Where will this module be used?
                 Log: Who did what when?

   $System archet: UNIX

   -------------------------------------------------------------------
                          Modification History
   -------------------------------------------------------------------
   $Log: qcdocen.sas,v $
   Revision 1.1  2010/08/02 07:45:43  liu04
   draft version


   -------------------------------------------------------------------
*/
%macro AHGqcdocen(filename,user=,users=&users,studyname=,qclib=QClib,folder=,version=,datetime=,status=0,Reason=,bugids=,rpt=rpt,duedate=)/secure;
    %put filename=&filename;

%if %lowcase(&version)=curr %then
    %if not %index(%upcase(&filename),.SAS) %then
        %DO;
        %AHGtabver(%lowcase(&filename),currver);;
        %let version=&currver;
        %END;
    %else 
        %do;
        %AHGfilever(%sysfunc(compress(&root3/&folder/&filename)));
        %let version=&rcrpipe;
        %end;


%if &bugids eq AND &status=1 %then
  %do;
  x 'ECHO PLEASE FILL IN BUGIDS';
  %goto backdoor;
  %end;


%local QCdocExist QCdocNotEmp ;
proc sql noprint;
  select nobs into :QCdocExist
  from  sashelp.vtable
  where libname=UPCASE("&QCLIB") and memname='QCDOC'
  ;
quit;
%local maxid;



%IF &QCDOCEXIST<=0 %then
  %do;
  data &qclib..QCdoc;
  run;
  %let maxid=1;
  %end;
%else
  %do;
  proc sql noprint;
    select max(maxid) into :maxid
    from  &qclib..qcdoc
    ;
  quit;

  %end;

%put maxid=&maxid;
data QCdoc(where=(filename^=''));
  length studyname  filename $30 version $10 datetime 8 status 8 reason $500 bugid $40 maxid 8;
  format datetime datetime20.;
  drop i;
  set &qclib..QCdoc end=end;
  /*set maxid for future use*/
  %if &status ne 1  %then  maxid=&maxid+max(1,%AHGcount(&bugids),%AHGcount(&filename));;

  output;
  if _n_=1 then
    do;
    studyname="&studyname";
    filename="&filename";
    version="&version";
    %if &status eq 9 %then  version="&duedate"; ;
    datetime=datetime();
    /*datetime=input("&datetime",datetime20.);*/
    status=&status;
    Reason="&reason";
    user=input(upcase("&user"),$20.);
    rpt=&rpt;

    %if &status eq 1  %then /*qc passed*/
      %do;
      /*multiple bugids for one filename*/
      do i=1 to %AHGcount(&bugids);
        bugid=scan("&bugids",i);
        output;
      end;
      %end;
    %else %if &status eq 0  %then /*add original task*/
      %do;
      i=0;
      /*multiple original tasks */
      do i=1 to %AHGcount(&filename,dlm=@);
        filename=scan("&filename",i,'@');
        bugid=trim(user)||put(&maxid+i,z5.);
        output;
      end;
      %end;

    %else %if &status eq 9 %then /*assignments */
      %do;
      /*multiple assignments*/
      do i=1 to %AHGcount(&bugids);
        bugid=scan("&bugids",i);
        output;
      end;
      %end;

    %else %if &status eq 2 or &status eq 3  %then /*bugs of numbers, bugs of words */
      %do;
      bugid=trim(user)||put(&maxid+1,z5.);
      output;

      %end;



    end;
run;



  data qcdoc;
    format dateframe 8. ;
    set qcdoc;
    filename=left(upcase(filename));

    fileid=scan(filename,1,'.-')||put(scan(filename,2,'.-')+0,z2.)||put(scan(filename,3,'.-')+0,z2.)||
            put(scan(filename,4,'.-')+0,z2.)||put(scan(filename,5,'.-')+0,z2.)||put(scan(filename,6,'.-')+0,z2.);
    sortid=put(scan(version,1,'.-')+0,z2.)||put(scan(version,2,'.-')+0,z2.)||put(scan(version,3,'.-')+0,z2.);
    if datetime<&dateframe1 then dateframe=0;
    if &dateframe1<=datetime<&dateframe2 then dateframe=1;
    if &dateframe2<=datetime<&dateframe3 then dateframe=2;
    if &dateframe3<=datetime<&dateframe4 then dateframe=3;
    if &dateframe4<=datetime<&dateframe5 then dateframe=4;
    if &dateframe5<=datetime<&dateframe6 then dateframe=5;
    if &dateframe6<=datetime<&dateframe7 then dateframe=6;
    bugid=upcase(bugid);
    if version='rlog' then version='';
  run;


  proc sort data=qcdoc;
    by dateframe fileid sortid datetime;
  run;

proc sql noprint;
  select nobs into :QCdocNotEmp
  from  sashelp.vtable
  where libname='WORK' and memname='QCDOC'
  ;
quit;

%IF &QCdocNotEmp>0 %then

  %do;
  proc sort data=QCdoc out=&qclib..QCdoc;
    by dateframe fileid sortid datetime;
    where filename^='';
  run;

  proc sort data=QCdoc out=&qclib..QCdoclast;
    by dateframe fileid sortid datetime;
    where filename^='';
  run;

  data &qclib..QCdoclast;
    set &qclib..QCdoclast;
    by dateframe fileid sortid datetime;
    if last.fileid;
  run;

  proc sort data=QCdoc out=&qclib..QCdoc%sysfunc(date(),date9.);
    by dateframe fileid sortid datetime;
    where filename^='';
  run;

  proc sort data=QCdoc out=network.QCdoc%sysfunc(date(),date9.);
    by dateframe fileid sortid datetime;
    where filename^='';
  run;

  proc sort data=QCdoc out=network.QCdoc;
    by dateframe fileid sortid datetime;
    where filename^='';
  run;

  %macro backupqc;
    %local i user;
    %do i=1 %to %AHGcount(&users);
      %let user=%scan(&users,&i);

      proc sort data=&user..qcdoc out=&qclib..QCdoc&user;
        by dateframe fileid sortid datetime;
        where filename^='';
      run;
    %end;

  %mend;

  %backupqc;




  %end;




/*
status=0 means it is initialized
status=1 means it is passed ;
status=2 means it is not passed

*/

%backdoor:
%mend;


