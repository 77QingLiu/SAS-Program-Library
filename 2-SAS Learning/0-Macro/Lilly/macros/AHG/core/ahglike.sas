%macro ahglike(string,word);
	%local finalstr i;
	%let finalstr=;
	%do i=1 %to %AHGcount(&string);
	%if  %AHGequalmactext(%sysfunc(compress(%scan(&string,&i),0123456789)),&word) %then %let finalstr=&finalstr %scan(&string,&i);
	%end;
	&finalstr
%mend;

