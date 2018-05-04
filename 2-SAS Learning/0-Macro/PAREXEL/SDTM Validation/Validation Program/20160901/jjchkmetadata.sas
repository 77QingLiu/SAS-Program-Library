/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        222354

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Allen Zeng $LastChangedBy: $
  Creation Date:         25Jun2015 / $LastChangedDate: $

  Program Location/name: $HeadURL: $

  Files Created:         jjchkmetadata.log
                         PXLTimeCode_MetadataCheck_yyyymmdd.xml

  Program Purpose:       To check Study Level Metadata Dataset

  Macro Parameters       MLIB   = Library name of study metadata datasets
                                  <default = meta>

                         STDV   = Flag for sponsor metadata version
                                  JJ      = JJ standard
                                  JANSSEN = JANSSEN standard
                                  <default = JANSSEN>

                         OUTDIR = Full path specifying location of the output file.
                                  NB: Unix file and directory names are case sensitive.
                                  <default = _tglobal>

                         OUTPUT = File name of the output
                                  <default = MetadataCheck>

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: $
-----------------------------------------------------------------------------*/

/*To disable threaded processing and mute WARNING: The quoted string has become more than 262 characters long*/
options NOTHREADS NOQUOTELENMAX;

%macro jjchkmetadata( mlib=meta
                     , stdv=JANSSEN
                     , outdir= _tglobal
                     , output= MetadataCheck
                    );

/*Get dataset label*/
proc sql;
    create table tables as
        select *
        from dictionary.tables
        where LIBNAME=upcase("&mlib")
        ;
quit;

data _null_;
    set tables;
    call symputx(lowcase(memname), lowcase(memlabel));
run;

*******************************************************************************************;
**************************************DatasetChk*******************************************

*Check issues below:
    1. To check if the order of dataset in DATADEF is sorted by CLASSNM, DATASET

*******************************************************************************************;

proc format;
    invalue ord "Trial Design"    = 1
                "Special-Purpose" = 2
                "Special Purpose" = 2
                "Interventions"   = 3
                "Events"          = 4
                "Findings"        = 5
                "Findings About"  = 6
                "Relationship"    = 7
                "Operational"     = 8
                ;
run;

data datadef;
    set &mlib..datadef;
    if DATASET in ("TA", "TE", "TI", "TV", "TS") then CLASSNM="Trial Design";
    else if DATASET in ("CO", "DM", "SE", "SV") then CLASSNM=%if &stdv=JANSSEN %then "Special Purpose"; %else "Special-Purpose";;
    else if DATASET in ("CM", "EX", "SU") then CLASSNM="Interventions";
    else if DATASET in ("AE", "CE", "DS", "DV", "MH") then CLASSNM="Events";
    else if DATASET in ("EG", "IE", "LB", "PE", "QS", "SC", "VS", "DA", "MB", "MS", "PC", "PP", "FA") then CLASSNM="Findings";
    *else if DATASET in ("FA") then CLASSNM="Findings About";
    else if prxmatch('/(SUPP)/', DATASET) then CLASSNM="Relationship";
    ORD=input(CLASSNM, ord.);
    proc sort;
    by ORD DATASET;
run;

proc compare base=datadef(drop=ORD) compare=&mlib..datadef noprint;
run;

/*Check if two data sets contain the same variables, observations and values but do not care about labels, formats*/
%if &sysinfo > 64 %then %do;
data dachk1;
    length ISSUE $200;
    ISSUE="Note: The order of &datadef should be sorted by CLASSNM, DATASET, please check sheet Define_DATADEF if the order is correct";
run;
%end;
%else %do;
    data dachk1;
        length ISSUE $200;
        ISSUE='';
    run;
