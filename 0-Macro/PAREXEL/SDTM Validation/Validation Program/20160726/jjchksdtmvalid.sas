/*-------------------------------------------------------------------------------------
PAREXEL INTERNATIONAL LTD

Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
PXL Study Code:        222354

SAS Version:           9.2
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

/*Start programming*/
proc datasets nolist lib=work memtype=data kill;
quit;

options NOQUOTELENMAX;

%macro jjchksdtmvalid( slib=transfer
                      , mlib=meta
                      , stdv=JANSSEN
                      , outdir= _tglobal
                      , output= SdtmValid
                       );

/*Type*/
%if &stdv=JJ %then %let vart=DECOD;
%else %let vart=CODEVAL;;

/**************************************** Check030010 ****************************************/
%macro codelst();
/*Code list has code value*/
data cd;
    set &mlib..cd(where=(not missing(&vart) and codelst ^ in ('WHODRUG', 'MedDRA')));
    proc sort;
    by codelst;
run;

data cd1;
    set cd;
    length codeval_ $2000;
    retain codeval_;
    by codelst;
    if first.codelst then codeval_=&vart;
    else codeval_=catx(',',codeval_,&vart);
    if last.codelst;
    keep codelst codeval_;
run;

/*Code value is mssing*/

%let mcodelst=;

proc sql;
    select distinct codelst into :mcodelst separated by '","'
    from &mlib..cd(where=(missing(&vart)));
quit;

data cdcom;
    length checkid domain category details $200;
    call missing(checkid, domain, category, details);
run;

%macro codedomloop(indsn=);

/*Variable has code list*/
proc sql;
    create table int1 as
        select distinct varname,codelst
        from &mlib..vardef(where=(codelst not in ("","&mcodelst") and dataset="&indsn"))
        order by varname;
quit;

/*Merge to make variable with code value*/
data int2;
    if _n_=1 then do;
        if 0 then set cd1;
        dcl hash h(dataset:'cd1');
        h.definekey('codelst');
        h.definedata(all:'Y');
        h.definedone();
    end;
    set int1;
    if h.find() eq 0 then output;
run;

/*Check*/
data _null_;
    set int2;
    call execute('data out; set &slib..&indsn; varname='||quote(cats(varname))||';
                 codeval_='||quote(cats(codeval_))||'; codelst='||quote(cats(codelst))||
                 '; proc sort nodupkey; by '||cats(varname)||'; run;');

    call execute('data temp_cd01; length checkid domain category details $200 pattern $32767.; set out;
                 var=prxchange(''s/(\/|\.|\(|\)|\.|\*|\?|\+)/\\$1/'', -1, '||strip(varname)||');
                 pattern=''/(,''||cats(var)||'',)|^(''||cats(var)||'',)|(,''||cats(var)||'')$|^(''||cats(var)||'')$/'';
                 re=prxparse(pattern); if ^prxmatch(re, cats(codeval_)) and not missing('||strip(varname)||') then do;
                 domain="&indsn"; category="";
                 details="The value "'||'||cats(compress(var,''\''))||'||
                 '" cannot be found in the codelist '||cats(codelst)||' attached to the variable '||cats(varname)||'.";'||
                 'checkid="Check030010"; keep domain category details checkid; output; end; run;');

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

    call execute('data cdcom&indsn.out'||cats(_n_)||'_; length checkid domain category details $2000; set out1;
                  flag=compress(codeval_,codeval__);
                  if flag^="" and substr('||quote(cats(varname))||',1,2)="&indsn" then do;
                  domain="&indsn"; category=""; var='||cats(varname)||';
                  details="The value "'||'||cats(flag)||'||
                  '" in the codelist '||cats(codelst)||' is not attached to the variable '||cats(varname)||'.";'||
                  'checkid="Check030010"; keep domain category details checkid; output; end; run;');
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
    by valueoid;
run;

data valdef1;
    set valdef;
    length valval_ $2000;
    retain valval_;
    by valueoid;
    if first.valueoid then valval_=valval;
    else valval_=catx(',',valval_,valval);
    if last.valueoid;
    domain=prxchange('s/(.+?)\.(.+)/\1/',-1,valueoid);
    varname=prxchange('s/(.+)\.(\w+)/\2/',-1,valueoid);
    vlevel=countw(valueoid,'.');
    keep valueoid valval_ domain varname vlevel;
