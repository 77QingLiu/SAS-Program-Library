
%macro AHGforceFormat(dsn,vars,out=,pref=att_length_);
%macro ___type(dsn,var);
%local did;
%let did=  %sysfunc(open(&dsn,in));
%if %sysfunc(vartype(&did,%sysfunc(varnum(&did,&var))))=C %then $;
%LET DID=%sysfunc(CLOSE(&dID));
%mend;

%macro ___Def(vars);
  %local count i temp ;
  %do i=1 %to %AHGcount(&vars);
    %let temp=&pref%scan(&vars,&i);
    %if %symexist(&temp) %then LENGTH %scan(&vars,&i)  &&&temp ;;
  %end;
%mend;

%macro ___rename(vars,comma );
  %local count i temp ;
  %do i=1 %to %AHGcount(&vars);
    %scan(&vars,&i)=_%scan(&vars,&i)_ %bquote(&comma)
  %end;
%mend;

%if %AHGblank(&out) %then %let out=%AHGbarename(&dsn);
data &out;
  %___def(  &VARS  );
  set &dsn(rename=(%___rename(  &vars  )));

  %local count i temp ;
  %do i=1 %to %AHGcount(&vars);
  %let temp=&pref%scan(&vars,&i)%str(.);
  %let temp=&&&temp;
   drop _%scan(&vars,&i)_;
  %local onefmt;
  %let onefmt=%sysfunc(compress(%___type(&dsn,%scan(&vars,&i))20.) );
   %scan(&vars,&i)=input(left(put(_%scan(&vars,&i)_,&onefmt)),%unquote(&temp));
  %end;

run;

%mend;