%end;
/*
data dachk2;
    set &mlib..datadef;
    length ISSUE $200;
    if DATASET in ("TA", "TE", "TI", "TV", "TS") and CLASSNM ^in ("Trial Design") then
       ISSUE="The class of dataset "||cats(DATASET)||" is not correct";
    else if DATASET in ("CO", "DM", "SE", "SV") and CLASSNM ^in ("Special Purpose", "Special-Purpose") then
       ISSUE="The class of dataset "||cats(DATASET)||" is not correct";
    else if DATASET in ("CM", "EX", "SU") and CLASSNM ^in ("Interventions") then
       ISSUE="The class of dataset "||cats(DATASET)||" is not correct";
    else if DATASET in ("AE", "CE", "DS", "DV", "MH") and CLASSNM ^in ("Events") then
       ISSUE="The class of dataset "||cats(DATASET)||" is not correct";
    else if DATASET in ("EG", "IE", "LB", "PE", "QS", "SC", "VS", "DA", "MB", "MS", "PC", "PP", "FA") and CLASSNM ^in ("Findings") then
       ISSUE="The class of dataset "||cats(DATASET)||" is not correct";
    *else if DATASET in ("FA") and CLASSNM ^in ("Findings About") then
       ISSUE="The class of dataset "||cats(DATASET)||" is not correct";
    else if prxmatch('/(SUPP)/', DATASET) and CLASSNM ^in ("Relationship") then
       ISSUE="The class of dataset "||cats(DATASET)||" is not correct";
    if ^missing(ISSUE);
    keep ISSUE;
run;

/*DSORDER*
data _null_;
    set datadef;
    call symputx(DATASET, put(_n_, z3.));
run;

data dachk3;
    set &mlib..datadef;
    length ISSUE $200;
    %if &stdv=JANSSEN %then DSORDER=put(_n_, z3.);;
    DSORDER_C=resolve('&'||DATASET);
    if DSORDER^=DSORDER_C then
        ISSUE="The order attached to the dataset "||cats(DATASET)||" is not correct, should be "||cats(DSORDER_C);
    if ^missing(ISSUE);
    keep ISSUE;
run;
*/
data dachk;
    set dachk1; /* - dachk3;*/
    if ^missing(ISSUE);
run;

*******************************************************************************************;
**************************************CodelistChk******************************************

*Check issues below:
    1. To check if there is no duplicate DECOD
    1. To check if there is no duplicate CODEVAL
    2. To check if variable REFERENC is not missing(for JJ standard)
    3. To check if variables CODEVAL and DECOD is not missing except MedDRA and WHODRUG
    4. To check if variables DICTNRY and VERSION of MedDRA and WHODRUG is not missing
    5. To check if variables CODEVAL and DECOD of MedDRA and WHODRUG is missing

*******************************************************************************************;

proc sql;
    create table dupchk as
        select CODELST, case when sum(^missing(_CODEVAL_)) >1 then "There are duplicate CODEVAL attached to the code list "||cats(CODELST)
                             else ''
                        end as ISSUE length=200
                        from (select *, case when prxmatch('/MedDRA|WHODRUG/', CODELST) then CODELST
                                             else CODEVAL
                                        end as _CODEVAL_
                                 from &mlib..cd)                       
                        group by CODELST, DATATYPE, _CODEVAL_
        union 
        select CODELST, case when sum(^missing(DECOD)) >1 then "There are duplicate DECOD attached to the code list "||cats(CODELST)
                             else ''
                        end as ISSUE length=200
                        from &mlib..cd
                        group by CODELST, DATATYPE, DECOD
                        ;
quit;

data cdchk;
    set &mlib..cd;
    length ISSUE $200;
    /*
    if prxmatch('/(MedDRA|WHODRUG)/i',CODELST) and CODELST ^in ("MedDRA", "WHODRUG") then do;
        SSUE="CODELST MedDRA and WHODRUG are case sensitive";
        output;
    end; 
    */
    %if &stdv=JJ %then %do;
        if missing(REFERENC) then do;
            ISSUE="Variable REFERENC in &cd cannot be missing";
            output;
        end;
    %end;
    if not prxmatch('/(MedDRA|WHODRUG)/i',CODELST) and cmiss(CODEVAL, DECOD)^=0 then do;
        ISSUE="Variable CODEVAL and DECOD in code list is missing except MedDRA and WHODRUG";
        output;
    end;
    if prxmatch('/(MedDRA|WHODRUG)/i',CODELST) and cmiss(DICTNRY, VERSION)^=0 then do;
        ISSUE="Variable DICTNRY and VERSION of MedDRA and WHODRUG in code list is missing";
        output;
    end;
    if prxmatch('/(MedDRA|WHODRUG)/i',CODELST) and cmiss(CODEVAL, DECOD)^=2 then do;
        ISSUE="Variables CODEVAL and DECOD of MedDRA and WHODRUG in code list is not missing";
        output;
    end;
