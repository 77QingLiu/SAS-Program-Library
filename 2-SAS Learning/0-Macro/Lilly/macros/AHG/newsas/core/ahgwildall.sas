%macro AHGwildall(string,theword);
%local i item final;
%do i=1 %to %AHGcount(&string);
%let item=%scan(&string,&i,%str( ));
%AHGwild(&item,&theword)
%end;

%mend;

