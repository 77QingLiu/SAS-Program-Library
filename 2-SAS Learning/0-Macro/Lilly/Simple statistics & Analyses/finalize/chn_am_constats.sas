/**soh******************************************************************************************************************
Eli Lilly and Company (required)- GSS
CODE NAME (required)              : chn_am_constats
PROJECT NAME (required)           : component_modules
DESCRIPTION (required)            : Providing summary analysis for continuous variables and p-value                                    
SPECIFICATIONS(required)          : 
VALIDATION TYPE (required)        : 
INDEPENDENT REPLICATION (required): 
ORIGINAL CODE (required)          : N/A, this is the original code
COMPONENT CODE MODULES            : 
SOFTWARE/VERSION# (required)      : SAS/version 9.2
INFRASTRUCTURE                    : SDD version 3.4
DATA INPUT                        : 
OUTPUT                            : 
SPECIAL INSTRUCTIONS              : 
-------------------------------------------------------------------------------------------------------------------------------	
-------------------------------------------------------------------------------------------------------------------------------
DOCUMENTATION AND REVISION HISTORY SECTION (required):

       Author &
Ver# Validator            Code History Description
---- ----------------     -----------------------------------------------------------------------------------------------------
1.0  Yiwen Wang           Original version of the code

PARAMETERS:
Name       Type     Default  Description and Valid Values
---------- -------- -------- ---------------------------------------------------
indata     required null     Input SAS data set name.
 
trtn       required null     Specify the treatment to which subject is assigned
                             (valid value should be numeric)

param      required null     Specify the variable that need to be analyzed

dec        optional  0       Specify the decimal how data collected/stored 
                             Display mean, standard deviation, median, Q1 and Q3  to 1 dp beyond how data collected/stored. 
                             Display minimum, maximum as collected/stored.  

cond       optional null     The subset condition 

byvar      optional null     Variable(s) for by-group processing in the Descriptive Statistics

repeated_yn optional null    Specify whether the Statistical Model will be performed
                             (valid value: null = not perform statistical model
                                           0 = perform ANOVA/ANCOVA analysis by using proc mixed)
                                           1=  Repeated Measures Analysis )

mobyvar    optional null     Variable(s) for by-group processing in the BY
                             statement of PROC MIXED.

visitvar   optional visid    The visit variable for the Repeated Measures Analysis
                             (defaults to VISID)

classvar   optional null     Classification variables in CLASS statement of PROC MIXED.

indepvar   optional null     Independent variables in MODEL statement of PROC MIXED.

sstype     optional 3        The Type of Sum of Squares option in PROC MIXED.
                             (valid values: 1, 2, or 3) 

random     optional null     Random effects variables in RANDOM statment of PROC MIXED.

reptype    optional VC       The TYPE option on the REPEATED statement in PROC MIXED.

ci         optional 95       Specify the Confidence Interval limits around the p-value.
                             (valid values: between 0 and 100).

rank       optional null     Specify whether the data shall be rank-transformed.
                             (valid values: HIGH, LOW, MEAN or NOTIES)

--------------------------------------------------------------------------------
Usage Notes:
 
The user is required at a minimum to enter valid values for the required paramters
listed above.
--------------------------------------------------------------------------------
Assumptions:
 
It is assumed that the ADS/ADaM data structure will be followed for the input data set.
The input data set shall contain within each by-group:
1) one unique observation per subject or
2) one unique observation per visit per subject.
3) if need to compute "Total" group, derive the treatment group before using macro (trt value(total) = 99) 
--------------------------------------------------------------------------------
Typical Macro Call(s) and Description:

*scenario 1: age but not calculate p-value;
%chn_am_constats(indata=subjinfo1,trtn=trtsort,param=ageyr,dec=,cond=,byvar=,repeated_yn=);

*scenario 2(ANOVA): age and calculate p-value;
%chn_am_constats(indata=subjinfo1,trtn=trtsort,param=ageyr,dec=1,cond=,byvar=,
                 repeated_yn=0,mobyvar=,classvar=PINVID TRTSORT,indepvar=PINVID TRTSORT,sstype=2);

*scenario 3: change from baseline by two level but not calculate p-value;
%chn_am_constats(indata=bpi2,trtn=trtsort,param=BPICHGBLTR,dec=,
                 cond=%str(substr(BPIQSNUM,1,4)="BPIS" and 4<=visid<=8),byvar=BPIQSNUM visid);

*scenario 4(ANCOVA and dependent variable need rank-transformed): baseline, endpoint, chg and calculate p-value;
%chn_am_constats(indata=bpi2,trtn=trtsort,param=BPIBLVALTR,dec=,cond=%str(BPIEPFLGTR = 1 and BPICHGBLTR ne .),byvar=BPIQSNUM);
%chn_am_constats(indata=bpi2,trtn=trtsort,param=BPIRN,dec=,cond=%str(BPIEPFLGTR = 1 and BPICHGBLTR ne .),byvar=BPIQSNUM);
%chn_am_constats(indata=bpi2,trtn=trtsort,param=BPICHGBLTR,dec=,cond=%str(BPIEPFLGTR = 1 and BPICHGBLTR ne .),byvar=BPIQSNUM,
repeated_yn=0,mobyvar=BPIQSNUM,classvar=TRTSORT PINVID,indepvar=TRTSORT PINVID BPIBLVALTR,sstype=3,random=,ci=90,rank=MEAN);

*scenario 5(repeated measure): endpoint, chg by two level and calculate p-value;
%chn_am_constats(indata=bpi2,trtn=trtsort,param=BPIRN,dec=,cond=%str(4<=visid<=8 and BPICHGBLTR ne . and BPIRN ne . and BPIBLVALTR ne .),byvar=BPIQSNUM visid);
%chn_am_constats(indata=bpi2,trtn=trtsort,param=BPICHGBLTR,dec=,cond=%str(4<=visid<=8 and BPICHGBLTR ne . and BPIRN ne . and BPIBLVALTR ne .),
byvar=BPIQSNUM visid,repeated_yn=1,mobyvar=BPIQSNUM,classvar=TRTSORT PINVID visid USUBJID,
indepvar=TRTSORT PINVID VISID BPIBLVALTR TRTSORT*VISID BPIBLVALTR*VISID,sstype=3,random=,reptype=UN,visitvar=visid);

Note:
Summary statistics (N, MEAN, STD, MEDIAN, MIN, MAX, Q1 and Q3) and p-value from ANOVA/ANCOVA or repeated measures 
could be generated from the macro.

Name of output dataset:
Summary statistics: &param._
Model: tests&sstype = &param._mixstats
       lsmeans = &param._lsm
       diffs = &param._lsmdif
**eoh*******************************************************************************************************************/;

