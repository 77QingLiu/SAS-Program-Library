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

  Files Created:         jjchkacrfvar.log
                         PXLTimeCode_CRFVarCheck.xml

  Program Purpose:       Check issues below:
                           1. To check if the variable in aCRF is consistent with the variable in standard metadata VARDEF
                           2. To check if the variable in study metadata dataset is consistent with the variable in aCRF
                           3. To check if the variable in SDTM dataset is consistent with the variable in aCRF
                           4. To check if the value in study metadata VALDEF is consistent with the value in aCRF

  Macro Parameters       SLIB   = Library name of SDTM datasets
                                  <default = transfer>

                         MLIB   = Library name of study metadata datasets
                                  <default = meta>

                         SMLIB  = Library name of standard metadata datasets
                                  <default = metastd>

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

%macro jjchkacrfvar(  slib=transfer
                     , mlib=meta
                     , smlib=metastd
                     , outdir= _tglobal
                     , output= CRFVarCheck
                     );

/* Generate filename for output xml file */
filename var_chk "&&&outdir..&_tims._&output..xml";

/* Delete current output file if exists */
%if %sysfunc(fexist(var_chk)) %then %do;
    data _null_;
        x=fdelete("var_chk");
    run;
%end;

/*Load comments to SAS dataset*/
data temp0;
    infile "&_rawspec.comments.txt" truncover lrecl=32676;
    input STRING $200.;
    if compress(compress(STRING, , 'kw'))='' then delete;
run;

/*Drop undesired observation*/
data temp1;
    set temp0;
    STRING=compress(STRING, , 'kw');
    STRING_=lag(STRING);
    if prxmatch('/^(\d{1})$/', cats(STRING)) and prxmatch('/^(page:)/i', cats(STRING_))
       then STRING='Page: '||cats(STRING);
    if prxmatch('/^(note|note:|example|example:|:|\d+\.)$/i', cats(STRING_)) then STRING='Note: '||cats(STRING);
    if ^ prxmatch('/^(Author:|Date:|Subject:|\[not submitted|For annotations|linked to|Comments from page|Note:|example)/i', cats(STRING));;
    retain CRFPAGE;
    if prxmatch('/^(Page: ?\d+)/', cats(STRING)) then CRFPAGE=input(scan(STRING, 2, ': '), best.);
    if not prxmatch('/^(Page:)/i', cats(STRING)) and CRFPAGE>0;
    keep STRING CRFPAGE;
run;

%macro crf(i=, in_data=, out_data=);
/*Variables list*/
proc sql noprint;
    select distinct VARNAME_ into :varlist separated by '|'
        from
        %if &i=1 %then %do;
            (select distinct *, case when prxmatch("/^(SUPP)/", cats(DATASET)) then cats(DATASET, VARNAME)
                                     else VARNAME
                                end as VARNAME_
             from &in_data)
         %end;
         %else %do;
             (select distinct CRFPAGE, prxchange("s/([A-Z])\s([A-Z])/\1z\2/", -1, cats(VALVAL)) as VARNAME_
             from &in_data where prxmatch('/(crf)/i', ORIGIN) and VALVAL^='(NO VALUE RECORDED)');
         %end;
        ;
quit;

/*CRF page*/
data temp2;
    set temp1;
    %if &i=1 %then %do;
        if prxmatch("/\s(SUPP)(\w{2})\s/", STRING) then
           STRING=prxchange('s/(.+?)(SUPP)(\w{2})(.+)/\2\3QLABEL\/\2\3QVAL/', -1, STRING);
    %end;
    %else %do;
        STRING=prxchange("s/([A-Z])\s([A-Z])/\1z\2/", -1, cats(STRING));
        if prxmatch("/\s(SUPP)(\w{2})\s/", STRING) then
        STRING=prxchange("s/(\w+)\s?=\s?\w+\s\w+\s(SUPP\w{2}).+/\1 in \2/", -1, cats(STRING));
    %end;
run;

/*keep only variables from the varlist*/
data &out_data;
    set temp2;
    %if &i=1 %then if countc(STRING, '=')=1 then STRING=scan(STRING, 1, '=');;
    STRING2=compbl(prxchange("s/.*?(\b(?:&varlist)\b)?/$1 /", -1, cats(STRING)));
    STRING2=compress(cats(STRING2), , 'kw');
    if prxmatch('/^([A-Z]{1,})/', cats(STRING2));
    proc sort nodupkey;
    by STRING2 CRFPAGE;
