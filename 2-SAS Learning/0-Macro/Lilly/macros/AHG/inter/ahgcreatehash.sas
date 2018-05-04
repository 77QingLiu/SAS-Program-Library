%macro 	AHGcreateHash(HashID,Pairs,dlm=%str( ),dlm2=%str( ));
%local i;
%AHGclearglobalmac(begin=&hashID);
%if &dlm ne %str( ) or &dlm2 ne %str( ) %then
	%do i= 1 %to %AHGcount(&pairs,dlm=&dlm);
/*	%PUT  @@@@@@@@@@@@@@@@@;*/
	%let ahuige=%AHGcount(&pairs,dlm=&dlm);
/*	%AHGlogshow(ahuige);*/
	%local id;
	%let id=&hashID%AHGscan2(&pairs,&i,1,dlm=&dlm,dlm2=&dlm2);
	%AHGlogshow(id);
	
	
	%global  &id;
	%let &id=%AHGscan2(&pairs,&i,2,dlm=&dlm,dlm2=&dlm2);
	%end;
%else
	%do;
/*		%PUT  ##################;*/
		%local localpairs;
		%let localpairs=&pairs;
		%do %while(not %AHGblank(&localpairs));
		%local id;
		%let id= &hashID%AHGleft(localpairs) ;
		%AHGpm(id);
		%global &id;
		%let &id=%AHGleft(localpairs);
		%end;
	%end;

%mend;
