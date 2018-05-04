/*-------------------------------------------------------------------------------------
PAREXEL INTERNATIONAL LTD

Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
PXL Study Code:        222354

SAS Version:           9.2 and above
Operating System:      UNIX
---------------------------------------------------------------------------------------

Author:                Allen Zeng $LastChangedBy: $
Creation Date:         22Jul2014 / $LastChangedDate: $

Program Location/name: $HeadURL: $

Files Created:         jjchksdtmvalid.log
                       PXLTimeCode_ SdtmValid _yyyymmdd.xml

Program Purpose:       To validate SDTM datasets and produce a XML report

Macro Parameters:      SLIB   = Library name of SDTM datasets
                                <default = transfer>

                       MLIB   = Library name of study metadata datasets
                                <default = meta>

                       STDV   = Flag for sponsor metadata version
                                JJ      = JJ standard
                                JANSSEN = JANSSEN standard
                                <default = JJ>

                       OUTDIR = Full path specifying location of the output file.
                                NB: Unix file and directory names are case sensitive.
                                <default = _tglobal>

                       OUTPUT = File name of the output
                                <default = SdtmValid>

--------------------------------------------------------------------------------------
MODIFICATION HISTORY:  Subversion $Rev: $
--------------------------------------------------------------------------------------

/*Cleaning WORK library*/
proc datasets nolist lib=work memtype=data kill;
run;

/*Prevent multi-threaded sorting and message to the SAS log about the maximum length for strings in quotation marks*/
options NOTHREADS NOQUOTELENMAX;

%macro jjchksdtmvalid( slib   = transfer
                      , mlib   = meta
                      , stdv   = JANSSEN
                      , outdir = _tglobal
                      , output = SdtmValid
                      );

/*Sponsor metadata version*/
%if &stdv=JJ %then %let vart=DECOD;
%else %let vart=CODEVAL;;

/******************************************************* Check030000 ******************************************************/
/*Variables attributes*/
/*SDTM datasets*/
proc sql;
    create table columns as
        select *
        from dictionary.columns
        where LIBNAME=upcase("&slib")
        ;
quit;

data sdata;
    length DATASET $8 TYPE $8;
    set columns;
    rename NAME=VARNAME LENGTH=LENGTH_;
    DATASET=MEMNAME;
    keep DATASET NAME TYPE LENGTH LABEL;
run;

/*Study metadata*/
data mdata;
    set &mlib..vardef;
    LENGTH=input(LNGTH, best.);
    if DATATYPE in ('text', 'datetime') then DATATYPE='char';
    else if DATATYPE in ('integer', 'float') then DATATYPE='num';
    if DATATYPE='num' and LENGTH > 8 then LENGTH=8;
    keep DATASET VARNAME DATATYPE LENGTH VARLABEL;
run;

proc compare base=sdata compare=mdata noprint;
run;

/*Check if two data sets contain the same variables, observations and values but do not care about labels, formats*/
%if &sysinfo > 64 %then %do;
    proc sort data=sdata;
        by DATASET VARNAME;
    run;

    proc sort data=mdata;
        by DATASET VARNAME;
    run;

    data varatt;
        merge sdata(in=a) mdata(in=b);
        by DATASET VARNAME;
        length CHECKID DOMAIN DETAILS $200;
        if a and not b then do;
            CHECKID='Check030000';
            DOMAIN=cats(DATASET);
            DETAILS="Variable "||cats(VARNAME)||" in SDTM dataset " ||cats(DATASET)||" but not in VARDEF";
            output;
        end;
        if b and not a then do;
            CHECKID='Check030000';
            DOMAIN=cats(DATASET);
            DETAILS="Variable "||cats(VARNAME)||" in VARDEF but not in SDTM dataset " ||cats(DATASET);
            output;
        end;
        if a and b then do;
            if TYPE^=DATATYPE or LENGTH^=LENGTH or LABEL^=VARLABEL then do;
                CHECKID='Check030000';
                DOMAIN=cats(DATASET);
                DETAILS="The attributes of variables in SDTM datasets is not consistent with the attributes of
 variables in VARDEF, the variable lsit is "||cats(VARNAME);
            end;
            output;
        end;
        keep CHECKID DOMAIN DETAILS;
    run;
