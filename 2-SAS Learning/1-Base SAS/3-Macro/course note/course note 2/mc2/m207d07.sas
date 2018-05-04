*m207d07;

%let dsid    =%sysfunc(open    (orion.order_fact));
%let position=%sysfunc(varnum  (&dsid,Total_Retail_Price));
%let type    =%sysfunc(vartype (&dsid,&position));
%let label   =%sysfunc(varlabel(&dsid,&position));
%let dsid    =%sysfunc(close   (&dsid));

%put &=position &=type &=label;
