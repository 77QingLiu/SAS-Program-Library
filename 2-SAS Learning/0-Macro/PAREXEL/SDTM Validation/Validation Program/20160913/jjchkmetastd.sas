/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        222354

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Allen Zeng $LastChangedBy: $
  Creation Date:         28Oct2014 / $LastChangedDate: $

  Program Location/name: $HeadURL: $

  Files Created:         jjchkmetastd.log
                         qc_CD.txt
                         qc_COMPMETH.txt
                         qc_DATADEF.txt
                         qc_VALDEF.txt
                         qc_VARDEF.txt
                         PXLTimeCode_MetadataDiff.xml

  Program Purpose:       To compare study level metadata with standard metadata

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: $
-----------------------------------------------------------------------------*/

%macro jjchkmetastd;
/*Create QC dataset*/
%macro libm(meta=   /*Metadata type*/
            ,cond=   /*Condition*/
            ,label=  /*Metadata label*/
            ,id=     /*ID variable in QC result*/
            ,dv=     /*Undesired variable*/
            ); 
proc sql;
    create table &meta._ as
        select * from
        meta.&meta a
        where not exists
        (select * from metastd.&meta b
         where &cond)
    ;

    create table m_&meta(label="&label") as
        select * from
        meta.&meta a
        where not exists
        (select * from &meta._ b
         where &cond)
        order by 1,2 %if &meta^=compmeth %then ,3;;
    ;

    create table q_&meta as
        select * from
        metastd.&meta a
        where exists
        (select * from meta.&meta b
         where &cond)
         order by 1,2 %if &meta^=compmeth %then ,3;;
    ;
quit;

%if &meta=valdef %then %do;
    proc sort data=q_valdef nodupkey dupout=dup;
        by VALUEOID VALVAL;
    run;
%end;

/*Get dataset label
data _null_;
    set sashelp.vtable(where=(libname='META'));
    call symputx(memname,memlabel);
run;
*/

/*Remove specified characters*/
data q_&meta(label="&label");
    set q_&meta;
    array vlst{*} _character_;
    do num=1 to dim(vlst);
        vlst(num)=compress(vlst(num), , 'kw');
    end;
    drop num;
run;

/*Remove FORMAT and INFORMAT*/
proc datasets lib=work nolist;
    modify q_&meta;
    attrib _all_ format= informat=;
quit;

/*Compare*/
proc printto file = "&_tglobal.qc_%upcase(&meta).txt" new;
run;

proc compare base=m_&meta(drop=&dv) compare=q_&meta(drop=&dv) listall;
   id &id;
run;

proc printto;
run;

%mend libm;

/*Dataset Level Metadata*/
%libm(meta=datadef, cond=%str(a.DATASET=b.DATASET),label=Dataset Level Metadata, id=DATASET notsorted)

/*Value Level Metadata*/
%libm(meta=valdef, cond=%str(a.VALUEOID=b.VALUEOID and a.VALVAL=b.VALVAL), label=Value Level Metadata
      , id=VALUEOID VALVAL, dv=VARORDER)

/*Controlled Terminology Definition*/
%libm(meta=cd, cond=%str(a.CODELST=b.CODELST and a.CODEVAL=b.CODEVAL), label=Controlled Terminology Definition
      , id=CODELST CODEVAL, dv=RNK)

/*Computational Algorithm Method*/
%libm(meta=compmeth, cond=%str(a.MTHNAM=b.MTHNAM), label=Computational Algorithm Method ,id=MTHNAM, dv=)

/*Variable Level Metadata*/
%libm(meta=vardef, cond=%str(a.DATASET=b.DATASET and a.VARNAME=b.VARNAME), label=Variable Level Metadata
      , id=DATASET VARNAME, dv=VARORDER)

/*Output Excel*/
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
ods tagsets.excelxp file="&_tglobal.&_tims._MetadataDiff.xml" style = XLsansPrinter
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

%macro loop(dataset=);
/*Empty Check*/
%let e=1;

data _null_;
    set &dataset._;
    if _n_=1 then call symputx('e',0);
run;

%if &e=1 %then %do;
    data &dataset._;
        DATASET='No finding';
    run;
%end;

ods tagsets.ExcelXP options(sheet_name="&dataset" absolute_column_width ="30");
title;

proc print data=&dataset._ label noobs;
    var _all_ /style(data)={tagattr='format:@'};
run;
%mend loop;

%loop(dataset=Datadef)
%loop(dataset=Valdef)
%loop(dataset=CD)
%loop(dataset=Compmeth)
%loop(dataset=Vardef)

/*Missing Req or Exp Variable*/
proc sql noprint;
    select DATASET into : domainlst separated by '", "'
        from meta.vardef
        ;

    create table Vardef_Reqexp_ as
        select * from metastd.vardef(where=(DATASET in ("&domainlst") and prxmatch('/REQ|EXP/i', CORE))) a
        where not exists
        (select * from meta.vardef b
         where a.DATASET=b.DATASET and a.VARNAME=b.VARNAME)
    ;
quit;

%loop(dataset=Vardef_Reqexp)

ods tagsets.excelxp close;
ods listing;
%mend jjchkmetastd;

%jjchkmetastd;

/*EOP*/