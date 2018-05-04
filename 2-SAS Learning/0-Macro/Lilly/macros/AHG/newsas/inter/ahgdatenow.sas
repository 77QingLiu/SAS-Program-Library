%macro AHGdatenow(macForNow,global=1,dlm=);
%if &global %then %global &macForNow;;
Data _null_;
    call symput("&macForNow",compress(put(date(),yymmdd10.)||"&dlm"||put(time(),time8.),':- '));
run;
%mend;
