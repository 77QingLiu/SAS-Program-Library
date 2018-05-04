%macro AHGdelimit;
%if %AHGpos(&sysscp,win)%then%str(\);
%else%str(/);
%mend;