%end;
%else %do;
    data varatt;
        length CHECKID DOMAIN DETAILS $200;
        call missing(CHECKID, DOMAIN, DETAILS);
    run;
%end;

/*Format*/
proc format;
    value $chk "Check030000"   = "Check for if the variable or variable attributes in SDTM datasets is consistent with the attributes of variables in metadata VARDEF."
               "Check030010"   = "Check for each codelist related variable, that the value is found in the study-specific codelist attached to that variable."
               "Check030026"   = "Check for each value level metadata related variable, that the value is found in the value level metadata attached to that variable."
               "Check030026_2" = "Check for each value level metadata related variable, that the value is found in the study-specific codelist attached to that variable."
    ;
run;

data comb;
    set varatt;
    if not missing(CHECKID);
    length DESCR $200;
    DESCR=put(CHECKID, $chk.);
    keep CHECKID DESCR DOMAIN DETAILS;
    proc sort nodupkey;
        by _ALL_;
    label CHECKID = 'CheckID'
          DESCR   = 'Check Description'
          DOMAIN  = 'Dataset Name'
          DETAILS = 'Message'
          ;
run;

data Check030000;
    retain CHECKID DESCR DOMAIN DETAILS;
    set comb;
run;

/**************************************** Check030010 ****************************************/
%macro codelst();
/*Code list has code value*/
data cd;
    set &mlib..cd(where=(not missing(&vart) and CODELST ^ in ('WHODRUG', 'MedDRA')));
    proc sort;
    by CODELST;
run;

data cd1;
    set cd;
    length CODEVAL_ $32767;
    retain CODEVAL_;
    by CODELST;
    if first.CODELST then CODEVAL_=&vart;
    else CODEVAL_=catx(',', CODEVAL_, &vart);
    if last.CODELST;
    keep CODELST CODEVAL_;
run;

/*Code value is mssing*/

%let mcodelst=;

proc sql;
    select distinct CODELST into :mcodelst separated by '","'
    from &mlib..cd(where=(missing(&vart)));
quit;

data cdcom;
    length CHECKID DOMAIN DETAILS $200;
    call missing(CHECKID, DOMAIN, DETAILS);
run;

%macro codedomloop(indsn=);

/*Variable has code list*/
proc sql;
    create table int1 as
        select distinct VARNAME, CODELST
        from &mlib..vardef(where=(CODELST not in ("","&mcodelst") and DATASET="&indsn"))
        order by VARNAME;
quit;

/*Merge to make variable with code value*/
data int2;
    if _n_=1 then do;
        if 0 then set cd1;
        dcl hash h(dataset:'cd1');
        h.definekey('CODELST');
        h.definedata(all:'Y');
        h.definedone();
    end;
    set int1;
    if h.find() eq 0 then output;
run;