run;

/*Split multi-level VALUEOID to generate sas statement for checking*/
proc sql noprint;
    select max(vlevel)-2 into :vlnum from valdef1;
quit;

%let vlnum=&vlnum;

data valdef2;
    set valdef1;
    valueoid=prxchange('s/(\.)(\w{2})(CAT|SPEC|METHOD|TESTCD|QNAM)/~\2\3/i',-1,valueoid);
    valueoid=prxchange('s/(\w{2})(CAT|SPEC|METHOD|TESTCD|QNAM)(\.)/\1\2~/i',-1,valueoid);
    length varcom $1000;
    do i=2 to &vlnum by 2;
        if scan(valueoid,i,'~') ne '' and scan(valueoid,i+1,'~') ne '' then do;
            varc=catx('=',scan(valueoid,i,'~'),quote(scan(valueoid,i+1,'~')));
                varcom=catx(' and ', varcom,varc);
        end;
    end;
    keep domain varname  valval_ varcom;
run;

proc sql noprint;
    select distinct domain into :domainlst separated by '","'
        from valdef1;
quit;

data vacom;
    length checkid domain category details $200;
    call missing(checkid, domain, category, details);
run;

%macro valdomloop(indsn=);

/*Variable has value definition*/
proc sql;
    create table int1 as
        select distinct VARNAME,VALVAL_,VARCOM
        from valdef2(where=(DOMAIN="&indsn"))
        order by VARNAME;
quit;

data &indsn;
    set &slib..&indsn;
    if LBCAT='' then LBCAT='(NO VALUE RECORDED)';
    if LBSPEC='' then LBSPEC='(NO VALUE RECORDED)';
    if LBMETHOD='' then LBMETHOD='(NO VALUE RECORDED)';
run;

