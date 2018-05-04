%macro AHGmergeprintEx(
dsns
,by=
,keep=
,drop=,
label=label
,out=mergeprintout,print=1
,prefix=ahuigecol
,clean=1
);

%local i dsnN  J ;
%let dsnN=%AHGcount(&dsns);
%local %AHGwords(Printing,&dsnN);


%do i=1 %to &dsnN;
%let printing&i=;
%AHGgettempName(printing&i);
%end;
%do i=1 %to &dsnN;
%local varlist;
%let varlist=;
%AHGvarlist(%scan(&dsns,&i,%str( )),Into=varlist);
%AHGpm(printing&i);
data &&printing&i;
    set %scan(&dsns,&i,%str( ))
( 
drop=&drop 
%do j=1 %to %AHGcount(&varlist);
%if not %sysfunc(indexw(%upcase(&by &keep &drop),%upcase(%scan(&varlist,&j))  )  )
	 and  %lowcase(%scan(&varlist,&j)) ne ahuigebylabel
	%then rename=(%scan(&varlist,&j)=&prefix._%sysfunc(putn(&i,z2.))_%sysfunc(putn(&j,z2.))    ) ;
%end;
);
/*%do j=1 %to %AHGcount(&varlist);*/
/*label &prefix._%sysfunc(putn(&i,z2.))_%sysfunc(putn(&j,z2.))="%scan(&varlist,&j)";*/
/*%end;*/

run;

%end;
data &out;
	set &printing1;
run;
 %do i=2 %to &dsnN;
%AHGmergedsn(&out,&&printing&i  ,&out,by=&by,joinstyle=full/*left right full matched*/);
%end;   ;



%if &clean %then 
%do;
%AHGdatadelete(data=
%do i=1 %to &dsnN;
 &&printing&i  
 %end;
 );
%end;

%if &print %then
%do;
proc print &label noobs;
run;
%end;


%mend;

