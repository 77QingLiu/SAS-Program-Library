
%macro AHGrank(num);
  %local i rank;
  %if &num=0 %then 
    %let rank=1;
  %else 
    %do;
    %let rank=1;
    %do i=1 %to &num;
      %let rank=%eval(&rank*&i);
    %end;
    %end;
  &rank
%mend;

%macro AHGpermutation(big,small);
  %local i perm;
  %if &small=0 %then %let perm=1;
  %else  %let perm=%eval(%AHGrank(&big)/%AHGrank(%eval(&big-&small)));
  &perm
%mend;


%put %AHGrank(1);
%put %AHGrank(2);
%put %AHGrank(3);
%put %AHGrank(4);
%put %AHGpermutation(7,2);

/**/
%macro AHGcombination(big,small);
  %local i comb;
  %if &small=0 %then %let comb=1;
  %else  %let comb=%eval(%AHGrank(&big)/%AHGrank(%eval(&big-&small))/%AHGrank(&small));
  &comb
%mend;
/**/
/**/
%put %AHGpermutation(7,2);
%put %AHGcombination(7,2);




%macro dosomething(n);
%let rightRate=0.4;
%local i size;
%do i=1 %to &n;
  %let size=%AHGcombination(10,&i);
  %AHGpm(i size);
%end;

%mend;
%doSomething(10);



%macro win(N);
%local money sum comb i j;
  %let sum=0;
%do i=2 %to &N;
  %let money=1;


  %let comb=%AHGcombination(&N,&i);
  %do j=1 %to &i;
  %let money=%sysevalf(&money*3.2);
  %end;
  %let money=%sysevalf(&money*&comb);
  %let sum=%sysevalf(&sum+&money);

%end;

%put &sum;

  
%mend;

%win(2);
%win(3);
%win(4);
%win(5);
%win(6);
%win(7);

proc printto;run;

data distr;
  do i=1 to 10000;
  array game game1-game10;
  array one{1:10} _temporary_((90 80 70 70););

  total=0;
  do j=1 to 10;
  game(j)=RANBIN(0,1,3/8); 
  total=total+game(j);
  end;
  if total=2 then win=10;
  if total=3 then win=64;
  if total=4 then win=298;
  if total=5 then win=1290;
  if total=6 then win=5468;
  if total=7 then win=23030;
  if total=8 then win=96799;
  if total=9 then win=406641;
  if total=10 then win=1707986;
  output;
  end;
  drop i j;

run;
proc means data=distr;
  var total win;
run;

/* 
3371    %local money sum comb i j;
3372      %let sum=0;
3373    %do i=2 %to &N;
3374      %let money=1;
3375
3376
3377      %let comb=%AHGcombination(&N,&i);
3378      %do j=1 %to &i;
3379      %let money=%sysevalf(&money*3.2);
3380      %end;
3381      %let money=%sysevalf(&money*&comb);
3382      %let sum=%sysevalf(&sum+&money);
3383
3384    %end;
3385
3386    %put &sum;
3387
3388
3389    %mend;
3390
3391    %win(2);
10.24
3392    %win(3);
63.488
3393    %win(4);
297.3696
3394    %win(5);
1289.91232
3395    %macro dosomething(n);
3396    %let rightRate=0.4;
3397    %local i size;
3398    %do i=1 %to &n;
3399      %let size=%AHGcombination(10,&i);
3400      %AHGpm(i size);
3401    %end;
3402
3403    %mend;
3404    %doSomething(10);
i=1
size=10
MPRINT(DOSOMETHING):  ;
i=2
size=45
MPRINT(DOSOMETHING):  ;
i=3
size=120
MPRINT(DOSOMETHING):  ;
i=4
size=210
MPRINT(DOSOMETHING):  ;
i=5
size=252
MPRINT(DOSOMETHING):  ;
i=6
size=210
MPRINT(DOSOMETHING):  ;
i=7
size=120
MPRINT(DOSOMETHING):  ;
i=8
size=45
MPRINT(DOSOMETHING):  ;
i=9
size=10
MPRINT(DOSOMETHING):  ;
i=10
size=1

*/