/*Check*/
data _null_;
    set int2;
    call execute('data out; set &slib..&indsn; VARNAME='||quote(cats(VARNAME))||';
                 codeval_='||quote(cats(CODEVAL_))||'; codelst='||quote(cats(CODELST))||
                 '; proc sort nodupkey; by '||cats(VARNAME)||'; run;');

    call execute('data temp_cd01; length CHECKID DOMAIN DETAILS $200 pattern $32767.; set out;
                 VAR=prxchange(''s/(\/|\.|\(|\)|\.|\*|\?|\+)/\\$1/'', -1, '||cats(VARNAME)||');
                 PATTERN=''/(,''||cats(VAR)||'',)|^(''||cats(VAR)||'',)|(,''||cats(VAR)||'')$|^(''||cats(VAR)||'')$/'';
                 RE=prxparse(PATTERN); if ^prxmatch(re, cats(CODEVAL_)) and not missing('||cats(VARNAME)||') then do;
                 DOMAIN="&indsn";
                 DETAILS="The value "'||'||cats(compress(var,''\''))||'||
                 '" cannot be found in the codelist '||cats(codelst)||' attached to the variable '||cats(VARNAME)||'.";'||
                 'CHECKID="Check030010"; keep DOMAIN DETAILS CHECKID; output; end; run;');

    call execute('data temp_cd02; set cdcom temp_cd01; run;');
    call execute('data cdcom; set temp_cd02; run;');

    /*
    call execute('data out1; set out end=eof; by '||cats(varname)||';
                  length codeval__ $2000;
                  retain codeval__;
                  if substr('||quote(cats(varname))||',1,2)="&indsn" then do;
                  if first.'||cats(varname)||' then codeval__= '||cats(varname)||';
                  else codeval__=catx(",",codeval__,'||cats(varname)||');
                  if eof; end;
                  varname='||quote(cats(varname))||';
                  codeval_='||quote(cats(codeval_))||'; codelst='||quote(cats(codelst))||
                  '; proc sort nodupkey; by '||cats(varname)||'; run;');

    call execute('data cdcom&indsn.out'||cats(_n_)||'_; length checkid domain details $2000; set out1;
                  flag=compress(codeval_,codeval__);
                  if flag^="" and substr('||quote(cats(varname))||',1,2)="&indsn" then do;
                  domain="&indsn"; var='||cats(varname)||';
                  details="The value "'||'||cats(flag)||'||
                  '" in the codelist '||cats(codelst)||' is not attached to the variable '||cats(varname)||'.";'||
                  'checkid="Check030010"; keep domain details checkid; output; end; run;');
    */

run;

%mend codedomloop;

/*Invoke macro*/
data _null_;
    set &mlib..datadef;
    call execute('%nrstr(%codedomloop(indsn='||cats(DATASET)||'))');
run;

%mend codelst;

%codelst

/**************************************** Check030026 ****************************************/
%macro valdef();
/*Value definition*/
data valdef;
    set &mlib..valdef;
    proc sort;
    by VALUEOID;
run;

data valdef1;
    set valdef;
    length VALVAL_ $32767;
    retain VALVAL_;
    by VALUEOID;
    if first.VALUEOID then VALVAL_=VALVAL;
    else VALVAL_=catx(',', VALVAL_, VALVAL);
    if last.VALUEOID;
    DOMAIN=prxchange('s/(.+?)\.(.+)/\1/', -1, VALUEOID);
    VARNAME=prxchange('s/(.+)\.(\w+)/\2/', -1, VALUEOID);
    VLEVEL=countw(VALUEOID, '.');
    keep VALUEOID VALVAL_ DOMAIN VARNAME VLEVEL;
run;

/*Split multi-level VALUEOID to generate sas statement for checking*/
proc sql noprint;
    select max(VLEVEL)-2 into :vlnum from valdef1;
quit;

%let vlnum=&vlnum;

data valdef2;
    set valdef1;
    VALUEOID=prxchange('s/(\.)(\w{2})(CAT|SPEC|METHOD|TESTCD|QNAM|DSDECOD)/~\2\3/i', -1, VALUEOID);
    VALUEOID=prxchange('s/(\w{2})(CAT|SPEC|METHOD|TESTCD|QNAM|DSDECOD)(\.)/\1\2~/i', -1, VALUEOID);
    length VARCOM $32767;
    do i=2 to &vlnum by 2;
        if scan(VALUEOID, i, '~') ne '' and scan(VALUEOID, i+1, '~') ne '' then do;
            VARC=catx('=', scan(VALUEOID, i, '~'), quote(scan(VALUEOID, i+1, '~')));
            VARCOM=catx(' and ', VARCOM, VARC);
        end;
    end;
    keep DOMAIN VARNAME VALVAL_ VARCOM;
run;

proc sql noprint;
    select distinct DOMAIN into :domainlst separated by '","'
        from valdef1;
quit;

data vacom;
    length CHECKID DOMAIN DETAILS $200;
    call missing(CHECKID, DOMAIN, DETAILS);
run;

%macro valdomloop(indsn=);

/*Variable has value definition*/
proc sql;
    create table int1 as
        select distinct VARNAME, VALVAL_, VARCOM
        from valdef2(where=(DOMAIN="&indsn"))
        order by VARNAME;
quit;

data &indsn;
    length LBCAT $200 LBSPEC $100 LBMETHOD $200;
    set &slib..&indsn;
    if LBCAT='' then LBCAT='(NO VALUE RECORDED)';
    if LBSPEC='' then LBSPEC='(NO VALUE RECORDED)';
    if LBMETHOD='' then LBMETHOD='(NO VALUE RECORDED)';
run;

/*Check*/
data _null_;
    set int1;
    if missing(VARCOM) then do;
        call execute('data out; set &indsn; VARNAME='||quote(cats(VARNAME))||'; VALVAL_='||quote(cats(VALVAL_))||'; 
                      proc sort nodupkey; by '||cats(VARNAME)||'; run;');

        call execute('data temp_va01; length CHECKID DOMAIN DETAILS $200 PATTERN $32767;
                     set out; VAR=prxchange(''s/(\/|\.|\(|\)|\.|\*|\?|\+)/\\$1/'', -1, '||cats(VARNAME)||');
                     PATTERN=''/(,''||cats(VAR)||'',)|^(''||cats(VAR)||'',)|(,''||cats(VAR)||'')$|^(''||cats(VAR)||'')$/'';
                     RE=prxparse(PATTERN); if ^prxmatch(RE, cats(VALVAL_)) and not missing('||cats(VARNAME)||') then do;
                     DOMAIN="&indsn";
                     DETAILS="The value "'||'||cats(compress(VAR, ''\''))||'||
                     '" cannot be found in the value level metadata '||
                     'attached to the variable '||cats(VARNAME)||'.";'||
                     'CHECKID="Check030026"; keep DOMAIN DETAILS CHECKID; output; end; run;');
    end;
    else do;
        call execute('data out; set &indsn; length CONDITION $200; if '||cats(VARCOM)||'; CONDITION= '||quote(cats(VARCOM))||'; 
                      VARNAME='||quote(cats(VARNAME))||'; VALVAL_='||quote(cats(VALVAL_))||'; 
                      proc sort nodupkey; by '||cats(VARNAME)||'; run;');

        call execute('data temp_va01; length CHECKID DOMAIN DETAILS $200 PATTERN $32767.;
                     set out; VAR=prxchange(''s/(\/|\.|\(|\)|\.|\*|\?|\+)/\\$1/'', -1, '||cats(VARNAME)||');
                     PATTERN=''/(,''||cats(VAR)||'',)|^(''||cats(VAR)||'',)|(,''||cats(VAR)||'')$|^(''||cats(var)||'')$/'';
                     RE=prxparse(PATTERN); if ^prxmatch(RE, cats(VALVAL_)) and '||cats(VARCOM)||' and not missing('||cats(VARNAME)||') then do;
                     DOMAIN="&indsn";
                     DETAILS="The value "'||'||cats(compress(VAR, ''\''))||'||
                     '" cannot be found in the value level metadata '||
                     'attached to the variable '||cats(VARNAME)||'.";'||
                     'CHECKID="Check030026"; keep DOMAIN DETAILS CHECKID CONDITION; output; end; run;');
    end;

    call execute('data temp_va02; set vacom temp_va01; run;');
    call execute('data vacom; set temp_va02; run;');
run;
%mend valdomloop;

/*Invoke macro*/
data _null_;
    set &mlib..datadef(where=(cats(DATASET) in ("&domainlst")));
    call execute('%nrstr(%valdomloop(indsn='||cats(DATASET)||'))');
run;

%mend valdef;

%valdef

/**************************************** --ORRES QVAL ****************************************/
data cd;
    set &mlib..cd(where=(not missing(CODEVAL)));
    proc sort;
    by CODELST;
run;

data cd1;
    set cd;
    length CODEVAL_ $32767;
    retain CODEVAL_;
    by CODELST;
    if first.CODELST then CODEVAL_=&vart;
    else CODEVAL_=catx(',', CODEVAL_, &vart);
    if last.CODELST;
    keep CODELST CODEVAL_;
run;

/*Value has code list*/
data valchk1;
    set &mlib..valdef(where=(^ missing(CODELST) and CODELST ^ in ('WHODRUG', 'MedDRA')));
    length cond $32767;
    DOMAIN=prxchange('s/(.+?)\.(.+)/\1/', -1, VALUEOID);
    VARNAME1=prxchange('s/(.+)\.(\w+)/\2/', -1, VALUEOID);
    if prxmatch('/(testcd)$/i', cats(VALUEOID)) then VARNAME2=cats(DOMAIN, 'ORRES');
    else if prxmatch('/(qnam)$/i', cats(VALUEOID)) then VARNAME2='QVAL';
    else if prxmatch('/(parmcd)$/i', cats(VALUEOID)) then VARNAME2=cats(DOMAIN, 'VAL');
    else if  prxmatch('/(cat)$/i', cats(VALUEOID)) then VARNAME2=cats(DOMAIN, 'CAT');
    COND=cats(VARNAME1, '=', quote(cats(VALVAL)));
    VLEVEL=countw(VALUEOID, '.');
    keep VALUEOID DOMAIN VARNAME: COND CODELST VLEVEL;
run;

/*Split multi-level VALUEOID to generate sas statement for checking*/
proc sql noprint;
    select max(vlevel)-2 into :vlnum from valchk1;
quit;

%let vlnum=&vlnum;

data valchk2;
    set valchk1;
    VALUEOID=prxchange('s/(\.)(\w{2})(CAT|SPEC|METHOD|TESTCD|QNAM)/~\2\3/i', -1, VALUEOID);
    VALUEOID=prxchange('s/(\w{2})(CAT|SPEC|METHOD|TESTCD|QNAM)(\.)/\1\2~/i', -1, VALUEOID);
    length VARCOM COND $32767;
    do i=2 to &vlnum by 2;
        if scan(VALUEOID, i, '~') ne '' and scan(VALUEOID, i+1, '~') ne '' then do;
            VARC=catx('=',scan(VALUEOID, i, '~'),quote(scan(VALUEOID, i+1, '~')));
            VARCOM=catx(' and ', VARCOM, VARC);
        end;
    end;
    if DOMAIN in ('CC', 'DS', 'FT', 'IE', 'LB', 'QS') then COND=catx(' and ',VARCOM, COND);
    COND=prxchange('s/(\(NO VALUE RECORDED\))//', -1, COND);
    keep VALUEOID DOMAIN VARNAME: COND CODELST;
run;

proc sql noprint;
    select distinct domain into :domainlst separated by '","'
        from valchk1;
quit;

data cvcom;
    length CHECKID DOMAIN CONDITION DETAILS $200;
    call missing(CHECKID, DOMAIN, CONDITION, DETAILS);
run;

%macro valloop(indsn=);
proc sql;
    create table int1 as
        select distinct *
        from valchk2(where=(DOMAIN="&indsn"))
        order by VARNAME1;
quit;

/*Merge to make variable with code value*/
data int2;
    if _n_=1 then do;
        if 0 then set cd1;
        dcl hash h(dataset:'cd1');
        h.definekey('CODELST');
        h.definedata(all:'Y');
        h.definedone();
    end;
    set int1;
    if h.find() eq 0 then output;
run;

/*Check*/
data _null_;
    set int2;
    call execute('data out; set &slib..&indsn;  length CONDITION $200; if '||cats(COND)||'; VARNAME2='||quote(cats(VARNAME2))||';
                 CODEVAL_='||quote(cats(CODEVAL_))||'; CODELST='||quote(cats(CODELST))||'; CONDITION= '||quote(cats(COND))||';
                 proc sort nodupkey; by '||cats(VARNAME2)||'; run;');

    call execute('data temp_cv01; length CHECKID DOMAIN CONDITION DETAILS $200 PATTERN $32767; set out;
                 set out; VAR=prxchange(''s/(\/|\.|\(|\)|\.|\*|\?|\+)/\\$1/'', -1, '||cats(VARNAME2)||');
                 PATTERN=''/(,''||cats(VAR)||'',)|^(''||cats(VAR)||'',)|(,''||cats(VAR)||'')$|^(''||cats(VAR)||'')$/'';
                 RE=prxparse(PATTERN); if ^prxmatch(RE, cats(CODEVAL_)) and not missing('||cats(VARNAME2)||') then do;
                 DOMAIN="&indsn";
                 DETAILS="The value "'||'||cats(compress(VAR, ''\''))||'||
                 '" cannot be found in the codelist '||cats(CODELST)||' attached to the variable '||cats(VARNAME2)||'.";'||
                 'CHECKID="Check030026_2"; keep DOMAIN DETAILS CHECKID CONDITION; output; end; run;');

    call execute('data temp_cv02; set cvcom temp_cv01; run;');
    call execute('data cvcom; set temp_cv02; run;');
run;

%mend valloop;

/*Invoke macro*/
data _null_;
    set &mlib..datadef(where=(DATASET in ("&domainlst")));
    call execute('%nrstr(%valloop(indsn='||cats(DATASET)||'))');
run;

/*Create result dataset*/
%macro fin(ind=,outd=);
data &outd;
    set &ind.;
    length DESCR $200;
    DESCR=put(CHECKID, $chk.);
    if not missing(CHECKID);
    proc sort nodupkey;
        by _ALL_;
    label CHECKID = 'CheckID'
          DESCR   = 'Check Description'
          DOMAIN  = 'Dataset Name'
          DETAILS = 'Message'
    %if &ind^=cdcom %then CONDITION = 'Condition';
          ;
run;

data &outd;
    retain CHECKID DESCR DOMAIN %if &ind^=cdcom %then CONDITION; DETAILS;
    set &outd;
run;

/*Drop missing variable CONDITION*/
%if &ind=vacom %then %do;
    %let econd=1;

    data _null_;
        set &outd(where=(^missing(CONDITION)));
        if _n_=1 then call symputx('econd', 0);
    run;

    data &outd;
        set &outd;
        %if &econd=1 %then drop CONDITION;;
    run;
%end;
%mend fin;

%fin(ind=cdcom, outd=Check030010)
%fin(ind=vacom, outd=Check030026)
%fin(ind=cvcom, outd=Check030026_2)

/*Produce validation report*/
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

%let HEAD = %nrstr(&amp;L&amp;&quot;Arial&quot;&amp; &_project.(&_tims.)&amp;C&amp;&quot;Arial,Bold&quot; PAREXEL);
%let FOOT = %nrstr(&amp;R&amp;&quot;Arial&quot;&amp;9 Page &amp;P of &amp;N  &#13;Printed Date:&amp;D &#13;File: &amp;F) %lowcase(&sysdate9.);

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

%macro output(dsn=, sheet=);
/*Empty Check*/
%let e=1;

data _null_;
    set &dsn;
    if _n_=1 then call symputx('e', 0);
run;

%if &e=1 %then %do;
    data &dsn;
        length CHECKID $200;
        CHECKID="No finding";
        label CHECKID = 'CheckID';
    run;
%end;

ods tagsets.ExcelXP options(sheet_name="&sheet" absolute_column_width ="15, 50, 10, 50, 30");
title;
proc print data=&dsn label noobs;
    var _all_ / style(data)={tagattr='format:@'};
run;

%mend output;

%output(dsn=Check030000, sheet=Varattchk)
%output(dsn=Check030010, sheet=Codelstchk)
%output(dsn=Check030026, sheet=Valuelstchk)
%output(dsn=Check030026_2, sheet=Valuelstchk2)

ods tagsets.excelxp close;
ods listing;

/*Tidy environment*/
proc datasets nolist lib=work memtype=data kill;
quit;

%mend jjchksdtmvalid;

%jjchksdtmvalid;

/*EOP*/