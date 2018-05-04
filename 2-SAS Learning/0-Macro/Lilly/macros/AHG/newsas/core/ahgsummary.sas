%macro AHGsummary(dsn,var,trt=,by=,out=
,stats=n @ mean\9. @ median\9.2 @ min\9.2 '-' max\9.2
,orie=
,labels=
,obs=100
,Print=1
);

%AHGsumextrt(&dsn,&var,by=&by,trt=&trt ,out=&out
,stats=&stats
,orie=&orie
,labels=&labels
);

%AHGalltocharnew(&out);
%AHGtrimdsn(&out);

data &out;
  set &out(obs=&obs);
run;
%local varinfo varlb trtlb bylb;

%AHGgettempname(varinfo)
%AHGvarinfo(%AHGpurename(&dsn),out=&varinfo,info= name label);
%AHGcolumn2mac(&varinfo(where=(upcase(name)=upcase("&var"))),varlb,label)
%AHGcolumn2mac(&varinfo(where=(upcase(name)=upcase("&trt"))),trtlb,label)
%AHGcolumn2mac(&varinfo(where=(upcase(name)=upcase("&by"))),bylb,label)

%AHGpm(varlb trtlb bylb);

title;
title1 "Dataset:  &dsn   ";
title2 "Variable:  &var %AHG1(&varlb,[&varlb])";
title3 "Treatment: %AHG1(&trt,&trt) %AHG1(&trtlb,[&trtlb]) ";
Title4 "By: %AHG1(&by,&by)  %AHG1(&bylb,[&bylb])";
%if &print %then %AHGreportby(&out,0); 
%local sepdsn;
%AHGgettempname(sepdsn);
data &sepdsn;
  format line $200.;
  line=repeat('#',200);output;
  line="End of  Dataset:%AHGpurename(&dsn)    Variable:&var   Treatment:&trt  By:&by";output;
  line=repeat('#',200);output;
run;
%if &print %then %AHGprt;
%mend;
