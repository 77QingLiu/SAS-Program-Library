/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 61610588LUC1001
  PXL Study Code:        227857

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Pengfei Lu $LastChangedBy: liuc5 $
  Creation Date:         06Jul2016 / $LastChangedDate: 2016-08-24 04:46:14 -0400 (Wed, 24 Aug 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_ss.sas $

  Files Created:         qc_ss.log
                         qc_ss.txt
                         /projects/janss229288/stats/transfer/data/qtransfer/ss.sas7bdat

  Program Purpose:       To QC Subject Status Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 25 $
-----------------------------------------------------------------------------*/
%jjqcclean;
*------------------- Get meta data --------------------;
%let domain=SS;
%jjqcvaratt(domain=SS);
%jjqcdata_type;

*------------------- Read raw data --------------------;
%let dropvar=projectid studyid environmentname subjectid studysiteid sdvtier sitegroup instanceid 
             instancerepeatnumber folderid folder targetdays datapageid recorddate recordid 
             mincreated maxupdated savets;
data SS_ONC_001; /* Form: Survival Data */
    set raw.SS_ONC_001(where=(&raw_sub));
    drop &dropvar;
run;

*------------------- Mapping --------------------;
data ss_(drop=VISIT VISITNUM VISITDY EPOCH SSDY SSSEQ);
  attrib &&&domain._varatt_;
  set SS_ONC_001(where=(&raw_sub));

   call missing(EPOCH,SSDY,VISIT, VISITNUM, VISITDY,SSBLFL);

   STUDYID  = strip(PROJECT);
   DOMAIN   = "&domain";
   USUBJID  = catx("-",PROJECT,SUBJECT);
   SSSPID   = upcase(catx("-","RAVE",INSTANCENAME,DATAPAGENAME,cats(PAGEREPEATNUMBER),cats(RECORDPOSITION)));

   %jjqcdate2iso(in_date=SSDAT, in_time=, out_date=&domain.DTC);
   %jjqcdate2iso(in_date=SSLKADAT, in_time=, out_date=SSLKADTC);

   SSTESTCD = 'SURVSTAT';
   SSTEST   = put(SSTESTCD,&domain._testcd.);
   SSORRES  = upcase(cats(SURVSTAT));
   SSSTRESC = SSORRES;
   SSSEQ = .;
  format _all_;
  informat _all_;
  if ^missing(SSORRES);
  keep &&&domain._varlst_ sitenumber subject foldername instancename SSLKADTC;
run;


/* Visit */
%jjqcvisit(in_data=ss_, out_data=ss_, date=, time=);

/*calculate --STDY and --ENDY*/
%jjqccomdy(in_data=ss_, out_data=ss_1, in_var=ssDTC, out_var=ssDY);

/*add epoch*/
%jjqcmepoch(in_data=ss_1, out_data=ss_2,in_date=ssDTC);

/*add seqnum*/
%jjqcseq(in_data=ss_2,out_data=ss_3,idvar_=USUBJID,retainvar_=STUDYID DOMAIN USUBJID);


/* Output */
%qcoutput(in_data =ss_3);


**SUPPSS**;
%jjqcvaratt(domain=SUPPSS);

data qtrans.supp&domain(keep = &&supp&domain._varlst_ label = &&supp&domain._dlabel_);
    attrib &&supp&domain._varatt_;;
    set SS_3;
	where ^missing(SSLKADTC);
    QNAM     = "SSLKADTC";
    QLABEL   = put(QNAM,$&domain._QL.);
    QVAL     = cats(SSLKADTC);

    RDOMAIN  = "&domain";
    IDVAR    = "SSSEQ";
    IDVARVAL = STRIP(put(SSSEQ,best.));
    QORIG    = "CRF";
    QEVAL    = "";
run;
          
proc sort nodupkey data = qtrans.supp&domain(&keep_sub keep = &&supp&domain._varlst_);
by &&supp&domain._keyvar_; run;

************************************************************
*  Compare Main domain and QC domain                       *
************************************************************;


%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.SS
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );

%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.SUPPSS
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );

