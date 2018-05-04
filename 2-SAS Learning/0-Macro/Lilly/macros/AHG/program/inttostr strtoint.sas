%macro AHGits(str);
%local i n outstr from char;
%let n=%eval(%length(&str)/2);

%do i=1 %to &n;
%let from=%eval(&i*2-1);
%let outstr=&outstr%sysfunc(byte(%substr(&str,&from,2)));
%end;
&outstr
%mend;

%macro sti(str);
%local i n outstr from char;
%let n=%length(&str);

%do i=1 %to &n;
%let outstr=&outstr%sysfunc(rank(%substr(&str,&i,1)));
%end;
&outstr
%mend;

%put %sti(AHGCOUNT);
%let theone=%its(6572716779857884);

OPTION mprint mlogic symbolgen;
%put %&theone(ahuige dasfas) ;