run;

data cdchk;
    set cdchk dupchk;
    if ^missing(ISSUE);
    keep ISSUE;
    proc sort nodupkey;
    by  _all_;
run;

*******************************************************************************************;
******************************ValuelistChk and VardefChk***********************************

*Check issues below:
    1. To check if the VALVAL in VALDEF is not missing
    2. To check if the ORIGIN is not missing
    3. To check if ORIGIN format is correct for multiple origin values. If there are multiple ORIGINS
       then the CRF should be in the end. For example: 'Assigned, CRF' not 'CRF, Assigned'
    4. To check if the CRFPAGE is not missing when ORIGIN contains CRF
    5. To check if the CRF page format is correct(the delimiter should be ", ")
    6. To check if the comment or computer method of derived variables is not missing
    7. To check if the comment or computer method of non-derived variables is missing
    8. To check if the value list of IECAT (JJ standard), CCCAT, DSCAT, FTCAT, QSCAT, 
       LBCAT, LBSPEC or LBMETHOD is correct
    9. To check if the DECDIG of float-point variable is not missing
    10. To check if the DECDIG of non-float-point variable is missing
    11.To check if the variable order is correct

*******************************************************************************************;

/*Variable order and crfpage format*/
%macro varcrf(i=, ind=, var=);
data chk&i;
    set &mlib..&ind;
    length ISSUE $200;
    %if &i=1 %then %do;
        length VAR_T $100;
        if missing(VALVAL) then do;
            ISSUE="The VALVAL in &&&ind is missing";
            output;
        end;
        if missing(ORIGIN) then do;
            ISSUE="The ORIGIN in &&&ind is missing";
            output;
        end;
        if prxmatch('/(CRF,)/i',ORIGIN) then do;
            ISSUE="The ORIGIN format: "||cats(ORIGIN)||" of "||cats(&var)||" is not correct, "
                   ||"should be "||prxchange('s/(.+?)?(CRF), (.+)?/\1\3, \2/', -1, cats(ORIGIN));
            output;
        end;
        if prxmatch('/(CRF)/i',ORIGIN) and CRFPAGE='' and ^ prxmatch('/NO VALUE RECORDED/', VALVAL) then do;
            ISSUE="The CRFPAGE of "||cats(&var)||" is missing when ORIGIN contains CRF";
            output;
        end;
        if ^missing(CRFPAGE) then do;
            if (prxmatch('/(,\d)/',CRFPAGE) or prxmatch('/(,)$/', cats(CRFPAGE))) then do;
                ISSUE="The CRF page format: "||cats(CRFPAGE)||" of "||cats(&var)||" is not correct";
                output;
            end;
            if prxmatch('/\D/', compress(CRFPAGE)) and ^ prxmatch('/^,+$/', compress(prxchange('s/\d//', -1, compress(CRFPAGE)))) then do;
                ISSUE="The CRF page format: "||cats(CRFPAGE)||" of "||cats(&var)||" is not correct";
                output;
            end;
        end;
        if prxmatch('/(Derived)/i',ORIGIN) and cmiss(COMMENTS, COMPMETH)=2 then do;
            ISSUE="The comment or computer method of "||cats(&var)||" can not be missing";
            output;
        end; 
        if not prxmatch('/(Derived)/i',ORIGIN) and cmiss(COMMENTS, COMPMETH)^=2 then do;
            ISSUE="The comment or computer method of "||cats(&var)||" should be missing";
            output;
        end;
        %if &stdv=JANSSEN %then %do;
            %let varl=CCCAT DSCAT FTCAT QSCAT LBCAT LBSPEC LBMETHOD;
            %do ii=1 %to 7;
                VAR_T="%scan(&varl, &ii)";
                if cats(prxchange('s/(.+)\.(\w+)/\2/', -1, VALUEOID))=VAR_T then do;
                    if missing(VALUELST) then ISSUE="The VALUELST of "||cats(&var)||" can not be missing";
                    else if VALUELST ^= catx(".", VALUEOID, VALVAL, %if &ii=2 %then 'DSDECOD'; 
                                                                    %else %if &ii<5 %then substr(VAR_T, 1, 2)||"TESTCD"; 
                                                                    %else %if &ii=5 %then 'LBSPEC'; 
                                                                    %else %if &ii=6 %then 'LBMETHOD'; 
                                                                    %else 'LBTESTCD';) then
                            ISSUE="The VALUELST ("||cats(VALUELST)||") of VALUEOID ("||cats(&var)||") is not correct";
                    output;
                end;
            %end;
        %end;
        %else %do;
            %let varl=IECAT LBCAT QSCAT;
            %do jj=1 %to 3;
                VAR_T="%scan(&varl, &jj)";
                if cats(prxchange('s/(.+)\.(\w+)/\2/', -1, VALUEOID))=VAR_T then do;
                    if missing(VALUELST) then ISSUE="The VALUELST of "||cats(&var)||" can not be missing";
                    else if VALUELST ^= catx(".", VALUEOID, VALVAL, substr(VAR_T, 1, 2)||"TESTCD") then
                            ISSUE="The VALUELST of "||cats(&var)||" is not correct";
                    output;
                end;
            %end;
        %end;
        if prxmatch('/(float)/', DATATYPE) and missing(DECDIG) then do;
            ISSUE="The DECDIG of float point variable "||cats(&var)||" in "||cats(&var)||" is missing";
            output;
        end;
        if not prxmatch('/(float)/', DATATYPE) and ^missing(DECDIG) then do;
            ISSUE="The DECDIG of non-float point variable "||cats(&var)||" in "||cats(&var)||" is not missing";
            output;
        end;
    %end;
    %else %do;
        if missing(ORIGIN) then do;
            ISSUE="The ORIGIN attached to the variable "||cats(VARNAME)||" in &&&ind is be missing";
            output;
        end;
        if prxmatch('/(CRF,)/i',ORIGIN) then do;
            ISSUE="The ORIGIN format: "||cats(ORIGIN)||" of "||cats(VARNAME)||" is not correct, "
                   ||"should be "||prxchange('s/(.+?)?(CRF), (.+)?/\1\3, \2/', -1, cats(ORIGIN));
            output;
        end;
        if prxmatch('/(CRF)/i',ORIGIN) and CRFPAGE='' then do;
            ISSUE="The CRFPAGE attached to the variable "||cats(VARNAME)||" of "||cats(&var)||
                  " in &&&ind is missing when ORIGIN contains CRF";
            output;
        end;
        if ^missing(CRFPAGE) then do;
            if (prxmatch('/(,\d)/',CRFPAGE) or prxmatch('/(,)$/', cats(CRFPAGE))) then do;
                ISSUE="The CRF page format: "||cats(CRFPAGE)||" attached to the derived variable "
                    ||cats(VARNAME)||" of "||cats(&var)||" is not correct";
                output;
            end;
            if prxmatch('/\D/', compress(CRFPAGE)) and ^ prxmatch('/^,+$/', compress(prxchange('s/\d//', -1, compress(CRFPAGE)))) then do;
                ISSUE="The CRF page format: "||cats(CRFPAGE)||" attached to the derived variable "
                    ||cats(VARNAME)||" of "||cats(&var)||" is not correct";
                output;
            end;
        end;
        if prxmatch('/(Derived)/i',ORIGIN) and cmiss(COMMENTS, COMPMETH)=2 then do;
            ISSUE="The comment or computer method attached to the variable "||cats(VARNAME)||" of "||cats(&var)||" can not be missing";
            output;
        end;
        if not prxmatch('/(Derived)/i',ORIGIN) and cmiss(COMMENTS, COMPMETH)^=2 then do;
            ISSUE="The comment or computer method attached to the variable "||cats(VARNAME)||" of "||cats(&var)||" should be missing";
            output;
        end;
        if prxmatch('/(float)/', DATATYPE) and missing(DECDIG) then do;
            ISSUE="The DECDIG of float point variable "||cats(VARNAME)||" in "||cats(&var)||" is missing";
            output;
        end;
        if not prxmatch('/(float)/', DATATYPE) and ^missing(DECDIG) then do;
            ISSUE="The DECDIG of non-float point variable "||cats(VARNAME)||" in "||cats(&var)||" is not missing";
            output;
        end;
    %end;
    if ^missing(ISSUE);
    keep ISSUE;
