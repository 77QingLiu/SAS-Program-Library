/*-------------------------------------------------------------------------------------
PAREXEL INTERNATIONAL LTD

Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
PXL Study Code:        222354

SAS Version:           9.2
Operating System:      UNIX
---------------------------------------------------------------------------------------

Author:                Harold Xu, Carlos Pang and Allen Zeng $LastChangedBy: $
Creation Date:         22Jul2014 / $LastChangedDate: $

Program Location/name: $HeadURL: $

Files Created:         jjchkother.log
                       PXLTimeCode_OtherChk_yyyymmdd.xml

Program Purpose:       To validate SDTM datasets and produce a XML report

Macro Parameters:      SLIB      = Library name of SDTM datasets

                       MLIB      = Library name of study metadata datasets

                       OUTDIR = Full path specifying location of the output file.
                                NB: Unix file and directory names are case sensitive.
                                <default = _tglobal>

                       OUTPUT    = File name of the summary output.

--------------------------------------------------------------------------------------
MODIFICATION HISTORY:  Subversion $Rev: $
--------------------------------------------------------------------------------------

/*Start programming*/
proc datasets nolist lib=work memtype=data kill;
quit;

options NOQUOTELENMAX;

%macro jjchkother(slib=transfer
                 , mlib=meta
                 , outdir= _tglobal
                 , output=OtherChk
                  );

/**************************************** Check030114 ****************************************/
proc sql;
    /*Meatdata ariable type list*/
    create table mvardef as
        select dataset as memname length=20, varname as name length=20,
              case when datatype in ('float','integer') then 'num'
                   when datatype in ('text','datetime') then 'char'
                   else ''
              end as mtype
        from &mlib..vardef
        order by 1,2;

    /*Study datasets variable type list*/
    create table svardef as
        select distinct memname length=20 ,name length=20,type as stype
        from dictionary.columns
        where libname=upcase("&slib");
quit;

/*Check*/
data vartype;
    if _n_=1 then do;
        if 0 then set mvardef;
        dcl hash h(dataset:'mvardef');
        h.definekey('memname','name');
        h.definedata(all:'Y');
        h.definedone();
    end;
    set svardef;
    if h.find() eq 0 then do;
        if mtype ne stype and mtype^='' then do;
            length checkid domain category details $200;
            domain=memname;
            category="";
            details="The datatype of column "||strip(name)||
                    " in the SAS dataset is different from the datatype of this column in the Define.xml.";
            checkid="Check030114";
            keep domain category details checkid;
            output;
        end;
     end;
run;

/**************************************** Check030271 ****************************************/
%macro comchk(chkid=,subid=);
/*Variable definition*/
data vardef;
    length dataset $200;
    set &mlib..vardef;
    if not missing(compmeth);
    comvar=scan(compmeth,2,'.');
    keep dataset varname comvar;
    proc sort nodupkey;
    by comvar;
run;

/*computation method definition*/
data compemeth;
    set &mlib..compmeth end=eof;
    mthnam=scan(mthnam,2,'.');
    keep mthnam;
run;

/*Check*/
proc sql noprint;
    select distinct %if &subid=1 %then mthnam; %else comvar; into :cmlist separated by '","'
        from %if &subid=1 %then compemeth;
             %else vardef;;
quit;

data mdata&chkid.&subid;
    set %if &subid=1 %then vardef;
        %else compemeth;;
    if %if &subid=1 %then comvar; %else mthnam; not in ("&cmlist") then do;
        length checkid domain category details $200;
        category="";
        domain=%if &subid=1 %then dataset; %else "";;
        %if &subid=1 %then details="A COMPUTATIONAL ALGORITHM "||strip(comvar)||
                                   " is attached to a variable or VLM value, but it is not present in the list of algorithms in define.xml.";
        %else %if &subid=2 %then details="A COMPUTATIONAL ALGORITHM "||strip(mthnam)||
                                         " is present in the list of algorithms in define.xml, but it is not attached to a variable or VLM value.";;
        checkid="Check030&chkid";
        keep checkid domain category details;
        output;
    end;
run;
%mend comchk;

%comchk(chkid=271,subid=1);
%comchk(chkid=271,subid=2);

/**************************************** Check030275 ****************************************/
%let dmn=dm;
%let chk=Check030275;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   strip(name)||" is other variable added to the SDTMIG model, except for VISITNUM, VISIT, VISITDY and DMXFN"
           as Details format=$200.,
           "&chk" as CheckID format=$200.
      from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          name not in ( "STUDYID",
                                        "DOMAIN",
                                        "USUBJID",
                                        "SUBJID",
                                        "RFSTDTC",
                                        "RFENDTC",
                                        "RFXSTDTC",
                                        "RFXENDTC",
                                        "RFICDTC",
                                        "RFPENDTC",
                                        "DTHDTC",
                                        "DTHFL",
                                        "SITEID",
                                        "INVID",
                                        "INVNAM",
                                        "BRTHDTC",
                                        "AGE",
                                        "AGETXT",
                                        "AGEU",
                                        "SEX",
                                        "RACE",
                                        "ETHNIC",
                                        "SPECIES",
                                        "STRAIN",
                                        "SBSTRAIN",
                                        "ARMCD",
                                        "ARM",
                                        "ACTARMCD",
                                        "ACTARM",
                                        "COUNTRY",
                                        "DMXFN",     /*Additional Permissible Variable*/
                                        "VISITNUM",  /*Additional Permissible Variable*/
                                        "VISIT",     /*Additional Permissible Variable*/
                                        "VISITDY",   /*Additional Permissible Variable*/
                                        "DMDTC",
                                        "DMDY"
                                         );
quit;

/**************************************** Check030276? ****************************************/
%let dmn=co;
%let chk=Check030276;
proc sql noprint;
    select distinct name into: varlist separated by ","
               from dictionary.columns
               where libname=upcase("&slib") and memname=upcase("&dmn");

    select prxchange("s/(\S+)/~/",-1,cats(RDOMAIN)) into :rvalue
        from &slib..&dmn;
quit;

%let varl=COGRPID|COREFID|COSPID|VISIT|VISITNUM|VISITDY|TAETORD|CODY|COTPT|COTPTNUM|COELTM|COTPTREF|CORFTDTC;

data &chk;
    if "%sysfunc(compress(&rvalue,%str(. )))"="" and
        prxmatch("/(&varl)/","&varlist") then do;
        length checkid domain category details $200;
        domain="&dmn";
        category="";
        details="The Use of this variable is not allowed in domain CO when RDOMAIN is completed.";
        checkid="&chk";
    end;
run;

/**************************************** Check030277? ****************************************/
%let dmn=se;
%let chk=Check030277;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   strip(name)||" is other identifier variable added to the SDTM IG model except for GRPID, REFID, SPID" as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          name not in ( "STUDYID",
                                        "DOMAIN",
                                        "USUBJID",
                                        "SESEQ",
                                        "SEGRPID",  /*Identifier Variables*/
                                        "SEREFID",  /*Identifier Variables*/
                                        "SESPID",   /*Identifier Variables*/
                                        "ETCD",
                                        "ELEMENT",
                                        "SESTDTC",
                                        "SEENDTC",
                                        "TAETORD",
                                        "EPOCH",
                                        "SEUPDES",
                                        "VISITNUM",
                                        "VISIT",
                                        "VISITDY",
                                        "SEDTC",
                                        "SEDY",
                                        "SESTDY",
                                        "SEENDY",
                                        "SEDUR",
                                        "SETPT",
                                        "SETPTNUM",
                                        "SEELTM",
                                        "SETPTREF",
                                        "SERFTDTC",
                                        "SESTRF",
                                        "SEENRF",
                                        "SEEVLINT",
                                        "SESTRTPT",
                                        "SESTTPT",
                                        "SEENRTPT",
                                        "SEENTPT");
quit;

/**************************************** Check030278? ****************************************/
%let dmn=se;
%let chk=Check030278;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   "Timing variable "||strip(name)||" is not added to the SDTMIG model" as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          substr(name, 3) in ("TPT", "TPTNUM", "ELTM", "TPTREF", "RFTDTC");
quit;

/**************************************** Check030279 ****************************************/
%let dmn=sv;
%let chk=Check030279;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   strip(name)||" is other identifier variable added to the SDTM IG model." as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          name not in ( "STUDYID",
                                        "DOMAIN",
                                        "USUBJID",
                                        "POOLID",
                                        "SVSEQ",    /*Identifier Variables*/
                                        "SVGRPID",  /*Identifier Variables*/
                                        "SVREFID",  /*Identifier Variables*/
                                        "SVSPID",   /*Identifier Variables*/
                                        "VISITNUM",
                                        "VISIT",
                                        "VISITDY",
                                        "TAETORD",
                                        "EPOCH",
                                        "SVDTC",
                                        "SVSTDTC",
                                        "SVENDTC",
                                        "SVDY",
                                        "SVSTDY",
                                        "SVENDY",
                                        "SVDUR",
                                        "SVTPT",
                                        "SVTPTNUM",
                                        "SVELTM",
                                        "SVTPTREF",
                                        "SVRFTDTC",
                                        "SVSTRF",
                                        "SVENRF",
                                        "SVSTRTPT",
                                        "SVSTTPT",
                                        "SVENRTPT",
                                        "SVENTPT",
                                        "SVUPDES");
quit;

/**************************************** Check030280 ****************************************/
%let dmn=sv;
%let chk=Check030280;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   "Timing variable "||strip(name)||" is added to the SDTMIG model" as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          substr(name, 3) in ("TPT", "TPTNUM", "ELTM", "TPTREF", "RFTDTC");
quit;

/**************************************** Check030281 ****************************************/
%let dmn=ex;
%let chk=Check030281;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   strip(name)||" is added to the SDTMIG model." as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          substr(name, 3) in ("PRESP", "OCCUR", "STAT", "REASND");
quit;

/**************************************** Check030282 ****************************************/
%let dmn=ae;
%let chk=Check030282;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   strip(name)||" is added to the SDTMIG model." as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          substr(name, 3) in ("OCCUR", "STAT", "REASND");
quit;

/**************************************** Check030283 ****************************************/
%let dmn=ds;
%let chk=Check030283;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   strip(name)||" is added to the SDTMIG model." as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          substr(name, 3) in ( "PRESP",
                                               "OCCUR",
                                               "STAT",
                                               "REASND",
                                               "BODSYS",
                                               "LOC",
                                               "SEV",
                                               "SER",
                                               "ACN",
                                               "ACNOTH",
                                               "REL",
                                               "RELNST",
                                               "PATT",
                                               "OUT",
                                               "SCAN",
                                               "SCONG",
                                               "SDISAB",
                                               "SDTH",
                                               "SHOSP",
                                               "SLIFE",
                                               "SOD" );
quit;

/**************************************** Check030284 ****************************************/
%let dmn=mh;
%let chk=Check030284;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   strip(name)||" is added to the SDTMIG model." as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          substr(name, 3) in ( "SER",
                                               "ACN",
                                               "ACNOTH",
                                               "REL",
                                               "RELNST",
                                               "OUT",
                                               "SCAN",
                                               "SCONG",
                                               "SDISAB",
                                               "SDTH",
                                               "SHOSP",
                                               "SLIFE",
                                               "SOD",
                                               "SMIE" );
quit;

/**************************************** Check030285 ****************************************/
%let dmn=dv;
%let chk=Check030285;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   strip(name)||" is added to the SDTMIG model." as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          substr(name, 3) in ( "PRESP",
                                               "OCCUR",
                                               "STAT",
                                               "REASND",
                                               "BODSYS",
                                               "LOC",
                                               "SEV",
                                               "SER",
                                               "ACN",
                                               "ACNOTH",
                                               "REL",
                                               "RELNST",
                                               "PATT",
                                               "OUT",
                                               "SCAN",
                                               "SCONG",
                                               "SDISAB",
                                               "SDTH",
                                               "SHOSP",
                                               "SLIFE",
                                               "SOD" );
quit;

/**************************************** Check030286 ****************************************/
%let dmn=ce;
%let chk=Check030286;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   strip(name)||" is added to the SDTMIG model." as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          substr(name, 3) in ( "SER",
                                               "ACN",
                                               "ACNOTH",
                                               "REL",
                                               "RELNST",
                                               "OUT",
                                               "SCAN",
                                               "SCONG",
                                               "SDISAB",
                                               "SDTH",
                                               "SHOSP",
                                               "SLIFE",
                                               "SOD",
                                               "SMIE" );
quit;

/**************************************** Check030287 ****************************************/
%let dmn=eg;
%let chk=Check030287;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   strip(name)||" is added to the SDTMIG model." as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          substr(name, 3) in ( "MODIFY",
                                               "BODSYS",
                                               "SPEC",
                                               "SPCNND",
                                               "FAST",
                                               "SEV" );
quit;

/**************************************** Check030288 ****************************************/
%let dmn=eg;
%let chk=Check030288;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   strip(name)||" is used." as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          substr(name, 3) eq "LOINC";
quit;

/**************************************** Check030289 ****************************************/
%let dmn=ie;
%let chk=Check030289;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   strip(name)||" is added to the SDTMIG model." as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          substr(name, 3) in ( "MODIFY",
                                               "POS",
                                               "BODSYS",
                                               "ORRESU",
                                               "ORNRLO",
                                               "ORNRHI",
                                               "STRESN",
                                               "STRESU",
                                               "STNRLO",
                                               "STNRHI",
                                               "STNRC",
                                               "NRIND",
                                               "RESCAT",
                                               "XFN",
                                               "NAM",
                                               "LOINC",
                                               "SPEC",
                                               "SPCCND",
                                               "LOC",
                                               "M" );
quit;

/**************************************** Check030290 ****************************************/
%let dmn=lb;
%let chk=Check030290;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   strip(name)||" is added to the SDTMIG model." as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          substr(name, 3) in ("BODSYS", "SEV");
quit;