%macro chn_am_constats(indata=,trtn=,param=,dec=,cond=,byvar=,repeated_yn=,mobyvar=,visitvar=,classvar=,indepvar=,sstype=,random=,reptype=,ci=,rank=);

    %*=============================================================================;
    %* prepare the data for computing the summary results;
    %*=============================================================================;

proc sort data = &indata out  = con_sum1;
   %if %length(&byvar) gt 0 %then %do;
      by &byvar &trtn ;
   %end;
   %else %do;
      by &trtn;
   %end;
   %if %length(&cond) gt 0 %then %do;
      where &cond;
   %end;
run;

    %*=============================================================================;
    %* Descriptive Statistics        ;
    %*=============================================================================;
proc means data=con_sum1 n mean std median min max noprint;
   %if %length(&byvar) gt 0 %then %do;
      by &byvar &trtn ;
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
   max=max_&param
   q1=q1_&param
   q3=q3_&param;
run;

%if %nrquote(&dec)= %then %let dec=0;

%local decadj;

%let decadj =%sysevalf(&dec+1);

data con_sum3;
   set con_sum2;   
   n=put(n_&param,15.);
   mean=put(mean_&param,15.&decadj);
   std=put(std_&param,15.&decadj);
   median=put(median_&param,15.&decadj);
   min=put(min_&param,15.&dec);
   max=put(max_&param,15.&dec);
   q1=put(q1_&param,15.&decadj);
   q3=put(q3_&param,15.&decadj);

   %if %length(&byvar) gt 0 %then %do;
      by &byvar &trtn;
   %end;
   %else %do;
      by &trtn;
   %end;

   if &trtn = . then delete;
   drop n_&param mean_&param std_&param median_&param min_&param max_&param q1_&param q3_&param;