run;

/*Variable order*/
proc sql;
    create table &ind._ as
        select &var, VARORDER, sum(&var^='') as VARNUM
        from &mlib..&ind
        group by &var
        order by &var, VARORDER
        ;
quit;

data chk%eval(&i+1);
    set &ind._;
    retain VAROR;
    length VAROR VAROR_ $500;
    by &var VARORDER;
    length ISSUE $200;
    if first.&var then VAROR=VARORDER;
    else VAROR=catx(',', VAROR, VARORDER);
    if last.&var;
    do i=1 to VARNUM;
        VAROR_=catx(',', VAROR_, put(i, z3.));
    end;
    if VAROR_^=VAROR then ISSUE="Variable order "||cats(VAROR)||" of &&&ind. "||cats(&var)||" is not correct";;
    if ^missing(ISSUE);
    keep ISSUE;
run;
%mend varcrf;

%varcrf(i=1, ind=valdef, var=VALUEOID)
%varcrf(i=3, ind=vardef, var=DATASET)

data valchk;
    set chk1 chk2;
    if ^missing(ISSUE);
    proc sort nodupkey;
    by _all_;
run;

/****************************************Check030270 ****************************************/
%macro vcodechk(chkid=);
data chkid_&chkid;
    length ISSUE $200;
    set &mlib..vardef;
    if prxmatch("/(DY|STDY|ENDY)$/", cats(VARNAME)) and VARNAME^='VISITDY';
    if COMPMETH='' then do;
        ISSUE="COMPUTATIONAL ALGORITHM attached to variable (--DY, --STDY or ¨CENDY) "||cats(VARNAME)||" is missing.";
        if ^missing(ISSUE);
        keep ISSUE;
        output;
    end;
