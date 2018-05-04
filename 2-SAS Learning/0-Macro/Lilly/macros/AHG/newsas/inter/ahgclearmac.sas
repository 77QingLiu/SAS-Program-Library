%macro AHGclearmac; 
    proc datasets lib=work memtype=catalog;
        delete sasmacr;
    run;
%mend;    
