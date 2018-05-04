%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods listing style=htmlblue image_dpi=&dpi gpath=&gpath; 
ods html close;
option missing=' ';

proc format;
  value wk 
    28='Max';
run;

data asat;
  format Week wk.;
  label ASAT='ASAT (/ULN)';
  do Week=0,1,2,4,8,12,24;
    count=.;
    do i=1 to 20;
          Drug='A'; ASAT=0.3+0.4*ranuni(2); DrugGT='>2(A)'; 
      count=int(ifn(i=1,220*(1-week/56), .)); gt2=int(ifn(i=1,2*ranuni(3), .)); output;
          Drug='B'; asat=0.4+0.5*ranuni(2); DrugGT='>2(B)'; 
      count=int(ifn(i=1,430*(1-week/56), .)); gt2=int(ifn(i=1,3*ranuni(3), .));output;
        end;
    do i=1 to 5;
          Drug='A'; asat=1+1*ranuni(2); count=.; output;
          Drug='B'; asat=1.2+0.8*ranuni(2); count=.; output;
        end;
  end;

  week=28;
  do i=1 to 20;
        Drug='A'; asat=0.3+0.4*ranuni(2); count=int(ifn(i=1,220, .)); DrugGT='>2(A)'; gt2=int(ifn(i=1,2, .)); output;
        Drug='B'; asat=0.4+0.5*ranuni(2); count=int(ifn(i=1,430, .)); DrugGT='>2(B)'; gt2=int(ifn(i=1,3, .)); output;
  end;
  do i=1 to 5;
        Drug='A'; asat=1+1*ranuni(2);     count=.;  output;
        Drug='B'; asat=1.2+0.8*ranuni(2); count=.;  output;
  end;
run;
/*proc print;run;*/

ods graphics / reset width=5in height=3in imagename="3_3_2_Distribution_of_ASAT_SG_V93";
title 'Distribution of ASAT by Time and Treatment';
proc sgplot data=asat;
  vbox asat / category=week group=drug name='box' nofill;
  refline 1 / lineattrs=(pattern=shortdash);
  refline 2 / lineattrs=(pattern=dash);
  refline 2.1 0.16;
  refline 25 / axis=x;
  xaxis type=linear values=(0 2 4 8 12 24 28) offsetmax=0.05 valueattrs=(size=8) labelattrs=(size=9);
  yaxis offsetmax=0.16 offsetmin=0.16 valueattrs=(size=8) labelattrs=(size=9);
  keylegend 'box' / position=top valueattrs=(size=8);
run;

/*--Build Annotation data set--*/
data anno;
  length x1Space y1Space $12;
  keep Id Function Label X1 Y1 x1Space y1Space Anchor TextColor TextSize TextWeight;
  set asat(keep=week drug drugGT gt2 count) end=last;
  Function='Text'; x1Space='DataValue'; y1Space='WallPercent'; Anchor='Center';
  TextSize=6;

  x1=week;  
  if count ne . then do;
    id='Count';
    label=strip(count); 
    if Drug = 'A' then do; y1=8; TextColor='GraphData1:contrastcolor'; end;
    else do; y1=3; TextColor='GraphData2:contrastcolor'; end;
    output;
  end;

  if gt2 ne . then do;
    id='GT2';
        label=strip(gt2);
    if DrugGT = '>2(A)' then do; y1=97; TextColor='GraphData1:contrastcolor'; end;
    else do; y1=92; TextColor='GraphData2:contrastcolor'; end;
    output;
  end;

  if last then do
        x1Space='WallPercent'; y1Space='WallPercent'; Anchor='Right'; TextWeight='Bold';

    id='Count';
        x1=-1; y1=8; label='A'; TextColor='GraphData1:contrastcolor'; output;
        x1=-1; y1=3; label='B'; TextColor='GraphData2:contrastcolor'; output;

    id='GT2';
        x1=-1; y1=97; label='>2(A)'; TextColor='GraphData1:contrastcolor'; output;
        x1=-1; y1=92; label='>2(B)'; TextColor='GraphData2:contrastcolor'; output;

  end;
run;

proc sort data=anno out=annoSort;
  by id;
run;

ods html;
proc print data=annoSort;
var Id Function Label x1Space X1 y1Space Y1 Anchor TextColor TextSize TextWeight;
run;

proc print data=annoSort(obs=4);
var Id Function Label x1Space X1 y1Space Y1 Anchor TextColor TextSize TextWeight;
run;

proc print data=annoSort(firstobs=17 obs=18);
var Id Function Label x1Space X1 y1Space Y1 Anchor TextColor TextSize TextWeight;
run;

ods html close;

ods graphics / reset width=5in height=3in imagename="3_3_1_Distribution_of_ASAT_Anno_SG_V93";
title 'Distribution of ASAT by Time and Treatment';
proc sgplot data=asat sganno=annoSort;
  vbox asat / category=week group=drug name='box' nofill;
  refline 1 / lineattrs=(pattern=shortdash);
  refline 2 / lineattrs=(pattern=dash);
  refline 2.1 0.16;
  refline 25 / axis=x;
  xaxis type=linear values=(0 2 4 8 12 24 28) offsetmax=0.05 valueattrs=(size=8) labelattrs=(size=9);
  yaxis offsetmax=0.16 offsetmin=0.16 valueattrs=(size=8) labelattrs=(size=9);
  keylegend 'box' / position=top valueattrs=(size=8);
run;



