%MACRO AHGfill(line,nums);

%let line=%sysfunc(prxchange(s/(\D*)\d+/$1```/, -1, &line));

%local i count one;
%do i=1 %to %AHGcount(&nums);
  %let one=%scan(&nums,&i,%str( ));
  %let one=s/([^`]*)```/$1 &one/;
  %let line=%sysfunc(prxchange(&one, 1, &line));
%end;
&line

%mend;