run;
%mend vcodechk;

%vcodechk(chkid=270);

/**************************************** Checkid030714, Checkid030715 ****************************************/
%macro comm(chkid=, var=, time=);
data chkid_&chkid;
    set &mlib..vardef;
    if prxmatch("/(&var)$/",cats(VARNAME)) then do;
        if missing(COMMENTS) then do;
            length ISSUE $200;
            ISSUE="A comment that describes the &time of the protocol-specified reference period "||cats(VARNAME)|| " is missing.";
            if ^missing(ISSUE);
            keep ISSUE;
            output;
        end;
    end;
run;
%mend comm;

%comm(chkid=714, var=STTPT, time=start);
%comm(chkid=715, var=ENTPT, time=end);

data varchk;
    set chk3 chk4 chkid_:;
    if ^missing(ISSUE);
    proc sort nodupkey;
    by _all_;
run;

*******************************************************************************************;
*******************************************CrossChk****************************************

*Check issues below:
    1. To check if there is mismatch between CODELST in VARDEF and VALDEF and CODELST in
       CD
    2. To check if there is mismatch between VALUELST in VARDEF and VALDEF and VALUEOID in
       VALDEF
    3. To check if there is mismatch between COMPMETH in VARDEF and VALDEF and MTHNAM 
       in COMPMETH 
    4. To check if there is mismatch between ORIGIN in VARDEF and ORIGIN in VALDEF
    5, To check if there is mismatch between CRF page in VARDEF and CRF page in VALDEF
    5. To check if the logical key order in VARDEF is consistent with the keys in DATADEF
       (for JJ standard)

