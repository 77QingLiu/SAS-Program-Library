/* %AHGcolumn2Mac(sasuser.actions,bigstring,action,global=1);*/
/* %AHGpm(bigstring);*/


 
%macro ahgoneAction;

filename ahgclip clear;
filename ahgclip clipbrd;
%local clip dsn;
data _null_;
  infile ahgclip;
  format clip    $500.;
  input clip;
  if substr(clip,1,1)='%' then clip=substr(clip,2);
  call symput('clip',strip(clip));   
run;

%global ahgaction_p ahgactionArr_n;
%AHGdefault(ahgaction_p,0);
%AHGdefault(ahgactionArr_n,0);

%if not %symexist(ahgactionArr&ahgaction_p) %then %AHGexpand;
%else %if %nrbquote(&&ahgactionArr&ahgaction_p) ne %nrbquote(&clip) %then %AHGexpand;


%if &ahgaction_n>0 %then
%do;
%if %AHGblank(&ahgaction_p) or (&ahgaction_p>=&ahgactionArr_n) %then %let ahgaction_p=1;
%else %AHGincr(ahgaction_p);
%AHGpm(ahgaction_p);
 
filename ahgclip clear;
filename ahgclip clipbrd;



data out;
  file ahgclip;
  format cmd    $500.;
  cmd=compress('%'||"&&ahgactionArr&ahgaction_p");
  put cmd;   
run;
%end;
%mend;


 
 
