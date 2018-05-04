*m207d18;

proc pmenu catalog=orion.menus;
   menu exit;
      item 'Exit' menu=x;

	    	menu x;

            item 'OK'     selection=y; 
	       	item 'Cancel' selection=z; 

            selection y 'end';
            selection z 'command focus';

quit;

%let msg=Press ENTER to continue.;

%window dsn columns=80 rows=20 menu=orion.menus.exit

 #3 @ 6 'Data Set: '  dsn 41 attr=underline required=yes
 #5 @16  msg protect=yes;

%window var columns=80 rows=20 menu=orion.menus.exit

 #3 @ 6 'Data Set: '  dsn 41 attr=underline protect=yes 
 #5 @ 6 'Variables: ' var 41 attr=underline
 #7 @17  msg protect=yes;

%window opt columns=80 rows=20 menu=orion.menus.exit

 # 3 @ 6 'Data Set:                 ' dsn 41 attr=underline protect=yes
 # 5 @ 6 'Variables:                ' var 41 attr=underline protect=yes 
 # 7 @ 6 '# of obs:                 ' obs  2 attr=underline
 # 9 @ 6 'Suppress Obs #s (Y or N): ' sup  1 attr=underline
 #10 @ 6 'Double Space    (Y or N): ' dbl  1 attr=underline
 #11 @ 6 'Column Labels   (Y or N): ' lab  1 attr=underline
 #14 @17  msg protect=yes;

 %window err columns=80 rows=20 menu=orion.menus.exit

 	#3 @ 6 'Data Set ' c=red dsn p=yes c=red attr=rev_video 
	 ' does not exist.' c=red

 	#5 @ 6 'Enter Y to try again or N to stop: ' 
         try 1 attr=underline

 	#7 @16  msg protect=yes;

%macro printwindow;

   %local dsn var vars dsid rc obs sup dbl lab supx dblx labx try msg;
   %let msg=Press ENTER to continue.;
   %let sysmsg=Enter dataset name.;
   %display dsn;
   %let dsn=%upcase(&dsn);

   %do %while(%sysfunc(exist(&dsn))=0);
	 	%let dsn=%upcase(&dsn);
	 	%let try=;
	 	%display err;
	 	%if %upcase(&try)=Y %then %display dsn;
	 	%else %do;
	    	%put ERROR: Dataset &dsn does not exist.;
	    	%return;
      %end;
   %end;

	%let sysmsg=Enter variable names or leave blank.;
   %display var;

   %if &var ne %then %do;
		%let dsid=%sysfunc(open(&dsn(keep=&var)));
		%let rc=%sysfunc(close(&dsid));
		%let var=%upcase(&var);
		%if &dsid=0 %then %do;
      	%put ERROR: Variables(&var) not in &dsn..;
	   	%return;
		%end;
		%let vars=var &var;
   %end;

	%let sysmsg=Select options.;
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

	%put NOTE: Processing complete.;

%mend printwindow;

%printwindow
