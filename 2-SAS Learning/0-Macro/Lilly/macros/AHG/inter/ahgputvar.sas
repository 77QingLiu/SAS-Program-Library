%macro AHGputvar(vars,sign=);
    %local i;
    put;
    put  "@@@&sign &sign &sign";put
    %do i =1 %to %AHGcount(&vars);
    %scan(&vars,&i)%str(=)  
    %end;
    ;
    put  "##################### &sign &sign &sign";
    put;

%mend;