/**************************************** Check030291 ****************************************/
%let dmn=pe;
%let chk=Check030291;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   strip(name)||" is added to the SDTMIG model." as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          substr(name, 3) in ("XFN", "NAM", "LOINC", "FAST", "TOX", "TOXGR");
quit;

/**************************************** Check030292 ****************************************/
%let dmn=qs;
%let chk=Check030292;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   strip(name)||" is added to the SDTMIG model." as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          substr(name, 3) in ( "POS",
                                               "BODSYS",
                                               "ORNRLO",
                                               "ORNRHI",
                                               "STNRLO",
                                               "STNRHI",
                                               "STRNC",
                                               "NRIND",
                                               "RESCAT",
                                               "XFN",
                                               "LOINC",
                                               "SPEC",
                                               "SPCCND",
                                               "LOC",
                                               "METHOD",
                                               "FAST",
                                               "TOX",
                                               "TOXGR",
                                               "SEV" );
quit;

/**************************************** Check030293 ****************************************/
%let dmn=sc;
%let chk=Check030293;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   strip(name)||" is added to the SDTMIG model." as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          substr(name, 3) in ( "MODIFY",
                                               "POS",
                                               "BODSYS",
                                               "ORNRLO",
                                               "ORNRHI",
                                               "STNRLO",
                                               "STNRHI",
                                               "STNRC",
                                               "NRIND",
                                               "RESCAT",
                                               "XFN",
                                               "NAM",
                                               "LOINC",
                                               "SPEC",
                                               "SPCCND",
                                               "METHOD",
                                               "BLFL",
                                               "FAST",
                                               "DRVRL",
                                               "TOX" );
quit;

/**************************************** Check030294 ****************************************/
%let dmn=vs;
%let chk=Check030294;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   strip(name)||" is added to the SDTMIG model." as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          substr(name, 3) in ( "BODSYS", "XFN", "SPEC", "SPCCND", "FAST", "TOX", "TOXGR" );
quit;

/**************************************** Check030295 ****************************************/
%let dmn=da;
%let chk=Check030295;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   strip(name)||" is added to the SDTMIG model." as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          substr(name, 3) in ( "MODIFY",
                                               "POS",
                                               "BODSYS",
                                               "ORNRLO",
                                               "ORNRHI",
                                               "STNRLO",
                                               "STNRHI",
                                               "STNRC",
                                               "NRIND",
                                               "RESCAT",
                                               "XFN",
                                               "NAM",
                                               "LOINC",
                                               "SPEC",
                                               "SPCCND",
                                               "METHOD",
                                               "BLFL",
                                               "FAST",
                                               "DRVRL",
                                               "TOX" );
quit;

/**************************************** Check030296 ****************************************/
%let dmn=mb;
%let chk=Check030296;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   strip(name)||" is added to the SDTMIG model." as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          substr(name, 3) in ( "MODIFY", "BODSYS", "FAST", "TOX", "TOXGR", "SEV" );
quit;

/**************************************** Check030297 ****************************************/
%let dmn=ms;
%let chk=Check030297;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   strip(name)||" is added to the SDTMIG model." as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          substr(name, 3) in ( "MODIFY", "BODSYS", "SPEC", "SPCCND", "FAST", "TOX", "TOXGR", "SEV" );
quit;

/**************************************** Check030298 ****************************************/
%let dmn=pc;
%let chk=Check030298;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   strip(name)||" is added to the SDTMIG model." as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          substr(name, 3) in ( "BODSYS", "SEV" );
quit;

/**************************************** Check030299 ****************************************/
%let dmn=pp;
%let chk=Check030299;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   strip(name)||" is added to the SDTMIG model." as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          substr(name, 3) in ( "BODSYS", "SEV" );
quit;

/**************************************** Check030424 ****************************************/
%let dmn=fa;
%let chk=Check030424;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   strip(name)||" is not present in the table listed in GS SDTMIG table." as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          name not in ( 'STUDYID',
                                        'DOMAIN',
                                        'USUBJID',
                                        'POOLID',
                                        'FASEQ',
                                        'FAGRPID',
                                        'FAREFID',
                                        'FASPID',
                                        'FALNKID',
                                        'FALNKGRP',
                                        'VISITNUM',
                                        'VISIT',
                                        'VISITDY',
                                        'TAETORD',
                                        'EPOCH',
                                        'FADTC',
                                        'FASTDTC',
                                        'FAENDTC',
                                        'FADY',
                                        'FASTDY',
                                        'FAENDY',
                                        'FADUR',
                                        'FATPT',
                                        'FATPTNUM',
                                        'FAELTM',
                                        'FATPTREF',
                                        'FARFTDTC',
                                        'FASTRF',
                                        'FAENRF',
                                        'FAEVLINT',
                                        'FASTRTPT',
                                        'FASTTPT',
                                        'FAENRTPT',
                                        'FAENTPT',
                                        'FADETECT',
                                        'FATESTCD',
                                        'FATEST',
                                        'FAMODIFY',
                                        'FACAT',
                                        'FASCAT',
                                        'FAPOS',
                                        'FABODSYS',
                                        'FAORRES',
                                        'FAORRESU',
                                        'FAORNRLO',
                                        'FAORNRHI',
                                        'FASTRESC',
                                        'FASTRESN',
                                        'FASTRESU',
                                        'FASTNRLO',
                                        'FASTNRHI',
                                        'FASTNRC',
                                        'FANRIND',
                                        'FARESCAT',
                                        'FASTAT',
                                        'FAREASND',
                                        'FAXFN',
                                        'FANAM',
                                        'FALOINC',
                                        'FASPEC',
                                        'FAANTREG',
                                        'FASPCCND',
                                        'FASPCUFL',
                                        'FALOC',
                                        'FALAT',
                                        'FADIR',
                                        'FAPORTOT',
                                        'FAMETHOD',
                                        'FALEAD',
                                        'FACASTATE',
                                        'FABLFL',
                                        'FAFAST',
                                        'FADRVFL',
                                        'FAEVAL',
                                        'FAEVALID',
                                        'FAACPTFL',
                                        'FATOX',
                                        'FATOXGR',
                                        'FASEV',
                                        'FADTHREL',
                                        'FALLOQ',
                                        'FAEXCLFL',
                                        'FAREASEX',
                                        'FAOBJ',
                                                         );
quit;


/**************************************** Check030431 ****************************************/
%let dmn=fa;
%let chk=Check030431;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   strip(name)||" is added to the SDTMIG model." as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          substr(name, 3) in ( "BODSYS", "MODIFY", "SEV", "TOXGR" );
quit;

/**************************************** Check030442 ****************************************/
%let dmn=sv;
%let chk=Check030442;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   strip(name)||" is added to the SDTMIG model." as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          substr(name, 3) in ( "TPT", "TPTNUM", "ELTM", "TPTREF", "RFTDTC" );
quit;

/**************************************** Check030735 ****************************************/
%let dmn=sv;
%let chk=Check030735;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   "SV."||strip(name)||" is present in the SDTMIG model." as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          substr(name, 3) in ( "STRF", "ENRF" );
quit;

/**************************************** Check030736 ****************************************/
%let dmn=sv;
%let chk=Check030736;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   "SV."||strip(name)||" is present in the SDTMIG model." as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          substr(name, 3) in ( "STRTPT", "ENRTPT", "ENTPT" );
quit;

/**************************************** Check017101 (Part 1) ****************************************/
%let dmn=ae;
%let chk=Check017101a;
proc sql noprint;
  select distinct name
    into: nmisslist separated by ", "
          from DICTIONARY.COLUMNS
            where libname=upcase("&slib") and
                  memname=upcase("&dmn") and
                          name in ("AESER", "AEACN", "AEACNOTH", "AEREL", "AERELNST", "AETOXGR", "AESEV");
quit;
%put nmisslist=&nmisslist;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   "Critical data fields missing in AE dataset: USUBJID="||strip(usubjid)||", AESEQ="||put(aeseq, 1.)  as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from &slib..&dmn
            where cmiss(&nmisslist) ne 0;
quit;

/**************************************** Check017101? (Part 2) ****************************************/
%let dmn=suppae;
%let chk=Check017101b;

/**************************************** Check017102 ****************************************/
%let dmn=ae;
%let chk=Check017102;
proc sql;
  create table &chk as
    select upcase("&dmn") as Domain format=$200.,
           "" as Category format=$200.,
                   "Level of Coding Missing: USUBJID="||strip(usubjid)||", AESEQ="||put(aeseq, 1.) as Details format=$200.,
                   "&chk" as CheckID format=$200.
      from &slib..&dmn
            where aedecod ne "" and cmiss(AELLT, AELLTCD, AEHLT, AEHLGT, AEBODSYS) ne 0;
quit;

/**************************************** Check030490 ****************************************/
%let chk=Check030490;
proc sql noprint;
  create table &chk as
    select memname as Domain format=$200.,
               "" as Category format=$200.,
                   "Dataset "||strip(memname)||" exists that "||substr(memname, 1, 2)||" NOT IN {CO, DM, SE, SV, TI, TE, TS, TV}"
                    as Details format=$200.,
                   "&chk" as CheckID format=$200.
          from DICTIONARY.TABLES
            where libname=upcase("&slib") and
                      length(memname) in (3, 4) and
                      substr(memname, 1 , 2) not in ("CO", "DM", "SE", "SV", "TI", "TE", "TS", "TV");
quit;

/**************************************** Check030490 ****************************************/
%let chk=Check030491;
proc sql noprint;
  create table &chk as
    select memname as Domain format=$200.,
           "" as Category format=$200.,
           "Dataset "||strip(memname)||" exists that "||substr(memname, 1, 2)||" NOT IN {CO, DM, SE, SV, TI, TE, TS, TV}"
           as Details format= $200.,
           "&chk" as CheckID format=$200.
          from DICTIONARY.TABLES
            where libname=upcase("&slib") and
                      length(memname) in (3, 4) and
                      substr(memname, 1 , 2) not in ( select memname
            from DICTIONARY.TABLES
                where libname=upcase("&slib") and
                           length(memname)
                                                                                        );
quit;

/**************************************** Check030490 ****************************************/
%let chk=Check030740;
%global a b;
proc sql noprint;
  select memname into: a from DICTIONARY.TABLES where libname=upcase("&slib") and memname="PP";
  select memname into: b from DICTIONARY.TABLES where libname=upcase("&slib") and memname="PC";
quit;
%put a=&a;
%put b=&b;
%macro temp;
%if &a=PP %then %do;
  %if &b= %then %do;
    data &chk;
          format Domain Category Details CheckID $ 200;
          Domain="PP";
          Category="";
          Details="Dataset PP is present that dataset PC is not present";
          CheckID="&chk";
        run;
  %end;
%end;
%mend temp;
%temp


%let _dm=&slib;
%let _meta=&mlib;

***************************************************;
****************Part 1*****************************;
***************************************************;

%macro cdisc1(CheckId=,Rule=,Domain=,VarC=,VarN=);
  %if %sysfunc(exist(&_dm..&Domain)) %then %do;
    data out1;
      length Domain Category Details CheckId &VarC. $200 ;
      call missing(Domain,Category,Details,CheckId);
      set &_dm..&Domain;
      %do i=1 %to %eval(%sysfunc(count(&VarC.,%str( )))+1);
        if %scan(&VarC.,&i.,%str( ))='' then %scan(&VarC.,&i.,%str( ))='';
      %end;
          %if "&VarN."^="" %then %do;
              %do i=1 %to %eval(%sysfunc(count(&VarN.,%str( )))+1);
                if %scan(&VarN.,&i.,%str( ))=. then %scan(&VarN.,&i.,%str( ))=.;
              %end;
          %end;
      if &Rule. then do;
        Domain="&Domain.";
        CheckId="&CheckId.";
        Details="Obs "||strip(put(_n_,best.));
        %do i=1 %to %eval(%sysfunc(count(&VarC.,%str( )))+1);
          Details=trim(Details)||" %scan(&VarC.,&i.,%str( ))=";
          Details=trim(Details)||'"'||trim(%scan(&VarC.,&i.,%str( )))||'"';
        %end;
                %if "&VarN."^="" %then %do;
                %do i=1 %to %eval(%sysfunc(count(&VarN.,%str( )))+1);
                  Details=trim(Details)||" %scan(&VarN.,&i.,%str( ))=";
                  Details=trim(Details)||trim(put(%scan(&VarN.,&i.,%str( )),best.));
                %end;
                %end;
        output;
      end;
    proc sort nodupkey; by Domain Category Details CheckId; run;
    data out2(keep=Domain Category Details CheckId);
      set out out1;
    run;
    data out;
      set out2;
    run;
  %end;
%mend;
data out;
  length Domain Category Details CheckId $200;
  call missing(Domain,Category,Details,CheckId);
run;


