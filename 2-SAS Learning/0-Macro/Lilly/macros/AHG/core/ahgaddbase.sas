%macro AHGaddBase(all,base);
	%local i;
	%do i=1 %to %AHGcount(&all);
		%eval(%scan(&all,&i)+&base)
	%end;
%mend;
