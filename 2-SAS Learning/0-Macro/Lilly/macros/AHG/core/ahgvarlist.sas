%macro AHGvarlist(dsn,Into=,dlm=%str( ),global=0,withlabel=0,print=0);
%if %sysfunc(exist(&dsn)) %then
%do;
data deletefromithere; 
%if &global %then %global &into;;
data _null_;
length varlist $ 8000;

tableid=open("&dsn",'i');
varlist=' ';
do i=1 to  attrn(tableid,'nvars');
   varlist=trim(varlist)||"&dlm"||varname(tableid,i);
   %if &withlabel %then       varlist=trim(varlist)||"&dlm "||'/*'||trim(varlabel(tableid,i))||'*/';; ;
end;
call symput("&into", varlist);
rc=close(tableid);
run;
%end;
%else %let &into=;
%if &print %then %AHGpm(&into);
data writetofilefromithere;
%mend;
