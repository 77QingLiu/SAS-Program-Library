%macro AHGvarlabel(dsn,out=,trim=1,print=1);
%if %AHGblank(&out) %then %let out=%AHGbasename(&dsn)_label867;
%AHGvarinfo(&dsn,out=&out,info= name label);
data &out;
	format name $50. label $260.;
	set &out;
	keep label ;
	label=trim(name)||' /*'||trim(label)||' */';
run;

%if &print %then %AHGprt;
%mend;

