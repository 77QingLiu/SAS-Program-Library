%macro AHGwinorunix;
    %if %UPCASE(%substr(&sysscp,1,3)) =WIN  %then WIN;
    %else UNIX;
%mend;
