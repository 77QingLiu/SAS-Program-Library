/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 61610588LUC1001
  PXL Study Code:        227857

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Pengfei Lu $LastChangedBy: lup $
  Creation Date:         05Jul2016 / $LastChangedDate: 2016-07-12 23:20:48 -0400 (Tue, 12 Jul 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_ie.sas $

  Files Created:         qc_ie.log
                         qc_ie.txt
                         /projects/janss229288/stats/transfer/data/qtransfer/ie.sas7bdat

  Program Purpose:       To QC Inclusion/Exclusion Criteria Not Met Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 8 $
-----------------------------------------------------------------------------*/
/*clean work dataset*/
proc datasets nolist lib = work memtype = data kill;
quit;

/*read attrib*/
%let domain=IE;
%jjqcvaratt(domain=IE, flag=1);
%jjqcdata_type;

/*start to create*/
data ie_(drop=VISIT VISITNUM VISITDY IEDTC IEDY EPOCH);
  attrib &&&domain._varatt_;
  set raw.IE_GL_900(drop = STUDYID rename=(IETESTCD=IETESTCD_ IECAT=IECAT_));

   call missing(EPOCH,VISIT,VISITNUM,VISITDY,IEDTC,IEDY);

   STUDYID  = strip(PROJECT);
   DOMAIN   = "&domain";
   USUBJID  = catx("-",PROJECT,SUBJECT);
   IESPID   = upcase(catx("-","RAVE",INSTANCENAME,DATAPAGENAME,cats(PAGEREPEATNUMBER),cats(RECORDPOSITION)));

   if ^missing(IECAT_) and ^missing(IETESTCD_) then do;
      IEN = put(input(scan(cats(IETESTCD_),1,'.'),best.),z2.);
	  IECAT = upcase(cats(IECAT_));
      if upcase(IECAT_)='INCLUSION' then do;
         IETESTCD = cats('IN',IEN);
		 IEORRES  = 'N';
	  end;
      else if upcase(IECAT_)='EXCLUSION' then do;
         IETESTCD = cats('EX',IEN);
		 IEORRES  = 'Y';
	  end;

	  if input(scan(cats(IETESTCD_),2,'.'),best.)=1 then IETESTCD = cats(IETESTCD,'A');
	  else if input(scan(cats(IETESTCD_),2,'.'),best.)=2 then IETESTCD = cats(IETESTCD,'B');
	  else if input(scan(cats(IETESTCD_),2,'.'),best.)=3 then IETESTCD = cats(IETESTCD,'C');
	  else if input(scan(cats(IETESTCD_),2,'.'),best.)=4 then IETESTCD = cats(IETESTCD,'D');

	  IETEST = put(IETESTCD,$IE_TESTCD.);
	  IESTRESC = IEORRES;

	  output;
   end;
   else if (missing(IECAT_) or missing(IETESTCD_)) and IEYN_STD='N' then 
     put 'WAR' 'NING[PXL]: records with missing(IECAT) or missing(IETESTCD):'
         sitenumber= subject= foldername= instancename= IEYN= iecat_= ietestcd_=;

  format _all_;
  informat _all_;

  keep &&&domain._varlst_ 
        sitenumber subject foldername instancename;
run;
proc sort; by sitenumber subject foldername instancename; run;

proc sort data=qtrans.sv out=sv(keep = sitenumber subject foldername instancename VISIT VISITNUM VISITDY SVSTDTC) nodupkeys;
  by sitenumber subject foldername instancename;
run;
data ie_;
  merge ie_(in=a) sv;
  by sitenumber subject foldername instancename;
  if a;
  IEDTC = SVSTDTC;
run;

/*calculate --STDY and --ENDY*/
%jjqccomdy(in_data=ie_, out_data=ie_1, in_var=IEDTC, out_var=IEDY);

/*add epoch*/
%jjqcmepoch(in_data=ie_1, out_data=ie,in_date=IEDTC);

/*add seqnum*/
%jjqcseq(out_data=qtrans.ie,retainvar_=STUDYID DOMAIN USUBJID &domain.SEQ &&&domain._varlst_);

proc sort data = qtrans.&domain (&keep_sub keep = &&&domain._varlst_ &domain.SEQ);
by &&&domain._keyvar_; run;


************************************************************
*  Compare Main domain and QC domain                       *
************************************************************;
%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.IE
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );

