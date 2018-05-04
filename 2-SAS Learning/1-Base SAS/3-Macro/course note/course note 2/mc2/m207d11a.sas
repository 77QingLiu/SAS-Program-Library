*m207d11a;

%macro varlist(dsn,type);

   %local dsid i;

   %let dsid=%sysfunc(open(&dsn));

   %if &dsid=0 %then %do;
      %put ERROR: Cannot open dataset: %upcase(&dsn).;
      %return;
   %end;

	%if %upcase(&type=N) %then %do i=1 %to %sysfunc(attrn(&dsid,nvars));
		%if %sysfunc(vartype(&dsid,&i))=N %then %sysfunc(varname(&dsid,&i));		
	%end;

	%else %if %upcase(&type)=C %then %do i=1 %to %sysfunc(attrn(&dsid,nvars));
		%if %sysfunc(vartype(&dsid,&i))=C %then %sysfunc(varname(&dsid,&i));	
	%end;

	%else %do i=1 %to %sysfunc(attrn(&dsid,nvars)); %sysfunc(varname(&dsid,&i)) %end;
	
   %let dsid=%sysfunc(close(&dsid));

%mend varlist;

%put %varlist(orion.order_fact,N);

%put %varlist(orion.order_fact,C);

%put %varlist(orion.order_fact);
