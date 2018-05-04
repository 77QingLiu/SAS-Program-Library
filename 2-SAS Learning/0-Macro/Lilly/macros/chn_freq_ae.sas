/*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME                 : chn_freq_ae.sas
CODE TYPE                 : Limited-use Module
PROJECT NAME (optional)   : 

DESCRIPTION               : Providing 3 levels frequency count  for AE or CM                           

SOFTWARE/VERSION#         : SAS/Version 9.2
INFRASTRUCTURE            : SDD version 3.5

LIMITED-USE MODULES       : n/a

BROAD-USE MODULES         : n/a
INPUT                     : n/a
OUTPUT                    : n/a
 
VALIDATION LEVEL          : 4
REQUIREMENTS              : n/a
ASSUMPTIONS               : Prior to using this macro, users need to create the
                            proper dataset as the input dataset
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
BROAD-USE MODULE/LIMITED-USE MODULE SPECIFIC INFORMATION: n/a

BROAD-USE MODULE TEMPORARY OBJECT PREFIX: n/a

PARAMETERS:
Name                 Type     Default    Description and Valid Values
---------            -------- ---------- --------------------------------------------------
inds	                  required                Input dataset
indemo                  required             input demo dataset
where                 required               
trt                          required                
tnb                       optional                 total groups
type                    optional                 specifies summary text to be printed in the report, for example, Patients with >= 1 TEAE
varorder            required                 the first level order

TYPICAL WAYS TO EXECUTE THIS CODE AND DESCRIPTION, if applicable:

 %freq_ae_cm(inds=&inds, indemo=&indemo,where=(trtn^=.), trt=trtn,varorder=2 );

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

          Author &
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
1.0   Jiashu Li & Xiaofeng Shi        Original version of the code
       
**eoh************************************************************************/

 
%macro chn_freq_ae(inds=,where=, indemo=, trt=, tnb=,type=,varorder=);

%macro sumae(indata=,param=,param2=,out=);
proc freq data=&indata noprint;
   table &trt %if &param ne %then %do;*&param %end;%if &param2 ne %then %do;*&param2 %end;/out=a01(drop=percent);
run;

data a001;
   length count1 $40;
   merge a01 subjto;
   by &trt;
   if count ne . ;
      P=count*100/big_n;
	  count1=right(put(count,5.)) || " (" || right(put(p,5.1)) || ")" ;
run;
%if &param ne %then %do;
proc sort data=a001(where=(missing(&param)=0 %if &param2 ne %then %do;  and missing(&param2)=0 %end;));by &param %if &param2 ne %then %do;&param2%end;;run;
%end;
/*templete*/
%if &param ne %then %do;
   %if %length(&param2) gt 0 %then %do;
  data temp_respa;
    length aesevlnm $400;
    set a001(keep = &param &param2);
                      aesevlnm='Mild';
	                  output ;
	                  aesevlnm='Moderate';
	                  output;
	                  aesevlnm='Severe';
	                  output;
	                  aesevlnm='More Severe Than Baseline';
	                  output;    
  run;
  %end;
  %else %do;
  data temp_respa;
    set a001(keep = &param );                    
  run;
  %end;
  
  proc sort data=temp_respa nodupkey;by &param %if &param2 ne %then %do;  &param2%end;;run;
%end;
%else %do;
data temp_respa;
    set a001(keep = &param );                    
run;
%end;
data temp_respb;
   set temp_respa;
    %do i=1 %to &n;
      &trt=&i ; 
      output; 
    %end; 
run;
  proc sort data=temp_respb;by &trt;run;
data temp_respc;
    merge temp_respb subjto;
	by &trt;
run;
data temp_respd;
   set temp_respc;
    response='Y';                                                                                                                       
    resp_freq=0;                                                                                                                  
    output;                                                                                                                             
    response='N';                                                                                                                       
    resp_freq=big_n;                                                                                                            
    output;        
run;  
/*templete end*/
data A001A;                                                                                                                
    set A001;                                                                                                                    
    response='Y';                                                                                                                       
    resp_freq=count;                                                                                                                  
    output;                                                                                                                             
    response='N';                                                                                                                       
    resp_freq=big_n-count;                                                                                                            
    output;  
  run; 