/*Check*/
data _null_;
    set int1;
    call execute('data out; set &indsn; varname='||quote(cats(varname))||';
                 valval_='||quote(cats(valval_))||'; proc sort nodupkey; by '||cats(varname)||'; run;');

    if missing(varcom) then do;
        call execute('data temp_va01; length checkid domain category details $200 pattern $32767;
                     set out; var=prxchange(''s/(\/|\.|\(|\)|\.|\*|\?|\+)/\\$1/'', -1, '||strip(varname)||');
                     pattern=''/(,''||cats(var)||'',)|^(''||cats(var)||'',)|(,''||cats(var)||'')$|^(''||cats(var)||'')$/'';
                     re=prxparse(pattern); if ^prxmatch(re, cats(valval_)) and not missing('||strip(varname)||') then do;
                     domain="&indsn"; category="";
                     details="The value "'||'||cats(compress(var,''\''))||'||
                     '" cannot be found in the value level metadata '||
                     'attached to the variable '||strip(varname)||'.";'||
                     'checkid="Check030026"; keep domain category details checkid; output; end; run;');
    end;
    else do;
        call execute('data temp_va01; length checkid domain category details $200 pattern $32767.;
                     set out; var=prxchange(''s/(\/|\.|\(|\)|\.|\*|\?|\+)/\\$1/'', -1, '||strip(varname)||');
                     pattern=''/(,''||cats(var)||'',)|^(''||cats(var)||'',)|(,''||cats(var)||'')$|^(''||cats(var)||'')$/'';
                     re=prxparse(pattern); if ^prxmatch(re, cats(valval_)) and '||strip(varcom)||' and not missing('||strip(varname)||') then do;
                     domain="&indsn"; category="";
                     details="The value "'||'||cats(compress(var,''\''))||'||
                     '" cannot be found in the value level metadata '||
                     'attached to the variable '||strip(varname)||'.";'||
                     'checkid="Check030026"; keep domain category details checkid; output; end; run;');
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

/**************************************** --STRESC QVAL ****************************************/
data cd;
    set &mlib..cd(where=(not missing(codeval)));
    proc sort;
    by codelst;
run;

data cd1;
    set cd;
    length codeval_ $2000;
    retain codeval_;
    by codelst;
    if first.codelst then codeval_=&vart;
    else codeval_=catx(',',codeval_,&vart);
    if last.codelst;
    keep codelst codeval_;
run;


/**************************************** LBSTRESC QVAL ****************************************/
/*Value has code list*/
data valchk1;
    set &mlib..valdef(where=(^ missing(CODELST) and CODELST ^ in ('WHODRUG', 'MedDRA')));
    length cond $2000;
    domain=prxchange('s/(.+?)\.(.+)/\1/',-1,valueoid);
    varname1=prxchange('s/(.+)\.(\w+)/\2/',-1,valueoid);
    if prxmatch('/(testcd)$/i',cats(valueoid)) then varname2=cats(domain,'ORRES');
    else if prxmatch('/(qnam)$/i',cats(valueoid)) then varname2='QVAL';
    else if prxmatch('/(parmcd)$/i',cats(valueoid)) then varname2=cats(domain,'VAL');
    else if  prxmatch('/(cat)$/i',cats(valueoid)) then varname2=cats(domain,'CAT');
    cond=cats(varname1, '=', quote(cats(VALVAL)));
    vlevel=countw(valueoid,'.');
    keep valueoid domain varname: cond codelst vlevel;
run;

/*Split multi-level VALUEOID to generate sas statement for checking*/
proc sql noprint;
    select max(vlevel)-2 into :vlnum from valchk1;
quit;

%let vlnum=&vlnum;

data valchk2;
    set valchk1;
    valueoid=prxchange('s/(\.)(\w{2})(CAT|SPEC|METHOD|TESTCD|QNAM)/~\2\3/i',-1,valueoid);
    valueoid=prxchange('s/(\w{2})(CAT|SPEC|METHOD|TESTCD|QNAM)(\.)/\1\2~/i',-1,valueoid);
    length varcom $1000 cond $2000;
    do i=2 to &vlnum by 2;
        if scan(valueoid,i,'~') ne '' and scan(valueoid,i+1,'~') ne '' then do;
            varc=catx('=',scan(valueoid,i,'~'),quote(scan(valueoid,i+1,'~')));
            varcom=catx(' and ', varcom,varc);
        end;
    end;
    if domain in ('CC', 'DS', 'FT', 'IE', 'LB', 'QS') then cond=catx(' and ',varcom, cond);
    keep valueoid domain varname: cond codelst;
    cond=prxchange('s/(\(NO VALUE RECORDED\))//',-1,cond);
run;

proc sql noprint;
    select distinct domain into :domainlst separated by '","'
        from valchk1;
quit;

data cvcom;
    length Checkid domain Condition Details $200;
    call missing(Checkid, domain, Condition, Details);
run;

%macro valloop(indsn=);
proc sql;
    create table int1 as
        select distinct *
        from valchk2(where=(domain="&indsn"))
        order by varname1;
quit;

/*Merge to make variable with code value*/
data int2;
    if _n_=1 then do;
        if 0 then set cd1;
        dcl hash h(dataset:'cd1');
        h.definekey('codelst');
        h.definedata(all:'Y');
        h.definedone();
    end;
    set int1;
    if h.find() eq 0 then output;
run;

/*Check*/
data _null_;
    set int2;
    call execute('data out; set &slib..&indsn;  length condition $200; if '||strip(cond)||'; varname2='||quote(cats(varname2))||';
                 codeval_='||quote(cats(codeval_))||'; codelst='||quote(cats(codelst))||'; Condition= '||quote(cats(cond))||';
                 proc sort nodupkey; by '||cats(varname2)||'; run;');

    call execute('data temp_cv01; length Checkid domain Condition Details $200 pattern $32767.; set out;
                 set out; var=prxchange(''s/(\/|\.|\(|\)|\.|\*|\?|\+)/\\$1/'', -1, '||strip(varname2)||');
                 pattern=''/(,''||cats(var)||'',)|^(''||cats(var)||'',)|(,''||cats(var)||'')$|^(''||cats(var)||'')$/'';
                 re=prxparse(pattern); if ^prxmatch(re, cats(codeval_)) and not missing('||strip(varname2)||') then do;
                 domain="&indsn";
                 details="The value "'||'||cats(compress(var,''\''))||'||
                 '" cannot be found in the codelist '||cats(codelst)||' attached to the variable '||cats(varname2)||'.";'||
                 'checkid="Check030026_2"; keep domain details checkid condition; output; end; run;');

    call execute('data temp_cv02; set cvcom temp_cv01; run;');
    call execute('data cvcom; set temp_cv02; run;');
run;

%mend valloop;

/*Invoke macro*/
data _null_;
    set &mlib..datadef(where=(dataset in ("&domainlst")));
    call execute('%nrstr(%valloop(indsn='||cats(DATASET)||'))');
run;

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
    rename NAME=VARNAME TYPE=DATATYPE LABEL=VARLABEL;
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

proc compare base=sdata compare=mdata out=result outnoequal outbase outcomp outdif;
run;

/*Check if two data sets contain the same variables, observations and values but do not care about labels, formats*/
%if &sysinfo > 64 %then %do;
    proc sort data=sdata;
        by DATASET VARNAME;
    run;

    proc sort data=mdata;
        by DATASET VARNAME;
    run;

    data temp1;
        merge sdata(in=a) mdata(in=b);
        by DATASET VARNAME;
        length CHECKIN DOMAIN DETAILS $200;
        if a and not b then do;
            CHECKIN='Check030000';
            DOMAIN=cats(DATASET);
            DETAILS="Variable "||cats(VARNAME)||" in SDTM dataset " ||cats(DATASET)||" but not in VARDEF";
            output;
        end;
        if b and not a then do;
            CHECKIN='Check030000';
            DOMAIN=cats(DATASET);
            DETAILS="Variable "||cats(VARNAME)||" in VARDEF but not in SDTM dataset " ||cats(DATASET);
            output;
        end;
        keep CHECKIN DOMAIN DETAILS;
    run;

    data temp2;
        set result;
        length CHECKIN DOMAIN DETAILS $200;
        if _n_=1 then do;
            CHECKIN='Check030000';
            DOMAIN=cats(DATASET);
            DETAILS="The attributes of variables in SDTM datasets is not consistent with the attributes of
 variables in VARDEF, the observation number is "||cats(_OBS_);
        end;
        keep CHECKIN DOMAIN DETAILS;
    run;

    data varatt;
        set temp1 temp2;
        if ^missing(DETAILS);
    run;
%end;
%else %do;
    data varatt;
    run;
%end;

/**************************************** Check030267, Check030270 and Check030272 ****************************************/
%macro vcodechk(chkid=);
/*--ORRES codelist chk*/
data mdata_&chkid;
    length dataset $200;
    set &mlib..vardef;
    %if &chkid=267 %then if prxmatch("/(ORRES)$/",strip(varname)) and varname ne 'IEORRES';
    %else %if &chkid=270 %then if prxmatch("/(DY|STDY|ENDY)$/",strip(varname)) and VARNAME^='VISITDY';
    %else if prxmatch("/(QVAL)$/",strip(varname));;
    if %if &chkid=267 or &chkid=272 %then codelst ne; %else %if &chkid=270 %then compmeth eq; '' then do;
        length checkid domain category details $200;
        category="";
        domain=dataset;
        %if &chkid=267 or &chkid=272 %then details="In Define.xml a codelist is assigned to "||strip(varname)||".";
        %else %if &chkid=270 %then details="A STUDY DAY OF COLLECTION "||strip(varname)||
                                           " is present but there is no link to a COMPUTATIONAL ALGORITHM.";;
        checkid="Check030&chkid";
        keep checkid domain category details;
        output;
    end;
run;
%mend vcodechk;

*%vcodechk(chkid=267);
%vcodechk(chkid=270);
*%vcodechk(chkid=272);

/**************************************** Check030510 ****************************************
%if &stdv=JJ %then %do;
proc sql;
    create table bflag as
        select memname,name,length from dictionary.columns
        where libname=%upcase("&slib") and prxmatch('/(FL)$/i',strip(name));
quit;

/*Check*
data bflchk;
    set bflag;
    if length>1 then do;
        length checkid domain category details $200;
        category="";
        domain=memname;
        details="A flag "||strip(name)||
                "is used but the length of the column is more than 1.";
        checkid="Check030510";
        keep checkid domain category details;
        output;
    end;
run;
%end;
*/

/**************************************** Checkid030714, Checkid030715 ****************************************/
%macro comm(chkid=,var=);
data vardef_&chkid;
    set &mlib..vardef;
    if prxmatch("/(&var)$/",strip(varname)) then do;
        if missing(comments) then do;
            length checkid domain category details $200;
            category="";
            domain=dataset;
        %if &chkid=714 %then %do;
            details="A comment that describes the start of the protocol-specified reference period ("||strip(varname)||
                    ") is missing in sponsor's metadata.";
        %end;
        %else %do;
            details="A comment that describes the end of the protocol-specified reference period ("||strip(varname)||
                    ") is missing in sponsor's metadata.";
        %end;
            checkid="Check030&chkid";
            keep checkid domain category details;
            output;
        end;
    end;
run;
%mend comm;

%comm(chkid=714,var=STTPT);
%comm(chkid=715,var=ENTPT);

/*Create result dataset*/
/*Format*/
proc format;
    value $chk "Check030000" = "Check for if the variable or variable attributes in SDTM datasets is consistent with the attributes of variables in metadata VARDEF."
               "Check030010" = "Check for each codelist related variable, that the value is found in the study-specific codelist attached to that variable."
               "Check030026" = "Check for each value level metadata related variable, that the value is found in the value level metadata attached to that variable."
               "Check030026_2" = "Check for each value level metadata related variable, that the value is found in the study-specific codelist attached to that variable."
               /*"Check030267" = "Check for --ORRES that no codelist is assigned (except for IEORRES)"*/
               "Check030270" = "Check if --DY, --STDY or --ENDY is present in the dataset that a COMPMETHOD is provided in the comments"
               /*"Check030272" = "Check for QVAL that no codelist is attached"*/
               /*"Check030510" = "Check that the length of flag variables is 1"*/
               "Check030714" = "Check for each domain that a comment is attached to the variable --STTPT"
               "Check030715" = "Check for each domain that a comment is attached to the variable --ENTPT"
    ;
run;

data comb;
    set vardef_: mdata_: /*%if &stdv=JJ %then bflchk;*/ varatt;
    length descr $200;
    descr=put(checkid,$chk.);
    if not missing(CHECKID);
    keep Domain Details CheckId descr;
    proc sort nodupkey;
        by _ALL_;
    label CheckId = 'CheckID'
          Descr   = 'Check Description'
          Domain  = 'Domain Abbreviation'
          Details = 'Message'
          ;
run;

data comb;
    retain CheckId Descr Domain Details;
    set comb;
run;

%macro fin(ind=,outd=);
data &outd;
    set &ind.;
    by checkid domain;
    length descr $200;
    descr=put(checkid,$chk.);
    if not missing(CHECKID);
    %if &ind^=cvcom %then drop Category;;
    proc sort nodupkey;
        by _ALL_;
    label CheckId = 'CheckID'
          Descr   = 'Check Description'
          Domain  = 'Domain Abbreviation'
          Details = 'Message'
          ;
run;

data &outd;
    retain CheckId Descr Domain Details;
    set &outd;
run;

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
    if _n_=1 then call symputx('e',0);
run;

%if &e=1 %then %do;
    data &dsn;
        length CheckID $200;
        CHECKID="No finding";
    run;
%end;

ods tagsets.ExcelXP options(sheet_name="&sheet" absolute_column_width ="30");
title;
proc print data=&dsn label noobs;
    var _all_ / style(data)={tagattr='format:@'};
run;

%mend output;

%output(dsn=Check030010, sheet=Codelstchk)
%output(dsn=Check030026, sheet=Valuelstchk)
%output(dsn=Check030026_2, sheet=Valuelstchk2)
%output(dsn=comb, sheet=Comblstchk)

ods tagsets.excelxp close;
ods listing;

/*Tidy environment*/
proc datasets nolist lib=work memtype=data kill;
quit;

%mend jjchksdtmvalid;

%jjchksdtmvalid;

/*EOP*/