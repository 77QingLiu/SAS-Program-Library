%macro AHGaddslash(dir);
%if (%substr(&dir,%length(&dir),1) ne %AHGdelimit)  %then &dir%AHGdelimit;
%mend;
