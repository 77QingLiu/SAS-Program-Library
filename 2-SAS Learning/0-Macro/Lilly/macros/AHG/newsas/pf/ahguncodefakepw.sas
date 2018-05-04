%macro AHGuncodefakepw(fakepw=);
    %local mystr mychar i lg;
    %*pm(fakepw);
    %let lg=%sysevalf(%length(&fakepw)/3);
    %*pm(lg);
    %do i=1 %to &lg;
    %if %eval(&i/2) ne %sysevalf(&i/2) %then %let mychar=%substr(&fakepw,%eval((&i-1)*3+1),3);
    %else %let mychar=%sysfunc(reverse(%substr(&fakepw,%eval((&i-1)*3+1),3)));
    %*pm(mychar);
    %let mychar=%eval(&mychar-100-&i*3);
    %let mystr=&mystr%sysfunc(byte(&mychar));
    %end;
    &mystr
%mend;
