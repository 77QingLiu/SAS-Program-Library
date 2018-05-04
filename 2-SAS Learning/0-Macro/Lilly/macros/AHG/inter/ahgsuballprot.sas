%macro 	AHGsuballprot;
%local i subdir ;
%let subdir =%AHGscansubstr(&root2,1,6,dlm1st=-1,dlm=%str( /),compress=1);
%AHGpm(subdir);
%AHGrpipe(%str(echo $(ls &subdir/protocols)),allprot,print=no,format=$32767.,dlm=%str( ));
%AHGpm(allprot);

data _null_;
format line $300.;
file "&projectpath\analysis\suballprot.txt";
%do i=1 %to %AHGcount(&allprot);
line="&subdir/%scan(&allprot,&i)/saseng/pds1_0";
put line;
%end;
run;


%mend;


