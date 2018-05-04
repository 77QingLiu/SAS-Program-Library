/*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME                 : freqsum.sas
CODE TYPE                 : Limited-use Module
PROJECT NAME (optional)   : Japan I4V-JE-JADN 

DESCRIPTION               : Providing frequency count                            

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
GRP       not required missing            output group
SMALLN    not required missing(bign)      denominator used for percentage
                                          calculation
PCT       not required missing(not show)  if show percentage(1=xxx.x; 2=xxx.x%)
PARAMTY   not required missing(numeric)   give value when analysis variable is
                                          not numeric
DEC       not required missing(not show)  if show decimals(1=.x; 2=.xx)
VALPOS    not required missing(default position)      the alignment for the single 
                                          value position in the column

USAGE NOTES:
   Users may call the freqsum macro to get frequency count with or without
   percentage. Before doing this, please create proper input dataset. For
   example, the dataset could be per subject, per treatment, per lab test.
   If the user is going to get the freuency counts for different parameters,
   please call multiple times and apply on one parameter every time.

TYPICAL WAYS TO EXECUTE THIS CODE AND DESCRIPTION, if applicable:

%freqsum(indata=comb_cld2,trtn=trtn,param=anti_ccp,pct=Y,ord=15);

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

       Author &
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
1.0   Xiaofeng Shi        Original version of the code
      Weishan Shi
**eoh************************************************************************/

/*Compute the results for categorical data*/
%macro freqsum(indata=,trtn=,param=,cond=,ord=,grp=,smalln=,pct=,paramty=,dec=,valpos=);
/*dataset shell*/
proc sql;
   create table tmp as
   select distinct &trtn from &indata order by &trtn;
quit;

proc sql;
   create table in_subj as
   select distinct usubjid,&trtn from &indata order by usubjid;
quit;

proc sql;
   create table in_subj_s as
   select distinct usubjid,&trtn from &indata where &cond order by usubjid;
quit;

/*** prepare the data for computing the numerator and denominator ***/
proc sql;
   create table con_sum1 as
   %if %length(&cond) gt 0 %then %do;
      select * from &indata where &cond order by &trtn;
   %end;
   %else %do;
      select * from &indata order by &trtn;
   %end;
quit;

***-if the number of observations is 0 -***;
%if &sqlobs = 0 %then %do;
   data con_sum2;
      set tmp;
	  length val $15;
      %if &valpos eq 1 %then %do; 
         val = right(put(0,6.)) || repeat(" ",9);
      %end;
	  %else %if &valpos eq 11 %then %do; 
          val = right(put(0,5.)) || repeat(" ",10);
      %end;
	  %else %if &valpos eq 12 %then %do; 
         val = right(put(0,5.)) || repeat(" ",10);
      %end;
	  %else %if &valpos eq 2 %then %do; 
          val = right(put(0,6.)) || repeat(" ",9);
      %end;
	  %else %if &valpos eq 21 %then %do; 
          val = right(put(0,5.)) || repeat(" ",10);
      %end;
	  %else %if &valpos eq 22 %then %do; 
         val = right(put(0,4.)) || repeat(" ",11);
      %end;
	  %else %do; 
         val = right(put(0,9.)) || repeat(" ",6);
      %end;
	  ord = &ord;
   run;

   proc transpose data = con_sum2 out = con_sum3(drop=_name_) prefix = v;
      by ord;
      id trtn;
      var val;
   run;
%end;

%else %do;

/*** Compute the numerator and denominator ***/
proc freq data = con_sum1 noprint;
   tables &param / out = out_n(drop = percent rename = (count = num));   
   %if %upcase(&trtn) ne %upcase(&param) %then %do;
   by &trtn;
   %end;   
run;

/*** Compute the small n and big N ***/
proc freq data = in_subj_s noprint;
   tables &trtn / out = out_smalln(drop = percent rename = (count = smalln));
run;

proc freq data = in_subj noprint;
   tables &trtn / out = out_bign(drop = percent rename = (count = bign));
