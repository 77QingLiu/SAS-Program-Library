/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        80386

  SAS Version:           9.1 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Allen Zeng $LastChangedBy: $
  Creation Date:         25Jun2015 / $LastChangedDate: $

  Program Location/Name: $HeadURL: $

  Files Created:         HeaderChg.log

  Program Purpose:       The macro is used to change the header box.

  Macro Parameters:

    Name:                spath
      Allowed Values:
      Default Value:
      Description:       Path of status.

    Name:                status
      Allowed Values:
      Default Value:
      Description:       Name of Status.

    Name:                cpath
      Allowed Values:
      Default Value:
      Description:       Path of code.

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: $
-----------------------------------------------------------------------------*/

%macro HeaderChg(spath   = 
                , status = 
                , cpath  =
                );
/* Check if the inputs are valid */
%if "%superQ(spath)"="" %then %do;
    %gmMessage(codeLocation = HeaderChg
                , linesOut   = Path of status(spath) can not be missing
                , selectType = ABORT
                );
%end;

%if "%superQ(status)"="" %then %do;
    %gmMessage(codeLocation = HeaderChg
                , linesOut   = Name of Status(status) can not be missing
                , selectType = ABORT
                );
%end;

%if "%superQ(cpath)"="" %then %do;
    %gmMessage(codeLocation = HeaderChg
                , linesOut   = Path of code(cpath) can not be missing
                , selectType = ABORT
                );
%end;

%if not %sysfunc(fileexist(&spath)) %then %do;
    %gmMessage(codeLocation = HeaderChg
             , linesOut      = Directory(&spath) does not exist
             , selectType    = ABORT
             );
%end;
 
%if not %sysfunc(fileexist(&cpath)) %then %do;
    %gmMessage(codeLocation = HeaderChg
             , linesOut      = Directory(&cpath) does not exist
             , selectType    = ABORT
             );
%end;

/* Remove repeating slashes and symbolic link path*/
%let spath=&spath./;
%let cpath=&cpath./;

data _null_;
    SPATH="&spath";
    SPATH=prxchange("s/\/{2,}/\//", -1, SPATH);
    SPATH=prxchange("s/^(\/project\d+\/)/\/projects\//", -1, cats(SPATH));
    call symputx("spath", SPATH);
    CPATH="&cpath";
    CPATH=prxchange("s/\/{2,}/\//", -1, CPATH);
    CPATH=prxchange("s/^(\/project\d+\/)/\/projects\//", -1, cats(CPATH));
    call symputx("cpath", CPATH);
run;

/*Loop for each program*/
%macro loop(file   =
           , author =
           );
data _null_;
    infile  "&cpath.&file" truncover;
    file "&cpath.&file..new" ;
    input;
    if _N_ < 30 then do
        _INFILE_=prxchange("s/(.*Protocol No:.*\/\s).*/\1&protocol/", -1, _INFILE_);
        _INFILE_=prxchange("s/(.*Study Code:\s*)\s\w*/\1 &time/", -1, _INFILE_);
        _INFILE_=prxchange("s/(\s*Author:\s*)\w*\s*\w*(\s\$LastChangedBy:.*)/\1&author\2/", -1, _INFILE_);
        _INFILE_=prxchange("s/(\s*Creation.*\s*)\s.*(\s\/\s\$LastChangedDate:.*)/\1 &date\2/", -1, _INFILE_);
    end;
    put _INFILE_ ;
run;

/*Rename*/
x "mv &cpath.&file..new &cpath.&file";
%mend loop;

/*Status*/
proc import datafile="&spath.&status"
    out=status dbms=xlsx replace;
    getnames=no;
    range="Status$A1:L2000";
    guessingrows=32767;
run;

/*Remove non-printable character*/
data status;
    set status;
    array vlst{*} _character_;
    do NUM=1 to dim(vlst);
        vlst(NUM)=compbl(prxchange('s/\n|\r/ /', -1, vlst(NUM)));
        vlst(NUM)=compress(vlst(NUM), , 'kw');
    end;
    drop NUM;
run;

/*Protocol, time code*/
data _null_;
    set status;
    if _N_=1 then do;
        call symputx("protocol", B);
        call symputx("time", E);
    end;
run;

/*Split program name*/
data status;
    set status;
    if prxmatch('/\.sas$/', cats(F));
    length JJ $200;
    NUM=1;
    do while(scan(J, NUM, '/') ne "");
        JJ=cats(scan(J, NUM, '/'));
        NUM+1;
        output;
    end;
run;

/*PXLWAR*/
data _null_;
    call symput("PXLERR", "ERR"||"OR:[PXL]");
run;

/*Program name and author*/
data status;
    set status;
    if ^ prxmatch('/^\w+\.sas$/', cats(JJ)) then put "&PXLERR QC program name: " JJ "is not correct";
    CODE=cats(JJ);
    AUTHOR=cats(L);
run;

/*Creation date*/
%let date=%qsysfunc(date(), date9.);

/*Evoke macro*/
data _null_;
    set status;
    call execute('%nrstr(%loop(file='||cats(CODE)||', author='||cats(AUTHOR)||'))');
run;
%mend HeaderChg;

%HeaderChg(spath   = /projects/janss227857/stats/transfer/data/rawspec/
          , status = Status.xlsx
          , cpath  = /project23/janss227857/stats/transfer/qcprog/transfer/test
          );
/*EOP*/