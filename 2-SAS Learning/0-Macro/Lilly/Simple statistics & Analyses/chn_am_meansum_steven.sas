/*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME                 : meansum.sas
CODE TYPE                 : Limited-use Module
PROJECT NAME (optional)   : Japan I4V-JE-JADN 

DESCRIPTION               : Providing summary analysis for continuous variable
                            (mean,standard deviation,median,minimum,maximun) 

SOFTWARE/VERSION#         : SAS/Version 9.2
INFRASTRUCTURE            : SDD version 3.4

LIMITED-USE MODULES       : n/a

BROAD-USE MODULES         : n/a
INPUT                     : n/a
OUTPUT                    : n/a
 
VALIDATION LEVEL          : 3
REQUIREMENTS              : n/a
ASSUMPTIONS               : Prior to using this macro, users need to create the
                            proper dataset as the input dataset
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
BROAD-USE MODULE/LIMITED-USE MODULE SPECIFIC INFORMATION: n/a

BROAD-USE MODULE TEMPORARY OBJECT PREFIX: n/a

PARAMETERS:

Name      Type         Default            Description and Valid Values
--------- ------------ ------------------ --------------------------------------
INDATA    required                        input dataset
TRTN      required                        treatment groups
PARAM     required                        analysis variable(numeric variable)
COND      not required missing(no subset) subset condition
ORD       required                        table order number
BYVAR   not required                   by variables
GRP       not required missing            output group
DEC       required                        original anaylsis value decimals
PVAL      not required missing(not show)  if present p-value

USAGE NOTES:
   Users may call the meansum macro to get simple statistics with pre-specified
   decimals. Before doing this, please create proper input dataset. For
   example, the dataset could be per subject, per treatment, per lab test.
   If the user is going to get the simple statistics for different parameters,
   please call multiple times and apply on one parameter every time.

TYPICAL WAYS TO EXECUTE THIS CODE AND DESCRIPTION, if applicable:

%meansum(indata=comb_cld2,trtn=trtn,param=das28_crp,ord=12,dec=1);

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

       Author &
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
1.0   Xiaofeng Shi        Original version of the code
      Weishan Shi
**eoh************************************************************************/

/*Compute the results for continuous data*/
%macro meansum(indata=,trtn=,param=,cond=,ord=,byvar=,grp=,dec=,pval=);
/*** prepare the data for computing the summary results ***/
proc sort data = &indata out  = con_sum1;
   %if %length(&byvar) gt 0 %then %do;
      by &trtn &byvar;
   %end;
   %else %do;
      by &trtn;
   %end;
   %if %length(&cond) gt 0 %then %do;
      where &cond;
   %end;
run;

proc means data=con_sum1 n mean std median min max noprint;
   %if %length(&byvar) gt 0 %then %do;
      by &trtn &byvar;
   %end;
   %else %do;
      by &trtn;
   %end;
   var &param;
   output out=con_sum2 (drop=_type_ _freq_) 
   n=n_&param
   mean=mean_&param
   std=std_&param
   median=median_&param
   min=min_&param
   max=max_&param;
run;

data con_sum3;
   set con_sum2;
   length n Mean SD Median Min Max $15;

  %if &dec eq 0 %then %do;
      if n_&param gt . then n = right(put(n_&param,5.)) || repeat(" ",10); else n = "";
      if mean_&param gt . then Mean = right(put(mean_&param,7.1)) || repeat(" ",8); else Mean = "";
      if std_&param gt . then SD = right(put(std_&param,8.2)) || repeat(" ",7); else SD = "";
      if median_&param gt . then Median = right(put(median_&param,7.1)) || repeat(" ",8); else Median = "";
      if min_&param gt . then Min = right(put(min_&param,5.)) || repeat(" ",10); else Min = "";
      if max_&param gt . then Max = right(put(max_&param,5.)) || repeat(" ",10); else Max = "";
   %end;

   %else %if &dec eq 1 %then %do;
      if n_&param gt . then n = right(put(n_&param,5.)) || repeat(" ",10); else n = "";
      if mean_&param gt . then Mean = right(put(mean_&param,8.2)) || repeat(" ",7); else Mean = "";
      if std_&param gt . then SD = right(put(std_&param,9.3)) || repeat(" ",6); else SD = "";
      if median_&param gt . then Median = right(put(median_&param,8.2)) || repeat(" ",7); else Median = "";
      if min_&param gt . then Min = right(put(min_&param,7.1)) || repeat(" ",8); else Min = "";
      if max_&param gt . then Max = right(put(max_&param,7.1)) || repeat(" ",8); else Max = "";
   %end;

   %else %if &dec eq 2 %then %do;
      if n_&param gt . then n = right(put(n_&param,5.)) || repeat(" ",10); else n = "";
      if mean_&param gt . then Mean = right(put(mean_&param,9.3)) || repeat(" ",6); else Mean = "";
      if std_&param gt . then SD = right(put(std_&param,10.4)) || repeat(" ",5); else SD = "";
      if median_&param gt . then Median = right(put(median_&param,9.3)) || repeat(" ",6); else Median = "";
      if min_&param gt . then Min = right(put(min_&param,8.2)) || repeat(" ",7); else Min = "";
      if max_&param gt . then Max = right(put(max_&param,8.2)) || repeat(" ",7); else Max = "";
   %end;

   %else %if &dec = 3 %then %do;
      if n_&param gt . then n = right(put(n_&param,5.)) || repeat(" ",10); else n = "";
      if mean_&param gt . then Mean = right(put(mean_&param,10.4)) || repeat(" ",5); else Mean = "";
      if std_&param gt . then SD = right(put(std_&param,11.5)) || repeat(" ",4); else SD = "";
      if median_&param gt . then Median = right(put(median_&param,10.4)) || repeat(" ",5); else Median = "";
      if min_&param gt . then Min = right(put(min_&param,9.3)) || repeat(" ",6); else Min = "";
      if max_&param gt . then Max = right(put(max_&param,9.3)) || repeat(" ",6); else Max = "";
   %end;

