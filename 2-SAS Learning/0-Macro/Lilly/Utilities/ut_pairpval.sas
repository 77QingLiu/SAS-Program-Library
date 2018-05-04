%macro ut_pairpval(inds                     = _default_,
                   outds_prefix             = _default_,
                   allow_t1_gt_t2           = _default_,
                   allow_t1pool_t2nonpool   = _default_,
                   allow_t1nonpool_t2pool   = _default_,
                   allow_t1pool_t2pool      = _default_,
                   allow_nonexclusive_pools = _default_,
                   switch_treatments        = _default_,
                   debug                    = _default_,
                   verbose                  = _default_         
                   );
                                                                                            
/*soh**************************************************************************************                             
Eli Lilly and Company - Global Statistical Sciences                                                                     
CODE NAME           :  ut_pairpval                                                                                      
CODE TYPE           :  Broad-use Module                                                                                 
PROJECT NAME        :                                                                                                   
DESCRIPTION         :  Verify and edit the value of a macrovariable called                                              
                       PAIRPVAL, which contains treatment code pairs to be used for                                     
                       pairwise comparisons, according to the syntax rules                                              
                       described in the Usage Notes below. Set the error status                                         
                       flag and print the appropriate message if the value is                                           
                       invalid. Change the value of PAIRPVAL into a standardized                                        
                       form.                                                                                            
SOFTWARE/VERSION#   :  SAS/Version 9                                                                                    
INFRASTRUCTURE      :  SDD                                                                                              
LIMITED-USE MODULES :  N/A                                                                                              
BROAD-USE MODULES   :  ut_chk_ds, ut_chk_var, ut_errmsg, ut_logical, ut_parmcheck,                                      
                       ut_parmdef, ut_restore_env, ut_titlstrt                                                          
INPUT               :  A SAS data sets as specified by parameter INDS.                                                  
OUTPUT              :  Output SAS datasets are created to contain pairwise                                              
                       treatment info. The value of macrovariable PAIRPVAL may be                                       
                       changed. See Usage Notes below.                                                                  
VALIDATION LEVEL    :  6                                                                                                
REQUIREMENTS        :  /lillyce/qa/general/bums/ut_pairpval/documentation/                                              
                         ut_pairpval_rd.doc                                                                             
ASSUMPTIONS          : Macrovariable PAIRPVAL exists prior to execution of the                                      
                       module.                                                                                      
------------------------------------------------------------------------------------------                              
------------------------------------------------------------------------------------------                              
BROAD-USE MODULE SPECIFIC INFORMATION:    N/A                                                                           
BROAD-USE MODULE TEMPORARY OBJECT PREFIX: _AV                                                                           
                                                                                                                        
PARAMETERS:                                                                                                             
                                                                                                                        
Name                       Type      Default         Description and Valid Values                                       
------------------------   --------  -------------   -------------------------------------                              
INDS                       required  N/A             The input dataset name.                                            
                                                                                                                        
OUTDS_PREFIX               optional  N/A             The prefix for the output datasets.                                
                                                                                                                        
ALLOW_T1_GT_T2             required  1               The option to allow treatment pairs                                
                                                     (t1, t2) in which t1 > t2 (when                                    
                                                     neither t1 nor t2 contains pooled                                  
                                                     codes).                                                            
                                                                                                                        
ALLOW_T1POOL_T2NONPOOL     required  1               The option to allow pooling in the                                 
                                                     first treatment expression t1 in a                                 
                                                     treatment pair (t1,t2) when the                                    
                                                     second treatment expression t2 does                                
                                                     not contain pooled codes.                                          
                                                                                                                        
ALLOW_T1NONPOOL_T2POOL     required  1               The option to allow pooling in the                                 
                                                     second treatment expression t2 in a                                
                                                     treatment pair (t1,t2) when the                                    
                                                     first treatment expression t1 does                                 
                                                     not contain pooled codes.                                          
                                                                                                                        
ALLOW_T1POOL_T2POOL        required  1               The option to allow pooling in both                                
                                                     treatment expressions t1 and t2 in a                               
                                                     treatment pair (t1,t2).                                            
                                                                                                                        
ALLOW_NONEXCLUSIVE_POOLS   required  1               The option to allow a treatment code                               
                                                     that is part of a group of pooled                                  
                                                     codes to also be used as an                                        
                                                     individual treatment or in other                                   
                                                     pools that do not consist of the                                   
                                                     same treamtent codes                                               
                                                                                                                        
SWITCH_TREATMENTS          required  0               The option to automatically adjust                                 
                                                     the value of PAIRPVAL by switching                                 
                                                     the order of the treatments (t1,t2)                                
                                                     within a pair when the pair is                                     
                                                     invalid and revsersing the order                                   
                                                     results in a valid pair.                                           
                                                                                                                        
DEBUG                      required  0               A %ut_logical value specifying                                     
                                                     whether debug mode is on or off.                                   
                                                                                                                        
VERBOSE                    required  1               A %ut_logical value specifying                                     
                                                     whether verbose mode is on or off.                                 
                                                                                                                        
------------------------------------------------------------------------------------------                              
USAGE NOTES:                                                                                                            
                                                                                                                        
This macro is to be used outside of a DATA Step/Procedure.                                                              
                                                                                                                        
The correct syntax for PAIRPVAL is: p1 * p2 * … * pn, where each pair pi is a unique                                    
treatment pair in the form (t1,t2) (parentheses included), and t1 and t2 represent                                      
different values of numeric variable TRTSORT in the input dataset.                                                      
                                                                                                                        
Alternatively, the value of PAIRPVAL may be the word ALL, which represents the option                                   
to analyze all possible treatment pairs based on the available data, with no pooling.                                   
                                                                                                                        
Depending on the options specified, either treatment code t1 or t2 or both may be                                       
replaced with a string of multiple treatment codes, delimited by the plus sign (+),                                     
to be pooled in the analysis.                                                                                           
                                                                                                                        
All treatment codes included in the value of PAIRPVAL must be values of TRTSORT in                                      
the input dataset.                                                                                                      
                                                                                                                        
If there are fewer than three distinct non-missing values of variable TRTSORT in the                                    
the input dataset, then PAIRPVAL must have a null value.                                                                
                                                                                                                        
The module includes an option to edit the value of PAIRPVAL by reversing the order of                                   
treatments within a pair (t1,t2) if doing so results in a valid value.                                                  
                                                                                                                        
The module creates output datasets containing treatment data for use in further                                         
development.                                                                                                            
                                                                                                                        
Please refer to the requirments document for more details.                                                              
                                                                                                                        
------------------------------------------------------------------------------------------                              
TYPICAL MACRO CALL AND DESCRIPTION:                                                                                     
                                                                                                                        
The following macro call attempts to verify a string of                                                                 
treatment code pairs that contains an invalid group of                                                                  
pooled treatments:                                                                                                      
                                                                                                                        
%ut_pairpval(inds                     = testdata,                                                                       
             outds_prefix             = trtdata,                                                                        
             allow_t1_gt_t2           = 1,                                                                              
             allow_t1pool_t2nonpool   = 1,                                                                              
             allow_t1nonpool_t2pool   = 1,                                                                              
             allow_t1pool_t2pool      = 1,                                                                              
             allow_nonexclusive_pools = 1,                                                                              
             switch_treatments        = 1,                                                                              
             debug                    = 1,                                                                              
             verbose                  = 1                                                                               
             );                                                                                                         
------------------------------------------------------------------------------------------                              
------------------------------------------------------------------------------------------                              
REVISION HISTORY SECTION:                                                                                               
                                                                                                                        
        Author &                                                                                                        
Ver#    Peer Reviewer    Request #         Code History Description                                                     
------------------------------------------------------------------------------------------                              
1.0     Craig Hansen                       Original Version of the Code                                                 
        Melinda Rodgers                    BMRCSH15JUN2010A                                                                                     
                                                                                        
**eoh**************************************************************************************/                            
    
