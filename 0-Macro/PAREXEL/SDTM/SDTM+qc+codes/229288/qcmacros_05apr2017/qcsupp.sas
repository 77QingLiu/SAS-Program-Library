/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / CNTO1275SLE2001
  PXL Study Code:        221689

  SAS Version:           9.3
  Operating System:      UNIX
  ---------------------------------------------------------------------------------------

  Author:                Ran Liu $LastChangedBy: liuc5 $
  Creation Date:         07Sep2015 / $LastChangedDate: 2016-08-29 03:54:05 -0400 (Mon, 29 Aug 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/macros/qcsupp.sas $

  Files Created:         supp.log

  Program Purpose:       To create the supp- domain in the transfer lib.

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 42 $
-----------------------------------------------------------------------------*/
%macro qcsupp(in_data = );

%let sdomain = supp&domain;
%jjqcvaratt(domain = &sdomain);

proc sql noprint;
    select valval, valval, origin, vallabel
        into:valval1 separated by " ",:valval separated by "*",:origin separated by "*", :vallabel separated by "*"
        from qmeta.valdef
        where scan(valueoid,1,".") = upcase("&sdomain");
quit;

%put &valval1 &valval &origin &vallabel;

data _null_;
    call symputx("n", countw("&valval", "*"));
run;

proc sort data = &in_data(keep = studyid usubjid &domain.seq &valval1) out = supp1;
    by studyid usubjid &domain.seq;
run;

%let number = 0;
data _null_;
    set supp1 end = eof;
    if eof then call symputx("number",_n_);
run;
%put &number;

%if &number >0 %then %do;
proc transpose data = supp1 out = supp2;
    by studyid usubjid &domain.seq;
    var &valval1;
run;

data &sdomain;
    retain &&&sdomain._varlst_;
    attrib &&&sdomain._varatt_;

    set supp2(where = (col1 ^= ""));
    qval     = strip(col1);

    if Upcase(qval) = "NO" then qval = "N";
    if Upcase(qval) = "YES" then qval = "Y";
    if Upcase(qval) = "UNKNOWN" then qval = "U";
    if Upcase(qval) = "NOT APPLICABLE" then qval = "NA";

    qnam     = strip(upcase(_name_));
    rdomain  = upcase("&domain");
    idvar    = upcase("&domain.seq");
    idvarval = compress(put(&domain.seq,best.));
    qeval    = "";

    %do i = 1 %to &n;
        %let supp_val    = %scan(%bquote(&valval.),&i.,"*");
        %put &supp_val;

        /*%let supp_label  = %scan(&vallabel.,&i.,"*");*/
        %let supp_label  = %scan(%bquote(&vallabel.),&i.,%str(*));
        %put &supp_label;

        %let supp_origin = %scan(%bquote(&origin.),&i.,"*");
        %put &supp_origin;

        if qnam = "&supp_val" then do;
            qlabel = "&supp_label";
            qorig  = tranwrd(upcase("&supp_origin"),"EDT","eDT");
        end;
    %end;
	%if &domain=DM %then %do;
	idvar = "";
	idvarval = "";
	%end;
    keep &&&sdomain._varlst_;
run;

proc sort data =&sdomain nodupkey out =qtrans.&sdomain(Label = "&&&sdomain._dlabel_");
    by &&&sdomain._keyvar_;
run;
%end;
%else %do;
data qtrans.&sdomain(Label = "&&&sdomain._dlabel_");
	retain &&&sdomain._varlst_;
    attrib &&&sdomain._varatt_;
	call missing (studyid, rdomain, usubjid,idvar, idvarval, qnam, qlabel, qval, qorig, qeval);
	stop;
run;
%end;
%mend qcsupp;