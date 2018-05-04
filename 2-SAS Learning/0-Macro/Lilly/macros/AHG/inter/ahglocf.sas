%macro AHGlocf(indsn=
            ,outdsn=&indsn
            ,var=
            ,datevar=
            ,locfdate=99
            ,baseline=0
            ,byvar=
            ,lastbyvar=&byvar
            ,type=1
);
  %local sorteddsn;
  %AHGgettempname(sorteddsn);

  /*type 1 the last non-missing value post baseline*/
  %if &type=1 %then
    %do;
    proc sort data=&indsn out=&sorteddsn;
      by &byvar;
      where not missing(&var);
    run;

    data &outdsn;
      set &sorteddsn;
      put _all_;
      by &byvar;
      output;
      if  last.&lastbyvar and not (&baseline) then 
        do;
        &datevar=&locfdate;
        output;
        end;
    run;
      
    
    %end;

%mend;


/*
option mprint;
data ahuige;
  input subjid visit test;
  cards;
0 1 1
0 2 2
0 3 3
1 1 1
1 2 2
1 3 .
2 1 .
2 2 .
2 3 .
3 1 1
3 2 .
3 3 .
4 1 1
4 2 .
4 3 3
;
run;

%AHGlocf(indsn=ahuige
            ,outdsn=locfout
            ,var=test
            ,datevar=visit
            ,locfdate=99
            ,baseline=%str(visit=1)
            ,byvar=subjid visit
            ,lastbyvar=subjid
            ,type=1
);
;

*/