%if &param ne %then %do;
     %if &param2 ne %then %do;
           proc sort data=temp_respd out=temp_respd1 nodupkey;by &trt  &param &param2  response;run; 
           proc sort data=a001a;by &trt &param &param2 response;run;
           data a001a;
                 merge temp_respd1 a001a;
            	 by &trt &param &param2 response;
           run;
     %end;
     %else %do;
           proc sort data=temp_respd(keep= &trt  &param  response resp_freq) out=temp_respd2 nodupkey;by &trt  &param  response;run; 
           proc sort data=a001a;by &trt &param response;run;
           data a001a;
                 merge temp_respd2 a001a;
            	 by &trt &param response;
           run;
           proc sort data=a001a;by &param descending response;run;
     %end;
 %end;
 %else %do;
  proc sort data=temp_respd(keep= &trt    response resp_freq) out=temp_respd3 nodupkey;by &trt  response;run; 
  proc sort data=a001a;by &trt response;run;
  data a001a;
     merge temp_respd3 a001a;
	 by &trt response;
  run;
 %end;
 
%if &param ne %then %do;
proc sort data=a001a;by &param %if &param2 ne %then %do;  &param2%end;;run;
%end;

proc sql noprint;
 select count(*) into :obsn from a01;
quit;

%put &obsn;
%if &obsn ne 0 and &pval ne  %then %do;
ods listing close;  
ods output FishersExact=pval(where=(Name1="XP2_FISH") drop= table label1 cvalue1);
proc freq data=A001a(where=(&trt^=&n)); 
%if &param ne %then %do;
    by &param  %if &param2 ne %then %do; &param2%end;;
%end; 
    table &trt*response;                                                                                                         
    exact fisher / maxtime=300;                                                                                              
    weight resp_freq;  
run; 
ods listing;
%end;
proc transpose data=a001 out=a001x(drop =_NAME_ );
   var count1 ;
      %if &param ne %then %do;by &param %if  &param2 ne %then %do;    &param2 %end; ;%end;
   id &trt ;
run;
proc transpose data=a001 out=a001y(drop =_NAME_  _LABEL_)  prefix=count;
   var count ;
     %if &param ne %then %do;by &param %if  &param2 ne %then %do;    &param2 %end; ;%end;
   id &trt ;
run;
proc transpose data=a001 out=a001z(drop =_NAME_)  prefix=pct;
   var p ;
      %if &param ne %then %do;by &param %if  &param2 ne %then %do;    &param2 %end; ;%end;
   id &trt ;
run;
%if &obsn ne 0 and &pval ne %then %do;
data &out;
    merge a001x a001y a001z pval;
	 %if &param ne %then %do;by &param %if  &param2 ne %then %do;    &param2 %end; ;%end;
run;
%end;
%else %do;
data &out;
    merge a001x a001y a001z;
	 %if &param ne %then %do;by &param %if  &param2 ne %then %do;    &param2 %end; ;%end;
run;
%end;

%mend;

%if &TNB ne %then %do;%let n=&TNB;%end;
%else %do; 
%let  n=0;
proc sql NOPRINT;
select count (distinct &TRT) into: n from &indemo; 
quit;
%LET N=&N;
%end;
%PUT &N;

proc freq data=&indemo noprint;
   table &trt / out=subjto(drop=percent rename=count=big_n);
run;
/*** total AE  ***/
%if &varorder=1 %then %do;

      proc sort data=&inds    ;
          by usubjid &trt  %if &LEVEL3 ne %then descending &level3;;
      run;

      proc sort data=&inds out=ae1 nodupkey ;
          by usubjid &trt;
      run;

     %sumae(indata=ae1,param=,out=a1);
  
/*total AE By  &level 3*/
   %if &level3 ne %then %do;
    
     %sumae(indata=ae1,param=&level3,out=asev);
