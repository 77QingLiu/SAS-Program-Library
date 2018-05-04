%macro AHGlogshow(string,var=,loglevel=2);
/*
loglevel:
1:note
2:warning
3:error 
*/
  %local levels;
  %let levels=Note Warning Error;

  %global AHGlogshowbool;
	%if  &ahglogshowbool=nologshow %then %goto exit;
    %local i;
    %if not %AHGblank(&string) %then
        %do;
        %put ##############################;
        %put ##############################;
        %put ##############################;
        %put !@!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@;
        %put !@!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@;
        %put ahuige:%scan(&levels,&loglevel);

        %if %index(&string,%str(%')) or %index(&string,%str(%")) %then %put &string;
        %else       %AHGpm(&string);

        %put !@!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@;
        %put !@!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@;
        %put ##############################;
        %put ##############################;
        %put ;
        %end;

        %if not %AHGblank(&var) %then
        %do;
        do;
        put '##############################';
        put '##############################';
        put '##############################';

        put '!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@';
        put '!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@';
        put '!@!            logshow           @!@';
        %do i=1 %to %ahgcount(&var);
        put %scan(&var,&i)=;
        %end;

        put '!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@';
        put '!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@';
        put '##############################';
        put '##############################';
        put '##############################';
        put;
        end;
        %end;
	%exit:
%mend;

