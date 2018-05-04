%macro ahgD(d=%str(,));
%if &i ne 1 %then &d; 
%MEND;
