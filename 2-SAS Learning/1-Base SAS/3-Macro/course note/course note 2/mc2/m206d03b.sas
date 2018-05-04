*m206d03b;

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
   title;

%mend makefmt;

%makefmt(continent,orion.continent,continent_ID,continent_name)
%makefmt($country,orion.country,country,country_name)
