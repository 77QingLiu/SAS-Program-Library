%macro ahg1(m,str);
    %if not %AHGblank(&m) %then &str;
%mend;
