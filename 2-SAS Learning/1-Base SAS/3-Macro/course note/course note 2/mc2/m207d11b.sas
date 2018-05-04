*m207d11b;

*Submit two programs first;
	*m207d09 to compile the CHECKVAR macro;
	*m207d11a to compile the VARLIST macro;

%macro calc(dsn=,variables=) / minoperator;
   %local var badvar varflag varn n;
   %if &dsn= %then %do;
      %put ERROR: DSN required.;
      %return;
   %end;
   %if &variables= 
      %then %let n=1;
      %else %let n=%sysfunc(countw(&variables,%str( )));
   %do i=1 %to &n;
      %let varn=%scan(&variables,&i,%str( ));
      %let varflag=%checkvar(&dsn,&varn);
      %if &varflag=DX %then %return;   		    			   %*Bad dataset;
      %if &varflag in VX VI %then %goto listv;        		%*Bad var;
		%if &varflag=C %then %do;	                     		%*Char var;
    		%put ERROR: Variable %upcase(&varn) is character.;
			%listv: %put NOTE: Valid numeric variables: %upcase(%varlist(&dsn,N)).;
			%return;
   	%end;
      %if &varflag=N %then %let var=&var &varn;
   %end;   
   title "%upcase(&dsn)";
   proc means data=&dsn n nmiss min mean max maxdec=0;
      var &var;
   run;
%mend calc;

%calc(dsn=orion.order_fact,variables=coupon_code quantity)
%calc(dsn=orion.order_fact,variables=bad_var quantity)
%calc(dsn=orion.order_fact,variables=bad$var quantity)
%calc(dsn=orion.order_fact,variables=Total_Retail_Price quantity)
%calc(dsn=orion.order_fact)

