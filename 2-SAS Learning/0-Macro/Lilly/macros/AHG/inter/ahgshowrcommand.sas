%macro AHGshowRcommand;
  %local modcom words pos loop;
  %let modcom=&rcommand;

  %do %while(%index(&modcom,%str(;)));
    %let pos=%index(&modcom,%str(;));
    %let words=%substr(&modcom,1,&pos);
    %put &words;
    %if &words ne &modcom %then %let modcom=%substr(&modcom,&pos+1);
    %else %let modcom=;
/*    %let modcom= %sysfunc(tranwrd(&rcommand,%str(;),%str(;%sysfunc(byte(13)))));*/
  %end;
%mend;