/*Dummy data for aesev*/
          data tempc;
              set asev(obs=1); 
                     %if %length(pval) gt 0 %then drop NVALUE1 name1;;
	                 length _1-_&n $40 count1-count&n 8.  pct1-pct&n 8.    &level3 $400;
			              %do i=1%to &n;
	                                _&i='';
									count&i=.;
									pct&i=.;
			              %end; 
                      &level3='Mild';
	                  output ;
	                  &level3='Moderate';
	                  output;
	                  &level3='Severe';
	                  output;
	                  &level3='More Severe Than Baseline';
	                  output;
          run;
		  proc sort data=tempc;by &level3;run;
		  proc sort data=asev;by &level3;run;
          data asev1;
                  merge tempc asev;
               	  by &level3;
          run;
     %end;


     data a1;
           set a1 %if &level3 ne %then asev1;;
     run;
%end;
/*AE By &LEVEL &level 2 and (&level 3 optional)*/
%else %do;
   %if &level2 ne %then %do;
       proc sort data=&inds(where=(&where))  out=ae_1;by usubjid &trt &level &level2 %if &level3 ne %then descending &level3;;run;
       proc sort data=ae_1  out=ae1 nodupkey;                     by usubjid &trt  &level &level2;                                       run;
          %sumae(indata=ae1,param=&level2,out=a003a);

          %if &level3 ne %then %do;
                %sumae(indata=ae1,param=&level2,param2=&level3,out=a003aa);
/*Dummy data for PT&aesev*/
                 data tempca;
                    set a003a; 
                             %if %length(pval) gt 0 %then drop NVALUE1 name1;;
	                         length _1-_&n $40  count1-count&n 8.  pct1-pct&n 8.    &level3 $400;
			                  %do i=1%to &n;
	                                _&i='';
									count&i=.;
									pct&i=.;
			                  %end;  
                        &level3='Mild';
	                    output ;
	                    &level3='Moderate';
	                    output;
	                    &level3='Severe';
	                    output;
	                    &level3='More Severe Than Baseline';
	                    output;
               run;
		       proc sort data=tempca;by &level2 &level3;run;
		       proc sort data=a003aa;by &level2 &level3;run;
               data a003aaa;
                    merge tempca a003aa;
	                  by &level2 &level3;
               run;
           %end;

        data a003af;
              set a003a %if &level3 ne %then a003aaa;;
	          by &level2;
        run;

     %end;
   %if &level ne %then %do;
       proc sort data=&inds(where=(&where))  out=ae_2;by usubjid &trt &level %if &level3 ne %then descending &level3;;run;
       proc sort data=ae_2 out=ae2 nodupkey;                      by usubjid &trt  &level;                                                                                  run;

/*AE By &level  and &level 3*/
           %sumae(indata=ae2,param=&level,out=a003b);

          %if &level3 ne %then %do;
                 %sumae(indata=ae2,param=&level,param2=&level3,out=a003bb);
/*Dummy data for SOC&aesev*/
                        data tempcb;
                           set a003b; 
                             %if %length(pval) gt 0 %then drop NVALUE1 name1;;
	                         length _1-_&n $40  count1-count&n 8.  pct1-pct&n 8.    &level3 $400;
			                  %do i=1%to &n;
	                                _&i='';
									count&i=.;
									pct&i=.;
			                  %end; 
                             &level3='Mild';
	                         output ;
	                         &level3='Moderate';
	                         output;
	                         &level3='Severe';
	                         output;
	                          &level3='More Severe Than Baseline';
	                          output;
                      run;
					  proc sort data=tempcb;by &level &level3;run;
					  proc sort data=a003bb;by &level &level3;run;
                      data a003bbb;
                           merge tempcb a003bb;
	                       by &level &level3;
                      run;
           %end;

       data a003bf;
            set a003b %if &level3 ne %then a003bbb;;
	        by &level;
       run;
   %end;
       data atotal;
            set %if &level ne %then a003bf %if &level2 ne %then a003aF;;
       run;
%end;

/*insert blank trt column*/
/*       data temp;*/
/*            set atotal;*/
/*	          length _1-_&n $40   count1-count&n 8.  pct1-pct&n 8.  ;*/
/*			   %do i=1%to &n;*/
/*	               _&i='';	*/
/*                   count&i=.;*/
/*				   pct&i=.;*/
/*			   %end;*/
/*	        if 0;*/
/*       run;*/
/*For the first line total TEAE - add varorder and fill "" in blank column*/
%if &varorder=1 %then %do;
       data alldata;
          length varorder 8.   _1-_&n $40;
            set A1;
	           retain ord ordn ordnn;
	           varorder=&varorder ;
	           ord=-999;ordn=-999;ordnn=-999;
			       %do i=1%to &n;
	                   if _&i='' then _&i=right(put(0,5.)) ||" (" || right('  0.0') || ")";
				   %end;
        run;
