dm 'clear log';
%AHGdatadelete;
proc printto ;run;

data addedtotal;
  set adam.adsl;
  where fasfl='Y';
  output;
  trt01an=999;
  output;
run;



%AHGfreqCore(addedtotal,trt01an,by=,out=totaln,keep=value frequency );

%let totaln=;
proc sql;
  select frequency into: totaln separated by ' '
  from totaln
  ;quit;
%AHGpm(totaln);

%put %AHGfill(    (N = 0)         (N = 0)         (N = 0)         (N = 0),&totaln);


%macro oneVar(var,ord);
  format the_var 7.3;
  the_var=&var;
  id=put("&var",$20.);
  ord=&ord;
  output;
%mend;

data stat_IN;
  set addedtotal;
  %oneVar(age,1);
  %oneVar(height,5);
  %oneVar(weight,6);
  %oneVar(bmi,7);
  %oneVar(diadur,9);
run;

%AHGjuststat(stat_in,the_var,stat,by=ord id trt01an);

proc transpose data=stat out=tran;
  var n mean median std max min;
  by  ord id trt01an;
run;

%MACRO CELL(stat,fmt);
  if upcase(_name_)=upcase("&stat") then cell=put(col1,&fmt);  
%mend;


data stat;
  set tran;
  format cell $15.;
  %CELL(mean,6.1);
  %CELL(median,6.1);
  %CELL(std,6.2);
  %CELL(max,6.);
  %CELL(min,6.);
  %CELL(n,6.);

  if (ord = 5) or (ord=6) then 
    do;
    %CELL(max,6.1);
    %CELL(min,6.1);
    end;
  if ord = 7 then 
    do;
    %CELL(max,6.1);
    %CELL(min,6.1);
    end;
  if ord = 9 then 
    do;
    %CELL(mean,6.2);
    %CELL(median,6.2);
    %CELL(std,6.3);
    %CELL(max,6.2);
    %CELL(min,6.2);
    end;
  cohort='cohort';
run;


%AHGvarlist(stat,print=1,Into=allVar,dlm=%str( ),global=0);



%AHGdatasort(data =stat , out =stat , by =ord id _name_ );

proc transpose data=stat out=statlines prefix=cohort;
  var  cell;
  id trt01an;
  by ord id _name_;

run;



%macro oneVar(var,ord);
  the_var=put(&var,$50.);
  id=put("&var",$20.);
  ord=&ord;
  output;
  if not missing(&var) then the_var='yes';
  else the_var='';
  id=put(" total of &var",$20.);
  ord=&ord-0.1;
  output;
%mend;

data the_IN(where=(not missing(the_var)));
  set addedtotal;
  ecog=left(put(ecogn,1.));
  %oneVar(sex,2);
  %oneVar(race,3);
  %oneVar(subrace,4);
  %oneVar(ipdbas,8);
  %oneVar(stage,10);
  %oneVar(ecog,11);
run;



%AHGdatasort(data =the_in , out =the_in , by = ord id trt01an);


%ahgfreqcore(the_IN,THE_VAR,out=FREQ,by= ord id trt01an);

data freq;
  set freq;
  format cell $15.;
  if ceil(ord) ne ord then cell=put(frequency,3.);
  else cell=compbl(put(frequency,3.)||' ('||put(percent,5.1))||')';
  if ord=3.9 then delete;
  cohort='Cohort';
run;
%AHGprintToLog(_last_,n=20);
%AHGdatasort(data =freq , out =freq , by =ord id value );


proc transpose data=freq out=freqlines prefix=cohort;
  var  cell;
  id trt01an;
  by ord id value;
run;

data finalrpt finalrptbackup;
  format label $50.;
  set statlines freqlines;

  if value='yes'   then label='Number of patients';
  else if not missing(value) then label=value;

  if missing(label) then label=_name_;
run;

%AHGprintToLog(_last_,n=20);


data ord;
  format label $20. showstring $50.;
  input rank label & showstring &;
  cards;
1  n  Number of patients
2  mean  Mean
3  std  SD
4  median  Median
5  min   Minimum
6  max   Maximum
;
run;

%AHGmergedsn(finalrpt,ord,finalrpt,by=label,joinstyle=full/*left right full matched*/);

data finalrpt ;
  set finalrpt;
  if showstring='' then showstring=label;
run;

data stage;

  format label $20. showstring $50.;
  input rank label & showstring &;
  label=upcase(label);
  ord=10;
  cards;
1  Stage I   Stage I  
2  Stage II   Stage II  
3  Stage III   Stage III  
4  Stage IV   Stage IV  
5  Unknown   Unknown  
;
run; 

data diag;

  format label $20. showstring $50.;
  input rank label & showstring &;
  label=upcase(label);
  ord=8;
  cards;
1  Histopathological   Histopathological 
2  Cytological  Cytological 
;
run; 

data gender;

  format label $20. showstring $50.;
  input rank label & showstring &;
  label=upcase(label);
  ord=2;
  cards;
1  F  Female
2  M  Male
;
run; 

data ecog;
  format label $20. showstring $50.;
  do rank=0 to 5;
  label=left(put(rank,1.)); 
  showstring=label;
  ord=11;
  output;
  end;
run; 

%AHGmergedsn(finalrpt,diag,finalrpt,by=label ord,joinstyle=full/*left right full matched*/);
%AHGmergedsn(finalrpt,stage,finalrpt,by=label ord,joinstyle=full/*left right full matched*/);
%AHGmergedsn(finalrpt,ecog,finalrpt,by=label ord,joinstyle=full/*left right full matched*/);
%AHGmergedsn(finalrpt,gender,finalrpt,by=label ord,joinstyle=full/*left right full matched*/);




data addedline;
  format   showstring $100.;
  input ord   showstring &;
  ord=ord-0.2;
  rank=-1;
  cards;
1  Age (years) 
2  Sex [n (%)] 
3  Race [n (%)]  
5  Height at baseline (cm)
6  Weight at baseline (kg)  
7  BMI (kg/m2) 
8  Basis of Pathological Diagnosis [n (%)]  
9  Duration since Initial Diagnosis (years)   
10  Disease Stage at Initial Diagnosis [n (%)] 
11  ECOG Performance Status [n (%)]    



;
run; 

data finalrpt;
  set finalrpt addedline;
run;


%AHGordvar(finalrpt,id ord rank showstring cohort1 cohort2 cohort3 cohort999,out=,keepall=0);

%AHGdatasort(data =finalrpt , out =finalrpt , by =ord rank showstring );


data finalrpt;
  set finalrpt;
  array coh cohort:;
  do over coh ;
    if missing(coh ) and ord=ceiL(ord) then coh ='0';
    if LEFT(coh)='.' then coh='-';
  end;
  drop id ord rank;
run;

%printout;

%AHGprt;
