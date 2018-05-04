*m207s02;

%macro print(dsn,var,val) / minoperator;

	%local label rc;
	%let rc=%checkvar(&dsn,&var);
	%if not (&rc in C N) %then %return;

	proc print data=&dsn(obs=10);
		where &var=&val;
		title "&label: &val";
	run;
	title;

%mend print;

%print(abc,abc,3)
%print(orion.order_fact,abc,3)
%print(orion.order_fact,order_type,3)
%print(orion.order_fact,club_code,'GDM')



