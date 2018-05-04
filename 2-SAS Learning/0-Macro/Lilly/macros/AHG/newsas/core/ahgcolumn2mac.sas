%macro AHGcolumn2Mac(dsn,mac,vars,global=0);
	%if &global %then %global &mac;
	%local i ahuige456436;
	%let ahuige456436=sdksf4543534534;
  data deletefromithere; 
	data _null_;
		format  &ahuige456436 $10000.;
		retain &ahuige456436 '';
		set &dsn end=end;
		%do i=1 %to %AHGcount(&vars);
		&ahuige456436=Trim(&ahuige456436)||' '||%scan(&vars,&i);
		%end;

		if end then call symput("&mac",compbl(&ahuige456436));
	
	run;
  data writetofilefromithere;
%mend;