run;

/*Split string into variables based on the delimiter ' '*/
data &out_data;
    set &out_data;
    length VARNAME $200;
    I=1;
    if prxmatch('/\s/', cats(STRING2)) then do until(scan(STRING2, I, ' ')='');
        VARNAME=cats(scan(STRING2, I, ' '));
        output;
        I+1;
    end;
    else do;
        VARNAME=STRING2;
        output;
    end;
    keep VARNAME CRFPAGE;
run;
%mend crf;

/*keep keywords which are contained in standard metadata VARDEF*/
%crf(i=1, in_data=&smlib..vardef, out_data=temp3)

/*keep keywords which are contained in study metadata VALDEF and origin contains 'CRF'*/
%crf(i=2, in_data=&mlib..valdef, out_data=temp4)

/*Check 1*/
data smvardef;
    length VARNAME $200;
    set &smlib..vardef;
    if VARNAME in ('QLABEL', 'QVAL') then VARNAME=cats(DATASET, VARNAME);
    keep VARNAME;
run;

proc sort data=smvardef nodupkey;
    by VARNAME;
run;

proc sort data=temp3 out=temp31(keep=VARNAME) nodupkey;
    by VARNAME;
run;

data crf1(keep=ISSUE);
    merge smvardef(in=a) temp31(in=b);
    by VARNAME;
    length ISSUE $200;
    if b and not a then do;
        ISSUE="Variable "||cats(VARNAME)||" in aCRF but not in standard metadata VARDEF";
        output;
    end;
run;

/*Check 2&3&4*/
%macro check234(i=, in=);
/*Variables list*/
proc sql noprint;
    select distinct VARNAME_ into :varlist separated by '","'
        from
        (select distinct *, case when prxmatch("/^(SUPP)/", cats(DATASET)) then cats(DATASET, VARNAME)
                                 else VARNAME
                            end as VARNAME_
         from &mlib..vardef)
        ;

    %if &i=3 %then %do;
    select distinct VARNAME_ into :varlist_ separated by '","'
        from
        (select distinct *, case when prxmatch("/^(SUPP)/", cats(DATASET)) then cats(DATASET, VARNAME)
                                 else VARNAME
                            end as VARNAME_
         from &mlib..vardef where prxmatch('/(crf)/i', ORIGIN))
        ;
    %end;
quit;

%if &i=2 %then %do;
%let type=Variable;
%let source=study metadata dataset;

data mdata;
    length VARNAME $200;
    set &in;
    if prxmatch('/(crf)/i', ORIGIN);
    if VARNAME in ('QLABEL', 'QVAL') then VARNAME=cats(DATASET, VARNAME);
    keep VARNAME;
run;
%end;
%else %if &i=3 %then %do;
%let type=Variable;
%let source=SDTM dataset;

proc sql;
    create table column as
        select MEMNAME, NAME
        from &in
        where LIBNAME=upcase("&slib")
        ;
quit;

data mdata;
    length VARNAME $200;
    set column;
    if NAME in ('QLABEL', 'QVAL') then NAME=cats(MEMNAME, NAME);
    if NAME in ("&varlist_");
    VARNAME=NAME;
    keep VARNAME;
run;
%end;
%else %if &i=4 %then %do;
%let type=Value;
%let source=metadata VALDEF;

data mdata;
    length VARNAME $200;
    set &in;
    if VALVAL^='(NO VALUE RECORDED)' and prxmatch('/(crf)/i', ORIGIN);
    VALVAL=prxchange("s/([A-Z])\s([A-Z])/\1z\2/", -1, cats(VALVAL));
    VARNAME=VALVAL;
    keep VARNAME;
run;

proc sort data=temp4 out=temp41 nodupkey;
    by VARNAME;
run;
%end;

proc sort data=mdata nodupkey;
    by VARNAME;
run;

data crf&i;
    merge mdata(in=a) %if &i^=4 %then temp31(in=b); %else temp41(in=b);;
    by VARNAME;
    length ISSUE $200;
    if a and not b then do;
        ISSUE="&type "||tranwrd(cats(VARNAME), 'z', ' ')||" in &source which origin contains 'CRF' but not in aCRF";
        ORD=1;
        output;
    end;
    if b and not a then do;
        if VARNAME in ("&varlist") then 
           ISSUE="&type "||tranwrd(cats(VARNAME), 'z', ' ')||" in aCRF but the origin does not contain 'CRF' in &source";
        else if VARNAME ^ in ("&varlist") then 
           ISSUE="&type "||tranwrd(cats(VARNAME), 'z', ' ')||" in aCRF but not in &source";
        ORD=2;
        output;
    end;
    proc sort data=crf&i out=crf&i(keep=ISSUE);
    by ORD ISSUE;
run;
%mend check234;

%check234(i=2, in=&mlib..vardef)

%check234(i=3, in=dictionary.columns)

%check234(i=4, in=&mlib..valdef)

/*/*Check 5&6*/*/
/*/*Combine the crf page*/*/
/*%macro check56(i=, in=, invar=);*/
/*proc sort data=temp&i out=temp32 nodupkey;*/
/*    by VARNAME CRFPAGE;*/
/*run;*/
/**/
/*data temp5;*/
/*    set temp32;*/
/*    if ^missing(VARNAME);*/
/*    by VARNAME;*/
/*    length CRFPAGE_ $500;*/
/*    retain CRFPAGE_ ;*/
/*    if first.VARNAME then CRFPAGE_=cats(CRFPAGE);*/
/*    else CRFPAGE_=catx(', ', CRFPAGE_, cats(CRFPAGE));*/
/*    if last.VARNAME;*/
/*    %if &i=4 %then rename VARNAME=VALVAL;;*/
/*    drop CRFPAGE;*/
/*run;*/
/**/
/*%if &i=4 %then %do;*/
/*    %let in=valdef;*/
/*    data valdef;*/
/*        set &mlib..valdef;      */
/*        if &invar^='(NO VALUE RECORDED)';*/
/*        VALVAL=prxchange("s/([A-Z])\s([A-Z])/\1z\2/", -1, cats(VALVAL));*/
/*    run;*/
/*%end;*/
/**/
/*/*Check*/*/
/*data crf%eval(&i+2);*/
/*    length &invar $200.;*/
/*    if _n_=1 then do;*/
/*        if 0 then set &in(where=(index(ORIGIN, 'CRF') ^=0 and &invar^='(NO VALUE RECORDED)'));*/
/*        dcl hash h(dataset: "&in(where=(index(ORIGIN, 'CRF') ^=0 and &invar^='(NO VALUE RECORDED)'))", multidata: "Y");*/
/*        h.definekey("&invar");*/
/*        h.definedata(all: "Y");*/
/*        h.definedone();*/
/*    end;*/
/*    set temp5;*/
/*    length ISSUE $200;*/
/*    if h.find()=0 then do;*/
/*        %if &i=3 %then %do;*/
/*            if CRFPAGE_^= CRFPAGE then  */
/*               ISSUE="The CRFPAGE attached to the variable "||cats(&invar)||" in VARDEF is not correct, shoule be "||cats(CRFPAGE_);*/
/*        %end;*/
/*        %else %do;*/
/*            if CRFPAGE_^= CRFPAGE then  */
/*              ISSUE="The CRFPAGE attached to the value "||tranwrd(cats(&invar), 'z', ' ')*/
/*                    ||" in VALDEF is not correct, shoule be "||cats(CRFPAGE_);;*/
/*            if scan(VALUEOID, 1, '.') in ('LB', 'QS') and ^missing(ISSUE) then ISSUE=cats(ISSUE, ', need further checks');*/
/*        %end;*/
/*    end;*/
/*    if ^missing(ISSUE);*/
/*    keep ISSUE;*/
/*run;*/
/*%mend check56;*/
/**/
/*%check56(i=3, in=&mlib..vardef, invar=VARNAME)*/
/**/
/*%check56(i=4, in=&mlib..valdef, invar=VALVAL)*/

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
ods tagsets.excelxp file=var_chk style = XLsansPrinter
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

%output(ind=crf1, sheet=VarChk1)
%output(ind=crf2, sheet=VarChk2)
%output(ind=crf3, sheet=VarChk3)
%output(ind=crf4, sheet=ValChk)
/*%output(ind=crf5, sheet=varCrfPageChk)*/
/*%output(ind=crf6, sheet=valCrfPageChk)*/

ods tagsets.excelxp close;
ods listing;

%mend jjchkacrfvar;

%jjchkacrfvar;

/*EOP*/
