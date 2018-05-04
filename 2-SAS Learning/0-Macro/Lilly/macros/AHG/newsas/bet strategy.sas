


data ahuige;
  set sasuser.rate;
  min=min(win,lose);
  max=max(win,lose);
  diff=abs(win-lose);
  x=min;
  y=tie;
  n=_n_;
  z=1/(1/x+1/y);
  winamt=z*106/120;
  max=max(x,y);
  min=min(x,y);
  winmax=max/2;
  winmin=min/2;

  rx=z*x;
  xx=x/2;
  yy=y/2;
  keep date diff id x y z  winamt winmax winmin ;
/*  if winamt>1 and winmin>1;*/
/*  put xx= yy= z= winamt;*/
run;

DM 'CLEAR log';
DM 'CLEAR lst';

%AHGdatasort(data =ahuige , out = , by =date descending diff winamt );

/*%AHGdatasort(data =ahuige , out = , by =date winmin);*/



data the14;
  set ahuige;
  IF _n_<=3 then twoplus=2;
  else twoplus=1;
  if _n_<=14 and not missing(winmin);
run;

%AHGdatasort(data =THE14 , out = , by =descending twoplus ID);

%AHGPrt;


data scores;
  set allscores;
  if abs>0;
  if abs=1 then cat=1;
  else cat=2;
run;




data betamt;
  input win tie;
  z=1/(1/win+1/tie)*.88;
  put x=;
  cards;
1.35 6.5
1.63 3.4
1.4 5.25
2.1 4.35
1.76 5.35
1.80 3.25
;

run;

%AHGprintToLog(_last_,n=20);