%cdisc1(CheckId=Check030003_2, Rule=%str((AESCAN='Y' or AESCONG='Y' or AESDISAB='Y' or AESDTH='Y' or AESHOSP='Y' or AESLIFE='Y' or AESMIE='Y' or AESOD='Y') and AESER^='Y'), Domain=AE
, VarC=%str(AESCAN AESCONG AESDISAB AESDTH AESHOSP AESLIFE AESMIE AESOD AESER));
%cdisc1(CheckId=Check030015_4, Rule=%str(^MISSING(IDVAR) and MISSING(IDVARVAL)), Domain=CO, VarC=%str(IDVAR IDVARVAL));
%cdisc1(CheckId=Check030015_5, Rule=%str(MISSING(IDVAR) and ^MISSING(IDVARVAL)), Domain=CO, VarC=%str(IDVAR IDVARVAL));
%cdisc1(CheckId=Check030024, Rule=%str(length(IETEST)<=200), Domain=IE, VarC=%str(IETEST));
%cdisc1(CheckId=Check030226_2, Rule=%str(^missing(SEUPDES) and ETCD^='UNPLAN'), Domain=SE, VarC=%str(SEUPDES ETCD));
%cdisc1(CheckId=Check030400, Rule=%str(ARMCD in ('SCRNFAIL','NOTASSGN') and ^missing(RFSTDTC)), Domain=DM, VarC=%str(ARMCD RFSTDTC));
%cdisc1(CheckId=Check030401, Rule=%str(ARMCD in ('SCRNFAIL','NOTASSGN') and ^missing(RFENDTC)), Domain=DM, VarC=%str(ARMCD RFENDTC));
%cdisc1(CheckId=Check030405_2, Rule=%str(missing(ELEMENT) and ETCD^='UNPLAN'), Domain=SE, VarC=%str(ELEMENT ETCD));
%cdisc1(CheckId=Check030478_1, Rule=%str(QLABEL^='Race, Other' and QNAM = 'RACEOTH'), Domain=SUPPDM, VarC=%str(QLABEL QNAM));
%cdisc1(CheckId=Check030478_2, Rule=%str(QLABEL='Race, Other' and QNAM^='RACEOTH'), Domain=SUPPDM, VarC=%str(QLABEL QNAM));
%cdisc1(CheckId=Check017105, Rule=%str((AESCAN = 'Y' or AESOD = 'Y' or AESCONG='Y' or AESDISAB='Y' or AESDTH='Y' or AESHOSP='Y' or AESLIFE='Y' or AESMIE='Y' or AESOSP = 'Y' or AEHOSPP = 'Y' or AEHOSPR = 'Y' or AETRLPRC = 'Y') and AESER^='Y'), Domain=AE
, VarC=%str(AESCAN AESOD AESCONG AESDISAB AESDTH AESHOSP AESLIFE AESMIE AESOSP AEHOSPP AEHOSPR AETRLPRC AESER));
%cdisc1(CheckId=Check017113_1, Rule=%str(AEOUT='FATAL' and DSDECOD^='DEATH'), Domain=AE, VarC=%str(AEOUT DSDECOD));
%cdisc1(CheckId=Check017113_2, Rule=%str(DSDECOD='DEATH' and AEOUT^='FATAL'), Domain=AE, VarC=%str(DSDECOD AEOUT));
%cdisc1(CheckId=Check017114, Rule=%str(^missing(AEENDTC) and AEOUT not in ('RECOVERED/RESOLVED','RECOVERED/RESOLVED WITH SEQUELAE')), Domain=AE, VarC=%str(AEENDTC AEOUT));
%cdisc1(CheckId=Check017115, Rule=%str(missing(AEENDTC) and AEOUT not in ('FATAL','RECOVERING/RESOLVING','NOT RECOVERED/NOT RESOLVED','UNKNOWN')), Domain=AE, VarC=%str(AEENDTC AEOUT));
%cdisc1(CheckId=Check017126_1, Rule=%str(^missing(CMTRT) and missing(CMDECOD)), Domain=CM, VarC=%str(CMTRT CMDECOD));
%cdisc1(CheckId=Check017126_2, Rule=%str(missing(CMTRT) and ^missing(CMDECOD)), Domain=CM, VarC=%str(CMTRT CMDECOD));
%cdisc1(CheckId=Check017127, Rule=%str(^missing(CMDECOD) and (missing(CMCLAS) or missing(CMCLASCD) or missing(CMLVL2) or missing(CMLVL2CD))), Domain=CM, VarC=%str(CMDECOD CMCLAS CMCLASCD CMLVL2 CMLVL2CD));
%cdisc1(CheckId=Check017131, Rule=%str(USUBJID^=catx('-',STUDYID,SITEID,SUBJID)), Domain=DM, VarC=%str(USUBJID STUDYID SITEID SUBJID));
%cdisc1(CheckId=Check017161, Rule=%str(missing(RDOMAIN) and (^missing(IDVAR) or ^missing(IDVARVAL))), Domain=CO, VarC=%str(RDOMAIN IDVAR IDVARVAL));
%cdisc1(CheckId=Check030413, Rule=%str(AEOCCUR='N' ), Domain=AE, VarC=%str(AEOCCUR));
*%cdisc1(CheckId=Check030425, Rule=%str(mod(TAETORD,1)=0), Domain=TA, VarC=%str(TAETORD));
%cdisc1(CheckId=Check030504_2, Rule=%str(DSDECOD='DEATH' and missing(DTHFL)), Domain=DS, VarC=%str(DSDECOD DTHFL));
%cdisc1(CheckId=Check017102, Rule=%str(^missing(AEDECOD) and (missing(AELLT) or missing(AELLTCD) or missing(AEHLT) or missing(AEHLGT) or missing(AEBODSYS) or missing(AEDICTVS))), Domain=AE, VarC=%str(AEDECOD AELLT AEHLT AEHLGT AEBODSYS AEDICTVS)
, VarN=AELLTCD);
%cdisc1(CheckId=Check030750, Rule=%str(TSPARMCD='RANDOM' and TSVAL not in ('N','NA','U','Y')), Domain=TS, VarC=%str(TSPARMCD TSVAL));
%cdisc1(CheckId=Check030032, Rule=%str(ETCD^='UNPLAN'), Domain=TA, VarC=%str(ETCD));
%cdisc1(CheckId=Check030032, Rule=%str(ETCD^='UNPLAN'), Domain=TE, VarC=%str(ETCD));
%cdisc1(CheckId=Check017101, Rule=%str((qnam="AEACNS1" and qval="") or (qnam="AEACNS2" and qval="") or (qnam="AEACNS3" and qval="") or (qnam="AEACNS4" and qval="") or (qnam="AEACNO1" and qval="") or (qnam="AEACNO2" and qval="")
or (qnam="AEACNO3" and qval="") or (qnam="AEACNO4" and qval="") or (qnam="AERELS1" and qval="") or (qnam="AERELS2" and qval="") or (qnam="AERELS3" and qval="") or (qnam="AERELS4" and qval="") or (qnam="AERELO1" and qval="")
or (qnam="AERELO2" and qval="") or (qnam="AERELO3" and qval="") or (qnam="AERELO4" and qval="")), Domain=SUPPAE, VarC=%str(QNAM QVAL));
%cdisc1(CheckId=Check030276, Rule=%str(RDOMAIN^="" and (COGRPID^="" or COREFID^="" or COSPID^="" or VISIT^="" or TAETORD^="" or COTPT^="" or COELTM^="" or COTPTREF^="" or CORFTDTC^="" or VISITNUM^=. or VISITDY^=. or CODY^=. or COTPTNUM^=.)), Domain=CO
, VarC=%str(COGRPID COREFID COSPID VISIT TAETORD COTPT COELTM COTPTREF CORFTDTC), VarN=VISITNUM VISITDY CODY COTPTNUM);

data val_out1; set out; run;

***************************************************;
****************Part 2*****************************;
***************************************************;
%macro GT(L,R);
(substr(&L.||repeat(' ',10),1,4)>substr(&R.||repeat(' ',10),1,4)
or (substr(&L.||repeat(' ',10),1,4)=substr(&R.||repeat(' ',10),1,4)
        and substr(&L.||repeat(' ',10),6,2)>substr(&R.||repeat(' ',10),6,2)>'' )
or (substr(&L.||repeat(' ',10),1,4)=substr(&R.||repeat(' ',10),1,4)
        and substr(&L.||repeat(' ',10),6,2)=substr(&R.||repeat(' ',10),6,2)
        and substr(&L.||repeat(' ',10),9,2)>substr(&R.||repeat(' ',10),9,2)>'' ) )
%mend;

%macro EQ(L,R);
(length(&L.)>length(&R.) and substr(&L.||repeat(' ',10),1,4)=substr(&R.||repeat(' ',10),1,4)
and (substr(&L.||repeat(' ',10),6,2)=substr(&R.||repeat(' ',10),6,2) or substr(&R.||repeat(' ',10),6,2)='')
and (substr(&L.||repeat(' ',10),9,2)=substr(&R.||repeat(' ',10),9,2) or substr(&R.||repeat(' ',10),9,2)='') )
%mend;

%macro cdisc2(CheckId=,Rule=,Domain=,VarBy=USUBJID,VarC=,VarN=);
%if %sysfunc(exist(&_dm..&Domain)) %then %do;
        proc sort data=&_dm..&Domain out=&Domain; by &VarBy;
        proc sort data=base1; by &VarBy;
        data out1;
          length Domain Category Details CheckId &VarC. $200;
          merge &Domain(in=in1) base1(in=in_base1);
          by &VarBy;
          call missing(Domain,Category,Details,CheckId);
          %if &VarC.^= %then %do;
          %do i=1 %to %eval(%sysfunc(count(&VarC.,%str( )))+1);
            if missing(%scan(&VarC.,&i.,%str( ))) then %scan(&VarC.,&i.,%str( ))='';
          %end;
          %end;
          %if &VarN.^= %then %do;
          %do i=1 %to %eval(%sysfunc(count(&VarN.,%str( )))+1);
            if missing(%scan(&VarN.,&i.,%str( ))) then %scan(&VarN.,&i.,%str( ))=.;
          %end;
          %end;
          if &Rule. and in1 and &in_out.-in_base1 then do;
            *Domain="&Domain.";
            Domain="";
            CheckId="&CheckId.";
            *Details="Obs "||strip(put(_n_,best.));
                        %if &VarC.^= %then %do;
                    %do i=1 %to %eval(%sysfunc(count(&VarC.,%str( )))+1);
                      Details=trim(Details)||" %scan(&VarC.,&i.,%str( ))=";
                      Details=trim(Details)||'"'||trim(%scan(&VarC.,&i.,%str( )))||'"';
                    %end;
                        %end;
                        %if &VarN.^= %then %do;
                    %do i=1 %to %eval(%sysfunc(count(&VarN.,%str( )))+1);
                      Details=trim(Details)||" %scan(&VarN.,&i.,%str( ))=";
                      Details=trim(Details)||'"'||strip(put(%scan(&VarN.,&i.,%str( )),best.))||'"';
                    %end;
                        %end;
            output;
          end;
          proc sort nodupkey; by Domain Category Details CheckId; run;
          data out2(keep=Domain Category Details CheckId);
            set out out1;
          run;
          data out;
            set out2;
          run;
        run;
%end;
%mend;
/*
data out;
  length Domain Category Details CheckId $200;
  call missing(Domain,Category,Details,CheckId);
run;
*/
*intersection, in_out=0.  complementary set, in_out=1.
**ex***;
proc sort data=&_dm..ex out=base01; by usubjid;
data base1;
        length MAX_EXENDTC MIN_EXSTDTC $50;
        set base01;
        by usubjid;
        if EXSTDTC='' then EXSTDTC='';
        if EXENDTC='' then EXENDTC='';
        retain MAX_EXENDTC MIN_EXSTDTC '';
        if first.usubjid then do;
                MAX_EXENDTC=EXENDTC;
                MIN_EXSTDTC=EXSTDTC;
        end;
        if %GT(EXENDTC,MAX_EXENDTC) or %EQ(EXENDTC,MAX_EXENDTC) then MAX_EXENDTC=EXENDTC;
        if %GT(EXSTDTC,MAX_EXENDTC) or %EQ(EXSTDTC,MAX_EXENDTC) then MAX_EXENDTC=EXSTDTC;
        if EXSTDTC^='' and (%GT(MIN_EXSTDTC,EXSTDTC) or %EQ(EXSTDTC,MIN_EXSTDTC)) then MIN_EXSTDTC=EXSTDTC;
        if length(MIN_EXSTDTC)>=10 then MIN_EXSTDTC_ADD1=put(input(MIN_EXSTDTC,yymmdd10.)+1,yymmdd10.);
        else MIN_EXSTDTC_ADD1=MIN_EXSTDTC;
        if last.usubjid then output;
        keep usubjid MAX_EXENDTC MIN_EXSTDTC MIN_EXSTDTC_ADD1;
run;
%let in_out=0;
%cdisc2(CheckId=Check030500,Rule=%str(RFXSTDTC^=MIN_EXSTDTC),Domain=DM,VarC=USUBJID RFXSTDTC);
%cdisc2(CheckId=Check030501,Rule=%str(RFXENDTC^=MAX_EXENDTC),Domain=DM,VarC=USUBJID RFXENDTC);

%cdisc2(CheckId=Check017110
,Rule=(AEACN^='NOT APPLICABLE' or AEACNS1^='NOT APPLICABLE' or AEACNS2^='NOT APPLICABLE'
or AEACNS3^='NOT APPLICABLE' or AEACNS4^='NOT APPLICABLE' or AEACNO1^='NOT APPLICABLE'
or AEACNO2^='NOT APPLICABLE' or AEACNO3^='NOT APPLICABLE' or AEACNO4^='NOT APPLICABLE')
and %gt(MAX_EXENDTC,AESTDTC) and %gt(AESTDTC,MIN_EXSTDTC)
,Domain=AE
,VarC=USUBJID AEACN AEACNS1 AEACNS2 AEACNS3 AEACNS4 AEACNO1 AEACNO2 AEACNO3 AEACNO4 AESTDTC );

%cdisc2(CheckId=Check017112
,Rule=(AEREL^='NOT RELATED' or AERELS1^='NOT RELATED' or AERELS2^='NOT RELATED'
or AERELS3^='NOT RELATED' or AERELS4^='NOT RELATED' or AERELO1^='NOT RELATED'
or AERELO2^='NOT RELATED' or AERELO3^='NOT RELATED' or AERELO4^='NOT RELATED')
and %gt(MIN_EXSTDTC,AESTDTC) and AESTDTC^=''
,Domain=AE,VarC=USUBJID AEREL AERELS1 AERELS2 AERELS3 AERELS4 AERELO1 AERELO2 AERELO3 AERELO4 AESTDTC );

%cdisc2(CheckId=Check017143
,Rule=DSDECOD='RANDOMIZED' and MIN_EXSTDTC^=DSSTC and MIN_EXSTDTC_ADD1^=DSSTC and length(MIN_EXSTDTC)=length(DSSTC)
,Domain=DS,VarC=USUBJID DSDECOD DSSTC );

%let in_out=1;
%cdisc2(CheckId=Check017118,Rule=%str(DSDECOD='SCREEN FAILURE'),Domain=DS,VarC=USUBJID DSDECOD );
%cdisc2(CheckId=Check017135,Rule=%str(ARMCD^="SCRNFAIL"),Domain=DM,VarC=USUBJID ARMCD );

**ds****;
proc sort data=&_dm..ds out=base01; by usubjid DSDECOD;
data base02(keep=usubjid MIN_DSSTDTC MAX_DSSTDTC)
        base03(keep=usubjid)
        base04(keep=usubjid)
        base05(keep=usubjid)
        base06(keep=usubjid INFDT_18)
        base07(keep=usubjid);
        length MIN_DSSTDTC MAX_DSSTDTC INFDT_18 $50;
        set base01;
        by usubjid DSDECOD;
        if DSSTDTC='' then DSSTDTC='';
        if first.usubjid then do;
                MAX_DSSTDTC=DSSTDTC;
                MIN_DSSTDTC=DSSTDTC;
        end;
        if %GT(DSSTDTC,MAX_DSSTDTC) or %EQ(DSSTDTC,MAX_DSSTDTC) then MAX_DSSTDTC=DSSTDTC;
        if DSSTDTC^='' and (%GT(MIN_DSSTDTC,DSSTDTC) or %EQ(DSSTDTC,MIN_DSSTDTC)) then MIN_DSSTDTC=DSSTDTC;
        if last.usubjid then output base02;

        if DSDTC='' then DSDTC='';
        else if length(DSDTC)>=4 then INFDT_18=strip(put(input(compress(substr(DSDTC,1,4),'0123456789','k'),best.)-18,best.))||substr(DSDTC||repeat(' ',10),5);
        if DSDECOD='' then DSDECOD='';
        else if DSDECOD='ADVERSE EVENT' and last.DSDECOD then output base03;
        else if DSDECOD='RANDOMIZED' and last.DSDECOD then output base04;
        else if DSDECOD='SCREEN FAILURE' and last.DSDECOD then output base05;
        else if DSDECOD='INFORMED CONSENT OBTAINED' then output base06;
        else if DSDECOD='DEATH' then output base07;
run;

data base1;
        merge base02(in=in2) base03(in=in3) base04(in=in4) base05(in=in5) base06(in=in6);
        by usubjid;
        call missing(ae_fl,ran_fl,sf_fl,inf_fl);
        if in3 then ae_fl=1;
        if in4 then ran_fl=1;
        if in5 then sf_fl=1;
run;
%let in_out=0;
%cdisc2(CheckId=Check030505,Rule=%str(DSDECOD='DEATH' and DSSTDTC^=MAX_DSSTDTC),Domain=DS,VarC=USUBJID DSDECOD DSSTDTC);
%cdisc2(CheckId=Check017111,Rule=%str(AEACN='DRUG WITHDRAWN' and ae_fl),Domain=AE,VarC=USUBJID AEACN );
%cdisc2(CheckId=Check017129
,Rule=(%GT(CMSTDTC,MAX_DSSTDTC) and CMSTDTC^='') or (%GT(CMENDTC,MAX_DSSTDTC) and MAX_DSSTDTC^='')
,Domain=CM,VarC=USUBJID CMSTDTC CMENDTC);
%cdisc2(CheckId=Check017133_1,Rule=%str(ARMCD^="" and ran_fl),Domain=DM,VarC=USUBJID ARMCD );
%cdisc2(CheckId=Check017134,Rule=%str(ARMCD^="SCRNFAIL" and sf_fl),Domain=DM,VarC=USUBJID ARMCD );
%cdisc2(CheckId=Check017136,Rule=%GT(BRTHDTC,INFDT_18) and INFDT_18^=''
,Domain=DM,VarC=USUBJID BRTHDTC );

%cdisc2(CheckId=Check017160
,Rule=(%gt(MIN_DSSTDTC,SVSTDTC) and SVSTDTC^='') or (%gt(MIN_DSSTDTC,SVENDTC) and SVENDTC^='')
        or (%gt(SVSTDTC,MAX_DSSTDTC) and MAX_DSSTDTC^='') or (%gt(SVENDTC,MAX_DSSTDTC) and MAX_DSSTDTC^='')
,Domain=SV,VarC=USUBJID SVSTDTC SVENDTC );

%let in_out=0;
data base1; set base05; run;
%cdisc2(CheckId=Check017119,Rule=%str(QNAM="RANUM"),Domain=SUPPDS,VarC=USUBJID IDVARVAL );
%let in_out=1;
%cdisc2(CheckId=Check017134,Rule=%str(ARMCD="SCRNFAIL"),Domain=DM,VarC=USUBJID );
data base1; set base06; run;
%cdisc2(CheckId=Check017124,Rule=1,Domain=DM,VarC=USUBJID );
data base1; set base04; run;
%cdisc2(CheckId=Check017133_2,Rule=MISSING(ARMCD),Domain=DM,VarC=USUBJID );
%cdisc2(CheckId=Check017145,Rule=1,Domain=EX,VarC=USUBJID );
data base1; set base07; run;
%cdisc2(CheckId=Check017113_1,Rule=%str(AEOUT='FATAL'),Domain=AE,VarC=USUBJID );

**dm****;
proc sort data=&_dm..dm out=base01 nodupkey; by usubjid;
data base1;
        merge base01 base02;
        by usubjid;
        if RFENDTC='' then RFENDTC='';
        keep usubjid RFENDTC MIN_DSSTDTC;
run;
%let in_out=0;
%cdisc2(CheckId=Check017103
,Rule=(%gt(MIN_DSSTDTC,AESTDTC) and AESTDTC^='') or (%gt(AEENDTC,RFENDTC) and RFENDTC^='')
,Domain=AE,VarC=USUBJID AESTDTC AEENDTC );

data base02(keep=usubjid) base03(keep=usubjid);
        set base01;
        if ARMCD='' then ARMCD='';
        else if ARMCD='SCRNFAIL' then output base02;
        else if ARMCD='NOTASSGN' then output base03;

data base1;
        merge base01(in=in1) base02(in=in2) base03(in=in3);
        by usubjid;
        if RFENDTC='' then RFENDTC='';
        call missing(sf_fl,nota_fl);
        if in2 then sf_fl=1;
        if in3 then nota_fl=1;
        keep usubjid RFENDTC sf_fl nota_fl;
run;
%let in_out=0;
%cdisc2(CheckId=Check017106
,Rule=%str((AEREL^='NOT RELATED' or AERELS1^='NOT RELATED' or AERELS2^='NOT RELATED'
or AERELS3^='NOT RELATED' or AERELS4^='NOT RELATED' or AERELO1^='NOT RELATED'
or AERELO2^='NOT RELATED' or AERELO3^='NOT RELATED' or AERELO4^='NOT RELATED') and sf_fl),Domain=AE
,VarC=USUBJID AEREL AERELS1 AERELS2 AERELS3 AERELS4 AERELO1 AERELO2 AERELO3 AERELO4 );

%cdisc2(CheckId=Check017107
,Rule=%str((AEREL^='NOT RELATED' or AERELS1^='NOT RELATED' or AERELS2^='NOT RELATED'
or AERELS3^='NOT RELATED' or AERELS4^='NOT RELATED' or AERELO1^='NOT RELATED'
or AERELO2^='NOT RELATED' or AERELO3^='NOT RELATED' or AERELO4^='NOT RELATED') and nota_fl),Domain=AE
,VarC=USUBJID AEREL AERELS1 AERELS2 AERELS3 AERELS4 AERELO1 AERELO2 AERELO3 AERELO4 );

%cdisc2(CheckId=Check017108
,Rule=%str((AEACN^='NOT APPLICABLE' or AEACNS1^='NOT APPLICABLE' or AEACNS2^='NOT APPLICABLE'
or AEACNS3^='NOT APPLICABLE' or AEACNS4^='NOT APPLICABLE' or AEACNO1^='NOT APPLICABLE'
or AEACNO2^='NOT APPLICABLE' or AEACNO3^='NOT APPLICABLE' or AEACNO4^='NOT APPLICABLE') and sf_fl),Domain=AE
,VarC=USUBJID AEACN AEACNS1 AEACNS2 AEACNS3 AEACNS4 AEACNO1 AEACNO2 AEACNO3 AEACNO4 );

%cdisc2(CheckId=Check017109
,Rule=%str((AEACN^='NOT APPLICABLE' or AEACNS1^='NOT APPLICABLE' or AEACNS2^='NOT APPLICABLE'
or AEACNS3^='NOT APPLICABLE' or AEACNS4^='NOT APPLICABLE' or AEACNO1^='NOT APPLICABLE'
or AEACNO2^='NOT APPLICABLE' or AEACNO3^='NOT APPLICABLE' or AEACNO4^='NOT APPLICABLE') and nota_fl),Domain=AE
,VarC=USUBJID AEACN AEACNS1 AEACNS2 AEACNS3 AEACNS4 AEACNO1 AEACNO2 AEACNO3 AEACNO4 );


**suppdm****;
proc sql;
create table base1 as
select distinct usubjid
from &_dm..suppdm
where qnam='RACE1' or qnam='RACE2'
group by usubjid
having count(distinct qnam)=2
order by 1
;
%let in_out=1;
%cdisc2(CheckId=Check030402,Rule=%str(RACE='MULTIPLE'),Domain=DM,VarC=USUBJID RACE);

data base1;
        set &_dm..suppdm;
        where qnam='RACEOTH' and ^missing(qval);
        keep usubjid;
proc sort nodupkey; by usubjid; run;
%let in_out=1;
%cdisc2(CheckId=Check030477,Rule=%str(RACE='OTHER'),Domain=DM,VarC=USUBJID RACE);


**other****;
%macro exst;
%if %sysfunc(exist(&_dm..se)) %then %do;
**se****;
proc sort data=&_dm..SE out=base01; by usubjid;
data base02;
        set base01;
        if EPOCH='' then EPOCH='';
        else if index(EPOCH,'TREATMENT') then output;
data base1;
        length MAX_SEENDTC MIN_SESTDTC $50;
        set base02;
        by usubjid;
        if SESTDTC='' then SESTDTC='';
        if SEENDTC='' then SEENDTC='';
        retain MAX_SEENDTC MIN_SESTDTC '';
        if first.usubjid then do;
                MAX_SEENDTC=SEENDTC;
                MIN_SESTDTC=SESTDTC;
        end;
        if %gt(SEENDTC,MAX_SEENDTC) or %eq(SEENDTC,MAX_SEENDTC) then MAX_SEENDTC=SEENDTC;
        if %gt(SESTDTC,MAX_SEENDTC) or %eq(SESTDTC,MAX_SEENDTC) then MAX_SEENDTC=SESTDTC;
        if (%gt(MIN_SESTDTC,SESTDTC) or %eq(SESTDTC,MIN_SESTDTC)) and SESTDTC^='' then MIN_SESTDTC=SESTDTC;
        if last.usubjid then output;
        keep usubjid MAX_SEENDTC MIN_SESTDTC;
run;
%let in_out=0;
%cdisc2(CheckId=Check030506,Rule=%str(RFXSTDTC^=MIN_SESTDTC),Domain=DM,VarC=USUBJID RFXSTDTC);
%cdisc2(CheckId=Check030507,Rule=%str(RFXENDTC^=MAX_SEENDTC),Domain=DM,VarC=USUBJID RFXENDTC);
%end;

%if %sysfunc(exist(&_dm..mk)) %then %do;
        proc sort data=&_dm..mk out=base1 nodupkey; by usubjid; run;
        %let in_out=1;
        %cdisc2(CheckId=Check017120,Rule=%str(DSDECOD='Screen failure'),Domain=DS,VarC=USUBJID DSDECOD );
%end;

%if %sysfunc(exist(&_dm..vs)) %then %do;
data base1;
        set &_dm..vs;
        if VSTESTCD='' then VSTESTCD='';
        if VSDTC='' then VSDTC='';
        else if VSTESTCD='SYSBP' then output;
        SYSBP_VSSTRESN=VSSTRESN;
        keep usubjid SYSBP_VSSTRESN visitnum VSDTC;
proc sort; by usubjid visitnum VSDTC;run;
%let in_out=0;
%cdisc2(CheckId=Check017138,Rule=%str(VSTESTCD='DIABP' and VSSTRESN>=SYSBP_VSSTRESN)
,Domain=VS,VarC=usubjid VSDTC,VarN=VSSTRESN,VarBy=usubjid visitnum VSDTC);
%end;

%if %sysfunc(exist(&_dm..suppex)) %then %do;
data base1;
        set &_dm..suppex;
        where QNAM='EXAMONTU' and QVAL^='';
proc sort; by usubjid IDVARVAL;
%let in_out=0;
%cdisc2(CheckId=Check017141,Rule=%str(QNAM='EXAMONT' and QVAL=''),Domain=SUPPEX,VarC=USUBJID QNAM QVAL );

data base1;
        set &_dm..suppex;
        where QNAM='EXAMONT' and QVAL^='';
proc sort; by usubjid IDVARVAL; run;
%let in_out=0;
%cdisc2(CheckId=Check017141,Rule=%str(QNAM='EXAMONTU' and QVAL=''),Domain=SUPPEX,VarC=USUBJID QNAM QVAL );
%end;

data base1;
        set &_dm..ie;
        if ietestcd='' then ietestcd='';
        else output;
        keep usubjid;
proc sort nodupkey; by usubjid; run;
%let in_out=0;
%cdisc2(CheckId=Check017156,Rule=%str(ARMCD^='SCRNFAIL'),Domain=DM,VarC=USUBJID ARMCD );

%if %sysfunc(exist(&_dm..tu)) %then %do;
data base1;
        length trlnkid $8;
        set &_dm..tu;
        trlnkid=tulnkid;
        if tulnkid='' then tulnkid='';
        else output;
        keep usubjid trlnkid;
proc sort nodupkey; by usubjid trlnkid; run;
%let in_out=1;
%cdisc2(CheckId=Check030600,Rule=1,Domain=TR,VarC=USUBJID TRLNKID,VarBy=usubjid trlnkid);
%end;

%if %sysfunc(exist(&_dm..tr)) %then %do;
data base1;
        length TRLNKGRP $8;
        set &_dm..tr;
        RSLNKGRP=TRLNKGRP;
        if TRLNKGRP='' then TRLNKGRP='';
        else output;
        keep usubjid RSLNKGRP;
proc sort nodupkey; by usubjid RSLNKGRP; run;
%let in_out=1;
*%cdisc2(CheckId=Check030602,Rule=1,Domain=RS,VarC=USUBJID RSLNKGRP,VarBy=USUBJID RSLNKGRP);
%end;

%if %sysfunc(exist(&_dm..suppeg)) and %sysfunc(exist(&_dm..eg)) %then %do;
data base1;
        set &_dm..eg;
        where EGORRES='ABNORMAL';
        IDVARVAL=strip(put(EGSEQ,best.));
        keep usubjid IDVARVAL;
proc sort; by usubjid IDVARVAL; run;
%let in_out=1;
%cdisc2(CheckId=Check017149,Rule=%str(QNAM='EGCLSIG' and QVAL='YES')
        ,Domain=SUPPEG,VarC=USUBJID EGORRES,VarBy=usubjid IDVARVAL);

data base1;
        set &_dm..suppeg;
        egseq=input(IDVARVAL,best.);
        if qnam='' then qnam='';
        else if qnam='EGCLSIG' then output;
        keep usubjid egseq;
proc sort nodupkey; by usubjid egseq; run;
%let in_out=1;
%cdisc2(CheckId=Check017147,Rule=%str(EGORRES='ABNORMAL'),Domain=EG,VarC=USUBJID EGORRES,Varby=USUBJID EGSEQ);
%end;

proc sort data=&_dm..sv out=base1(keep=usubjid) nodupkey; by usubjid; run;
%let in_out=1;
%cdisc2(CheckId=Check017159,Rule=1,Domain=DM,VarC=USUBJID );

data base01 base02;
        set &_dm..ae;
        if aeacn='' then aeacn='';
        else if aeacn='DRUG WITHDRAWN' then output base01;
        if AEOUT='' then AEOUT='';
        else if AEOUT='FATAL' then output base02;
        keep usubjid;
proc sort nodupkey; by usubjid; run;
%let in_out=1;
data base1; set base01; run;
%cdisc2(CheckId=Check018102,Rule=%str(DSDECOD='ADVERSE EVENT'),Domain=DS,VarC=USUBJID );
%let in_out=1;
data base1; set base02; run;
%cdisc2(CheckId=Check017113_2,Rule=%str(DSDECOD='DEATH'),Domain=DS,VarC=USUBJID );

%mend;
%exst;

data val_out2; set out; run;

***************************************************;
****************Part 3*****************************;
***************************************************;
*exst2 - merge by relrec;
*exst3 - run exst2;
*exst4 - sort, unique;
*exst5 - run exst3;
*exst6 other .... ;
%macro exst2(L,R,CheckId1,CheckId2);
        proc sort data=&l. nodupkey; by usubjid &l.seq;
        proc sort data=&r. nodupkey; by usubjid &r.seq;
        proc sort data=&_dm..relrec(where=(IDVAR="&l.SEQ")) out=rel_&l.(keep=usubjid relid idvarval); by usubjid relid;
        proc sort data=&_dm..relrec(where=(IDVAR="&r.SEQ")) out=rel_&r.(keep=usubjid relid idvarval); by usubjid relid;
        data rel;
                merge rel_&l.(rename=(idvarval=idvarval_&l.)) rel_&r.(rename=(idvarval=idvarval_&r.));
                by usubjid relid;
                &l.seq=input(idvarval_&l.,best.);
                &r.seq=input(idvarval_&r.,best.);
        proc sort;by usubjid &l.seq;run;
        data base01;
                merge &l.(in=in1) rel;
                by usubjid &l.seq;
                if in1 then &l._fl=1;
                else &l._fl=0;
        proc sort;by usubjid &r.seq;run;
        data base02;
                merge &r.(in=in1) base01;
                by usubjid &r.seq;
                if in1 then &r._fl=1;
                else &r._fl=0;
        run;
        data out1;
          length Domain Category Details CheckId $200;
          call missing(Domain,Category,Details,CheckId);
          set base02;
          if &l._fl or ^&r._fl then do;
                Domain="&l. &r.";
                        CheckId="&CheckId1.";
            Details=cats("USUBJID=",USUBJID,", &l.SEQ=",put(&l.SEQ,best.),", not in &r.");
            output;
          end; else if ^&l._fl or &r._fl then do;
                Domain="&l. &r.";
                        CheckId="&CheckId2.";
            Details=cats("USUBJID=",USUBJID,", &r.SEQ=",put(&r.SEQ,best.),", not in &l.");
            output;
          end;
        proc sort nodupkey; by Domain Category Details CheckId;run;
        data out2(keep=Domain Category Details CheckId);
          set out out1;
        run;
        data out;
          set out2;
        run;
%mend;

%macro exst3;
%if %sysfunc(exist(&_dm..pp)) and %sysfunc(exist(&_dm..pc)) %then %do;
data pp; set &_dm..pp;keep usubjid ppseq; run;
data pc; set &_dm..pc;keep usubjid pcseq; run;
%exst2(PP,PC,Check030066,Check030066);
%end;

%if %sysfunc(exist(&_dm..mb)) and %sysfunc(exist(&_dm..ms)) %then %do;
data mb; set &_dm..mb;keep usubjid mbseq; run;
data ms; set &_dm..ms;keep usubjid msseq; run;
%exst2(MB,MS,Check030067,Check030067);
%end;

data ae;
        set &_dm..ae;
        if AECONTRT='' then AECONTRT='';
        else if AECONTRT='Y' then output;
        keep usubjid aeseq AESTDTC;
run;
data cm;
        set &_dm..cm;
        if CMINDC='' then CMINDC='';
        else if CMINDC='ADVERSE EVENT' then output;
        keep usubjid cmseq CMSTDTC;
run;
%exst2(AE,CM,Check017116_1,Check017116_2);

data out1;
  length Domain Category Details CheckId $200;
  call missing(Domain,Category,Details,CheckId);
        set base02;
        if %gt(AESTDTC,CMSTDTC) then do;
                Domain="AE CM";
                CheckId="Check017117";
                Details=cats("USUBJID=",USUBJID,", AESEQ=",put(AESEQ,best.),", CMSEQ=",put(CMSEQ,best.)
                        ,", AESTDTC=",AESTDTC,", CMSTDTC=",CMSTDTC);
                output;
        end;
proc sort nodupkey; by Domain Category Details CheckId;run;
data out2(keep=Domain Category Details CheckId); set out out1;
data out; set out2; run;

%mend;
%exst3;

%macro exst4(CheckId,indat,VarBy);
proc sort data=&indat. out=base2 nodupkey dupout=base1; by &varby.; run;
data out1;
  length Domain Category Details CheckId $200;
  call missing(Domain,Category,Details,CheckId);
  set base1;
        CheckId="&CheckId.";
  %do i=1 %to %eval(%sysfunc(count(&VarBy.,%str( )))+1);
    Details=trim(Details)||" %scan(&VarBy.,&i.,%str( ))=";
    Details=trim(Details)||'"'||trim(%scan(&VarBy.,&i.,%str( )))||'"';
  %end;
  output;
proc sort nodupkey; by Domain Category Details CheckId;run;
data out2(keep=Domain Category Details CheckId);
  set out out1;
run;
data out;
  set out2;
run;
%mend;

%macro exst5;

%if %sysfunc(exist(&_dm..ts)) %then %do;
proc sort data=&_dm..ts out=base01 nodupkey; by tsparmcd tsparm; run;
%exst4(Check030034_1,base01,tsparmcd);
%exst4(Check030034_2,base01,tsparm);
%end;

%if %sysfunc(exist(&_dm..AE)) %then %do;
%exst4(Check017104,&_dm..ae,USUBJID AEDECOD AESTDTC AEENDTC);
%end;

%if %sysfunc(exist(&_dm..IE)) %then %do;
%exst4(Check017155,&_dm..ie,USUBJID IECAT IETESTCD);
%end;

%if %sysfunc(exist(&_dm..sv)) %then %do;
proc sort data=&_dm..sv out=base01 nodupkey; by USUBJID VISIT SVSTDTC SVENDTC; run;
%exst4(Check017157,base01,USUBJID VISIT);
%end;

%mend;
%exst5;


%macro exst6;
%if %sysfunc(exist(&_dm..se)) %then %do;
proc sort data=&_dm..se out=base01; by usubjid seseq; run;
data out1;
        length Domain Category Details CheckId LAG_SESTDTC LAG_SEENDTC $200;
        set base01;
        by usubjid;
  call missing(Domain,Category,Details,CheckId);
  if SESTDTC='' then SESTDTC='';
        if SEENDTC='' then SEENDTC='';
        LAG_SESTDTC=LAG(SESTDTC);
        LAG_SEENDTC=LAG(SEENDTC);
        if %gt(LAG_SESTDTC,SESTDTC) and ^first.usubjid then do;
                CheckId="Check030406";
          Details="USUBJID="||strip(USUBJID)||", SESEQ="||STRIP(PUT(SESEQ,BEST.));
          output;
        end;
        if LAG_SEENDTC=SESTDTC and ^first.usubjid then do;
                CheckId="Check030408";
          Details="USUBJID="||strip(USUBJID)||", SESEQ="||STRIP(PUT(SESEQ,BEST.));
          output;
        end;
proc sort nodupkey; by Domain Category Details CheckId;run;
data out2(keep=Domain Category Details CheckId); set out out1;
data out; set out2; run;
%end;

proc sort data=&_dm..sv(where=(mod(visitnum,1)=0 and visitnum>=10 and SVSTDTC^=''))
        out=base01; by USUBJID VISITNUM SVSTDTC; run;
data out1;
        length Domain Category Details CheckId LAG_SVSTDTC $200;
        set base01;
        by usubjid;
  call missing(Domain,Category,Details,CheckId);
  if SVSTDTC='' then SVSTDTC='';
        LAG_SVSTDTC=LAG(SVSTDTC);
        if %gt(LAG_SVSTDTC,SVSTDTC) and ^first.usubjid then do;
                CheckId="Check017158";
          Details="USUBJID="||strip(USUBJID)||", VISIT="||STRIP(VISIT);
          output;
        end;
proc sort nodupkey; by Domain Category Details CheckId;run;
data out2(keep=Domain Category Details CheckId); set out out1;
data out; set out2; run;

%mend;

%exst6;

data val_out3; set out; run;

***************************************************;
****************Part 4*****************************;
***************************************************;
%macro exst7;
proc contents data=&_dm.._all_ out=vardef_data(rename=(memname=dataset name=varname) keep=memname name) noprint; run;
proc sort data=vardef_data; by dataset varname;
proc sort data=&_meta..vardef out=vardef; by dataset varname;

data out1(keep=Domain Category Details CheckId);
  length Domain Category Details CheckId $200;
  call missing(Domain,Category,Details,CheckId);
  merge vardef_data(in=in1) vardef(in=in2);
  by dataset varname;
  if in1 and ^in2;
        Domain=dataset;
        CheckId="Check030115";
  Details=cats("variable: ",varname);
proc sort nodupkey; by Domain Category Details CheckId;run;

data out2(keep=Domain Category Details CheckId);
        length Domain Category Details CheckId $200;
        call missing(Domain,Category,Details,CheckId);
        set vardef;
        Domain=dataset;
        Details=cats("variable: ",varname);
        if origin='' then do;
                CheckId="Check030115";
                output;
        end;
        if origin^='Assigned' and varname='DOMAIN' then do;
                CheckId="Check030721";
                output;
        end;
        if origin^='Assigned' and varname='RDOMAIN' then do;
                CheckId="Check030722";
                output;
        end;
proc sort nodupkey; by Domain Category Details CheckId;run;

data out3;
        length Domain Category Details CheckId $200;
        call missing(Domain,Category,Details,CheckId);
        set &_meta..valdef;
        if origin='' then do;
                CheckId="Check030115";
                output;
        end;
proc sort nodupkey; by Domain Category Details CheckId;run;

data out4;
        set out1 out2 out3 out;
data out; set out4;run;

%mend;

%exst7;

data val_out4;
    set out;
run;

