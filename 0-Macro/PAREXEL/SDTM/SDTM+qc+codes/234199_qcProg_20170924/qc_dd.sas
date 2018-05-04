/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   Janssen Research and Development LLC / CNTO1959PSA3002
  PAREXEL Study Code:    234200

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Owner:         Cony Geng        $LastChangedBy: xiaz $
  Creation Date:         12Jun2017 / $LastChangedDate: 2017-07-26 03:22:19 -0400 (Wed, 26 Jul 2017) $
  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/qc_dd.sas $

  Files Created:         dd.log
                         dd.sas7bdat

  Program Purpose:       To QC Death Information Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 3 $
-----------------------------------------------------------------------------*/

/*read attrib from spec*/
%let domain=DD;
%jjqcvaratt(domain=DD, flag=1);

%jjqcdata_type;

/*start to create*/

data dd;
    set raw.dd_gl_900(drop=studyid);
    attrib &&&domain._varatt_;
    studyid=strip(PROJECT);
    DOMAIN   = "&domain";
    usubjid=catx("-",PROJECT,SUBJECT);
    ddspid=catx("-","RAVE",upcase(INSTANCENAME),upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.),put(RECORDPOSITION,best.));
    %jjqcdate2iso(in_date=DDDAT, in_time=DTHTIM, out_date=DDDTC);

    if not missing(prcdth) or not missing(prcdth_oth) then do;
    ddtestcd='PRCDTH';
    ddorres=ifc(prcdth_std^='OTHER',prcdth_std,prcdth_oth);
    ddstresc=prcdth_std;
    output;
    end;

    if not missing(AUTOPSYN_STD) then do;
    ddtestcd='AUTOPSYN';
    ddorres=AUTOPSYN_STD;
    ddstresc=ddorres;
    output;
    end;
    ddtest="";
    dddtc='';
    dddy=.;
    epoch='';
run;

 data dd;
 	retain  &&&domain._varlst_;
    set dd;
    ddtest=put(strip(ddtestcd),&domain._testcd.);
	drop epoch;
run;

*---Add epoch;
%jjqcmepoch(in_data=DD, in_date=DDDTC);
%jjqccomdy(in_data=DD, in_var=dddtc, out_var=dddy);

/*add seqnum*/
%jjqcseq(retainvar_=STUDYID DOMAIN USUBJID &domain.SEQ &&&domain._varlst_);

proc sort nodupkey data =qtrans.&domain  (&keep_sub keep = &&&domain._varlst_ &domain.SEQ);
by &&&domain._keyvar_; run;

************************************************************
*  Compare Main domain and QC domain                       *
************************************************************;
%let domain=dd;
%let gmpxlerr = 0;
%GMCOMPARE( pathOut         =  &_qtransfer
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          , allowWorkLibrary=  1
          , debug           =  0
          );
