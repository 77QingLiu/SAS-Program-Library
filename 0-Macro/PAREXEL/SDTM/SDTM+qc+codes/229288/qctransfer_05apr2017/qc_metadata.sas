
/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: JANSEEN RESEARCH and DEVELOPMENT / 63871860BAC0003
  PXL Study Code:        230138

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Allen Zeng $LastChangedBy: wangfu $
  Creation Date:         03Dec2015 / $LastChangedDate: 2017-03-24 01:19:57 -0400 (Fri, 24 Mar 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_metadata.sas $

  Files Created:         qc_metadata.log
                         datadef.sas7bdat
                         valdef.sas7bdat
                         cd.sas7bdat
                         studydef.sas7bdat
                         compmeth.sas7bdat
                         vardef.sas7bdat
                         qc_datadef.txt
                         qc_valdef.txt
                         qc_cd.txt
                         qc_studydef.txt
                         qc_compmeth.txt
                         qc_vardef.txt



  Program Purpose:       To QC 1. Dataset Level Metadata Dataset
                               2. Value Level Metadata Dataset
                               3. Controlled Terminology Definition Dataset
                               4. Study Level Metadata Dataset
                               5. Computational Algorithm Method Dataset
                               6. Variable Level Metadata Dataset
  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 148 $
-----------------------------------------------------------------------------*/

%macro metadata(out=, range=, nlst=);
/*Get File Name*/
%jjqcgfname;

proc import datafile="&SPECPATH.&fname..xlsx"
    out=&out %if &metad=valdef %then (drop=L); %if &metad=cd %then (drop=G); dbms=xlsx replace;
    getnames=no;
    range="&range";
        guessingrows=350;
run;

%if &metad=cd %then %do;
    data &out;
        set &out(rename=I=II);
        length I $15;
        I=II;
        drop II;
    run;
%end;

/*Numeric to Character*/
%let vlist=;
%let llist=;
%let alist=;

proc sql noprint;
    select name
         , cats(name)||' $'||cats(length_)
         , alist into
           :vlist separated by ' '
         , :llist separated by ' '
         , :alist separated by ' '
        from (select a.name ,length_
                   , case when b.type='char' %if &metad=valdef %then or b.name in ('E','F');
                               then cats(a.name)||'=cats('||cats(b.name)||');'
                          when b.type='num' then cats(a.name)||'=put('||cats(b.name)||',z3.);'
                          else ''
                     end as alist length=100
                from (select name, varnum, case when type='char' and NAME='CRFPAGE' then '200'
                                                when NAME='CODELST' then '10'
                                                when type='char' and NAME='COMMENTS' then '400'
                                                when name = 'VALLABEL' then '200'
                                                else cats(length)
                                           end as length_
                          from dictionary.columns
                          where libname='METASTD' and memname=upcase("&metad") ) a
                left join
                (select name, varnum, type
                from dictionary.columns
                where libname='WORK' and memname=upcase("&metad") %if &metad=valdef %then and NAME ^ in ('N');) b
                on a.varnum=b.varnum)
        ;
quit;

data &out;
    set &out;
    array vlst{*} _character_;
    do num=1 to dim(vlst);
        vlst(num)=compbl(prxchange('s/\n|\r/ /', -1, vlst(num)));
        vlst(num)=compress(vlst(num), , 'kw');
    end;
    if not missing(B);
run;

data &out;
    length &llist;
    set &out;
    &alist;
    %if &metad=valdef %then %do;
        CRFPAGE=cats(N);
        COMPMETH=compress(strip(cats(O)),,'kw');
    %end;
    %if &metad=cd %then call missing(extra);;
    keep &vlist %if &metad=cd %then H I; %if &metad=valdef %then CRFPAGE;;

run;
%mend metadata;

/*Variable Attribute*/
%macro attrib(metad=);
%global  &metad._attri vlist;
proc sql noprint;
    select attri
    into :&metad._attri separated by ' '
    from
    (select case when format^='' and informat^='' then cats(name)||' '
                                                   ||"label"||'='||'"'||cats(label)||'"'||' '
                                                   ||"length"||'='||cats(length_)||' '
                                                   ||"format"||'='||cats(format)||' '
                                                   ||"informat"||'='||cats(informat)||' '
                 when format^='' then cats(name)||' '
                                                   ||"label"||'='||'"'||cats(label)||'"'||' '
                                                   ||"length"||'='||cats(length_)||' '
                                                   ||"format"||'='||cats(format)||' '
                 when informat^='' then cats(name)||' '
                                                   ||"label"||'='||'"'||cats(label)||'"'||' '
                                                   ||"length"||'='||cats(length_)||' '
                                                   ||"informat"||'='||cats(informat)||' '
                 when format='' and informat='' then cats(name)||' '
                                                   ||"label"||'='||'"'||cats(label)||'"'||' '
                                                   ||"length"||'='||cats(length_)||' '

                 else ''
           end as attri
    from (select *,case when type='num' then cats(length)
                        when type='char' and NAME='COMMENTS' then '$400'
                        when type='char' and NAME='CODELST' then '$10'
                        when type='char' and NAME = 'VALLABEL' then '$200'
                        when type='char' then '$'||cats(length)
                        else ''
                   end as length_
                 from dictionary.columns where libname='METASTD' and
                 %if &metad=datadef or &metad=valdef or &metad=cd or &metad=studydef or &metad=compmeth
                     %then memname=upcase("&metad"));
                 %else memname=upcase('VARDEF'));
    );

    select name into :vlist separated by ' '
        from dictionary.columns
        where libname='METASTD' and
        %if &metad=datadef or &metad=valdef or &metad=cd or &metad=studydef or &metad=compmeth
            %then memname=upcase("&metad");
        %else memname=upcase('VARDEF');
        order by varnum;
quit;
%mend attrib;

/*Evoke Macro*/
%macro evo(metad=,range=,nlst=,label=);
/*To get attribute statement*/
%attrib(metad=&metad)

/*Reading External Files*/
%metadata(out=&metad,range=&range,nlst=&nlst)

%if &metad=cd %then %do;
    proc sort data=cd;
        by CODELST CODEVAL;
    run;
%end;

/*Output Study Meatdata*/
data qmeta.&metad(label="&label");
    retain &vlist %if &metad=valdef %then CRFPAGE;;
    attrib &&&metad._attri %if &metad=valdef %then CRFPAGE label='CRF Page Number' STDUNIT length=$20 label='Standard Units'
                                                    CODELST label='Codelist Name' /*VALLABEL length=$202.*/;
                           %if &metad=cd %then REFERENC length=$40 label='Controlled Term Reference';
                           %if &metad=datadef %then DSORDER length=$3 label='Dataset Order';;
    set &metad;
    %if &metad=datadef %then DSORDER='';;
    %if &metad=valdef %then %str(STDUNIT='';drop II;);
    %if &metad=cd %then %do;
        RNK=put(input(RNK,best.),z3.);
        VERSION=cats(VERSION);
        REFERENC='';
        DICTNRY=cats(H);
        VERSION=strip(compress(cats(I), , "kw"));

        drop H I EXTRA %if &metad =valdef %then  II; ;
    %end;

run;

/*Remove FORMAT and INFORMAT*/
proc datasets lib=qmeta nolist;
    modify &metad;
    attrib _all_ format= informat=;
quit;

%mend evo;

/*Define_DATADEF*/
%evo(metad=datadef, range=Define_DATADEF$B6:I2000, label=Dataset Level Metadata)

/*VALDEF*/
%evo(metad=valdef, range=VALDEF$A2:O2000, label=Value Level Metadata)

/*Codelist-CD*/
%evo(metad=cd,range=Codelist-CD$B14:I2000,label=Controlled Terminology Definition)

/*STUDYDEF*/
%let metad=studydef;
%let range=STUDYDEF$A1:G1000;
%let out=studydef;
%let label=Study Level Metadata;

proc import datafile="&SPECPATH.&fname..xlsx"
    out=&out dbms=xlsx replace;
    getnames=yes;
    range="&range";
run;

data &out;
    set &out;
    array vlst{*} _character_;
    do num=1 to dim(vlst);
        vlst(num)=compbl(prxchange('s/\n|\r/ /', -1, vlst(num)));
        vlst(num)=compress(vlst(num), , 'kw');
    end;
    drop num;
    if not missing(STUDYID);
run;

/*Remove FORMAT and INFORMAT*/
proc datasets lib=work nolist;
    modify &metad;
    attrib _all_ format= informat=;
quit;

data qmeta.&metad(label="&label");
    retain STUDYID STUDYNM STUDDESC PROTONM METAVS SDTMIGVS DEFINEVS;
    attrib STUDYID  label='Study Identifier '           length=$40
           STUDYNM  label='Study Name'                  length=$40
           STUDDESC label='Study Description'           length=$1000
           PROTONM  label='Protocol Name'               length=$40
           METAVS   label='Metadata Version Number'     length=$40
           SDTMIGVS label='CDISC SDTMIG Version Number' length=$10
           DEFINEVS label='The Define Version Number'   length=$10
           ;
    set &metad(rename=(DEFINEVS=DEFINEVS_ METAVS=METAVS_));
    DEFINEVS = put(DEFINEVS_,best. -l);
/*     DEFINEVS = strip(DEFINEVS_); */
    METAVS = strip(METAVS_);
    drop DEFINEVS_ METAVS_;
