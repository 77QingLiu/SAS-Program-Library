%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods listing style=htmlblue image_dpi=&dpi gpath=&gpath;  
ods html close;

data QTc_Mean_Group;
  input Week Drug $ Mean Low High N;
  if week ne 28 then mean2=mean;
  datalines;
0  A  0     0    0    216   
0  B  0     0    0    431
1  A -0.1  -2.0  1.8  210   
1  B  0.5  -1.0  2.1  423 
2  A -0.6  -2.8  1.8  206
2  B -3.2  -4.8 -1.6  364
4  A  0.4  -1.9  2.4  199
4  B -1.8  -3.6  0.0  362
8  A -1.6  -4.0  0.8  191
8  B -2.8  -4.4 -1.2  337
12 A -3.0  -5.6 -0.4  184
12 B -2.0  -3.6 -0.4  315
16 A -1.2  -3.6  1.2  176
16 B -3.0  -5.0 -1.0  311
20 A -1.6  -4.6  1.4  169
20 B -3.2  -4.8 -1.6  299
24 A -2.2  -5.0  0.6  164  
24 B -2.0  -3.8 -0.2  293
28 A -1.6  -3.6  1.0  214
28 B -1.8  -3.2 -0.4  429
;
run;

ods html;
proc print data=QTc_Mean_Group(obs=5) noobs;run;
ods html close;

/*--Add observation for Number of Subjects label--*/
data QTc_Mean_Group_Label;
  set QTc_Mean_Group end=last;
  output;
  if last then do; 
    week=3; mean=.; low=.; high=.; drug=''; ylabel='C'; n=.;
    label='Number of subjects at visit'; 
    output;  end; 
proc print;run;

proc format;
  value qtcmean 
    28='LOCF';
        ;
run;

/*--Anno data set for Outer Subjects Table--*/
ods escapechar '~';
data annoOuter;
  retain Function 'text' Y1Space 'graphpercent';
  retain  TextSize 5;
  length TextColor $25 Label $100 X1Space $12 TextWeight $6;
  drop week n drug;
  set QTc_Mean_Group(keep=week n drug) end=last;
  Width=10; Anchor='center'; X1Space='datavalue'; TextWeight='bold';
  Label=put(n, 5.0);
  Y1=6; TextColor='GraphData2:contrastcolor';
  if drug='A' then do; Y1=9; TextColor='Graphdata1:contrastcolor'; end;
  X1=week;
  if last then do;
    output;
    X1=-1; Y1=6; TextColor='Graphdata2:contrastcolor'; Width=10; Label='Drug B'; X1Space='wallpercent';
    Anchor='right'; TextSize=5; TextWeight='bold'; output;
    X1=-1; Y1=9; TextColor='Graphdata1:contrastcolor'; Width=10; Label='Drug A'; X1Space='wallpercent';
    Anchor='right'; TextSize=5; textweight='bold'; output;
    X1=0; Y1=13; TextColor=''; Width=40; Label='Number of subjects at visit';  X1Space='wallpercent';
    Anchor='left'; TextSize=8; textweight='normal'; output;
    X1=2; Y1=2; TextColor=''; Width=100;   X1Space='graphpercent';
    Label='Note: Vertical lines represent 95% confidence intervals.  LOCF is last observation carried forward';
    Anchor='left'; TextSize=7; TextStyle='italic'; TextWeight='normal'; output;
  end;
  else output;
;
run;

ods html;
proc print data=QTc_Mean_Group(obs=5);run;

/*proc print data=annoOuter(obs=5);*/
/*var function x1space y1space label anchor x1 y1;*/
/*run;*/

proc print data=annoOuter(obs=5);
var function x1space y1space X1 Y1 label anchor TextSize TextWeight TextColor;
run;

proc print data=annoOuter(firstobs=21 obs=24);
var function x1space y1space label anchor x1 y1;
run;
ods html close;

/*--QTc Graph witn Outer AtRisk Table--*/
ods graphics / reset width=5in height=3in imagename='3_2_1_1_QTc_Mean_OuterAxisTable_V93';
title 'Mean Change of QTc by Week and Treatment';
proc sgplot data=QTc_Mean_Group sganno=annoOuter pad=(bottom=14%);
  format week qtcmean.;
  scatter x=week y=mean / yerrorupper=high yerrorlower=low group=drug 
          groupdisplay=cluster clusterwidth=0.5 markerattrs=(size=7 symbol=circlefilled);
  series x=week y=mean2 / group=drug groupdisplay=cluster clusterwidth=0.5 lineattrs=(pattern=solid);
  refline 26 / axis=x;
  refline 0  / axis=y lineattrs=(pattern=shortdash);
  xaxis type=linear values=(0 1 2 4 8 12 16 20 24 28) max=29 valueshint display=(nolabel);
  yaxis label='Mean change (msec)' values=(-6 to 3 by 1);
/*  keylegend / location=inside;*/
  run;
title;
footnote;


