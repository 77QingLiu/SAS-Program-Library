%macro ahg0(m,str);
    %if %AHGblank(&m) %then &str;
%mend;
