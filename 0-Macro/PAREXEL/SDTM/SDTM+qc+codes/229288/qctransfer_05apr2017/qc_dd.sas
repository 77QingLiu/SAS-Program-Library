/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 61610588LUC1001
  PXL Study Code:        227857

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Pengfei Lu $LastChangedBy: lup $
  Creation Date:         04Jul2016 / $LastChangedDate: 2016-07-12 23:20:48 -0400 (Tue, 12 Jul 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_dd.sas $

  Files Created:         qc_dd.log
                         qc_dd.txt
                         /projects/janss229288/stats/transfer/data/qtransfer/dd.sas7bdat

  Program Purpose:       To QC Death Details Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 8 $
-----------------------------------------------------------------------------*/
/*clean work dataset*/
proc datasets nolist lib = work memtype = data kill;
quit;

/*read attrib*/
%let domain=DD;
%jjqcvaratt(domain=DD, flag=1);
%jjqcdata_type;

/*start to create*/
data dd_(drop=DDDY EPOCH);
  attrib &&&domain._varatt_;
  set raw.DD_GL_900(drop = STUDYID);

   call missing(EPOCH,DDDY);

   STUDYID  = strip(PROJECT);
   DOMAIN   = "&domain";
   USUBJID  = catx("-",PROJECT,SUBJECT);
   DDSPID   = upcase(catx("-","RAVE",INSTANCENAME,DATAPAGENAME,cats(PAGEREPEATNUMBER),cats(RECORDPOSITION)));

   %jjqcdate2iso(in_date=DDDAT, in_time=, out_date=&domain.DTC);

   if ^missing(PRCDTH) then do;
     DDTESTCD = 'PRCDTH';
	 DDTEST = put(DDTESTCD,&domain._testcd.);
     DDORRES  = ifc(^missing(PRCDTH_OTH),upcase(cats(PRCDTH_OTH)),upcase(cats(PRCDTH)));
     DDSTRESC = upcase(cats(PRCDTH));
	 output;
   end;

   if ^missing(AUTOPSYN) then do;
     DDTESTCD = 'AUTOPSYN';
	 DDTEST = put(DDTESTCD,&domain._testcd.);
     DDORRES  = cats(AUTOPSYN_std);
     DDSTRESC = DDORRES;
	 output;
   end;

  format _all_;
  informat _all_;

  keep &&&domain._varlst_ 
        sitenumber subject foldername instancename;
run;

/*calculate --STDY and --ENDY*/
%jjqccomdy(in_data=dd_, out_data=dd_1, in_var=DDDTC, out_var=DDDY);

/*add epoch*/
%jjqcmepoch(in_data=DD_1, out_data=DD,in_date=DDDTC);

/*add seqnum*/
%jjqcseq(out_data=qtrans.DD,retainvar_=STUDYID DOMAIN USUBJID &domain.SEQ &&&domain._varlst_);

proc sort data = qtrans.&domain (&keep_sub keep = &&&domain._varlst_ &domain.SEQ);
by &&&domain._keyvar_; run;


************************************************************
*  Compare Main domain and QC domain                       *
************************************************************;
%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.DD
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );

