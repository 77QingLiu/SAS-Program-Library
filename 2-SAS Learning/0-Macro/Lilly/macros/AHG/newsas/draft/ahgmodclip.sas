
%macro AHGModClip(RESET) ;
filename ahgclip clear;
filename ahgclip clipbrd;
%GLOBAL AHG_I;
%AHGdefault(AHG_I,0);
%IF %BQUOTE(&RESET)=1 %THEN  %let ahg_i=0;
%AHGINCR(AHG_i);
%if &ahg_i>&ahg_n %then %let ahg_i=1;

%put xxx=(AHG_RESULT&AHG_I);
%IF %SYMexist(AHG_RESULT&AHG_I) %then
%do;
data _null_;
  file ahgclip;
  format cmd    $500.;
  cmd="&&AHG_RESULT&AHG_I";
  put cmd;   
run;
%end;
%ELSE %PUT $$$$$$$$$$$$$$$$$$$$$;
%mend;


