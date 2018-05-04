%macro makefmt(fmtname,dsn,start,label);
	data fmtdata;
		keep start label fmtname;
   	retain fmtname "&fmtname";
   	set &dsn(rename=(
			 &start=start
		 	 &label=label));
	run;

   proc format cntlin=fmtdata fmtlib;
      select &fmtname;
      title "%upcase(&fmtname) format based on %upcase(&dsn)";
   run;
%mend makefmt;
