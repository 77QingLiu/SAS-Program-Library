%macro AHGlinebyline(words);
%do i=1 %to  %AHGcount(&words);
%put %scan(&words,&i);
%end;
%mend;
