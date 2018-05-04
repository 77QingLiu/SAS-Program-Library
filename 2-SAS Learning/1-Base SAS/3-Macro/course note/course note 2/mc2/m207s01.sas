*m207s01;

%macro print(dsn,var,val) / minoperator;

   %local rc;
   %let rc=%checkvar(&dsn,&var);
   %if not (&rc in C N) %then %return;

   proc print data=&dsn(obs=10);
	 where &var=&val;
	 title "&var: &val";
   run;
   title;

%mend print;

%print(abc,abc,3)
%print(orion.order_fact,abc,3)
%print(orion.order_fact,order_type,3)
%print(orion.order_fact,club_code,'GDM')

