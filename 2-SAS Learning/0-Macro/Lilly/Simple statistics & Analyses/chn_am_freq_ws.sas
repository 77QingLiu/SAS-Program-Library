
/*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME                 : chn_am_freq_ws.sas
CODE TYPE                 : Limited-use Module
PROJECT NAME (optional)   : 

DESCRIPTION               : Reporting frequency of categorical variable and 
                            Calculate P-value

SOFTWARE/VERSION#         : SAS/Version 9.2
INFRASTRUCTURE            : SDD version 3.5

LIMITED-USE MODULES       : n/a

BROAD-USE MODULES         : n/a
INPUT                     : n/a
OUTPUT                    : n/a
 
VALIDATION LEVEL          : 4
REQUIREMENTS              : n/a
ASSUMPTIONS               : n/a
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
BROAD-USE MODULE/LIMITED-USE MODULE SPECIFIC INFORMATION: n/a

BROAD-USE MODULE TEMPORARY OBJECT PREFIX: n/a

PARAMETERS:

Name        Type     Default    Description and Valid Values
---------   -------- ---------- --------------------------------------------------
INSET       required            input dataset 
POP         optional            analysis population 
DENO        required            denominator of percentage, ALL/NONMISS(all patients or nonmissing values) 
PUTN        required            whether output total number(n) of patients, Y/N(yes or no) 
VAR         required            analysis variable(s)
VALVAR      optional            all values of variable, when &vartype=N
POPDS       optional            population dataset, used to count big N, when &DENO=ALL
TRT			required trtsorta   treatment variable 
BYVAR		optional            sorted variable(s) 
DEC         required 1          decimal place of the result
OUT         required _pct_      output dataset 
P           optional            p-value method

USAGE NOTES:
    Users may call the chn_am_freq_ws macro to summarize categorical variables.
    Be caution that there's no special handling for the analysis data within the macro.

TYPICAL WAYS TO EXECUTE THIS CODE AND DESCRIPTION, if applicable:

For numeric variable, don't have sorted variables: 
%chn_am_freq_ws(inset=sdytrt2,pop=subjfas,deno=all,putn=N,var=mdose_g,valvar=%str(1 to 6));

For character variable, don't have sorted variables: 
%chn_am_freq_ws(inset=ae2,pop=subjfas,deno=all,putn=N,var=lblAE);

For numeric variable, have 2 sorted variables: 
%chn_am_freq_ws(inset=eusr2(where=(resp>.)),pop=subjfas,deno=nonmiss,putn=Y, var=resp,
		valvar=%str(1 to 3),byvar=visid defi);

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

       Author &
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
1.0   Weishan Shi         Original version of the code
        Hui Liu
  **eoh************************************************************************/

%macro chn_am_freq_ws
             (inset=,
              pop=, 
              deno=, 
              putn=, 
              var=,
              valvar=,
			  popds=,
			  trt=trtsorta,
			  byvar=,
			  dec=,
              out=_pct_,
			  p=
              );

/*Data for summary*/
data _sa1_;
	set &inset;
	%if &pop ne %then if &pop=1;;
	vartype=vtype(&var);
	trttype=vtype(&trt);
run;

data _sa_;
    set _sa1_;
    where not missing(&var);  
run;

proc sql noprint;
   select distinct(vartype) into: vartype from _sa1_; *Variable Type: N or C;
   select distinct(trttype) into: trttype from _sa1_; *Treatment Type: N or C;
quit;

proc sql noprint;
   *All treatment(&trt) groups number;
   %if &trttype eq N %then select distinct(&trt) into: alltrt separated by ',' from _sa1_;
   %else %if &trttype eq C %then %do;
       create table _zerotrt_ as select distinct &trt from _sa1_;
   %end; 
quit;

/*Summary of frequency*/
%if &byvar ne %then %do;
    proc sort data=_sa_; by &byvar; run;
%end;

proc freq data=_sa_ noprint;
   tables &var * &trt/ out=_tcnt_(drop=PERCENT PCT_ROW rename=(pct_col=percent)) outpct
   %if %upcase(&p) eq CHISQ or %upcase(&p) eq EXACT %then %do; 
		chisq exact ;
		output out=_p_ chisq fisher;
   %end;;
   %if &byvar ne %then by &byvar;;
run;

%if %upcase(&p) eq CMH %then %do;
proc freq data=_sa_ noprint;
   tables &var * &trt * &byvar/cmh ;
   output out=_p_ cmh;
run;
%end;;

proc freq data=_sa_ noprint;
   /*n = patients with non-missing values (small n) for each group*/
   %if %upcase(&deno) eq NONMISS %then tables &trt/ out=_n_(drop=percent);;
   %if &byvar ne %then by &byvar;;
run;

%if %upcase(&p) eq WILCOXON %then %do;
	proc npar1way data=_sa_ wilcoxon noprint;
		var &var;
        class &trt;
        %if &byvar ne %then by &byvar;;
		output out=_p_ wilcoxon;
	run;
%end;

/*Generate dummy datasets (all count=0)*/