/*  %if &dec eq 0 %then %do;*/
/*      if n_&param gt . then n = right(put(n_&param,5.)) || repeat(" ",6); else n = "";*/
/*      if mean_&param gt . then Mean = right(put(mean_&param,7.1)) || repeat(" ",4); else Mean = "";*/
/*      if std_&param gt . then SD = right(put(std_&param,8.2)) || repeat(" ",3); else SD = "";*/
/*      if median_&param gt . then Median = right(put(median_&param,7.1)) || repeat(" ",4); else Median = "";*/
/*      if min_&param gt . then Min = right(put(min_&param,5.)) || repeat(" ",6); else Min = "";*/
/*      if max_&param gt . then Max = right(put(max_&param,5.)) || repeat(" ",6); else Max = "";*/
/*   %end;*/
/**/
/*   %else %if &dec eq 1 %then %do;*/
/*      if n_&param gt . then n = right(put(n_&param,5.)) || repeat(" ",6); else n = "";*/
/*      if mean_&param gt . then Mean = right(put(mean_&param,8.2)) || repeat(" ",3); else Mean = "";*/
/*      if std_&param gt . then SD = right(put(std_&param,9.3)) || repeat(" ",2); else SD = "";*/
/*      if median_&param gt . then Median = right(put(median_&param,8.2)) || repeat(" ",3); else Median = "";*/
/*      if min_&param gt . then Min = right(put(min_&param,7.1)) || repeat(" ",4); else Min = "";*/
/*      if max_&param gt . then Max = right(put(max_&param,7.1)) || repeat(" ",4); else Max = "";*/
/*   %end;*/
/**/
/*   %else %if &dec eq 2 %then %do;*/
/*      if n_&param gt . then n = right(put(n_&param,5.)) || repeat(" ",6); else n = "";*/
/*      if mean_&param gt . then Mean = right(put(mean_&param,9.3)) || repeat(" ",2); else Mean = "";*/
/*      if std_&param gt . then SD = right(put(std_&param,10.4)) || repeat(" ",1); else SD = "";*/
/*      if median_&param gt . then Median = right(put(median_&param,9.3)) || repeat(" ",2); else Median = "";*/
/*      if min_&param gt . then Min = right(put(min_&param,8.2)) || repeat(" ",3); else Min = "";*/
/*      if max_&param gt . then Max = right(put(max_&param,8.2)) || repeat(" ",3); else Max = "";*/
/*   %end;*/
/**/
/*   %else %if &dec = 3 %then %do;*/
/*      if n_&param gt . then n = right(put(n_&param,5.)) || repeat(" ",6); else n = "";*/
/*      if mean_&param gt . then Mean = right(put(mean_&param,10.4)) || repeat(" ",1); else Mean = "";*/
/*      if std_&param gt . then SD = right(put(std_&param,11.5)) || repeat(" ",0); else SD = "";*/
/*      if median_&param gt . then Median = right(put(median_&param,10.4)) || repeat(" ",1); else Median = "";*/
/*      if min_&param gt . then Min = right(put(min_&param,9.3)) || repeat(" ",2); else Min = "";*/
/*      if max_&param gt . then Max = right(put(max_&param,9.3)) || repeat(" ",2); else Max = "";*/
/*   %end;*/

   %if %length(&byvar) gt 0 %then %do;
      by &trtn &byvar;
   %end;
   %else %do;
      by &trtn;
   %end;
run;

%if %length(&pval) gt 0 %then %do;
/*** Obtain P-value ***/
proc glm data=&indata;
   %if %length(&cond) gt 0 %then %do;
      where &cond;
   %end;
   %if %length(&byvar) gt 0 %then %do;
      by &byvar;
   %end;   
   class &trtn;
   model &param=&trtn;
   ods output ModelANOVA=pval2(where=(HypothesisType=3));
quit;

data pval2;
   set pval2;
   length n $15;
   &trtn = 99;
   if probf gt 0.999 then n = ">.999**";
   else if probf lt 0.001 then n = "<.001**";
   else n = trim(left(put(probf,5.3)))||"**";
   %if %length(&byvar) gt 0 %then %do;
      keep &trtn &byvar n;
   %end;
   %else %do;
      keep &trtn n;
   %end;
run;

data con_sum3;
   set con_sum3 pval2;
run;
%end;

%if %length(&byvar) gt 0 %then %do;
proc sort data = con_sum3;
   by &byvar;
run;
%end;

proc transpose data=con_sum3 out=con_sum4 prefix = v;
   %if %length(&byvar) gt 0 %then %do;
      by &byvar;
   %end;
   id &trtn;
   var n Mean SD Median Min Max;
run;

%if %length(&grp) gt 0 %then %do; 
   data out_t&grp&ord;
      set con_sum4;
      grp = &grp;
%end;
%else %do;
   data out_t&ord;
      set con_sum4;
%end;
      length param $50;
      ord = &ord;
      param = _name_;
	  type = "M";
      drop _name_;
   run;
%mend meansum;
