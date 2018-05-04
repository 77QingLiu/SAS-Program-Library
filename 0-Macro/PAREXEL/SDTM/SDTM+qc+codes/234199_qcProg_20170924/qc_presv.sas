/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   Janssen Research and Development LLC / CNTO1959PSA3002
  PAREXEL Study Code:    234199

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Owner:         FU WANG        $LastChangedBy: xiaz $
  Last Modified:     2017-07-10    $LastChangedDate: 2017-09-18 07:48:49 -0400 (Mon, 18 Sep 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/qc_presv.sas $

  Files Created:         sv.log
                         sv.sas7bdat

  Program Purpose:       To Create Subject Visits Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 33 $
-----------------------------------------------------------------------------*/

/*Cleaning WORK library */
proc datasets nolist lib=work memtype=data kill;
run;

/*Do not use threaded processing*/
options NOTHREADS;

%let domain=SV;
%jjqcvaratt(domain=&domain,flag=1)
%jjqcdata_type;


data sv_gl;
    set raw.sv_gl_900(drop=studyid where=(&raw_sub)) ;
    attrib &&&domain._varatt_;
    length w $10.;
/*     if not missing(visdat); */
    studyid=strip(PROJECT);
    DOMAIN   = "&domain";
    usubjid=catx("-",PROJECT,SUBJECT);
    
    if folder='FOLLOW' then w='60';
    if index(folder,'WK')  then w=compress(folder,,'kd');
    
    
	if ^missing(w) then do;
    n=input(w,best.);
	visitnum=20000+n;
	visitdy=7*n+1;

	if n not in(52,60) then visit="WEEK "||strip(w);
	if n=52 then visit= 'FINAL EFFICACY VISIT / WEEK 52';
	if n=60 then visit='FINAL SAFETY FOLLOW-UP / WEEK 60';
    end;

    if instancename='Screening' then do;
    visitdy=-42;
    visitnum=10000;
    visit='SCREENING';
    end;

    
    %jjqcdate2iso(in_date=visdat,out_date=svstdtc);
    %jjqcdate2iso(in_date=visdat,out_date=svendtc);
    svstdy=.;
    svendy=.;
    visit=compbl(visit);
    epoch='';
    keep &&&domain._varlst_ folder visdat sitenumber subject instancename instanceid ;
run;

proc sort nodupkey data=sv_gl;by usubjid sitenumber folder instancename;run;

proc sort data=sv_gl;by usubjid folder visdat;run;


/*start of add covance*/
data covance_lb;
    set rawlb.covance_lb(rename=(usubjid=usubjid_) drop=domain rename=(visit=_visit visitnum=_visitnum));
    length svstdtc svendtc $19 usubjid $40 folder $50 domain $2.;
    if not missing(lbdtc) then svstdtc=scan(lbdtc,1,'T');
    svendtc=svstdtc;
    usubjid=usubjid_;
    domain='SV';
    if not missing(lbdtc);
    if index(_visit,'UNS') then folder='UNS';
    if not missing(lbdtc) then visdat=(input(scan(lbdtc,1,'T'),is8601da.))*24*60*60;
    domain2='LB';
	
    keep studyid usubjid svstdtc svendtc folder visdat domain2 domain _visit _visitnum;
run;

proc sort data=covance_lb nodupkey;
   by usubjid svstdtc;
run;

proc sql;
    create table lb_ready as
    select a.*,b.visit,b.visitnum,b.visitdy
    from covance_lb as a left join sv_gl as b
    on a.usubjid=b.usubjid and a.visdat=b.visdat;
quit;

data lb_map;
    set lb_ready;
	where missing(visit);
run;

/****Unschduled in Rave *****/
data uns;
  length usubjid studyid $40;
    set raw.sv_gl_901(drop=studyid where=(&raw_sub));
	usubjid=catx("-",PROJECT,SUBJECT);
	studyid=strip(PROJECT);
	
run;

proc sort data=uns;by usubjid visdat descending subject;run;
proc sort nodupkey data=uns dupout=dup;by usubjid visdat;run;

proc sort data=sv_gl;by usubjid visdat;run;
proc sort data=uns;by usubjid visdat;run;

proc sql;
    create table uns_ready as
    select a.*,b.visit,b.visitnum,b.visitdy
    from uns as a left join sv_gl as b
    on a.usubjid=b.usubjid and a.visdat=b.visdat;
quit;

data uns_ready;
    length SVSTDTC SVENDTC $19;
    set uns_ready;
    if substr(visit,1,1)='W' then seqq=1;
    
    if substr(visit,1,1)='S' then seqq=0;
	%jjqcdate2iso(in_date=visdat,out_date=svstdtc);
    %jjqcdate2iso(in_date=visdat,out_date=svendtc);
run;

proc sort data=uns_ready;by usubjid visdat svstdtc descending seqq;run;
proc sort nodupkey data=uns_ready;by usubjid visdat svstdtc;run;

data uns_ready;
    set uns_ready;
    if not missing(visit) then rave_flag='UNS1';
run;

data final;
    set uns_ready(where=(missing(visit))) sv_gl(where=(folder^='UNS' and folder^='DEV')) lb_map;
    if not missing(visit) then indic=1;
run;

proc sort data=final;by usubjid;run;

proc sort data=final;by usubjid svstdtc indic visitnum folder visit instancename;run;

data final;
    set final;
    by usubjid svstdtc indic visitnum folder visit instancename;
    length visit1 $60.;
    retain visit1 visitnum1 seq;
	
    DOMAIN   = "&domain";
    if first.usubjid then do; visit1=""; visitnum1=.; end;
    if visitnum gt .z then do;
        visit1=visit; visitnum1=visitnum; seq=0;
    end;
    else if folder="UNS" then do;
        seq+1;
        if not missing(visitnum1) then visitnum=visitnum1+seq*0.01;
        if missing(visitnum1) then visitnum=seq*0.01;
        visit = left(strip(visit1)||" UNSCHEDULED "||strip(put(seq,z2.)));
        end;
    if not missing(visit);
    visit=compbl(visit);
    format _all_;
    informat _all_;
run;


data sv;
set final;
run;

/*calculate svstdy and svendy*/
%jjqccomdy(in_data=SV, in_var=svstdtc, out_var=svstdy);
%jjqccomdy(in_data=SV, in_var=svendtc, out_var=svendy);
/*add epoch*/

%jjqcmepoch(in_data=SV,in_date=SVSTDTC);

proc sort /*nodupkey*/ data =sv(keep = &&&domain._varlst_ sitenumber subject folder instancename ); by &&&domain._keyvar_; run;

data qtrans.&domain(&keep_sub Label = "&&&domain._dlabel_");
    retain &&&domain._varlst_ Subject SiteNumber InstanceName Folder;
    set &domain;
run;

%gmcompare( pathOut         =  &_qtransfer.
          , dataMain        =  transfer.&domain.
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          , allowWorkLibrary=  1
          , debug           =  0
          )