%local i j k _pfx save_pairpval _editflg
       _numtrt _only _pwval _trtexp _trtcode _trtvals _ts;      

%*===========================================;  
%*  Set prefix assigned to this module       ;  
%*===========================================;  
%let _pfx = _AV;                    


%*===========================================;  
%*                                           ;  
%*        Begin Parameter Checking           ;  
%*                                           ;  
%*===========================================;  

%** Automated parameter checking **;            
%ut_parmcheck(ut_pairpval,1);       

%** Exit on error **;               
%if &error_status %then %do;        
  %ut_errmsg(msg=%sysfunc(compbl("An invalid condition has been detected.     
    The macro will stop executing.")),          
                  type=error,print=0,macroname=ut_pairpval);                  
  %return;                          
%end; 

%** Delete temporary datasets from previous runs **;                          
%ut_restore_env(prefixlist=&_pfx,optds=,debug=0);                             

%** Save SAS system option values **;           
proc optsave out=&_pfx.optsave;     
run;  

%** Set standard options for production mode **;
%if ^&debug %then %do;              
  options nomprint nomlogic nosymbolgen;        
%end; 

%** Check for the existince of macrovariable PAIRPVAL **;    
%if ^%symexist(pairpval) %then %do;
  %ut_errmsg(msg=%sysfunc(compbl("Macrovariable PAIRPVAL does not exist. There is
      no expression for UT_PAIRPVAL to process.")),          
                  type=warning,print=0,macroname=ut_pairpval);                  
  %return;
%end;

%** Verify OUTDS_PREFIX does not exceed ten characters in length **;    
%if %length(%bquote(&outds_prefix))>10 %then %do;
  %ut_errmsg(msg=%sysfunc(compbl("The value specified for OUTDS_PREFIX exceeds the maximum length of 
  ten characters.  The value will be truncated.")),          
                  type=warning,print=0,macroname=ut_pairpval);                  
  %let outds_prefix=%sysfunc(substr(%bquote(&outds_prefix),1,10));
%end;

%** Save value of PAIRPVAL for comparison later **;
%let save_pairpval = &pairpval;


%*===========================================;  
%*                                           ;  
%*   Begin BUM Main Processing Section       ;  
%*                                           ;  
%*===========================================;  

%** Get the number and list of actual treatment codes from the data **;
%let _numtrt = 0;
data &_pfx.temp;
  set &inds;
  where trtsort^=.;
run;
proc sql noprint;
  select distinct trtsort into : _trtvals separated by ' '        from &_pfx.temp;
  select strip(put(count(distinct trtsort),best.)) into : _numtrt from &_pfx.temp;
quit;

%if %bquote(&pairpval)^= %then %do;

  %** Verify there are at least three distinct values of TRTSORT in the data **;
  %if &_numtrt < 3 %then %do;
    %ut_errmsg(msg=%sysfunc(compbl("A non-null value of PAIRPVAL is invalid
    when there are fewer than three distinct non-missing TRTSORT values in dataset
    %qupcase(&inds).")),
               type=error,print=0,macroname=ut_pairpval);
    %let error_status=1; 
    %return; 
  %end;

  %** Create an explicit list of ALL treatment pairs if specified **;
  %if %qupcase(%bquote(&pairpval))=ALL %then %do;
    %let pairpval=;
    %do i=1 %to &_numtrt;
      %do j=&i+1 %to &_numtrt; 
        %if &i^=1 or &j^=2 
          %then %let pairpval=&pairpval*(%scan(&_trtvals,&i),%scan(&_trtvals,&j));
          %else %let pairpval=          (%scan(&_trtvals,&i),%scan(&_trtvals,&j));
      %end;
    %end;
  %end;

  %** Verify there are no invalid characters **;
  %if %sysfunc(verify(%bquote(&pairpval),%bquote(+*(),1234567890 ))) %then %do; 
    %ut_errmsg(msg=%sysfunc(compbl("PAIRPVAL is in an invalid format. An invalid character
  was found.")),
               type=error,print=0,macroname=ut_pairpval);
    %let error_status=1; 
    %return; 
  %end;

  %** Verify there are no blank pairs **;
  %let pairpval = %qsysfunc(left(%bquote(&pairpval)));
  %let pairpval = %qsysfunc(trim(%bquote(&pairpval)));
  %do %while(%index(%bquote(&pairpval),%nrstr(* )));
    %let pairpval = %qsysfunc(tranwrd(%bquote(&pairpval),%nrstr(* ),%nrstr(*)));
  %end;
  %do %while(%index(%bquote(&pairpval),%nrstr( *)));
    %let pairpval = %qsysfunc(tranwrd(%bquote(&pairpval),%nrstr( *),%nrstr(*)));
  %end;
  %if %qsysfunc(substr(%bquote(&pairpval),1,1))=%nrstr(*) %then %do;
    %ut_errmsg(msg=%sysfunc(compbl("PAIRPVAL is in an invalid format. The value specified
       must begin with a left parenthesis.")),
               type=error,print=0,macroname=ut_pairpval);
    %let error_status=1; 
    %return; 
  %end;
  %else %if %qsysfunc(substr(%bquote(&pairpval),%length(&pairpval),1))=%nrstr(*) %then %do; 
    %ut_errmsg(msg=%sysfunc(compbl("PAIRPVAL is in an invalid format. The value specified
       must end with a right parenthesis.")),
               type=error,print=0,macroname=ut_pairpval);
    %let error_status=1;
    %return; 
  %end;
  %else %if %index(%bquote(&pairpval),%nrstr(**)) %then %do; 
    %ut_errmsg(msg=%sysfunc(compbl("PAIRPVAL is in an invalid format. The value specified
       cannot have consecutive asterisks with no treatment pairs in between.")), 
               type=error,print=0,macroname=ut_pairpval);
    %let error_status=1; 
    %return;
  %end;

  %** Loop through the pairs **;
  %let i = 1;
  %do %while(%qscan(%bquote(&pairpval),&i,*)^=);
    %let _pwval = %qscan(%bquote(&pairpval),&i,*);
    %let _pwval = %qsysfunc(left(%bquote(&_pwval)));
    %let _pwval = %qsysfunc(trim(%bquote(&_pwval)));

    %** Verify the pair is enclosed in parentheses **;
    %if %qsysfunc(substr(%bquote(&_pwval),1,1))^=%nrstr(%() or 
        %qsysfunc(substr(%bquote(&_pwval),%length(&_pwval),1))^=%nrstr(%)) 
    %then %do;
      %ut_errmsg(msg=%sysfunc(compbl("PAIRPVAL is in an invalid format. Each treatment
        pair must be enclosed in parentheses ( ).")), 
                 type=error,print=0,macroname=ut_pairpval); 
      %let error_status=1; 
      %return; 
    %end;
    %else %do;
      %let _pwval = %qsysfunc(substr(%bquote(&_pwval),2,%eval(%length(&_pwval)-2)));
    %end;

    %** Verify the pair contains exactly one comma **;
    %if %sysfunc(countc(&_pwval,%str(,)))^=1 %then %do; 
      %ut_errmsg(msg=%sysfunc(compbl("PAIRPVAL is in an invalid format. Each treatment
        pair must contain two codes separated by one comma (<trtcd1>,<trtcd2>).")), 
                 type=error,print=0,macroname=ut_pairpval); 
      %let error_status=1; 
      %return; 
    %end;

    %** Loop through the two treatments in the pair **;
    %do j = 1 %to 2; 
      %let _trtexp = %scan(%bquote(&_pwval),&j,%str(,));

      %** Verify the treatment is not null **;
      %if %bquote(&_trtexp)= %then %do; 
        %ut_errmsg(msg=%sysfunc(compbl("PAIRPVAL is in an invalid format. Both treatment codes
          in each treatment pair must be present (<trtcd1>,<trtcd2>).")), 
                   type=error,print=0,macroname=ut_pairpval); 
        %let error_status=1; 
        %return; 
      %end;

      %let _trtexp = %qsysfunc(left(%bquote(&_trtexp)));
      %let _trtexp = %qsysfunc(trim(%bquote(&_trtexp)));

      %** Verify there are no blank treatments within a pooled group **;
      %do %while(%index(%bquote(&_trtexp),%nrstr(+ )));
        %let _trtexp = %qsysfunc(tranwrd(%bquote(&_trtexp),%nrstr(+ ),%nrstr(+)));
      %end;
      %do %while(%index(%bquote(&_trtexp),%nrstr( +)));
        %let _trtexp = %qsysfunc(tranwrd(%bquote(&_trtexp),%nrstr( +),%nrstr(+)));
      %end;
      %if %qsysfunc(substr(%bquote(&_trtexp),1,1))=%nrstr(+) %then %do; 
        %ut_errmsg(msg=%sysfunc(compbl("PAIRPVAL is in an invalid format. Groups of pooled 
  treatments must begin with a treatment code. The plus sign (+) must be placed between 
  treatment codes only.")),
                   type=error,print=0,macroname=ut_pairpval); 
        %let error_status=1; 
        %return; 
      %end;
      %else %if %qsysfunc(substr(%bquote(&_trtexp),%length(&_trtexp),1))=%nrstr(+) %then %do;
        %ut_errmsg(msg=%sysfunc(compbl("PAIRPVAL is in an invalid format. Groups of pooled 
  treatments must end with a treatment code. The plus sign (+) must be placed between 
  treatment codes only.")),  
                   type=error,print=0,macroname=ut_pairpval); 
        %let error_status=1; 
        %return; 
      %end;
      %else %if %index(%bquote(&_trtexp),%nrstr(++)) %then %do; 
        %ut_errmsg(msg=%sysfunc(compbl("PAIRPVAL is in an invalid format. Groups of pooled 
  treatments cannot contain consecutive plus signs with no treatment codes in between.")),
                   type=error,print=0,macroname=ut_pairpval); 
        %let error_status=1; 
        %return; 
      %end;

      %** Loop through the treatment codes within a pooled group **;
      %let k = 1;
      %do %while(%scan(%bquote(&_trtexp),&k,+)^=);
        %let _trtcode = %qscan(%bquote(&_trtexp),&k,+);
        %let _trtcode = %qsysfunc(left(%bquote(&_trtcode)));
        %let _trtcode = %qsysfunc(trim(%bquote(&_trtcode)));

        %** Verify there are no invalid codes within the treatment **;
        %if %qsysfunc(verify(%bquote(&_trtcode),%nrstr(1234567890))) %then %do;
          %ut_errmsg(msg=%sysfunc(compbl("PAIRPVAL is in an invalid format. An invalid
  character was found in one of the treatment pairs.")),
                   type=error,print=0,macroname=ut_pairpval);  
          %let error_status=1;
          %return;
        %end;

        %** Verify all treatment codes are found in the source data **;
        %if ^%qsysfunc(indexw(&_trtvals,&_trtcode)) %then %do;
          %ut_errmsg(msg=%sysfunc(compbl("A treatment code specified on PAIRPVAL 
  is not found in input dataset %upcase(&inds)")),
                     type=error,print=0,macroname=ut_pairpval);
          %let error_status = 1;
          %return;
        %end;

        %** Load treatment codes into a dataset **;
        %if &i=1 and &j=1 and &k=1 %then %do;
          data &_pfx.bytrtcd; delete; run;
        %end;
        data &_pfx.tempnew;
          pairnum   = &i;
          trtexpnum = &j;
          trtcd     = &_trtcode;
        run;
        data &_pfx.bytrtcd;
          set &_pfx.bytrtcd &_pfx.tempnew;
        run;
        %let k = %eval(&k+1);
      %end;  %** End of k-loop through pooled trt codes delimited by plus sign **;
    %end;    %** End of j-loop through the two trt expressions delimited by comma **;
    %let i = %eval(&i+1);
  %end;  %** End of i-loop through pairs delimited by astersisk **;

  %** Check for duplicate treatment codes within a pool **;
  proc sort data=&_pfx.bytrtcd;
    by pairnum trtexpnum trtcd;
  run;
  data &_pfx.check;
    set &_pfx.bytrtcd;
    by pairnum trtexpnum trtcd;
    if ^first.trtcd then call symputx('error_status','1','G');
  run;
  %if &error_status %then %do;
    %ut_errmsg(msg=%sysfunc(compbl("A group of pooled treatments in the value of 
  PAIRPVAL contains a duplicate treatment code.")),
               type=error,print=0,macroname=ut_pairpval);
    %let error_status = 1;
    %return;
  %end;

  %** Create dataset with one obs per treatment expression **;
  data &_pfx.bytrt;
    length trtexp $50;
    retain trtexp;
    set &_pfx.bytrtcd;
    by pairnum trtexpnum;
    if first.trtexpnum then trtexp = left(put(trtcd,best.));
                       else trtexp = cats(trtexp,'+',put(trtcd,best.));
    if last.trtexpnum then output;
    drop trtcd;
  run;
  data &_pfx.bytrtcd;
    merge &_pfx.bytrtcd &_pfx.bytrt;
    by pairnum trtexpnum;
  run;

  %** Check for same treatment code used in different pools or treatments **;
  %if ^&allow_nonexclusive_pools %then %do;
    proc sort data=&_pfx.bytrtcd out=&_pfx.check(keep=trtcd trtexp) nodupkey;
      by trtcd trtexp;
    run;
    data _null_; 
      set &_pfx.check;
      by trtcd;
      if ^first.trtcd then do;
        call symputx('error_status','1','G');
        stop;
      end;
    run;
    %if &error_status %then %do;
      %ut_errmsg(msg=%sysfunc(compbl("A treatment code in the value of PAIRPVAL was found in
    in multiple sets of pooled treatments, or as both a pooled and an individual treatment.")),
                 type=error,print=0,macroname=ut_pairpval);
      %let error_status = 1;
      %return;
    %end;
  %end; %** End of ALLOW_NONEXCLUSIVE_POOLS = FALSE **;

  %** Create by-pair dataset with a variable for each treatment expression **;
  proc transpose data=&_pfx.bytrt out=&_pfx.bytrtpair(drop=_name_) prefix=trtexp;
    var trtexp;
    id trtexpnum;
    by pairnum; 
  run;

  %** Check for duplicate treatment expressions within a pair **;
  data _null_;
    set &_pfx.bytrtpair;
    if trtexp1 = trtexp2 then do;
      call symputx('error_status','1','G');
      stop;
    end;
  run;
  %if &error_status %then %do;
    %ut_errmsg(msg=%sysfunc(compbl("At least one treatment pair in the value of
  PAIRPVAL contains two identical treatments. The two treatments within each pair 
  must be different.")),
               type=error,print=0,macroname=ut_pairpval);
    %let error_status = 1;
    %return;
  %end;

  %let _editflg = 0;

  %** Verify pooling only specified where allowed **;
  %if ^&allow_t1pool_t2nonpool | ^&allow_t1nonpool_t2pool | ^&allow_t1pool_t2pool 
  %then %do;
    %if &allow_t1pool_t2pool %then %let _only = only;
                             %else %let _only = ;
    %if ^&allow_t1pool_t2nonpool and ^&allow_t1nonpool_t2pool and ^&allow_t1pool_t2pool 
    %then %do;
      data _null_;
        set &_pfx.bytrtpair;
        if index(trtexp1,'+') | index(trtexp2,'+') then do;
          call symputx('error_status','1','G');
          stop;
        end;
      run;
      %if &error_status %then %do;
        %ut_errmsg(msg=%sysfunc(compbl("The value of PAIRPVAL cannot contain any pooled
     treatment codes in the requested analysis. The plus sign is an invalid character.")),
                   type=error,print=0,macroname=ut_pairpval);
        %return;
      %end;
    %end;  %** End of no pooling allowed **;
    %else %if ^&allow_t1pool_t2pool %then %do;
      data _null_;
        set &_pfx.bytrtpair;
        if index(trtexp1,'+') and index(trtexp2,'+') then do;
          call symputx('error_status','1','G');
          stop;
        end;
      run;
      %if &error_status %then %do;
        %ut_errmsg(msg=%sysfunc(compbl("The value of PAIRPVAL cannot contain any treatment
  pairs in which both treatments contain pooled treatment codes.")),
                   type=error,print=0,macroname=ut_pairpval);
        %return;
      %end;
    %end;  %** End of pooling not allowed in both treatments **;
    %else %if ^&allow_t1nonpool_t2pool and ^&allow_t1pool_t2nonpool %then %do;
      data _null_;
        set &_pfx.bytrtpair;
        if (^index(trtexp1,'+') and index(trtexp2,'+')) |
           (^index(trtexp2,'+') and index(trtexp1,'+')) 
        then do;
          call symputx('error_status','1','G');
          stop;
        end;
      run;
      %if &error_status %then %do;
        %ut_errmsg(msg=%sysfunc(compbl("The value of PAIRPVAL cannot contain any treatment
  pairs in which only one but not both of the treatments contain pooled treatment codes.")),
                   type=error,print=0,macroname=ut_pairpval);
        %return;
      %end;
    %end;  %** End of pooling not allowed in one treatment only **;
    %if ^&switch_treatments %then %do;
      %if ^&allow_t1pool_t2nonpool %then %do;
        data _null_;
          set &_pfx.bytrtpair;
          if index(trtexp1,'+') and ^index(trtexp2,'+') then do;
            call symputx('error_status','1','G');
            stop;
          end;
        run;
        %if &error_status %then %do;
          %ut_errmsg(msg=%sysfunc(compbl("The value of PAIRPVAL cannot contain any treatment
    pairs in which &_only the first treatment contains pooled treatment codes.")),
                     type=error,print=0,macroname=ut_pairpval);
          %return;
        %end;
      %end;  %** End of pooling not allowed in the first treatment only **;
      %if ^&allow_t1nonpool_t2pool %then %do;
        data _null_;
          set &_pfx.bytrtpair;
          if ^index(trtexp1,'+') and index(trtexp2,'+') then do;
            call symputx('error_status','1','G');
            stop;
          end;
        run;
        %if &error_status %then %do;
          %ut_errmsg(msg=%sysfunc(compbl("The value of PAIRPVAL cannot contain any treatment
    pairs in which &_only the second treatment contains pooled treatment codes.")),
                     type=error,print=0,macroname=ut_pairpval);
          %return;
        %end;
      %end; %** End of pooling not allowed in the second treatment only **;
    %end;   %** End of SWITCH_TREATMENTS = FALSE **;
    %else %do;
      %if ^&allow_t1pool_t2nonpool and &allow_t1nonpool_t2pool %then %do;
        data &_pfx.bytrtpair(drop=tempstr);
          length tempstr $50;
          set &_pfx.bytrtpair;
          if index(trtexp1,'+') and ^index(trtexp2,'+') then do;
            tempstr = trtexp2;
            trtexp2 = trtexp1;
            trtexp1 = tempstr;
            call symputx('_editflg','1','L'); 
          end;
        run;
      %end;  %** End of pooling not allowed in the first treatment only **;
      %else %if &allow_t1pool_t2nonpool and ^&allow_t1nonpool_t2pool %then %do;
        data &_pfx.bytrtpair(drop=tempstr);
          length tempstr $50;
          set &_pfx.bytrtpair;
          if ^index(trtexp1,'+') and index(trtexp2,'+') then do;
            tempstr = trtexp2;
            trtexp2 = trtexp1;
            trtexp1 = tempstr;  
            call symputx('_editflg','1','L');
          end;
        run;
      %end;  %** End of pooling not allowed in the first treatment only **;
    %end;    %** End of SWITCH_TREATMENTS = TRUE **;
  %end;      %** End of pooling restricted **;

  %** Verify correct order of non-pooled treatment codes **;
  %if ^&allow_t1_gt_t2 %then %do;
    %if ^&switch_treatments %then %do;
      data _null_;
        set &_pfx.bytrtpair;
        if ^index(trtexp1,'+') and ^index(trtexp2,'+') then do;
          if . < input(trtexp2,?? 32.) < input(trtexp1,?? 32.) then do;
            call symputx('error_status','1','G');
            stop;
          end;
        end;
      run;
      %if &error_status %then %do;
        %ut_errmsg(msg=%sysfunc(compbl("The value of PAIRPVAL contains a pair in which
    the higher treatment code comes before the lower code. The codes must be in ascending
    order.")),
                   type=error,print=0,macroname=ut_pairpval);
        %return;
      %end;
    %end;  %** End of SWITCH_TREATMENTS = FALSE **;
    %else %do;
      data &_pfx.bytrtpair(drop=tempstr);
        length tempstr $50;
        set &_pfx.bytrtpair;
        if ^index(trtexp1,'+') and ^index(trtexp2,'+') then do;
          if . < input(trtexp2,?? 32.) < input(trtexp1,?? 32.) then do;
            tempstr = trtexp2;
            trtexp2 = trtexp1;
            trtexp1 = tempstr;  
            call symputx('_editflg','1','L'); 
          end;
        end;
      run;
    %end;  %** End of SWITCH_TREATMENTS = TRUE **;
  %end;  %** End of ALLOW_T1_GT_T2 = FALSE **;

  %** Check for duplicate treatment pairs **;
  proc sort data=&_pfx.bytrtpair out=&_pfx.check;
    by trtexp1 trtexp2;
  run;
  data _null_;
    set &_pfx.check;
    by trtexp1 trtexp2;
    if ^first.trtexp2 then do;
      call symputx('error_status','1','G');
      stop;
    end;
  run;
  %if &error_status %then %do;
    %ut_errmsg(msg=%sysfunc(compbl("A duplicate treatment pair was found in the value of
  PAIRPVAL.")),
               type=error,print=0,macroname=ut_pairpval);
    %let error_status = 1;
    %return;
  %end;

  %** Update the value of PAIRPVAL **;
  proc sql noprint;
    select cats('(',trtexp1,',',trtexp2,')') into : pairpval separated by '*'
    from &_pfx.bytrtpair
    ;
  quit;

  %** Display note if PAIRPVAL is valid **;
  %if &verbose %then %do;
    %if ^&_editflg %then %do;
      %ut_errmsg(msg=%sysfunc(compbl("The value specified for PAIRPVAL is valid.")),
                 type=note,print=0,macroname=ut_pairpval);
    %end;
    %else %do;
      %ut_errmsg(msg=%sysfunc(compbl("The value specified for PAIRPVAL was not valid
  as specified, but was edited to a valid value.")),
                 type=note,print=0,macroname=ut_pairpval);
    %end;
  %end;

%end; %** End of PAIRPVAL is not null **;
%else %do;

  %if &verbose %then %do;
    %ut_errmsg(msg=%sysfunc(compbl("A null value was specified for PAIRPVAL.")),
               type=note,print=0,macroname=ut_pairpval);
  %end;

  %** Create dataset containing treatment info when PAIRPVAL is null **; 
  %if %bquote(&outds_prefix)^= or &debug %then %do;
    data &_pfx.bytrtcd;
      length trtexp $50;
      pairnum = 0;
      %do i=1 %to &_numtrt;
        %do j=&i+1 %to &_numtrt;
          pairnum   = pairnum + 1;
          trtexpnum = 1;
          trtcd     = %scan(&_trtvals,&i);
          trtexp    = "%scan(&_trtvals,&i)";
          output; 
          trtexpnum = 2;
          trtcd     = %scan(&_trtvals,&j);
          trtexp    = "%scan(&_trtvals,&j)";
          output; 
        %end;
      %end;
    run;
    data &_pfx.bytrt;
      set &_pfx.bytrtcd(drop=trtcd);
    run;
    proc sort data=&_pfx.bytrt;
      by pairnum;
    run;
    proc transpose data=&_pfx.bytrt out=&_pfx.bytrtpair(drop=_name_) prefix=trtexp;
      var trtexp;
      id trtexpnum;
      by pairnum; 
    run;
  %end;

%end;  %** End of PAIRPVAL is null **;

%** Display before-and-after values of PAIRPVAL **;
%if %bquote(&pairpval)^=%bquote(&save_pairpval) or &verbose %then %do;
  %if %bquote(&pairpval)^=%bquote(&save_pairpval) %then %do;
    %ut_errmsg(msg=%sysfunc(compbl("The value of PAIRPVAL has been changed.")),
               type=note,print=0,macroname=ut_pairpval);
  %end;
  %put UNOTE(UT_PAIRPVAL): "Value of PAIRPVAL BEFORE processing : &save_pairpval"; 
  %put UNOTE(UT_PAIRPVAL): "Value of PAIRPVAL AFTER processing  : &pairpval";
%end;

%** Print datasets in debug mode **;
%if &debug %then %do;
  %ut_titlstrt(tstartvar=_ts,debug=&debug);
  proc print data=&_pfx.bytrtcd;   title&_ts "Dataset &_pfx.bytrtcd";   run;
  proc print data=&_pfx.bytrt;     title&_ts "Dataset &_pfx.bytrt";     run;
  proc print data=&_pfx.bytrtpair; title&_ts "Dataset &_pfx.bytrtpair"; run;
%end;

%** Save output dataset containing treatment info **;
%if %bquote(&outds_prefix)^= %then %do;
  data &outds_prefix.bytrtcd;
    label pairnum   = 'Sequential number of the treatment pair';
    label trtexpnum = 'Sequential number of the treatment expression within each pair';
    label trtcd     = 'Treatment code';
    label trtexp    = 'Treatment expression (treatment code or group of pooled codes)';
    set &_pfx.bytrtcd;
  run;  
  data &outds_prefix.bytrt;
    label pairnum   = 'Sequential number of the treatment pair';
    label trtexpnum = 'Sequential number of the treatment expression within each pair';
    label trtexp    = 'Treatment expression (treatment code or group of pooled codes)';
    set &_pfx.bytrt;
  run;
  data &outds_prefix.bytrtpair;
    label pairnum = 'Sequential number of the treatment pair';
    label trtexp1 = 'Treatment expression 1 (treatment code or group of pooled codes)';
    label trtexp2 = 'Treatment expression 2 (treatment code or group of pooled codes)';
    set &_pfx.bytrtpair;
  run;
%end;

%*==================================================;                         
%* Delete temporary datasets, reset system options  ;                         
%*==================================================;

%ut_restore_env(prefixlist=&_pfx,optds=&_pfx.optsave,debug=&debug);           

%mend ut_pairpval;
/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="13a87a0:129836b8972:-2e3" sddversion="3.4" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter id="INDS" resolution="INTERNAL" type="TEXT" order="1">*/
/*  </parameter>*/
/*  <parameter id="OUTDS_PREFIX" resolution="INTERNAL" type="TEXT" order="2">*/
/*  </parameter>*/
/*  <parameter id="ALLOW_T1_GT_T2" resolution="INTERNAL" type="TEXT" order="3">*/
/*  </parameter>*/
/*  <parameter id="ALLOW_T1POOL_T2NONPOOL" resolution="INTERNAL" type="TEXT" order="4">*/
/*  </parameter>*/
/*  <parameter id="ALLOW_T1NONPOOL_T2POOL" resolution="INTERNAL" type="TEXT" order="5">*/
/*  </parameter>*/
/*  <parameter id="ALLOW_T1POOL_T2POOL" resolution="INTERNAL" type="TEXT" order="6">*/
/*  </parameter>*/
/*  <parameter id="ALLOW_NONEXCLUSIVE_POOLS" resolution="INTERNAL" type="TEXT" order="7">*/
/*  </parameter>*/
/*  <parameter id="SWITCH_TREATMENTS" resolution="INTERNAL" type="TEXT" order="8">*/
/*  </parameter>*/
/*  <parameter id="DEBUG" resolution="INTERNAL" type="TEXT" order="9">*/
/*  </parameter>*/
/*  <parameter id="VERBOSE" resolution="INTERNAL" type="TEXT" order="10">*/
/*  </parameter>*/
/*  <parameter id="I" resolution="INTERNAL" type="TEXT" order="11">*/
/*  </parameter>*/
/*  <parameter id="J" resolution="INTERNAL" type="TEXT" order="12">*/
/*  </parameter>*/
/*  <parameter id="K" resolution="INTERNAL" type="TEXT" order="13">*/
/*  </parameter>*/
/*  <parameter id="_PFX" resolution="INTERNAL" type="TEXT" order="14">*/
/*  </parameter>*/
/*  <parameter id="SAVE_PAIRPVAL" resolution="INTERNAL" type="TEXT" order="15">*/
/*  </parameter>*/
/*  <parameter id="_EDITFLG" resolution="INTERNAL" type="TEXT" order="16">*/
/*  </parameter>*/
/*  <parameter id="_NUMTRT" resolution="INTERNAL" type="TEXT" order="17">*/
/*  </parameter>*/
/*  <parameter id="_ONLY" resolution="INTERNAL" type="TEXT" order="18">*/
/*  </parameter>*/
/*  <parameter id="_PWVAL" resolution="INTERNAL" type="TEXT" order="19">*/
/*  </parameter>*/
/*  <parameter id="_TRTEXP" resolution="INTERNAL" type="TEXT" order="20">*/
/*  </parameter>*/
/*  <parameter id="_TRTCODE" resolution="INTERNAL" type="TEXT" order="21">*/
/*  </parameter>*/
/*  <parameter id="_TRTVALS" resolution="INTERNAL" type="TEXT" order="22">*/
/*  </parameter>*/
/*  <parameter id="_TS" resolution="INTERNAL" type="TEXT" order="23">*/
/*  </parameter>*/
/*  <parameter id="ERROR_STATUS" resolution="INTERNAL" type="TEXT" order="24">*/
/*  </parameter>*/
/*  <parameter id="PAIRPVAL" resolution="INTERNAL" type="TEXT" order="25">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/