%macro 	AHGcreateHashex(HashID,Pairs,dlm=%str( ),dlm2=%str( ));
%AHGclearglobalmac(begin=&hashID);
%local i;
%global &hashid.list;
%let &hashid.list=;

%if &dlm ne %str( ) or &dlm2 ne %str( ) %then
	%do i= 1 %to %AHGcount(&pairs,dlm=&dlm);
	%let &hashid.list=&&&hashid.list %AHGscan2(&pairs,&i,1,dlm=&dlm,dlm2=&dlm2);
	%local id;
	%let id=&hashid&i;
	%global  &id;
	%let &id=%AHGscan2(&pairs,&i,2,dlm=&dlm,dlm2=&dlm2);
	%end;
%else
	%do;
		%local localpairs;
		%let localpairs=&pairs;
		%let i=0;
		%do %while(not %AHGblank(&localpairs));
		%AHGincr(i);
		%local id;
		%let &hashid.list=&&&hashid.list %AHGleft(localpairs);
		%let id= &hashID&i ;
		%global &id;
		%let &id=%AHGleft(localpairs);
		%end;
	%end;

%mend;