/*Format*/
proc format;
    value $chk
    "Check017101_1" = "Critical data fields missing in AE dataset."
    "Check017101_2" = "Critical data fields missing in SUPPAE dataset."
    "Check017102" = "Level of coding missing: (Lower level term (AELLT), Lower level term code ( AELLTCD), Higher level term (AEHLT), Higher level group term (AEHLGT), Body system (AEBODSYS) and/or Dictionary version (AEDICTVS)"
    "Check017103" = "AE is not falling between signing ICF and reference end date."
    "Check017104" = "Duplicate AEs reported."
    "Check017105_1" = "The AE is serious, but none of the serious criteria is answered 'Y'."
    "Check017105_2" = "The AE is not serious, but one of the serious critera is answered 'Y'."
    "Check017106" = "Screen failure subject, but relationship to study treatment is not equal to 'NOT RELATED'."
    "Check017107" = "Subject not assigned to a treatment arm, but relationship to study treatment is not equal to 'NOT RELATED'."
    "Check017108" = "Screen failure subject, but 'action taken with study treatment' is not equal to 'NOT APPLICABLE'."
    "Check017109" = "Subject not assigned to a treatment arm, but 'action taken with study treatment' is not equal to 'NOT APPLICABLE'."
    "Check017110" = "AE start during period of exposure, but 'action taken to study treatment' is not different from 'NOT APPLICABLE'."
    "Check017111" = "AE action taken is 'drug withdrawn', but no corresponding record in DS"
    "Check017112" = "AE start before first drug intake, but 'Relationship to study treatment' is different from 'not related'."
    "Check017113_1" = "AE with outcome fatal, but reason for trial termination is not 'death'."
    "Check017113_2" = "Reason for trial termination is 'death' but AE outcome is not 'fatal'."
    "Check017114" = "AE end date reported but AEOUT different from 'RECOVERED/RESOLVED', or 'RECOVERED/RESOLVED WITH SEQUELAE'."
    "Check017115" = "AE end date blank but AEOUT different from FATAL 'RECOVERING/RESOLVING', NOT RECOVERED/NOT RESOLVED' or 'UNKNOWN'."
    "Check017116_1" = "[AE] indicating relation to concomitant therapy (AE.AECONTRT='Y') without corresponding record in [CM]."
    "Check017116_2" = "Concomitant medication administered due to AE but no related record in [AE]."
    "Check017117" = "[AE] with start date later than start date of concomitant therapy"
    "Check017118" = "Reason for withdrawal is 'Screen failure' but the subject received trial medication."
    "Check017119" = "Reason for withdrawal is 'Screen failure' but a randomization number is present for the subject."
    "Check017120" = "Reason for withdrawal is 'Screen failure' but medication kits dispensed."
    "Check017124" = "[DM] subject without signed informed consent"
    "Check017126_1" = "Medication reported name (CMTRT) or format (CMDECOD) is missing"
    "Check017126_2" = "Medication reported name (CMTRT) or format (CMDECOD) is missing"
    "Check017127" = "CM term coded but ATC classification is missing."
    "Check017129" = "Start or end date of CM falling after max disposit date"
    "Check017131" = "UNIQUE SUBJECT ID INCOMPLETE/INCORRECT"
    "Check017132" = "Variable RACE is completed with 'MULTIPLE' but the multiple values cannot be found in SUPPDM."
    "Check017133_1" = "SUBJECT WITH DM.ARMCD=null BUT NO RANDOMIZED REC. IN DS"
    "Check017133_2" = "RANDOMIZED SUBJECT IN DS BUT DM.ARMCD NOT NULL"
    "Check017134_1" = "SUBJECT WITH DM.ARMCD=SCRNFAIL BUT NO SF RECORD IN DS"
    "Check017134_2" = "SCREEN FAILURE IN DS BUT DM.ARMCD <> SCRNFAIL"
    "Check017135" = "SUBJECT WITH DM.ARMCD=SCRNFAIL HAS RECORD IN EXPOSURE"
    "Check017136" = "CALCULATED AGE < 18 YEARS"
    "Check017138" = "Diastolic BP is greater than systolic BP"
    "Check017139" = "Vital signs result is out of expected range"
    "Check017141_1" = "Number of capsules (EXAMONT) is present but the unit (EXAMONTU) is missing."
    "Check017141_2" = "Unit (EXAMONTU) is present but the EXAMONT is missing."
    "Check017142" = "Exposure end date is not less than or equal to the maximum disposition date."
    "Check017143" = "Minimum exposure start date falls before randomization date or after 1 day after randomization"
    "Check017144" = "DOSING DATE AND TIME NOT UNIQUE WITHIN A SITE"
    "Check017145" = "Subject has received study medication, but is not randomized"
    "Check017147" = "If Overall Interpretation = abnormal but 'Was the ECG Clinically Significant?' is not answered"
    "Check017148" = "ECG date does not lie between Date of Consent and Date of Study Completion / Withdrawal"
    "Check017149" = "Clinically Significant ECGs but not reported as 'Abnormal'"
    "Check017150" = "LAB SAMPLE DATE NOT BETWEEN START AND END OF TRIAL DATES"
    "Check017151" = "Lab values (LBCAT, LBMETHOD, LBSPEC, LBTEST/LBTESTCD) not found in LB valuelst and inconsistent with the Ludwig dictionary"
    "Check017152" = "STANDARD UNIT MISSING OR INCONSISTENT WITH THE DICTIONARY"
    "Check017153" = "IECAT = 'INCLUSION' but IEORRES and/or IESTRESC are not 'N'"
    "Check017154" = "IECAT = 'EXCLUSION' but IEORRES and/or IESTRESC are not 'Y'"
    "Check017155" = "IECAT/IETESTCD reported more than once"
    "Check017156" = "Violation of Incl. Excl. Criteria but subject not screen failure"
    "Check017157" = "DIFFERENT VISITS ON THE SAME VISIT DATE"
    "Check017158" = "DATE IN THE VISIT DOMAIN INCONSISTENT WITH VISIT SEQUENCE"
    "Check017159" = "SUBJECT WITHOUT RECORD IN THE SV DOMAIN"
    "Check017160" = "Visit date is not falling between date of informed consent and max disposit date."
    "Check017161" = "if cordomain is empty, idvar and idvarval should also be empty"
    "Check018101" = "AE is not falling between signing ICF and date of completion/withdrawal."
    "Check018102" = "Reason for withdrawal is 'AE' but no AE with action taken drug withdrawn"
    "Check030001" = "DATE VARIABLE does not have a ISO 8601 format."
    "Check030002" = "The STANDARD UNIT is not consistent per TEST or EXAMINATION."
    "Check030003_1" = "The AE is serious, but none of the serious criteria is answered 'Y'."
    "Check030003_2" = "The AE is not serious, but one of the serious critera is answered 'Y'."
    "Check030004_1" = "A STANDARD RESULT is completed, but the STATUS is completed."
    "Check030004_2" = "No STANDARD RESULT is completed, but STATUS is not completed."
    "Check030005" = "START DATE/TIME OF OBSERVATION falls after the END DATE/TIME OF OBSERVATION."
    "Check030006" = "The OCCURRENCE is completed differently from 'Y' or 'N'."
    "Check030007" = "The LENGTH of the --TEST variable is more than 40 characters."
    "Check030008_1" = "The --TESTCD starts with a number."
    "Check030008_2" = "The --TESTCD contains special characters."
    "Check030009" = "An ORIGINAL RESULT is completed but the STANDARD RESULT (CHARACTERISTIC) is missing."
    "Check030011" = "The variable is REQUIRED or EXPECTED but is not included in the dataset."
    "Check030012" = "The variable is REQUIRED but the field is empty."
    "Check030015_1" = "The value of the RDOMAIN variable is not a reference to an existing domain."
    "Check030015_2" = "The value of the IDVAR variable is not a reference to a variable in the related domain."
    "Check030015_3" = "The value of the IDVARVAL variable is not a reference to a value in the related domain."
    "Check030015_4" = "The IDVAR variable is completed but the IDVARVAL variable has no value."
    "Check030015_5" = "The IDVARVAL variable is completed but the IDVAR variable has no value."
    "Check030016_1" = "The value of the RDOMAIN variable is not a reference to an existing domain."
    "Check030016_2" = "The value of the IDVAR variable is not a reference to a variable in the related domain."
    "Check030016_3" = "The value of the IDVARVAL variable is not a reference to a value in the related domain."
    "Check030017_1" = "The value of the RDOMAIN variable is not a reference to an existing domain."
    "Check030017_2" = "The value of the IDVAR variable is not a reference to a variable in the related domain."
    "Check030017_3" = "The value of the IDVARVAL variable is not a reference to a value in the related domain."
    "Check030018" = "The USUBJID is not unique in the DM domain."
    "Check030019" = "The COUNTRY reported in the DM domain cannot be found in the SDTM codelist 'COUNTRY' as described in the SDTMIG V3.1.3."
    "Check030020" = "The 'STUDYID, USUBJID, IDVAR, IDVARVAL, QNAM' combination is not unique."
    "Check030021_1" = "The REFERENCE START DATE is not completed however the subject is no screening failure or is assigned to an arm."
    "Check030021_2" = "The REFERENCE START DATE is completed however the subject is a screening failure or is not assigned to an arm."
    "Check030022_1" = "The REFERENCE END DATE is not completed however the subject is no screening failure or is assigned to an arm."
    "Check030022_2" = "The REFERENCE END DATE is completed however the subject is a screening failure or is not assigned to an arm."
    "Check030023_1" = "The AE OUTCOME is 'FATAL' but AESDTH is not answered 'Y'."
    "Check030023_2" = "AESDTH is not answered 'Y' but the AE OUTCOME is not 'FATAL'."
    "Check030024" = "The LENGTH of the IETEST variable is more than 200 characters."
    "Check030025" = "The LENGTH of the --TESTCD variable is more than 8 characters."
    "Check030027" = "The value cannot be found in the codelist attached to the particular value of --TESTCD or QNAM."
    "Check030028" = "Variables --ORRES and --STAT should not be completed both in the same record."
    "Check030031" = "The Planned Study Day of Visit (VISITDY) equals '0'."
    "Check030032" = "Unplanned Elements should only be reported in Subject Elements (SE) domain."
    "Check030034_1" = "One TSPARMCD is assigned to more than one TSPARM."
    "Check030034_2" = "One TSPARM is assigned to more than one --TSPARMCD."
    "Check030035" = "An --ORRES should generally not be populated for derived records (--DRVFL is completed)."
    "Check030036" = "Record present where --ORRES, --STAT and --DRVFL are empty."
    "Check030037" = "The TOXICITY is completed but the TOXICITY GRADE is missing."
    "Check030042_1" = "The LAB TEST OR EXAMINATION NAME is not assigned to the corresponding CDISC CT LAB TEST OR EXAMINATION SHORT NAME."
    "Check030042_2" = "The LAB TEST OR EXAMINATION SHORT NAME is not assigned to the corresponding CDISC CT LAB TEST OR EXAMINATION NAME."
    "Check030044_1" = "The ECG TEST OR EXAMINATION NAME is not assigned to the corresponding CDISC CT ECG TEST OR EXAMINATION SHORT NAME."
    "Check030044_2" = "The ECG TEST OR EXAMINATION SHORT NAME is not assigned to the corresponding CDISC CT ECG TEST OR EXAMINATION NAME."
    "Check030046_1" = "The VITAL SIGNS TEST NAME is not assigned to the corresponding CDISC CT VITAL SIGNS TEST SHORT NAME."
    "Check030046_2" = "The VITAL SIGNS TEST SHORT NAME is not assigned to the corresponding CDISC CT VITAL SIGNS TEST NAME."
    "Check030048_1" = "The TRIAL SUMMARY PARAMETER is not assigned to the corresponding CDISC CT TRIAL SUMMARY PARAMETER SHORT NAME."
    "Check030048_2" = "The TRIAL SUMMARY PARAMETER SHORT NAME is not assigned to the corresponding CDISC CT TRIAL SUMMARY PARAMETER."
    "Check030055" = "Demographics domain is required in the SDTM model."
    "Check030056" = "Janus: Domains DM, EX and DS are required for loading a study into Janus datawarehouse."
    "Check030058" = "Dataset/Domain name format is not conforming to SDTMIG V3.1.3."
    "Check030059" = "The data type of the variable is not conform with SDTM global standards."
    "Check030060" = "VISITNUM cannot be formatted to more than three decimal places."
    "Check030061" = "A subcategory (--SCAT) can only be completed when the category (--CAT) is completed."
    "Check030062" = "Values of DVTERM are not mapped to the values of DVDECOD."
    "Check030063" = "Inconsistency in IECAT between IE and TI."
    "Check030064" = "Dataset/Domain name format is not conforming to SDTMIG V3.1.3."
    "Check030065" = "Dataset/Domain name format is not conforming to SDTMIG V3.1.3."
    "Check030066" = "Pharmacokinetics domains PC and PP should be linked via RELREC."
    "Check030067" = "Microbiology domains MB and MS should be linked via RELREC."
    "Check030068" = "Domain TS: The value of TSVAL for TSPARMCD='ADDON' cannot be found in CDISC CT codelist NY (C66742)."
    "Check030072" = "Domain TS: The value of TSVAL for TSPARMCD='AGEU' cannot be found in CDISC CT codelist AGEU (C66781)."
    "Check030082" = "Domain TS: The value of TSVAL for TSPARMCD='SEXPOP' cannot be found in CDISC CT codelist SEXPOP (C66732)."
    "Check030098_1" = "Domain DA: DATESTCD is completed with 'DISPAMT', however DATEST is not completed with 'Dispensed Amount'. (SDTMIG V3.1.2 APPENDIX C4)."
    "Check030098_2" = "Domain DA: DATEST is completed with 'Dispensed Amount', however DATESTCD is not completed with 'DISPAMT'. (SDTMIG V3.1.2 APPENDIX C4)."
    "Check030099_1" = "Domain DA: DATESTCD is completed with 'RETAMT', however DATEST is not completed with 'Returned Amount'. (SDTMIG V3.1.2 APPENDIX C4)."
    "Check030099_2" = "Domain DA: DATEST is completed with 'Returned Amount', however DATESTCD is not completed with 'RETAMT'. (SDTMIG V3.1.2 APPENDIX C4)."
    "Check030100" = "Domain contains no data."
    "Check030101" = "Domain Abbreviation column doesn't match the name of Domain.))))))))))"
    "Check030102" = "The SEQUENCE is not unique within a subject."
    "Check030103" = "The STUDY DAY START is not equal to or lesser than the STUDY DAY END."
    "Check030104" = "The END RELATIVE TO REFERENCE PERIOD does not equal 'BEFORE', 'DURING', 'AFTER', 'DURING/AFTER' or 'U'."
    "Check030105" = "The START RELATIVE TO REFERENCE PERIOD does not equal 'BEFORE', 'DURING', 'AFTER', 'U'."
    "Check030106" = "The LENGTH of the TRIAL SUMMARY PARAMETER variable is more than 40 characters."
    "Check030107" = "The LENGTH of the TRIAL SUMMARY PARAMETER TESTCD variable is more than 8 characters."
    "Check030108" = "The END DATE/TIME OF OBSERVATION is missing and the END RELATIVE TO REFERENCE PERIOD is null."
    "Check030109" = "The START DATE/TIME OF OBSERVATION is missing but the START RELATIVE TO REFERENCE PERIOD is null."
    "Check030110" = "The NORMAL RANGE UPPER LIMIT is lower than the NORMAL RANGE LOWER LIMIT."
    "Check030111_1" = "A PLANNED TIME POINT NUMBER is present but the PLANNED TIME POINT NAME is missing."
    "Check030111_2" = "A PLANNED TIME POINT NAME is present but the PLANNED TIME POINT NUMBER is missing."
    "Check030112_1" = "A DOSE UNIT is present but the DOSE or DOSE DESCRIPTION is missing."
    "Check030112_2" = "A DOSE or DOSE DESCRIPTION is present but the DOSE UNIT is missing."
    "Check030113" = "The STUDY DAY equals '0'."
    "Check030114" = "The datatype of this column in the SAS dataset is different from the datatype of this column in the Define.xml."
    "Check030115" = "This column is present in the SAS dataset but is not described in the Define.xml."
    "Check030116" = "The PLANNED ARM CODE cannot be found in the TA domain."
    "Check030117" = "The ELEMENT CODE cannot be found in the TE domain."
    "Check030118" = "The INCLUSION/EXCLUSION SHORT NAME cannot be found in the TI domain."
    "Check030119" = "The subject has no record in the DS domain."
    "Check030120" = "The subject has no record in the EX domain."
    "Check030121" = "The PLANNED ARM and PLANNED ARM CODE cannot be found in TA domain."
    "Check030122" = "The AGE is not a positive number."
    "Check030123" = "The value for 'SEX' cannot be found in the codelist 'SEX'."
    "Check030124" = "The value for 'SERIOUS EVENT' is not in the codelist 'NY'."
    "Check030125" = "The value for 'INCLUSION/EXCLUSION CATEGORY' can not be found the CDISC CT codelist 'IECAT'."
    "Check030126" = "The value for I/E CRITERION ORIGINAL RESULT cannot be foud in the code list 'NY'."
    "Check030127" = "The value for I/E CRITERION RESULT IN STANDARD FORMAT cannot be found in the CDISC CT codelist 'NY'."
    "Check030128" = "The I/E CRITERION ORIGINAL RESULT is completed differently from I/E CRITERION RESULT IN STANDARD FORMAT."
    "Check030129_1" = "The AGE is missing, but AGE UNIT is completed."
    "Check030129_2" = "The AGE UNIT is missing, but AGE is completed."
    "Check030130_1" = "The variable name is not as described in SDTM V1.3."
    "Check030130_2" = "The variable label in dataset is not as described in the SDTM V1.3."
    "Check030132" = "A Start Relative to Reference Time Point is completed but the Start Reference Time Point is missing."
    "Check030133" = "An End Relative to Reference Time Point is completed but the End Reference Time Point is missing."
    "Check030134_1" = "TREATMENT VEHICLE AMOUNT is not missing but TREATMENT VEHICLE is missing."
    "Check030134_2" = "Informative Check: TREATMENT VEHICLE is not missing but TREATMENT VEHICLE AMOUNT is missing."
    "Check030135_1" = "TREATMENT VEHICLE AMOUNT UNIT is not missing but TREATMENT VEHICLE AMOUNT is missing."
    "Check030135_2" = "Informative Check: TREATMENT VEHICLE AMOUNT is not missing but TREATMENT VEHICLE AMOUNT UNIT is missing."
    "Check030138_1" = "The PLANNED ARM CODE is 'NOTASSGN' but the DESCRIPTION OF PLANNED ARM is not 'NOT ASSIGNED'."
    "Check030138_2" = "The DESCRIPTION OF PLANNED ARM is 'NOT ASSIGNED' but the PLANNED ARM CODE is not 'NOTASSGN'."
    "Check030140" = "The combination VISIT - VISITNUM is not unique."
    "Check030143" = "The value of START RELATIVE TO REFERENCE TIME POINT is invalid (should be 'BEFORE', 'COINCIDENT', 'AFTER', or 'U')."
    "Check030144" = "The value of END RELATIVE TO REFERENCE TIME POINT is invalid (should be 'BEFORE', 'COINCIDENT', 'AFTER', 'ONGOING', or 'U')."
    "Check030145" = "The RESULT OR FINDING IN STANDARD FORMAT is missing but the RESULT CATEGORY is not missing."
    "Check030146" = "Subject has EX record but is not assigned to an arm."
    "Check030147" = "AE start date is not less than or equal to the latest disposition date."
    "Check030148" = "Observation date is not less than or equal to the latest disposition date."
    "Check030149" = "Exposure end date is not less than or equal to the latest disposition date."
    "Check030150" = "The variable does not have a ISO 8601 format."
    "Check030151" = "The value of TAETORD does not match entries in Trial Arms dataset."
    "Check030152" = "The value of VISITNUM does not match entries in Trial Visits dataset."
    "Check030153" = "The combination VISITNUM/VISIT/VISITDY cannot be found in Trial Visits dataset."
    "Check030154" = "Description of Unplanned Visit (SVUPDES) is provided but Planned Study Day of Visit (VISITDY) is not null."
    "Check030155" = "The START REFERENCE TIME POINT (--STTPT) is equal to the DATE OF COLLECTION (--DTC) but the --STRTPT is completed 'AFTER'."
    "Check030156" = "The END REFERENCE TIME POINT (--ENTPT) is equal to the DATE OF COLLECTION (--DTC) but the --ENRTPT is completed 'AFTER'."
    "Check030201_1" = "The PLANNED ARM CODE is 'SCRNFAIL' but the DESCRIPTION OF PLANNED ARM is not 'SCREEN FAILURE'."
    "Check030201_2" = "The DESCRIPTION OF PLANNED ARM is 'SCREEN FAILURE' but the PLANNED ARM CODE is not 'SCRNFAIL'."
    "Check030202_1" = "The PLANNED ARM CODE is 'SCRNFAIL' but the DESCRIPTION OF PLANNED ARM is not 'SCREEN FAILURE'."
    "Check030202_2" = "The DESCRIPTION OF PLANNED ARM is 'SCREEN FAILURE' but the PLANNED ARM CODE is not 'SCRNFAIL'."
    "Check030203" = "The BASELINE FLAG does not equal '' or 'Y'."
    "Check030204" = "The DERIVED FLAG does not equal '' or 'Y'."
    "Check030205" = "The FASTING STATUS is completed differently from 'Y', 'N' or 'U'."
    "Check030206" = "The STATUS is completed differently from 'NOT DONE'."
    "Check030207" = "The STATUS is blank, but a REASON NOT DONE is completed."
    "Check030210" = "The END DATE/TIME OF OBSERVATION is present but the START DATE/TIME OF OBSERVATION and START REFERENCE is missing."
    "Check030211" = "The ELAPSED TIME FROM REFERENCE POINT is present but the TIME POINT REFERENCE is missing."
    "Check030212" = "The UNIQUE SUBJECT IDENTIFIER is missing in the SUPPQUAL domain."
    "Check030213" = "The value has more than 200 characters."
    "Check030214" = "The UNIQUE SUBJECT IDENTIFIER is not present in the DM domain."
    "Check030215" = "The value for 'CONGENITAL ANOMALY OF BIRTH DEFECT' is not in the codelist 'NY'."
    "Check030216" = "The value for 'PERSIST OF SIGNIF DISABILITY/INCAPACITY' is not in the codelist 'NY'."
    "Check030217" = "The value for 'RESULTS IN DEATH' is not in the code list 'NY'."
    "Check030218" = "The value for 'REQUIRES OR PROLONGS HOSPITALIZATION' is not in the codelist 'NY'."
    "Check030219" = "The value for 'IS LIFE THREATNING' is not in the code list 'NY'."
    "Check030220" = "The value for 'CONCOMITANT OR ADDITIONAL TRTMNT GIVEN' is not in the code list 'NY'."
    "Check030221" = "The value for 'INVOLVES CANCER' is not in the codelist 'NY'."
    "Check030222" = "The value for 'OTHER MEDICALLY IMPORTANT SERIOUS ADVERSE EVENT' is not in the code list 'NY'."
    "Check030223" = "The value for 'OCCURRED WITH OVERDOSE' is not in the codelist 'NY'."
    "Check030224" = "The value for AGE UNIT is not in the codelist 'AGEU' as described in the SDTM IG."
    "Check030225" = "The RULE FOR END OF ELEMENT and PLANNED DURATION OF ELEMENT are missing."
    "Check030226_1" = "The SUBJECT ELEMENT CODE ='UNPLAN' but the DESCRIPTION OF UNPLANNED ELEMENT is missing."
    "Check030226_2" = "The DESCRIPTION OF UNPLANNED ELEMENT is provided, but ETCD is not equal to 'UNPLAN'."
    "Check030228" = "Record is duplicated."
    "Check030233" = "VISIT is missing where VISIT NUMBER is present."
    "Check030234" = "The order of the variables in the domain is wrong."
    "Check030236" = "The domain name or domain prefix is not as described in the SDTMIG V3.1.3."
    "Check030237" = "The variable name or variable label in dataset is not as described in the SDTMIG V3.1.3."
    "Check030238" = "The datatype of this column in the SAS dataset is different from the datatype described in the SDTMIG V3.1.3."
    "Check030239" = "The 'REASON NOT DONE' is specified but the status is not completed with 'NOT DONE'."
    "Check030240" = "Subject without --BLFL='Y'."
    "Check030241" = "An ORIGINAL RESULT is missing and an STANDARD RESULT (CHARACTERISTIC) is completed, but the DERIVED FLAG is not answered 'Y'."
    "Check030242" = "The DOSE has a negative value."
    "Check030243" = "The STUDYID is not unique within the study."
    "Check030244" = "The DERIVED FLAG is answered 'Y' but the RESULT OR FINDING IN STANDARD FORMAT is missing."
    "Check030245_1" = "One --TESTCD is assigned to more than one --TEST."
    "Check030245_2" = "One --TEST is assigned to more than one --TESTCD."
    "Check030246_1" = "One QNAM is assigned to multiple QLABEL."
    "Check030246_2" = "One QLABEL is assigned to multiple QNAM."
    "Check030247" = "The TOXICITY GRADE is not a valid number."
    "Check030248" = "The END DATE/TIME OF OBSERVATION is completed but the DATE/TIME OF COLLECTION is missing."
    "Check030249" = "The END DATE/TIME OF OBSERVATION comes before the DATE/TIME OF COLLECTION."
    "Check030251" = "The RELATED DOMAIN is not completed."
    "Check030254" = "Data is not in uppercase."
    "Check030255" = "A key specified in Define.xml does not exist in the dataset."
    "Check030256" = "The character field is not null but a '.' is reported."
    "Check030257" = "The UNIT codelist is not assigned to the UNIT variable."
    "Check030258" = "The label of the dataset differs from the label reported in the DOMAIN codelist."
    "Check030259_1" = "An ORIGINAL UNIT is completed but the STANDARD UNIT is missing."
    "Check030259_2" = "A STANDARD UNIT is completed but the ORIGINAL UNIT is missing."
    "Check030260" = "The ORIGIN and PAGE NUMBERS present for a --ORRES in the dataset are not consistent with the ORIGIN and PAGE NUMBERS present in the Value Level Metadata of that dataset in Define.xml."
    "Check030261_1" = "DOSE is not missing and DOSE DESCRIPTION is completed."
    "Check030261_2" = "DOSE DESCRIPTION is not missing and DOSE is completed."
    "Check030262" = "A DATE/TIME OF COLLECTION is available, but the STUDY DAY OF VISIT/COLLECTION/EXAM is missing."
    "Check030263" = "A START DATE/TIME OF OBSERVATION is available, but the STUDY DAY OF START OF OBSERVATION is missing."
    "Check030264" = "An END DATE/TIME OF OBSERVATION is available, but the STUDY DAY OF END OF OBSERVATION is missing."
    "Check030266" = "The ORIGIN and PAGE NUMBERS present for a QVAL in the dataset are not consistent with the ORIGIN and PAGE NUMBERS present in the Value Level Metadata of that dataset in Define.xml."
    "Check030268" = "Origin is missing for a variable or VLM TESTCD or QNAM in Define.xml."
    "Check030269" = "ARMCD has more than 20 characters."
    "Check030271_1" = "A COMPUTATIONAL ALGORITHM is attached to a variable or VLM value, but it is not present in the list of algorithms in define.xml."
    "Check030271_2" = "A COMPUTATIONAL ALGORITHM is present in the list of algorithms in define.xml, but it is not attached to a variable or VLM value."
    "Check030275" = "VISITNUM, VISIT, VISITDY and DMXFN are the only additional permissible variables that may be added to DM."
    "Check030276" = "The Use of this variable is not allowed in domain CO when RDOMAIN is completed."
    "Check030277" = "Only the identifier variables --GRPID, --REFID, --SPID can be added to SE."
    "Check030278" = "Inapproriate to use variables that support time points (--TPT, --TPTNUM, --ELTM, --TPTREF, --RFTDTC) in SE."
    "Check030279" = "Only the identifier variables --SEQ, --GRPID, --REFID, --SPID can be added to SV."
    "Check030280" = "Inapproriate to use variables that support time points (--TPT, --TPTNUM, --ELTM, --TPTREF, --RFTDTC) in SV."
    "Check030281" = "Variables --PRESP, --OCCUR, --STAT, --REASND should generally not be used in EX."
    "Check030282" = "Variables --OCCUR, --STAT, --REASND are not allowed in domain AE."
    "Check030283" = "Variable should generally not be used in DS."
    "Check030284" = "Variable should generally not be used in MH."
    "Check030285" = "Variable should generally not be used in DV."
    "Check030286" = "Variable should generally not be used in CE."
    "Check030287" = "Variable should generally not be used in EG."
    "Check030288" = "It is recommended not to use --LOINC in EG."
    "Check030289" = "Variable should generally not be used in IE."
    "Check030290" = "Variable should generally not be used in LB."
    "Check030291" = "Variable should generally not be used in PE."
    "Check030292" = "Variable should generally not be used in QS."
    "Check030293" = "Variable should generally not be used in SC."
    "Check030294" = "Variable should generally not be used in VS."
    "Check030295" = "Variable should generally not be used in DA."
    "Check030296" = "Variable should generally not be used in MB."
    "Check030297" = "Variable should generally not be used in MS."
    "Check030298" = "Variable should generally not be used in PC."
    "Check030299" = "Variable should generally not be used in PP."
    "Check030400" = "RFSTDTC should be null for subjects with ARMCD = 'SCRNFAIL' or 'NOTASSGN'."
    "Check030401" = "RFENDTC should be null for subjects with ARMCD = 'SCRNFAIL' or 'NOTASSGN'."
    "Check030402" = "Variable RACE is completed with 'MULTIPLE' but the multiple values cannot be found in SUPPDM."
    "Check030403" = "CODTC should be null because the timing of the parent record(s) is inherited by the comment record."
    "Check030404" = "The maximum length of ETCD values cannot be bigger than 8 characters."
    "Check030405_1" = "ELEMENT should be null when ETCD = 'UNPLAN'."
    "Check030405_2" = "ETCD should be 'UNPLAN' when ELEMENT is blank."
    "Check030406" = "SESEQ is not consistent with the chronological order of SESTDTC."
    "Check030407" = "TAETORD should not be populated when ETCD = 'UNPLAN'."
    "Check030408" = "SEENDTC for one Element should always be the same as the value of SESTDTC of the next Element."
    "Check030411" = "Variable --PRESP is not completed 'Y' or NULL."
    "Check030412" = "Variable AEPRESP is not completed 'Y' or NULL."
    "Check030413" = "Domain AE should only contain Adverse Events that have actually occurred (and Variable AEOCCUR should not be used)."
    "Check030414" = "The value of --DUR has the format '-PnYnMnDTnHnMnS' or '-PnW', but only 'PnYnMnDTnHnMnS' or 'PnW' is allowed."
    "Check030415" = "The value of EPOCH should not be completed when DSCAT = 'PROTOCOL MILESTONE'."
    "Check030416" = "The values of EPOCH are not drawn from the Trial Arms domain."
    "Check030424" = "The Variable present in FA is not in the SDTMIG and cannot be found in the SDTM Identifiers, Timing variables or Findings Observation class."
    "Check030425" = "The value of TAETORD should be an integer value."
    "Check030426" = "Value of RELTYPE is completed with a value other than 'ONE' or 'MANY'."
    "Check030427" = "The linking variables IDVAR and/or IDVARVAL are completed, but the parent domain is missing."
    "Check030428_1" = "The relationship is at a dataset level, however IDVARVAL is completed."
    "Check030428_2" = "USUBJID is completed where IDVARVAL is blank. They should both be blank if the relationship is at dataset level; if not both variables should be completed."
    "Check030429" = "The Linking variable cannot be found in the related domain."
    "Check030430_1" = "PRE-SPECIFIED is completed but OCCURRENCE or COMPLETION STATUS is not completed."
    "Check030430_2" = "OCCURRENCE or COMPLETION STATUS is not missing but PRE-SPECIFIED is not completed 'Y'."
    "Check030431" = "Variable should generally not be used in FA."
    "Check030432" = "The Sequence number is not uniquely assigned accross the split datasets."
    "Check030442" = "Define.xml: Inapproriate to use variables that support time points (--TPT, --TPTNUM, --ELTM, --TPTREF, --RFTDTC) in SV."
    "Check030471" = "A STUDY DAY OF VISIT/COLLECTION/EXAM or STUDY DAY OF START/END OF OBSERVATION is completed, but the SUBJECT REFERENCE START DATE/TIME (DM.RFSTDTC) is missing."
    "Check030472" = "A STUDY DAY OF VISIT/COLLECTION/EXAM or STUDY DAY OF START/END OF OBSERVATION is completed, but the correspong DATE/TIME OF COLLECTION or START/END DATE/TIME OF OBSERVATION is missing, incomplete or not fully ISO 8601 compliant."
    "Check030473" = "A PLANNED STUDY DAY OF VISIT is completed, but the SUBJECT REFERENCE START DATE/TIME (DM.RFSTDTC) is missing."
    "Check030474" = "The variable value contains non-printable characters."
    "Check030475" = "A START or END RELATIVE TO REFERENCE PERIOD is completed but the STUDY REFERENCE PERIOD is missing."
    "Check030476_1" = "The SUBJECT IDENTIFIER is assigned to multiple UNIQUE SUBJECT IDENTIFIERS."
    "Check030476_2" = "The UNIQUE SUBJECT IDENTIFIER is assigned to multiple SUBJECT IDENTIFIERS."
    "Check030477" = "RACE is completed 'OTHER' but the value for RACEOTH cannot be found in dataset SUPPDM."
    "Check030478_1" = "The value for QLABEL is not 'Race, Other' where QNAM = 'RACEOTH'."
    "Check030478_2" = "The value for QNAM is not 'RACEOTH' where QLABEL = 'Race, Other'."
    "Check030480" = "The custom domain contains no timing variables."
    "Check030482" = "A SUBCATEGORY is completed equal to the CATEGORY."
    "Check030483" = "The START/END RELATIVE TO REFERENCE PERIOD is completed but the Event or Intervention did not occur."
    "Check030484" = "The value of --ORNRLO is numeric but greater than the value of --ORNRHI."
    "Check030485" = "The value of --STNRLO is greater than the value of --STNRHI."
    "Check030486" = "The TOTAL DAILY DOSE is completed but both the DOSE and DOSE description are blank."
    "Check030487" = "The use of SUPPLEMENTAL QUALIFIERS is not recommended for this domain."
    "Check030489" = "The combination of VISITNUM-VISIT-VISITDY does not match the entries in dataset TV."
    "Check030490" = "Only Datasets belonging to the three general observation classes should be split."
    "Check030491" = "A split domain dataset is present together with the unsplit dataset."
    "Check030500" = "RFXSTDTC does not equal the first intake of Trial Drug."
    "Check030501" = "RFXENDTC does not equal the last intake of Trial Drug."
    "Check030502" = "RFPENDTC is not the last date of patient contact."
    "Check030503" = "A date of Death is present but the Death Flag is not flagged."
    "Check030504_1" = "A Death Flag is present but a record in DS indicating Death is missing."
    "Check030504_2" = "A record in DS indicating Death is present but a Death Flag is missing."
    "Check030505" = "A record in DS indicating Death is present but it is not the last record in DS."
    "Check030506" = "RFXSTDTC does not equal the first drug intake in the SE domain."
    "Check030507" = "RFXENDTC does not equal the last drug intake in the SE domain."
    "Check030508" = "Domain SE is missing."
    "Check030509" = "MedDRA decoding variables have been used but MedDRA dictionary is not present."
    "Check030511" = "A date is present but the study day is missing."
    "Check030512" = "The baseline flag is missing."
    "Check030513" = "Variable EPOCH is missing."
    "Check030514" = "EPOCH is not correctly assigned"
    "Check030600" = "TRLNKID is present in TR but not in TU"
    "Check030601" = "EVAL is missing while EVALID is not missing"
    "Check030602" = "--LNKGRP is present in RS but not in TR"
    "Check030603" = "Variables --DTHREL, --EXCLFL, --REASEX, --DETECT should never be used in SDTM of clinical trials data"
    "Check030604" = "Informative:: --ANTREG should be used with extreme caution in SDTM of clinical trials data"
    "Check030605" = "Informative:: SETCD should be used with extreme caution in SDTM of clinical trials data"
    "Check030608" = "The sas version 5 character variable length for flags should be 1"
    "Check030609" = "The sas version 5 character variable length for --TESTCD should always be 8"
    "Check030610" = "The sas version 5 character variable length for IDVAR should always be 8"
    "Check030611_1" = "TSVALNF is completed, but TSVAL is not null"
    "Check030611_2" = "TSVAL is missing, but TSVALNF is not completed"
    "Check030700_1" = "Informative Check: The NUMERIC RESULT IN STANDARD UNITS is present but a STANDARD UNIT is missing."
    "Check030700_2" = "Informative Check: The NUMERIC RESULT IN STANDARD UNITS is missing but a STANDARD UNIT is provided."
    "Check030702" = "Informative Check: Status is completed with 'NOT DONE' but the 'REASON NOT DONE' is not specified."
    "Check030703" = "Informative Check: A RESULT OR FINDING IN ORIGINAL UNITS is completed but an ORIGINAL RESULT UNIT is missing."
    "Check030704" = "Informative Check: The ORIGINAL RESULT is missing but an ORIGINAL UNIT is provided."
    "Check030705" = "Informative Check: The variable is permissible and has no value."
    "Check030707" = "Informative Check: VISIT is missing where VISIT NUMBER is present."
    "Check030710" = "Informative Check: QVAL is not in uppercase."
    "Check030711" = "Informative Check: the variable value is not stripped and contains a blank as first character."
    "Check030721" = "Informative Check: The origin of variable DOMAIN is not set to 'Assigned' in define.xml."
    "Check030722" = "Informative Check: The origin of variable RDOMAIN is not set to 'Assigned' in define.xml."
    "Check030723_1" = "Informative Check: The dataset is empty but the xpt-link is present."
    "Check030723_2" = "Informative Check: The xpt-link is missing but the dataset is not empty."
    "Check030726" = "Informative Check: --STNRLO is missing. Should be completed if --STRESC/--STRESN is a continuous result."
    "Check030727" = "Informative Check: --STNRHI is missing. Should be completed if --STRESC/--STRESN is a continuous result."
    "Check030728" = "Informative Check: --ORNRLO is missing. Should be populated if --ORRES is a continuous result."
    "Check030729" = "Informative Check: --ORNRHI is missing. Should be populated if --ORRES is a continuous result."
    "Check030730" = "Informative Check: The variable present in the dataset is not listed in the standard variables set for that domain in the SDTMIG V3.1.2."
    "Check030733" = "Informative check: Domain IE should only contain inclusion/exclusion criteria not met. However the exclusion criterion is answered 'N'."
    "Check030734" = "Informative check: Domain IE should only contain inclusion/exclusion criteria not met. However the inclusion criterion is answered 'Y'."
    "Check030735" = "Informative check: SVSTRF and SVENRF could be used, but are considered unnecessary."
    "Check030736" = "Informative check: SVSTRTPT, SVSTTPT, SVENRTPT and SVENTPT could be used, but are considered unnecessary."
    "Check030737" = "Informative check: Value of DSCAT is missing. It is recommended that DSCAT is always populated."
    "Check030738" = "Informative check: Domain IE should only contain inclusion/exclusion crirteria not met. However IESTRESC is not answered 'Y' or 'N'."
    "Check030739" = "Informative check: Domain MS is intended to be used in conjugation with domain MB. However domain MB is missing."
    "Check030740" = "Informative check: Domain PP is recognized to be derived from domain PC. However domain PC is missing."
    "Check030741" = "Informative check: SDTM Event or Intervention qualifier variable is used as FATESTCD but FATEST is different from the corresponding qualifier variable label."
    "Check030748" = "Domain TS: The value of TSVAL for TSPARMCD='DOSFRQ' cannot be found in CDISC CT codelist FREQ (C71113)."
    "Check030749" = "Domain TS: The value of TSVAL for TSPARMCD='DOSU' cannot be found in CDISC CT codelist UNIT (C71620)."
    "Check030750" = "Domain TS: The value of TSVAL for TSPARMCD='RANDOM' cannot be found in CDISC CT codelist NY (C66742)."
    "Check030751" = "Domain TS: The value of TSVAL for TSPARMCD='ROUTE' cannot be found in CDISC CT codelist ROUTE (C66729)."
    "Check030752" = "Domain TS: The value of TSVAL for TSPARMCD='TBLIND' cannot be found in CDISC CT codelist TBLIND (C66735)."
    "Check030753" = "Domain TS: The value of TSVAL for TSPARMCD='TCNTRL' cannot be found in CDISC CT codelist TCNTRL (C66785)."
    "Check030754" = "Domain TS: The value of TSVAL for TSPARMCD='TDIGRP' cannot be found in CDISC CT codelist TDIGRP (C66787)."
    "Check030755" = "Domain TS: The value of TSVAL for TSPARMCD='TINDTP' cannot be found in CDISC CT codelist TINDTP (C66736)."
    "Check030756" = "Domain TS: The value of TSVAL for TSPARMCD='TPHASE' cannot be found in CDISC CT codelist TPHASE (C66737)."
    "Check030757" = "Domain TS: The value of TSVAL for TSPARMCD='TTYPE' cannot be found in CDISC CT codelist TTYPE (C66739)."
    "Check030758" = "Domain TS: The value of TSVAL for TSPARMCD='AGESPAN' cannot be found in CDISC CT codelist AGESPAN (C66780)."
    "Check030759" = "Informative Check: The BASELINE FLAG is completed for multiple records within the same TEST or EXAMINATION."
    ;
run;

data val_out;
    set val_out1 val_out2 val_out3 val_out4;
    if not missing(checkid);

run;

data val_out1;
    set val_out;
    message=details;
    details=put(checkid,$chk.);
run;

/*Produce validation report*/
data comb;
    set vartype vardef_: mdata: check: val_out1;
    if not missing(CHECKID);
    keep Domain Details CheckId message;
     proc sort nodupkey;
        by _ALL_;
run;

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

%let HEAD = %nrstr(&amp;L&amp;&quot;Arial&quot;&amp;Janssen MMY3007(219129)&amp;C&amp;&quot;Arial,Bold&quot; PAREXEL);
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
        length CHECKID $200;
        CHECKID="No finding";
    run;
%end;

ods tagsets.ExcelXP options(sheet_name="&sheet" absolute_column_width ="30");
title;
proc print data=&dsn label noobs;
    var _all_ /style(data)={tagattr='format:@'};
run;

%mend output;

%output(dsn=comb, sheet=Comblstchk)

ods tagsets.excelxp close;
ods listing;

/*Tidy environment*/
proc datasets nolist lib=work memtype=data kill;
quit;

%mend jjchkother;

%jjchkother;

/*EOP*/
