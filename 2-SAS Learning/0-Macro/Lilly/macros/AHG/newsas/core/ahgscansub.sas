%macro AHGscansub(line,Num,dlm=%str( ));
    %put cnt=%AHGcount(&line,dlm=&dlm);
    %do i=1 %to &num;
        %scan(%bquote(&line),&i,&dlm)&dlm
    %end;
%mend;


