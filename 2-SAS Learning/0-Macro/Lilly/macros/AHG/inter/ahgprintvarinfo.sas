%macro AHGprintVarInfo(dsn,out=,trim=1,print=1,Which=%str()/*name  type  length num fmt */ );
%if %AHGblank(&out) %then %AHGgettempname(out);
%AHGvarinfo(&dsn,out=&out, info=name label );
%AHGdatasort(data =&out , out = , by =name );
data &out;
	format name $50. print $350.;
	set &out;
  label=translate(trim(compbl(label)),'______',' /\()?');
	keep print;
	print=trim(name)||' ='||trim(label) ;
%local i;
%do i=1 %to %AHGcount(&which);
  if %AHGequaltext(name,"%scan(&which,&i)") then output;
%end;
run;

%if &print %then %AHGprt;
%mend;


