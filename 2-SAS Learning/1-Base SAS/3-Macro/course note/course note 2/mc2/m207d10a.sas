*m207d10a;

*Submit m207d09 first, to compile the CHECKVAR macro;

%macro calc(dsn=,var=) / minoperator;
   %local varflag;
   %if &dsn= %then %do;
      %put ERROR: DSN required.;
      %return;
   %end;
   %let varflag=%checkvar(&dsn,&var);
   %if &varflag in DX VX VI %then %return;
	%if &varflag=C %then %do;
		%put ERROR: Variable %upcase(&var) is character.;
		%return;
	%end;
   title "%upcase(&dsn)";
   proc means data=&dsn n nmiss min mean max maxdec=0;
      var &var;
   run;
%mend calc;

%calc(dsn=bad.data)
%calc(dsn=orion.order_fact)
%calc(dsn=orion.order_fact,var=Total_Retail_Price)
%calc(dsn=orion.order_fact,var=Coupon_code)
%calc(dsn=orion.order_fact,var=bad_var)
%calc(dsn=orion.order_fact,var=bad$var)
%calc(dsn=orion.order_fact,var=Total_Retail_Price quantity)