run;

/*** Prepare the dataset for tabulation ***/
data con_sum2;
   merge tmp(in=a) out_n out_smalln out_bign;
   by &trtn;
   length param $50 val $15;

   %if %length(&smalln) gt 0 %then %do;
      if missing(num) eq 1 then num = 0;
      else if missing(num) eq 0 and missing(smalln) eq 0 then pct = (num/smalln)*100;

      %if %length(&pct) gt 0 %then %do;
	     %if &pct eq 1 %then %do;
		    %if &dec eq 1 %then %do;
		       if pct gt 0  then val = right(put(num,5.)) || " (" || right(put(pct,5.1)) || ")" || repeat(" ",2);
               else val = right(put(0,5.)) || repeat(" ",10);
            %end;
		    %else %if &dec eq 2 %then %do;
		       if pct gt 0  then val = right(put(num,5.)) || " (" || right(put(pct,6.2)) || ")" || repeat(" ",1);
               else val = right(put(0,5.)) || repeat(" ",10);
            %end;
		    %else %if %length(&dec) eq 0 %then %do;
		       if pct gt 0  then val = right(put(num,6.)) || " (" || right(put(pct,3.)) || ")" || repeat(" ",3);
               else val = right(put(0,6.)) || repeat(" ",9);
            %end;
         %end;  

	     %else %if &pct eq 2 %then %do;
		    %if &dec eq 1 %then %do;
		       if pct gt 0  then val = right(put(num,5.)) || " (" || right(put(pct,5.1)) || "%)" || repeat(" ",1);
               else val = right(put(0,5.)) || repeat(" ",10);
            %end;
		    %else %if &dec eq 2 %then %do;
		       if pct gt 0  then val = right(put(num,4.)) || " (" || right(put(pct,6.2)) || "%)" || repeat(" ",1);
               else val = right(put(0,4.)) || repeat(" ",11);
            %end;
		    %else %if %length(&dec) eq 0 %then %do;
		       if pct gt 0  then val = right(put(num,6.)) || " (" || right(put(pct,3.)) || "%)" || repeat(" ",2);
               else val = right(put(0,6.)) || repeat(" ",9);
            %end;
		 %end;
      %end;

	  %else %do;
	     %if &valpos eq 1 %then %do; 
            if pct gt 0  then val = right(put(num,6.)) || repeat(" ",9);
            else val = right(put(0,6.)) || repeat(" ",9);
         %end;
	     %else %if &valpos eq 11 %then %do; 
            if pct gt 0  then val = right(put(num,5.)) || repeat(" ",10);
            else val = right(put(0,5.)) || repeat(" ",10);
         %end;
	     %else %if &valpos eq 12 %then %do; 
            if pct gt 0  then val = right(put(num,5.)) || repeat(" ",10);
            else val = right(put(0,5.)) || repeat(" ",10);
         %end;
	     %else %if &valpos eq 2 %then %do; 
            if pct gt 0  then val = right(put(num,6.)) || repeat(" ",9);
            else val = right(put(0,6.)) || repeat(" ",9);
         %end;
	     %else %if &valpos eq 21 %then %do; 
            if pct gt 0  then val = right(put(num,5.)) || repeat(" ",10);
            else val = right(put(0,5.)) || repeat(" ",10);
         %end;
	     %else %if &valpos eq 22 %then %do; 
            if pct gt 0  then val = right(put(num,4.)) || repeat(" ",11);
            else val = right(put(0,4.)) || repeat(" ",11);
         %end;
	     %else %do; 
            if pct gt 0  then val = right(put(num,9.)) || repeat(" ",6);
            else val = right(put(0,9.)) || repeat(" ",6);
         %end;
      %end;
   %end;

   %else %do;
      if missing(num) eq 1 then num = 0;
      else if missing(num) eq 0 and missing(bign) eq 0 then pct = (num/bign)*100;

      %if %length(&pct) gt 0 %then %do;
	     %if &pct eq 1 %then %do;
		    %if &dec eq 1 %then %do;
		       if pct gt 0  then val = right(put(num,5.)) || " (" || right(put(pct,5.1)) || ")" || repeat(" ",2);
               else val = right(put(0,5.)) || repeat(" ",10);
            %end;
		    %else %if &dec eq 2 %then %do;
		       if pct gt 0  then val = right(put(num,5.)) || " (" || right(put(pct,6.2)) || ")" || repeat(" ",1);
               else val = right(put(0,5.)) || repeat(" ",10);
            %end;
		    %else %if %length(&dec) eq 0 %then %do;
		       if pct gt 0  then val = right(put(num,6.)) || " (" || right(put(pct,3.)) || ")" || repeat(" ",3);
               else val = right(put(0,6.)) || repeat(" ",9);
            %end;
         %end;  

	     %else %if &pct eq 2 %then %do;
		    %if &dec eq 1 %then %do;
		       if pct gt 0  then val = right(put(num,5.)) || " (" || right(put(pct,5.1)) || "%)" || repeat(" ",1);
               else val = right(put(0,5.)) || repeat(" ",10);
            %end;
		    %else %if &dec eq 2 %then %do;
		       if pct gt 0  then val = right(put(num,4.)) || " (" || right(put(pct,6.2)) || "%)" || repeat(" ",1);
               else val = right(put(0,4.)) || repeat(" ",11);
            %end;
		    %else %if %length(&dec) eq 0 %then %do;
		       if pct gt 0  then val = right(put(num,6.)) || " (" || right(put(pct,3.)) || "%)" || repeat(" ",2);
               else val = right(put(0,6.)) || repeat(" ",9);
            %end;
		 %end;
      %end;

	  %else %do;
	     %if &valpos eq 1 %then %do; 
            if pct gt 0  then val = right(put(num,6.)) || repeat(" ",9);
            else val = right(put(0,6.)) || repeat(" ",9);
         %end;
	     %else %if &valpos eq 11 %then %do; 
            if pct gt 0  then val = right(put(num,5.)) || repeat(" ",10);
            else val = right(put(0,5.)) || repeat(" ",10);
         %end;
	     %else %if &valpos eq 12 %then %do; 
            if pct gt 0  then val = right(put(num,5.)) || repeat(" ",10);
            else val = right(put(0,5.)) || repeat(" ",10);
         %end;
	     %else %if &valpos eq 2 %then %do; 
            if pct gt 0  then val = right(put(num,6.)) || repeat(" ",9);
            else val = right(put(0,6.)) || repeat(" ",9);
         %end;
	     %else %if &valpos eq 21 %then %do; 
            if pct gt 0  then val = right(put(num,5.)) || repeat(" ",10);
            else val = right(put(0,5.)) || repeat(" ",10);
         %end;
	     %else %if &valpos eq 22 %then %do; 
            if pct gt 0  then val = right(put(num,4.)) || repeat(" ",11);
            else val = right(put(0,4.)) || repeat(" ",11);
         %end;
	     %else %do; 
            if pct gt 0  then val = right(put(num,9.)) || repeat(" ",6);
            else val = right(put(0,9.)) || repeat(" ",6);
         %end;
      %end;
   %end;

   ord = &ord;
   %if %length(&paramty) gt 0 %then %do;
      param = trim(left(&param));
   %end;
   %else %do;
      param = trim(left(put(&param,best.)));
   %end;
   keep &trtn ord val param;
run;

proc sort data = con_sum2;
   by ord param;
run;

proc transpose data = con_sum2 out = con_sum3(drop=_name_) prefix = v;
   %if %upcase(&trtn) ne %upcase(&param) %then %do;
      by ord param;
   %end;
   %else %do;
      by ord;
   %end;
   id trtn;
   var val;
run;

%end;

%if %length(&grp) gt 0 %then %do; 
   data out_t&grp&ord;
      set con_sum3;
      grp = &grp;
%end;
%else %do;
   data out_t&ord;
      set con_sum3;
%end;
	  type = "F";
   run;
%mend freqsum;