run;

proc transpose data=con_sum3 out=con_sum4 prefix = t;
   %if %length(&byvar) gt 0 %then %do;
      by &byvar;
   %end;
   id &trtn;
   var n Mean STD Median Min Max Q1 Q3;
run;

data &param._;
	set con_sum4;
	%if %length(&byvar) eq 0 %then %do;
      param = "&param";
    %end;
	if lowcase(_NAME_) = 'n' then ord = 1;
	else if lowcase(_NAME_) = 'mean' then ord = 2;
    else if lowcase(_NAME_) = 'std' then ord = 3;
	else if lowcase(_NAME_) = 'median' then ord = 4;
	else if lowcase(_NAME_) = 'min' then ord = 5;
    else if lowcase(_NAME_) = 'max' then ord = 6;
	else if lowcase(_NAME_) = 'q1' then ord = 7;
	else if lowcase(_NAME_) = 'q3' then ord = 8;
run;

    %*=============================================================================;
    %* Analyses of Variance;
    %*=============================================================================;

%if %length(&repeated_yn) gt 0 %then %do;

proc sort data = &indata out  = pvaldata;
   %if %length(&mobyvar) gt 0 %then %do;
      by &mobyvar &classvar ;
   %end;
   %else %do;
      by &classvar;
   %end;
   %if %length(&cond) gt 0 %then %do;
      where &cond;
   %end;
run;
%* Default values for missing LSMeans information;

%if &repeated_yn = 0 %then %do;
  %let lsmeans = &trtn;
%end;
%else %if &repeated_yn = 1 %then %do;
  %if %nrquote(&visitvar)= %then %let visitvar=visid;
  %let ntrtvar = &visitvar;
  %let lsmeans = &trtn*&ntrtvar;
%end;

%* Default values for missing sstype;
%if %nrquote(&sstype)= %then %let sstype=3;

    %*=============================================================================;
    %* Analysis of Variance either on ranked data or observed data.                ;
    %*=============================================================================;

    %if %length(&rank)>0 %then %do;

      PROC RANK DATA=pvaldata

      %if %upcase(&rank)=LOW or %upcase(&rank)=HIGH or %upcase(&rank)=MEAN %then %do;

        TIES=&rank

      %end;

        OUT=pvaldata;

	  where &trtn ne 99;

      %if &mobyvar ne %then %do;
        BY &mobyvar;
      %end;

        VAR &param;
      RUN;

    %end;

    %*=============================================================================;
    %* Proc Mixed                ;
    %*=============================================================================;

    ODS OUTPUT tests&sstype = &param._mixstats(rename=(numdf  = effect_numdf
                                                     dendf  = effect_dendf
                                                     fvalue = effect_fval
                                                     probf  = effect_pvnum));
    ODS OUTPUT lsmeans = &param._lsm;


    ODS OUTPUT diffs = &param._lsmdif;

    %if &repeated_yn %then %do;

      ODS OUTPUT convergencestatus = &param._converge;

    %end;


   PROC MIXED DATA=pvaldata;

   where &trtn ne 99;

    %if &mobyvar ne %then %do;
      BY &mobyvar;
    %end;

      CLASS &classvar;
      MODEL &param = &indepvar / HTYPE=&sstype

                               %if &repeated_yn = 1 %then %do;

                                 SOLUTION DDFM=KR

                               %end;
                               ;

    %if &repeated_yn = 1 %then %do;

      REPEATED &visitvar / SUB=USUBJID

                     %if %nrbquote(&reptype)^= %then %do;
                       TYPE=&reptype
                     %end;
      ;
    %end;
    %if %length(&random)>0 %then %do;

      RANDOM &random;

    %end;

      LSMEANS &lsmeans / DIFFS

                       %if %length(&ci)>0 %then %do;

                         ALPHA=%sysevalf(1-(&ci*0.01))

                       %end;
                       ;
      %end;


    RUN;
%mend chn_am_constats;

