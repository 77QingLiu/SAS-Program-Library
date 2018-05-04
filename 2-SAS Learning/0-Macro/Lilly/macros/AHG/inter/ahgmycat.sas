%macro AHGmycat(items,dlm=' ');
%local i num;
%let num=%AHGcount(&items,dlm=@);
&dlm
%do  i=1 %to &num;
	%if not %index(&num,%str(%'%")) %then	||trim(%scan(&items,&i,@)) ;
	%else ||%scan(&items,&i,@) ;
	||&dlm
%end;

%mend;
