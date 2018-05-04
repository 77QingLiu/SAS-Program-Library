%macro AHGalltocharnew(dsn,out=%AHGbasename(&dsn),rename=,zero=0,width=100,name=0);
%local i varlist informat nobs varinfo  %AHGwords(cmd,100);
%AHGgettempname(varinfo);
 
%AHGvarinfo(&dsn,out=&varinfo,info= name  type  length num);
 
data _null_&varinfo;
  set &varinfo;
  format cmd $200.;
  if type='N' then cmd='input(left(put('||name||',best.)),$'||"&width"||'.) as '||name;
  else 
    do;
    if num>=&width then cmd=name;
    else cmd='put('||name||',$'||"&width"||'.) as '||name;
    end;
  call symput('cmd'||%AHGputn(_n_),cmd);
  call symput('nobs',%AHGputn(_n_));
run;
 
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

%if &name %then
%do;
  data &out;
    set &out;
    array _allchar_ _character_;
    if _n_=1 then 
      do;
      do over _allchar_;
        _allchar_=vname(_allchar_);
      end;
      output;
      set &out;
      end;
    output;
  run;
%end;

%mend;
