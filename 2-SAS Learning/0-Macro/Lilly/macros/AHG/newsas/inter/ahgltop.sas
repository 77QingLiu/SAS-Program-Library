/*Landscope to Portrait*/
%macro AHGLtoP(line,dlm=%str( ));
  %do i=1 %to %AHGcount(&line);
    %put %scan(&line,&i,&dlm);
  %end;
%mend;

