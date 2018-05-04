%MACRO rdownAlltable(type=rpt pdf);
%local mode;

%do i=1 %to %AHGcount(&type);
%if %AHGequalmactext(%scan(&type,&i),pdf) %then %let mode=binary;

%AHGrdown(rpath=/home/liu04/temp/rpt,binary=&mode,locpath=&projectpath\archive,open=0,filename=*.%scan(&type,&i));
%end;
%mend;
