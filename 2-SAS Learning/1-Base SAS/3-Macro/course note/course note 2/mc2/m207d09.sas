*m207d09;

%macro checkvar(dsn,var);

   %local dsid varnum position;

   %let dsid=%sysfunc(open(&dsn));

   %if &dsid=0 %then %do;
      DX
      %put ERROR: Cannot open dataset: %upcase(&dsn).;
      %return;
   %end;

   %if &var=  %then %do;
      VM
      %put WARNING: Missing VAR parameter;
      %goto exit;
   %end;

   %if %sysfunc(nvalid(&var))=0 %then %do;
      VI
      %put ERROR: Invalid variable name: %upcase(&var).;
      %goto exit;
   %end;

   %let position=%sysfunc(varnum(&dsid,&var));

   %if &position=0 %then %do;
      VX
      %put ERROR: Variable %upcase(&var) not in %upcase(&dsn).;
      %goto exit;
   %end;

   %sysfunc(vartype(&dsid,&position))

   %let label=%sysfunc(varlabel(&dsid,&position));

   %exit: %let dsid=%sysfunc(close(&dsid));

%mend checkvar;

%put TYPE=%checkvar(orion.order_fact,Total_Retail_Price);
%put TYPE=%checkvar(orion.order_fact,coupon_code);
%put TYPE=%checkvar(orion.order_fact);
%put TYPE=%checkvar(orion.order_fact,bad_var);
%put TYPE=%checkvar(orion.order_fact,bad var);
%put TYPE=%checkvar(bad.data,Total_Retail_Price);


