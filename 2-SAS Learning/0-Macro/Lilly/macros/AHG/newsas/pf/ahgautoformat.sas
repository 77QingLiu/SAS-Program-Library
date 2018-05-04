%macro AHGautoformat(str,fmt,dlm=/,quote=);
	%local fmtN;
	%let fmtN=%AHGcount(&str,dlm=/);
	%local i item;
	%do i=1 %to &fmtN;
	%let item=%scan(&str,&i,&dlm);
	%local value&i format&i;
	%AHGpop(item,value&i);
	%let  format&i=&item;
	%end;
	proc format;
	value  $&fmt
	%do i=1 %to &fmtN;
	"&&value&i"="&&format&i"
	%end;
    ;run;


%mend;