run;

/*Remove FORMAT and INFORMAT*/
proc datasets lib=qmeta nolist;
    modify &metad;
    attrib _all_ format= informat=;
quit;

/*Derivations-COMPMETH*/
%evo(metad=compmeth,range=Derivations-COMPMETH$B6:C1000,label=Computational Algorithm Method)

/*Vardef*/
/*Domain list*/
data domain_lst;
    length i 8 dataset $10 range $30;
    set datadef(keep=dataset);
    i=_n_;
    range=catx('$',dataset,'B7:T1000');
run;

/*Domain loop*/
/*Get File Name*/
%jjqcgfname;

%macro loop(i=,domain=,range=);
proc import datafile = "&SPECPATH.&fname..xlsx"
    out = &domain(drop=C) dbms = XLSX replace;
    getnames = no;
    range="&range";
run;

data &domain;
    retain B D E F G H I J K M O P Q R T L S N;
    set &domain;
run;

/*Numeric to Character*/
%let vlist=;
%let llist=;
%let alist=;

proc sql noprint;
    select name
         , cats(name)||' $'||cats(length_)
         , alist into
           :vlist separated by ' '
         , :llist separated by ' '
         , :alist separated by ' '
        from (select a.name ,length_
                   , case when b.type='char' or b.name in ('G','H') then cats(a.name)||'=cats('||cats(b.name)||');'
                          when b.type='num'                         then cats(a.name)||'=put('||cats(b.name)||',z3.);'
                          else ''
                     end as alist length=100
                from (select name, varnum,
                          case when NAME='CRFPAGE' then 200
                               when NAME='CODELST' then 10
                               else LENGTH
                          end as LENGTH_
                          from dictionary.columns
                          where libname='METASTD' and memname=upcase("VARDEF")) a
                left join
                (select name, varnum, type
                from dictionary.columns
                where libname='WORK' and memname=upcase("&domain")) b
                on a.varnum=b.varnum)
        ;
quit;

data &domain;
    set &domain;
    array vlst{*} _character_;
    do num=1 to dim(vlst);
        vlst(num)=compbl(prxchange('s/\n|\r/ /', -1, vlst(num)));
        vlst(num)=compress(vlst(num), , 'kw');
    end;
    if B="&domain" and ^missing(D);
run;

data &domain;
    length &llist VARKEY $2 CRFPAGE $200;
    set &domain;
    &alist CRFPAGE=cats(S);
    VARKEY=cats(N);
    keep &vlist CRFPAGE VARKEY;
run;

%mend loop;


data _null_;
    set domain_lst;
    call execute('%nrstr(%loop(i='||cats(i)||',domain='||cats(dataset)||',range='||cats(range)||'))');
run;

/*Domain list*/
proc sql noprint;
    select dataset into :dlist separated by ' '
    from domain_lst
    order by i;
quit;

/*To get attribute statement*/
%attrib(metad=vardef)

/*Output VARDEF*/
data qmeta.vardef(label="Variable Level Metadata" drop=II);
    attrib &vardef_attri CRFPAGE label='CRF Page Number' VARKEY label='Logical Key Order';
    set &dlist;
    VARORDER=put(input(VARORDER,best.),z3.);
    label CODELST='Codelist Name';
       if CODELST = "ISO 8601" and (DATATYPE in ("date", "time", "datetime") or reverse(substr(reverse(strip(VARNAME)),1,3))='DUR')
        then CODELST = "";
run;

/*Remove FORMAT and INFORMAT*/
proc datasets lib=qmeta nolist;
    modify vardef;
    attrib _all_ format= informat=;
quit;

/*Sort*/
proc sort data=qmeta.vardef;
    by dataset;
run;

************************************************************
*  Compare Main domain and QC domain                       *
************************************************************;
%let GMPXLERR=0;
%GmCompare( pathOut      =  &_qtransfer
          , dataMain      =  meta.studydef
          , libraryQC     =  qmeta
          );

%GmCompare( pathOut      =  &_qtransfer
          , dataMain      =  meta.datadef
          , libraryQC     =  qmeta
          );

%GmCompare( pathOut      =  &_qtransfer
          , dataMain      =  meta.vardef
          , libraryQC     =  qmeta
          );

%GmCompare( pathOut      =  &_qtransfer
          , dataMain      =  meta.valdef
          , libraryQC     =  qmeta
          );

%GmCompare( pathOut      =  &_qtransfer
          , dataMain      =  meta.cd
          , libraryQC     =  qmeta
          );

%GmCompare( pathOut      =  &_qtransfer
          , dataMain      =  meta.compmeth
          , libraryQC     =  qmeta
          );

/*End of Program*/
