*m206d03a;

data fmtdata;
   keep start label fmtname;
   retain fmtname "continent";
   set orion.continent(rename=(		 
       continent_ID=start
       continent_name=label));
run;

proc format cntlin=fmtdata fmtlib;
   select continent;
   title "CONTINENT format based on ORION.CONTINENT";
run;
title;
