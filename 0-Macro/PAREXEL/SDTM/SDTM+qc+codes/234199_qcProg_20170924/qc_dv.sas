/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   Janssen Research and Development LLC / CNTO1959PSA3002
  PAREXEL Study Code:    234200

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Owner:         Cony Geng        $LastChangedBy: xiaz $
  Last Modified:     2017-06-12    $LastChangedDate: 2017-09-13 02:15:40 -0400 (Wed, 13 Sep 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/qc_dv.sas $

  Files Created:         dv.log
                         dv.sas7bdat

  Program Purpose:       To QC DV Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 28 $
-----------------------------------------------------------------------------*/
%let gmpxlerr = 0;
/*Cleaning WORK library */
proc datasets nolist lib=work memtype=data kill;
run;

/*Do not use threaded processing*/
options NOTHREADS;

%let domain=DV;
%jjqcvaratt(domain=&domain,flag=1)
%jjqcdata_type;

/*remove special character*/
data _null_;
     infile "&_rawctms.filename.csv" recfm=n sharebuffers;
     file "&_rawctms.filename.csv" recfm=n;
     retain quote 0;
     input TXT $char1.;
     if TXT = '"' then quote = ^(quote);
     if quote then do;
         if TXT = '0D'x then put ;
         else if TXT = '0A'x then put ' ';
     end;
run;
/*end*/

/*PROC IMPORT OUT= work.mctms*/
/*            DATAFILE= "&_rawctms.filename.csv"*/
/*            DBMS=csv REPLACE;*/
/*            delimiter=',';*/
/*     GETNAMES=yes;*/
/*     DATAROW=2;*/
/*     GUESSINGROWS=300;*/
/*RUN;*/

 data WORK.mctms;
   infile "&_rawctms.filename.csv"  DSD delimiter = ',' MISSOVER  lrecl=32767  firstobs=2 ;
     informat Study_Name $40.;
     informat Country $40. ;
     informat Site_Number $40. ;
     informat Site_Name $100. ;
     informat Subject_Number $10. ;

     informat Deviation $500. ;
     informat Category $200. ;
     informat Reference 8. ;
     informat Linked_Subject_Visit $200. ;
     informat Reported anydtdtm40. ;

     informat Start_Date anydtdtm40. ;
     informat End_Date anydtdtm40. ;
     informat Status $8. ;
     informat Severity $40. ;
     informat Description__1_ $800. ;

     informat Sponsor_Response $500. ;
     informat Action_Taken $50. ;
     informat Actions $200. ;
     informat Action_Status $8. ;
     informat Lock_Deviation $3. ;

     informat Active $3. ;
     informat Last_Modified_Date anydtdtm40. ;

     format Study_Name $40. ;
     format Country $40. ;
     format Site_Number $40. ;
     format Site_Name $100. ;
     format Subject_Number $10. ;

     format Deviation $500. ;
     format Category $200. ;
     format Linked_Subject_Visit $200. ;
     format Reported datetime. ;

     format Start_Date datetime. ;
     format End_Date datetime. ;
     format Status $8. ;
     format Severity $40. ;
     format Description__1_ $800. ;

     format Sponsor_Response $500. ;
     format Action_Taken $50. ;
     format Actions $200. ;
     format Action_Status $8. ;
     format Lock_Deviation $3. ;

     format Active $3. ;
     format Last_Modified_Date datetime. ;

     input
       Study_Name $
       Country $
       Site_Number $
       Site_Name $
       Subject_Number $

       Deviation $
       Category $
       Reference
       Linked_Subject_Visit $
       Reported

       Start_Date
       End_Date
       Status $
       Severity $
       Description__1_ $

       Sponsor_Response $
       Action_Taken $
       Actions $
       Action_Status $
       Lock_Deviation $

       Active $
       Last_Modified_Date $
       ;

 run;


data dv(drop=EPOCH DVSTDY DVENDY DVSEQ);
  attrib &&&domain._varatt_;
  set mctms;
  if Active='Y';
  if not missing(country);
  STUDYID = upcase(study_name);
  DOMAIN  = "&domain";
  length subject $150;
  subject = cats(subject_number);
  USUBJID = catx("-", STUDYID, SUBJECT);
  DVSEQ   = .;
  DVREFID = cats(reference);
  DVSPID  = catx("-","SUBJECT DEVIATION",reference );
  %gmModifySplit(var=description__1_ ,width=200)
  DVTERM  = compress(upcase(scan(description__1_,1,'~')),,'kw');
  DVDECOD = upcase(category);
  DVCAT   = upcase(Severity);
  EPOCH   = "";
  DVSTDTC = strip(put(start_date,yymmdd10.));
  DVENDTC = strip(put(end_date,yymmdd10.));
/*  DVSTDTC='';*/
/*  DVENDTC='';*/
  DVSTDY  = .;
  DVENDY  = .;
  if ^missing(DVTERM) and DVCAT='MAJOR';
run;

 /*calculate --dy*/
%jjqccomdy(in_data=DV, in_var=DVSTDTC, out_var=DVSTDY);
%jjqccomdy(in_data=DV, in_var=DVENDTC, out_var=DVENDY);
 /*add epoch*/
%jjqcmepoch(in_data=DV,in_date=DVSTDTC);

%jjqcseq(retainvar_=STUDYID DOMAIN USUBJID &domain.SEQ &&&domain._varlst_);

/*SUPPDVA*/
%jjqcvaratt(domain=SUPPDV, flag=1);
proc sql noprint;
    select cats(max(count(description__1_, "~"))) into :varn
        from qtrans.dv;
quit;

%macro check;

%if &varn>0 %then %do;
data qtrans.supp&domain(keep = &&supp&domain._varlst_ label = &&supp&domain._dlabel_);
    attrib &&supp&domain._varatt_;
    set qtrans.&domain;
    RDOMAIN  = "&domain";
    IDVAR    = "DVSEQ";
    IDVARVAL = STRIP(put(DVSEQ,best.));;
    QORIG    = "EDT";
    QEVAL    = "";
    array vlst{*} $200 dvterm dvterm1 - dvterm&varn;
    do i=1 to %eval(&varn+1);
            vlst(i)=upcase(scan(description__1_, i+1, "~"));
        qnam="DVTERM"||cats(i);
        QLABEL = put(QNAM,$&domain._QL.);
        qval=vlst(i);
        if not missing(qval);
        output;
    end;
run;
proc sort nodupkey data = qtrans.supp&domain (&keep_sub keep = &&supp&domain._varlst_);
by &&supp&domain._keyvar_; run;
%end;
%else %do;
data qtrans.supp&domain(keep = &&supp&domain._varlst_ label = &&supp&domain._dlabel_);
    attrib &&supp&domain._varatt_;
    call missing(STUDYID, RDOMAIN ,USUBJID, IDVAR, IDVARVAL, QNAM, QLABEL, QVAL, QORIG, QEVAL);
    if _n_=1 then delete;
run;
proc sort nodupkey data = qtrans.supp&domain (&keep_sub keep = &&supp&domain._varlst_);
by &&supp&domain._keyvar_; run;
%end;
%mend;

%check;

proc sort data =qtrans.&domain (keep = &&&domain._varlst_ dvseq); by &&&domain._keyvar_; run;

%let domain=dv;


%GMCOMPARE( pathOut         =  &_qtransfer
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          , allowWorkLibrary=  1
          , debug           =  0
          );



%GMCOMPARE( pathOut         =  &_qtransfer
          , dataMain        =  transfer.supp&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          , allowWorkLibrary=  1
          , debug           =  0
          );
