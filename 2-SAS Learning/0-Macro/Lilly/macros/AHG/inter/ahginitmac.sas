%macro AHGinitmac(MACs);
%local i;
%do i=1 %to %AHGcount(&macs);
%nrbquote(%let %scan(&macs,&i)=;) 
%end;

%mend;
