%macro AHGfakepw(pw);
    %local i mystr mychar;
    %do i=1 %to %length(&pw);
        %let mychar=%sysevalf(%sysfunc(rank(%substr(&pw,&i,1)))+%eval(&i*3)+100);
        %if %eval(&i/2) eq %sysevalf(&i/2) %then %let mystr=&mystr%sysfunc(reverse(&mychar));
        %else %let mystr=&mystr&mychar;
    %end;
    &mystr
%mend;

