*m207e01;

%macro print(dsn,var,val);

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