*******************************************************************************************;

%macro mdcchk(i=, meta=, var1=, var2=, str=, dsn1=, dsn2=);
proc sql;
    create table &meta.1 as
        select distinct &var1
        from &mlib..vardef(where=(not missing(&var1)))
        %if &i=1 %then union corr select distinct CODELST
        from &mlib..valdef(where=(not missing(CODELST)));
        %else %if &i=2 %then union corr select distinct VALUELST
        from &mlib..valdef(where=(not missing(VALUELST)));
        %else union corr select distinct COMPMETH
        from &mlib..valdef(where=(not missing(COMPMETH)));
        order by 1
        ;

    create table &meta.2 as
        select distinct %if &i^=1 %then &var2 as &var1; %else &var1;
        from &mlib..&meta
        order by 1;
        ;
quit;

data final&i(keep=ISSUE);
    merge &meta.1(in=a) &meta.2(in=b);
    by &var1;
    length ISSUE $200;
    if a and not b then do;
        ISSUE="&str "||cats(&var1)||" in &dsn1 (&var1) but not in &dsn2 (&var2)";;
        output;
    end;
    if b and not a then do;
        ISSUE="&str "||cats(&var1)||" in &dsn2 (&var2) but not in &dsn1 (&var1)";;
        output;
    end;
run;
%mend mdcchk;

%mdcchk(i=1, meta=cd, var1=CODELST, var2=CODELST, str=Code list, dsn1=VALDEF or VARDEF, dsn2=CD)
%mdcchk(i=2, meta=valdef, var1=VALUELST, var2=VALUEOID, str=Value list, dsn1=VALDEF or VARDEF, dsn2=VALDEF)
%mdcchk(i=3, meta=compmeth, var1=COMPMETH, var2=MTHNAM, str=Computational Algorithm Method, dsn1=VALDEF or VARDEF, dsn2=COMPMETH)

/*Check origin and crf page in VALDEF and VARDEF*/
data final4;
    if _n_=1 then do;
        if 0 then set &mlib..vardef;
        dcl hash h(dataset: "&mlib..vardef", multidata: "Y");
        h.definekey("DATASET", "VARNAME");
        h.definedata(all: "Y");
        h.definedone();
    end;
    set &mlib..valdef(rename=(ORIGIN=ORIGIN_ CRFPAGE=CRFPAGE_));
    length ISSUE $200;
    DATASET=prxchange('s/(.+?)\.(.+)/\1/', -1, VALUEOID);
    VARN=prxchange('s/(.+)\.(\w+)/\2/', -1, VALUEOID);
    if VARN="QNAM" then VARN="QVAL";
    if prxmatch('/(TESTCD)/', VARN) then VARN=cats(DATASET, "ORRES");
    if h.find(key: DATASET, key: VARN)=0 then do;
        i=1;
        do until(scan(ORIGIN_, i, ", ")="");
            if findw(compress(ORIGIN), compress(scan(ORIGIN_, i, ", ")))=0 then
               ISSUE="ORIGIN of "||catx(".", DATASET, VARNAME)||" (VARDEF) do not correspond with "||cats(VALUEOID)||" (VALDEF)";
            output;
            i+1;
        end;
        j=1;
        if prxmatch('/(CRF)/i',ORIGIN_) then do until(scan(CRFPAGE_, j, ", ")="");
            if findw(compress(CRFPAGE), compress(scan(CRFPAGE_, j, ", ")))=0 and ^ prxmatch('/NO VALUE RECORDED/', VALVAL) then
               ISSUE="Mismatch between eCRF pages in "||catx(".", DATASET, VARNAME)||" (VARDEF) and "||cats(VALUEOID)||" (VALDEF)";
            output;
            j+1;
        end;
    end;
    keep ISSUE;
run;

