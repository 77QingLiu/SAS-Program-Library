
%macro AHGmergeall(
out=,
item1=,
item2=,
item3=,
item4=,
item5= ,
item6= ,
item7= ,
item8= ,
item9=
)
;
%local  i j itemN loopN	LastDsn
item1	dsn1	vars1	by1	tempdsn1
item2	dsn2	vars2	by2	tempdsn2
item3	dsn3	vars3	by3	tempdsn3
item4	dsn4	vars4	by4	tempdsn4
item5	dsn5	vars5	by5	tempdsn5
item6	dsn6	vars6	by6	tempdsn6
item7	dsn7	vars7	by7	tempdsn7
item8	dsn8	vars8	by8	tempdsn8
item9	dsn9	vars9	by9	tempdsn9

;
%do j =1  %to 9;
	%let i=%eval(10-&j);
	%if %AHGblank(&&item&i)  %then   %let itemN=%eval(&i-1);
%end;

%let loopN=%eval(&itemN-1);

%do i=1 %to &ItemN;
	%let dsn&i=%scan(&&item&i,1,@);
	%let vars&i=%scan(&&item&i,2,@);
	%if &i <= &loopN %then
	%do;
	%let by&i=%scan(&&item&i,3,@);
	%*pm(dsn&i  vars&i by&i);
	%end;
%end;

%AHGdatanodupkey(data =&dsn1(keep=&vars1) , out =&out , by =&by1 );

%do i=1 %to &loopN;
	%let j=%eval(&i+1);
	%AHGgettempname(tempdsn&j,start=%sysfunc(tranwrd(&&dsn&j,.,_))_);
	%AHGdatanodupkey(data =&&dsn&j(keep=&&by&i /*it is i not j*/ &&vars&j),
		out =&&tempdsn&j , by =&&by&i /*it is i not j*/ );

	%AHGmergedsn(&out,&&tempdsn&j,&out,rename=1,by=&&by&i,joinstyle=full/*left right full matched*/);
%end;
	

%mend;
