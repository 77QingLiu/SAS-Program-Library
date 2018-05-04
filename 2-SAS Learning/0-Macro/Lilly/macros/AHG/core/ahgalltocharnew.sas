%macro AHGalltocharnew(dsn,out=%AHGbasename(&dsn),rename=,zero=0,width=100);
%local i varlist informat nobs varinfo  %AHGwords(cmd,100);
%AHGgettempname(varinfo);
 
%AHGvarinfo(&dsn,out=&varinfo,info= name  type  length num);
data deletefromithere;
data _null_;
  set &varinfo;
  format cmd $200.;
  if type='N' then cmd='input(left(put('||name||',best.)),$'||"&width"||'.) as '||name;
  else cmd=name ;
    call symput('cmd'||%AHGputn(_n_),cmd);
  call symput('nobs',%AHGputn(_n_));
run;
data writetofilefromithere;

/*%AHGdatadelete(data=&varinfo);*/

proc sql noprint;
  create table &varinfo(drop= AHGdrop) as
  select ' ' as AHGdrop 
    %do i=1 %to &nobs;
    %local zeroI;
    %if &zero %then %let zeroI=%AHGzero(&i,z&zero.);
    %else %let zeroI=&i;
  ,&&cmd&i %if not %AHGblank(&rename) %then as &rename&zeroI;
  %end;
  from &dsn
  ;quit;

%AHGrenamedsn(&varinfo,&out);

%mend;