/*Logical key order*/
%if &stdv=JJ %then %do;
data datadef;
    set &mlib..datadef(keep=DATASET KEYS);
    i=1;
    do until(scan(KEYS,I)='');
        DO_KEYS=catx('_', DATASET, scan(KEYS,I));
        output;
        i+1;
    end;
run;

/*Create macro variable*/
data _null_;
    set datadef;
    call symputx(DO_KEYS, cats(I));
run;

proc sql noprint;
    select DO_KEYS into :keyvar separated by '","'
    from datadef
    ;
quit;

/*Check*/
data final5;
    set &mlib..vardef(keep=DATASET VARNAME VARKEY);
    length ISSUE $200;
    if catx('_', DATASET, VARNAME) in ("&keyvar");
    DO_KEYS=catx('_', DATASET, VARNAME);
    VARKEY_C=resolve('&'||DO_KEYS);
    if VARKEY^=VARKEY_C then
       ISSUE="The Logical key order attached to the variable "||cats(VARNAME)||" of "||cats(DATASET)||" is not correct";
    if ^missing(ISSUE);
    keep ISSUE;
run;
%end;

data crochk;
    set final1 - %if &stdv=JJ %then final5; %else final4;;
    if ^missing(ISSUE);
    *if prxmatch('/(VALUE LIST lb\.|VALUE LIST ie\.|VALUE LIST qs\.)/i',ISSUE) then delete;
    proc sort nodupkey;
    by _all_;
run;

/*Output*/
/*Template*/
ods path work(update) sashelp.tmplmst(read);

proc template;
    define style Styles.XLSansPrinter;
    parent = Styles.Default;

    style SystemTitle from SystemTitle /
        font_size  = 14pt
        just       = left
        foreground = black
        background = white;
    style SystemFooter from SystemFooter /
        font_size  = 10pt
        just       = left
        foreground = black
        background = white;

   style Body from Body /
        background = white;
    style Header from header /
        font_size  = 10pt
        just       = left
        foreground = black
        background = cxD3D3D3;
    style Data from Data /
        font_size  = 10pt
        background = white;
    style Table from Table /
        background = cxB0B0B0;
    end;
run;

%let head = %nrstr(&amp;L&amp;&quot;Arial&quot;&amp; &_project.(&_tims.)&amp;C&amp;&quot;Arial,Bold&quot; PAREXEL);
%let foot = %nrstr(&amp;R&amp;&quot;Arial&quot;&amp;9 Page &amp;P of &amp;N  &#13;Printed Date:&amp;D &#13;File: &amp;F) %lowcase(&sysdate9.);

ods listing close;
ods tagsets.excelxp file="&&&outdir..&_tims._&output._%sysfunc(date(),yymmddn8.).xml" style = XLsansPrinter
                    options(embedded_titles   = "yes"
                            embed_titles_once = "yes"
                            suppress_bylines  = 'yes'
                            sheet_interval    = 'bygroup'
                            sheet_label       = ' '
                            autofit_height    = 'yes'
                            orientation       = 'landscape'
                            row_repeat        = '1-3'
                            frozen_headers    = '1'
                            fittopage         = 'yes'
                            print_header      = "&HEAD"
                            print_footer      = "&FOOT"
                            autofilter        = "all"
                            );

%macro output(ind=, sheet=);
/*Empty Check*/
%let e=1;

data _null_;
    set &ind;
    if _n_=1 then call symputx('e',0);
run;

%if &e=1 %then %do;
    data &ind;
    length ISSUE $200;
    ISSUE="No finding";
run;
%end;

ods tagsets.excelxp options(sheet_name="&sheet" absolute_column_width ="100");
title;
proc print data=&ind label noobs;
    var _all_ /style(data)={tagattr='format:@'};
run;

%mend output;

%output(ind=dachk, sheet=DatasetChk)
%output(ind=cdchk, sheet=CodelistChk)
%output(ind=valchk, sheet=ValdefChk)
%output(ind=varchk, sheet=VardefChk)
%output(ind=crochk, sheet=CrossChk)

ods tagsets.excelxp close;
ods listing;

%mend jjchkmetadata;

%jjchkmetadata;

/*EOP*/
