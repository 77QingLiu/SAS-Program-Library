%macro AHGvar2arr(dsn,var,arrPre,dim=100);
%AHGdel(&arrpre,like=1);
%global &arrPre._n;
%local i;
%do i=1 %to &dim;
%global &arrPRE&i;
%end;
data _null_;
  set &dsn end=end;
  call symput(strip("&arrpre"||%AHGputn(_n_)),strip(&var));
  if end then call symput("&arrPre._n",strip(put(_n_,best.))  );
run;

%mend;


