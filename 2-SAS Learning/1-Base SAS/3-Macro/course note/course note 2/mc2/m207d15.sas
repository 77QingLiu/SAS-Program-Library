*m207d15;

%macro printwindow;
   %local dsn var vars obs sup dbl lab supx dblx labx msg;
   %let msg=Press ENTER to continue.;

   %display dsn;
   %let dsn=%upcase(&dsn);

   %display var;
   %if &var ne %then %let vars=var &var;

   %display opt;
   %if         &obs ne %then %let obs=(obs=&obs);
   %if %upcase(&sup)=Y %then %let supx=noobs;
   %if %upcase(&dbl)=Y %then %let dblx=double;
   %if %upcase(&lab)=Y %then %let labx=label;

   proc print data=&dsn &obs &supx &dblx &labx;
      &vars;
      title "&dsn";
   run;
   title;

%mend printwindow;

options mprint;
%printwindow
options nomprint;