/*&vartype eq C is for character variables*/
%if &byvar ne %then %do;
    proc sort data=_tcnt_ out=_zeroby_(keep=&byvar) nodupkey; 
       by &byvar;
    run;
%end;

%if &vartype eq C %then %do;
    proc sort data=_tcnt_ out=_zerovar_(keep=&var) nodupkey; 
       by &var; 
    run;
%end;
 
%if &byvar ne and &vartype eq C and &trttype eq C %then %do;
proc sql; 
     create table _zero_ as 
     select _zeroby_.*,_zerovar_.*,_zerotrt_.* 
     from _zeroby_,_zerovar_,_zerotrt_ order by &byvar, &var, &trt; 
quit;        
%end;
%else %if &byvar ne and &vartype eq C %then %do;
proc sql; 
     create table _zero_ as 
     select _zeroby_.*,_zerovar_.*
     from _zeroby_,_zerovar_ order by &byvar, &var; 
quit;        
%end;
%else %if &byvar ne and &trttype eq C %then %do;
proc sql; 
     create table _zero_ as 
     select _zeroby_.*,_zerotrt_.* 
     from _zeroby_,_zerotrt_ order by &byvar, &trt; 
quit;        
%end;
%else %if &var eq C and &trttype eq C %then %do;
proc sql; 
     create table _zero_ as 
     select _zerovar_.*,_zerotrt_.* 
     from _zerovar_,_zerotrt_ order by &var, &trt; 
quit;        
%end;
%else %if &byvar ne %then %do;
data _zero_;
   set _zeroby_;
run;
%end;
%else %if &vartype eq C %then %do;
data _zero_;
   set _zerovar_;
run;
%end;
%else %if &trttype eq C %then %do;
data _zero_;
   set _zerotrt_;
run;
%end;

data _zero_;
   %if (&byvar ne) or (&vartype eq C) or (&trttype eq C) %then set _zero_;;
   *for numeric variables;
   %if &vartype eq N %then do &var=&valvar;;
	 %if &trttype eq N %then   do &trt=&alltrt;;
	      count=0; output;
	 %if &trttype eq N %then   end;;
   %if &vartype eq N %then end;;
run;

proc sort data=_zero_;
   by %if &byvar ne %then &byvar; &var &trt;
run;

/*Merge frequency with dummy datasets*/
data _tcnt1_;
   merge _zero_ _tcnt_;
   by %if &byvar ne %then &byvar; &var &trt;
run;

/*n = all patients (big n) within each group*/
%if %upcase(&deno) eq ALL %then %do;
   
   data _bign_;
       set &popds;
	   %if &pop ne %then if &pop=1;;
   run; 
   
   %if &byvar ne %then %do;
       proc sort data=_bign_; by &byvar; run;
   %end;

   proc freq data=_bign_ noprint;
     tables &trt/ out=_n_(drop=percent);
     %if &byvar ne %then by &byvar;;
   run;

   proc sort data=_zero_ out=_zeron_(keep=%if &byvar ne %then &byvar; &trt count) nodupkey;
      by %if &byvar ne %then &byvar; &trt;
   run;

   data _n_;
      merge _zeron_ _n_;
      by %if &byvar ne %then &byvar; &trt;
      if count=. then count=0;
   run;

   proc sort data=_tcnt1_; by %if &byvar ne %then &byvar; &trt; run;

   data _tcnt1_;
      merge _tcnt1_ _n_(rename=(count=total)); 
      by %if &byvar ne %then &byvar; &trt;
      if total>0 then percent=count/total*100;
   run;

   %if %upcase(&p) eq CHISQ or %upcase(&p) eq EXACT %then %do; 
   data _tcnt3_;
      set _tcnt1_;
      flag='N';
      count=total-count;
   run;

   data _tcnt4_;
      set _tcnt1_ _tcnt3_;
   run;

   proc sort data=_tcnt4_;
      by %if &byvar ne %then &byvar; &var &trt;
   run;

   proc freq data=_tcnt4_ noprint;
      tables &trt*flag/exact chisq;
      weight count;
      by %if &byvar ne %then &byvar; &var;
   run;

   %end;

%end;

/*Summary of frequency and percentage*/
data _tcnt2_;
   length npct $15;
   set %if %upcase(&putn) eq Y %then _n_(in=a); _tcnt1_(in=b);
   %if &byvar ne %then by &byvar;;

   %if %upcase(&putn) eq Y %then %do;
      if a then do; 
         npct=right(put(count,6.0));
      end;
   %end;

   if count=0 then npct=right(put(count,6.0));  
   if b and count^=0 then do;
       npct=left(strip(put(count,6.0))||" ("||put(percent,6.&dec)||"%)");
   end;
run;

proc sort data=_tcnt2_; by %if &byvar ne %then &byvar; &var &trt; run;

/*Transpose*/
proc transpose data=_tcnt2_ out=&out(drop=_NAME_) prefix=grp;
   var npct;
   by %if &byvar ne %then &byvar; &var;
   id &trt;
run;

%mend;