data QTc_Mean_Group_Header;
  set QTc_Mean_Group end=last;
  output;
  if last then do;
    call missing (mean, high, low, drug, N);
        ylbl='.'; xlbl=-0.5; highlabel='Number of subjects at Visit'; output;
        highlabel='';
    ylbl='A'; xlbl=-1; lowlabel='A'; output;
        ylbl='B'; xlbl=-1; lowlabel='B'; output;
  end;
run;
/*proc print;run;*/

/*--QTc Graph witn Inner AtRisk Table using Y2 axis Scatter--*/
ods listing style=htmlblue;
ods graphics / reset width=5in height=3in imagename='3_2_2_1_QTc_Mean_InnerAxisTable_V93';
title 'Mean Change of QTc by Week and Treatment';
footnote j=l h=0.8 'Note: Vertical lines represent 95% confidence intervals.  LOCF is last observation carried forward';
proc sgplot data=QTc_Mean_Group_Header;
  format week qtcmean. N 3.0;
  scatter x=week y=mean / yerrorupper=high yerrorlower=low group=drug name='a' nomissinggroup 
          groupdisplay=cluster clusterwidth=0.5 markerattrs=(size=7 symbol=circlefilled);
  series x=week y=mean2 / group=drug groupdisplay=cluster clusterwidth=0.5;
  highlow y=ylbl low=xlbl high=xlbl / highlabel=highlabel y2axis lineattrs=(thickness=0);
  scatter x=week y=drug / markerchar=n group=drug markercharattrs=(size=5 weight=bold) y2axis nomissinggroup;
  refline 26 / axis=x;
  refline -6  / axis=y;
  refline 0  / axis=y lineattrs=(pattern=shortdash);
  xaxis type=linear values=(0 1 2 4 8 12 16 20 24 28) max=29 valueshint display=(nolabel);
  yaxis label='Mean change (msec)' values=(-6 to 3 by 1) offsetmin=0.14 offsetmax=0.02;
  y2axis offsetmin=0.88 offsetmax=0.03 display=none reverse;
  keylegend 'a' / location=inside position=top;
  run;
title;
footnote;

/*--QTc Graph witn Inner AtRisk Table blank space using Y2 axis Scatter--*/
ods listing style=htmlblue;
ods graphics / reset width=5in height=3in imagename='3_2_2_2_QTc_Mean_NoTable_V93';
title 'Mean Change of QTc by Week and Treatment';
footnote j=l h=0.8 'Note: Vertical lines represent 95% confidence intervals.  LOCF is last observation carried forward';
proc sgplot data=QTc_Mean_Group_Header;
  format week qtcmean. N 3.0;
  scatter x=week y=mean / yerrorupper=high yerrorlower=low group=drug name='a' nomissinggroup 
          groupdisplay=cluster clusterwidth=0.5 markerattrs=(size=7 symbol=circlefilled);
  series x=week y=mean2 / group=drug groupdisplay=cluster clusterwidth=0.5;
  refline 26 / axis=x;
  refline 0  / axis=y lineattrs=(pattern=shortdash);
  xaxis type=linear values=(0 1 2 4 8 12 16 20 24 28) max=29 valueshint display=(nolabel);
  yaxis label='Mean change (msec)' values=(-6 to 3 by 1) offsetmin=0.14 offsetmax=0.02;
  keylegend 'a' / location=inside position=top;
  run;
title;
footnote;

/*--QTc Graph witn Inner AtRisk Table using Y2 axis Scatter Journal--*/
%modstyle(name=markers, parent=journal, type=CLM, markers=circlefilled trianglefilled);
ods listing style=markers;
ods graphics / reset width=5in height=3in imagename='3_2_3_1_QTc_Mean_Inner_Journal_V93';
title 'Mean Change of QTc by Week and Treatment';
footnote j=l h=0.8 'Note: Vertical lines represent 95% confidence intervals.  LOCF is last observation carried forward';
proc sgplot data=QTc_Mean_Group_Header;
  format week qtcmean. N 3.0;
  scatter x=week y=mean / yerrorupper=high yerrorlower=low group=drug name='a' nomissinggroup 
          groupdisplay=cluster clusterwidth=0.5 markerattrs=(size=7);
  series x=week y=mean2 / group=drug groupdisplay=cluster clusterwidth=0.5 lineattrs=(pattern=solid);
  highlow y=ylbl low=xlbl high=xlbl / highlabel=highlabel lowlabel=lowlabel
          y2axis lineattrs=(thickness=0);
  scatter x=week y=drug / markerchar=n group=drug markercharattrs=(size=5 weight=bold) y2axis;
  refline 26 / axis=x;
  refline -6  / axis=y;
  refline 0  / axis=y lineattrs=(pattern=shortdash);
  xaxis type=linear values=(0 1 2 4 8 12 16 20 24 28) max=29 valueshint display=(nolabel);
  yaxis label='Mean change (msec)' values=(-6 to 3 by 1) offsetmin=0.14 offsetmax=0.02;
  y2axis offsetmin=0.88 offsetmax=0.03 display=none reverse;
  keylegend 'a' / location=inside position=top;
  run;
title;
footnote;




