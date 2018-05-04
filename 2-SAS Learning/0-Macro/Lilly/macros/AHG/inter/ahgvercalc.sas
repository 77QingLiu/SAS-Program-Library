%macro AHGverCalc(version,offset);
    %if &offset=0 %then %let offset=-0;
    %local left right;
    %let  left=%scan(&version,1);
    %let  right=%eval(%scan(&version,2)&offset);
    %if &right <=0 %then %let right=1;
    &left..&right
 %mend;
