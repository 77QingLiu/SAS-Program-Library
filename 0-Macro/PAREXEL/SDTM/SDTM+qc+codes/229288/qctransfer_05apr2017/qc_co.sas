/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 26866138MMY3037
  PXL Study Code:        229288

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Chase Liu $LastChangedBy: wangfu $
  Creation Date:         28Jun2016 / $LastChangedDate: 2017-03-03 03:38:05 -0500 (Fri, 03 Mar 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_co.sas $

  Files Created:         qc_co.log
                         co.sas7bdat

  Program Purpose:       To QC Comments Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 139 $
-----------------------------------------------------------------------------*/
%jjqcclean;
*------------------- Get meta data --------------------;
%let domain=CO;
%jjqcvaratt(domain=CO);
%jjqcdata_type;

*------------------- Read raw data --------------------;
data raw_co1;
    set raw.TR_ONC_001(where=(&raw_sub));
    if ^missing(COVAL);
    rename COVAL=COVAL_ ;
    keep subject project COVAL instancename datapagename PAGEREPEATNUMBER recordposition TULNKID;
run;

data raw_co2;
    set raw.CO_GL_900(where=(&raw_sub));
    if ^missing(COVAL); 
    rename COVAL=COVAL_;
    keep subject project coval COREF_V COREF_F;
run;
*------------------- Mapping --------------------;
/* Form: comments */
data co_1a;
    set raw_co2;
    attrib &&&domain._varatt_;
    STUDYID = strip(PROJECT);
    DOMAIN  = "&domain";
    RDOMAIN = "";
    USUBJID = catx("-",PROJECT,SUBJECT);
    COVAL   = compress(COVAL_,,'kw');
    IDVAR   = "";
    IDVARVAL= "";
    COREF   = upcase(catx('-',COREF_V,COREF_F));
    call missing(of COSEQ);
    drop COSEQ;
run;
/* Form: Extramedullary (Soft Tissue) Plasmacytomas Assessment */
data co_1b_;
    set raw_co1;
    attrib &&&domain._varatt_;
    STUDYID = strip(PROJECT);
    DOMAIN  = "&domain";
    RDOMAIN = "TR";
    USUBJID = catx("-",PROJECT,SUBJECT);
    COVAL   = compress(COVAL_,,'kw');
    IDVAR   = "TRSEQ";
    IDVARVAL= "";
    COREF   = '';
    SPID    = catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
    TRLNKID = put(TULNKID,best. -l);
    call missing(of COSEQ);
    drop COSEQ IDVARVAL;
run;
/* Get IDVARVAL */
proc sql;
    create table co_1b as 
    select a.*, put(b.TRSEQ,best. -l) as IDVARVAL length =200
    from co_1b_ as a left join qtrans.tr as b 
    on a.USUBJID=b.USUBJID and a.SPID=b.TRSPID;
quit;

data co_2;
    set co_1a co_1b;
    COVAL = strip(compbl(COVAL));
run;

*------------------- COSEQ --------------------;
%jjqcseq(in_data=co_2, out_data=co_3, idvar_=USUBJID, retainvar_=STUDYID DOMAIN USUBJID);

*------------------- Output --------------------;

%qcoutput(in_data =co_3)

*------------------- Compare --------------------;
%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );
