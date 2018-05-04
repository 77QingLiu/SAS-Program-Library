%macro AHGfreqstat(dsn,col=,by=,bigcol=
,colLabel=
,bylabel=
,bigcolLabel=
,print=0
,N_per_Page=3
,nfmt=3.
,pctfmt=5.1
,outdsns=
,defaultN=999999
);



%local i colN bigcolNcols colnum ;
%let bigcolN=%AHGcount(&bigcolLabel,dlm=\);


%let colN=%AHGcount(&colLabel,dlm=\);
%let cols=;
%do i=1 %to &colN;
%let cols=&cols ahuigepref%AHGscan2(&colLabel,&i,1) ;
%end;


%local %AHGwords(coldsn,&bigcolN);
%local %AHGwords(cross,&bigcolN);
%local %AHGwords(tran,&bigcolN);


%do i=1 %to &bigcolN;
%let  colDSN&i=;
%let  cross&i=;
%let  tran&i=;
%AHGgettempname(colDSN&i);
%AHGgettempname(cross&i);
%AHGgettempname(tran&i);
data &&colDsn&i;
    set &dsn;
    if &bigcol="%AHGscan2(&bigcolLabel,&i,1)" then output;
run;
%end;

%local defaultdsn;
%let defaultdsn=;
   %AHGgettempname(defaultdsn);

   data &defaultdsn;
   %do i=1 %to &coln;
   %do j=1 %to %AHGcount(&bylabel,dlm=\);
   &col=%AHGscan2(&collabel,&i,1);
   &by=%AHGscan2(&bylabel,&j,1);
   count=0;
   percent=0;
   output;
   %end;
   %end;
   run;

   proc sort data=&defaultdsn;
        by &by &col;
    run;

%do bigcolNum=1 %to &bigcolN;

    proc sort data=&&colDsn&bigcolNum;
        by &by;
    run;

   proc freq data=&&colDsn&bigcolNum noprint;
    tables &col/out=&&cross&bigcolNum;

    by &by;

   run;




   proc sort data= &&cross&bigcolNum;
   by &by &col;
   run;

   data  &&cross&bigcolNum;
   	  merge &defaultdsn &&cross&bigcolNum;
	  by &by &col;
   run;

/*   proc sql noprint;*/
/*   	create table &&cross&bigcolNum as*/
/*   	select 	&&cross&bigcolNum...**/
/*	from  &&cross&bigcolNum as left full join &defaultdsn as right*/
/*		on 	left.&col=right.&col*/
/*		;quit;*/
	
/**/
/*	proc sort data=&&cross&bigcolNum;*/
/*		by &by;*/
/*	run;*/

   data &&cross&bigcolNum;
    ahuigeprefix='pref';
    set &&cross&bigcolNum;
    by &by;
    ahuigestring=put(count,&nfmt)||'('||put(percent,&pctfmt)||')';

	%do i=1 %to  &colN;
	if %AHGequaltext(left(&col),"%AHGscan2(&colLabel,&i,1)") then ahuigeidlabel=put("%AHGscan2(&colLabel,&i,2)",$40.);
	%end;
    output;
    retain ahuigebign;
    if first.&by then ahuigebign=0;
    ahuigebign=ahuigebign+count;
    if last.&by then
    do;
	&col=&defaultN;
    ahuigestring=ahuigebign;
	ahuigeidlabel="N";
    output;
    end;
	put score= &col=;

   run;



   proc transpose data=&&cross&bigcolNum prefix=ahuigepref out=&&tran&bigcolNum(drop=_name_);
    var ahuigestring;
    id &col;
	idlabel ahuigeidlabel;
    by &by;
   run;


 %end;



%if not %AHGblank(&outdsns) %then
%do i=1 %to &bigcolN;
%let &outdsns=&&&outdsns &&tran&i  ;
%AHGaddvars(&&tran&i,&cols,fmt=$10. );
data  &&tran&i ;
	set &&tran&i ;
	%do j=1 %to  %AHGcount(&bylabel);
	if %AHGequaltext(left(&by),"%AHGscan2(&byLabel,&j,1)") then ahuigebylabel=put("%AHGscan2(&byLabel,&j,2)",$40.);
	%end;
	%do j=1 %to  &colN;
	if ahuigepref%AHGscan2(&colLabel,&j,1)='' then ahuigepref%AHGscan2(&colLabel,&j,1)=put(0,&nfmt)||'('||put (0,&pctfmt)||')';
	%end;
run;
%AHGordvar(&&tran&i,&by ahuigebylabel ahuigepref&defaultn &cols);
/*%let &outdsns=&&&outdsns out&i  ;*/
%end;

%local printN printdsns drop;
data _null_;
	n=ceil(&bigcoln/&n_per_page);
	call symput('printn',n);
run;

%if &print %then
%do i=1 %to &printn;
%let base=%eval((&i-1)*&n_per_page);
%let printdsns=;
%do j=1 %to  &n_per_page;
%let printdsns=&printdsns %scan(&&&outdsns,%eval(&base+&j)) ;
%end;
%if &i=1 %then %let drop=;
%else %let drop=ahuigebylabel;
%AHGmergeprint(&printdsns ,by=&by,drop=&drop);
%end;


%mend;

