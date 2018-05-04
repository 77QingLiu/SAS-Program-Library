%macro AHGsnaplib(id,pre=ahgworkdsns);
%local i all alist;
%global &pre&id;
%do i=1 %to %eval(&id-1);
%let all=&all &&&pre&i; 
%end;
%let alist=;
%AHGdsnInLib(lib=work,list=alist);
%AHGpm(alist);
%if %AHGnonblank(&all) %then %let &pre&id=%AHGremoveWords(&alist,&all,dlm=%str( ));
%else %let &pre&id=&alist;

%mend;
