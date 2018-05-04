*m207d08;

%macro checkvar(dsn,var);
   %let dsid=%sysfunc(open(&dsn));
   %let position=%sysfunc(varnum(&dsid,&var));
   %sysfunc(vartype(&dsid,&position))
   %let label=%sysfunc(varlabel(&dsid,&position));
   %let dsid=%sysfunc(close(&dsid));
%mend checkvar;

%global position label;

%put TYPE=%checkvar(orion.order_fact,Total_Retail_Price) &=position &=label;

%put TYPE=%checkvar(orion.order_fact,Bad_Var);
%put TYPE=%checkvar(orion.order_fact,Bad Var);
%put TYPE=%checkvar(bad.dsn,Total_Retail_Price);