/*For the first line total TEAE - add &type*/
        data stat_rpt;
	       length  type $100 ;
             set alldata;
             %if &level3 ne %then %do;	             
		          if  missing(&level3)=0 then type=repeat('',1)|| &level3;
				 else type="&type";
		     %end;
             %else %do;
				  type="&type";
		     %end;
        run;
%end;
/*output sort variable*/
%else %do;
   data alldata;
             length varorder 8.     _1-_&n $40 %if &level ne %then &level $400  %if &level2 ne %then &level2 $250;;
             set Atotal;
	         by &level2;
	           %if &level3 ne %then retain ord /*ordn ordnn*/;;
	           varorder=&varorder ;
			    %if &level ne %then %do;
	                 if  &level^=''  %if &level2 ne %then %do; and &level2='' %end; then do;ord=-888;ordn=-888;ordnn=-888;end;
	                 else if &level='' %if &level2 ne %then %do; and &level2^='' %end; %if &level3 ne %then %do;and missing(&level3) %end; then do;
                         if index(_&n,'(')>0 then ord=(-1)*input(scan(_&n,1,'('),best.);						 
                         if index(_%eval(&n-1),'(')>0 then ordn=(-1)*input(scan(_%eval(&n-1),1,'('),best.);							 
                         if index(_%eval(&n-2),'(')>0 then ordnn=(-1)*input(scan(_%eval(&n-2),1,'('),best.);						 
                     end;
                %end;
				%else %do;
				  %if &level3 ne %then %do;
                        if missing(&level3) then do;
                          if index(_&n,'(')>0 then ord=(-1)*input(scan(_&n,1,'('),best.);						 
                         if index(_%eval(&n-1),'(')>0 then ordn=(-1)*input(scan(_%eval(&n-1),1,'('),best.);							 
                         if index(_%eval(&n-2),'(')>0 then ordnn=(-1)*input(scan(_%eval(&n-2),1,'('),best.);		
					 end;	
                   %end; 
				  %else %do;
                          if index(_&n,'(')>0 then ord=(-1)*input(scan(_&n,1,'('),best.);						 
                         if index(_%eval(&n-1),'(')>0 then ordn=(-1)*input(scan(_%eval(&n-1),1,'('),best.);							 
                         if index(_%eval(&n-2),'(')>0 then ordnn=(-1)*input(scan(_%eval(&n-2),1,'('),best.);		
					%end;
                %end;
                  %do i=1%to &n;
	                   if _&i='' then _&i=right(put(0,5.)) ||" (" || right('  0.0') || ")";
				   %end;
        run;

        proc sort data=alldata;by varorder  ord &level2; run;
   data stat_rpt; 
             set stat_rpt alldata;
          %if &level3 ne %then %do;
		      %if &level ne % then %do;
		          if  missing(&level3)=0 then type=repeat('',2)|| &level3;
		          else if  &level^=''  and &level2='' then type=&level;
		          else if  &level=''  and &level2^='' and &level3=''   then type=repeat('',1)|| &level2;
			   %end;
		      %else %do;
		          if  missing(&level3)=0 then type=repeat('',2)|| &level3;
		          else if  &level2^='' and &level3=''   then type=repeat('',1)|| &level2;
			   %end;
		  %end;
		  %else %if &level2 ne and &level ne %then %do; 
		          if  &level^=''  and &level2=''   then type= &level;
		          else if  &level=''   and &level2^=''   then type=repeat('',1)||&level2;
		  %end;
		  %else %if &level2 ne  %then %do; 
		          if  &level2^=''  then type= repeat('',1)|| &level2;
		  %end;
		  %else %if  &level ne %then %do; 
		          if  &level^=''  then type= &level;
		  %end;
	    run;
%end;
%mend ;
