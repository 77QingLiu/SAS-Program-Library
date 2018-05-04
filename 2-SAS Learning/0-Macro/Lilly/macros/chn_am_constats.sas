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
%chn_am_constats(indata=subjinfo1,trtn=trtsort,param=ageyr,dec=,cond=,byvar=);

*scenario 3: change from baseline by two level but not calculate p-value;
%chn_am_constats(indata=bpi2,trtn=trtsort,param=BPICHGBLTR,dec=,
                 cond=%str(substr(BPIQSNUM,1,4)="BPIS" and 4<=visid<=8),byvar=BPIQSNUM visid);

Note:
Summary statistics (N, MEAN, STD, MEDIAN, MIN, MAX, Q1 and Q3) 
could be generated from the macro.

Name of output dataset:
Summary statistics: &param._

**eoh*******************************************************************************************************************/;

%macro chn_am_constats(indata=,trtn=,param=,out=,dec=,cond=,byvar=);

    %*=============================================================================;
    %* prepare the data for computing the summary results;
    %*=============================================================================;
%local rdm;
%let rdm=tvsyekd;
%if %length(&out) = 0 %then %let out=&param._;
proc sort data = &indata out  = con_sum1&rdm;
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
proc means data=con_sum1&rdm n mean std median min max noprint;
   %if %length(&byvar) gt 0 %then %do;
      by &byvar &trtn ;
   %end;
   %else %do;
      by &trtn;
   %end;
   var &param;
   output out=con_sum2&rdm (drop=_type_ _freq_) 
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

data con_sum3&rdm;
   set con_sum2&rdm;   
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

proc transpose data=con_sum3&rdm out=con_sum4&rdm prefix = t;
   %if %length(&byvar) gt 0 %then %do;
      by &byvar;
   %end;
   id &trtn;
   var n Mean STD Median Min Max Q1 Q3;
run;

data &out;
	set con_sum4&rdm;
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

%mend chn_am_constats;

