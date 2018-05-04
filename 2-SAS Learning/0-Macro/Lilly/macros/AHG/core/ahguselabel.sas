%macro AHGuseLabel(dsn,out=,dlm=%str( ),remove=,to=);
%local rename i;
%if %sysfunc(exist(&dsn)) %then
%do;


data _null_;
length varlist $ 32000;

tableid=open("&dsn",'i');
varlist=' ';
do i=1 to  attrn(tableid,'nvars');
   label=put(varlabel(tableid,i),$100.);
   %do i=1 %to %AHGcount(&remove);
   label=tranwrd(upcase(label),upcase("%scan(&remove,&i)"),"%scan(&to,&i)");
   %end;
   caplabel=put('', $100.);
   j=0;
   do until (scan(label,j+1) eq ' ');
	   j=sum(j,1);
	   word=scan(label,j);
	   word=lowcase(word);
	   substr(word,1,1)=upcase(substr(word,1,1));
	   caplabel=trim(caplabel)||word;
	   caplabel=compress(caplabel,compress(caplabel,'abcdefghijklmnopqrstuvwxyz'||upcase('abcdefghijklmnopqrstuvwxyz0123456789')));

	   if index('1234567890',substr(caplabel,1,1)) then caplabel='_'||caplabel;
   end;
   if length(caplabel)>32 then caplabel=compress(caplabel,'aeiouAEIOU');
   varlist=trim(varlist)||"&dlm ;rename "||varname(tableid,i)||'='||substr(caplabel,1,32)||';';
end;
call symput("rename", varlist);
rc=close(tableid);
run;
%AHGpm(rename);
%if not %AHGblank(&out) %then
%do;
data &out;
  set &dsn;
  &rename;
run;
%end;


%end;

%mend;


