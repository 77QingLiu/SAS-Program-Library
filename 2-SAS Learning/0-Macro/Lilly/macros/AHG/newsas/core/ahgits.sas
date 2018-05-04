%macro AHGits(str);
%local i n outstr from char;
%let n=%eval(%length(&str)/2);

%do i=1 %to &n;
%let from=%eval(&i*2-1);
%let outstr=&outstr%sysfunc(byte(%substr(&str,&from,2)));
%end;
&outstr
%mend;
