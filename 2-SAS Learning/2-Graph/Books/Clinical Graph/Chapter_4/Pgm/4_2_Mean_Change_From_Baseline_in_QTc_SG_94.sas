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

proc format;
  value qtcmean 
    28='LOCF';
        ;
run;

/*ods html;*/
/*proc print data=QTc_Mean_Group noobs;run;*/
/*ods html close;*/

/*--QTc Graph witn Outer Axis Table--*/
ods listing style=htmlblue;
ods graphics / reset width=5in height=3in imagename='4_2_1_QTc_Mean_OuterAxisTable_V94';
title 'Mean Change of QTc by Week and Treatment';
footnote j=l h=0.8 "Note: Vertical lines represent 95% confidence intervals."
   "  LOCF is last observation carried forward";
proc sgplot data=QTc_Mean_Group;
  format week qtcmean.;
  format n 3.0;
  scatter x=week y=mean / yerrorupper=high yerrorlower=low group=drug name='a' 
          groupdisplay=cluster clusterwidth=0.5 markerattrs=(size=7 symbol=circlefilled);
  series x=week y=mean2 / group=drug groupdisplay=cluster clusterwidth=0.5;
  xaxistable n / class=drug colorgroup=drug location=outside valueattrs=(size=5 weight=bold) 
            labelattrs=(size=6 weight=bold) title='Number of Subjects at Visit' titleattrs=(size=8);
  refline 26 / axis=x;
  refline 0  / axis=y lineattrs=(pattern=shortdash);
  xaxis type=linear values=(0 1 2 4 8 12 16 20 24 28) max=29 valueshint display=(nolabel);
  yaxis label='Mean change (msec)' values=(-6 to 3 by 1);
  run;
title;
footnote;

/*--QTc Graph witn internal AtRisk Table--*/
ods listing style=htmlblue;
ods graphics / reset width=5in height=3in imagename='4_2_2_QTc_Mean_InnerTable_V94';
footnote j=l h=0.8 "Note: Vertical lines represent 95% confidence intervals."
   "  LOCF is last observation carried forward";
title 'Mean Change of QTc by Week and Treatment';
proc sgplot data=QTc_Mean_Group;
  format week qtcmean.;
  format n 3.0;
  scatter x=week y=mean / yerrorupper=high yerrorlower=low group=drug name='a' 
          groupdisplay=cluster clusterwidth=0.5 markerattrs=(size=7 symbol=circlefilled);
  series x=week y=mean2 / group=drug groupdisplay=cluster clusterwidth=0.5;
  xaxistable n / class=drug colorgroup=drug location=inside valueattrs=(size=5 weight=bold) 
            labelattrs=(size=6 weight=bold) title='Number of Subjects at Visit' 
            titleattrs=(size=8) separator;
  refline 26 / axis=x;
  refline 0  / axis=y lineattrs=(pattern=shortdash);
  xaxis type=linear values=(0 1 2 4 8 12 16 20 24 28) max=29 valueshint display=(nolabel);
  yaxis label='Mean change (msec)' values=(-6 to 3 by 1);
  keylegend 'a' / title='Drug: ' location=inside position=top;
  run;
title;
footnote;

/*--QTc Graph witn internal AtRisk Table--*/
ods listing style=journal;
ods graphics / reset width=5in height=3in imagename='4_2_3_QTc_Mean_Journal_V94';
footnote j=l h=0.8 "Note: Vertical lines represent 95% confidence intervals."
   "  LOCF is last observation carried forward";
title 'Mean Change of QTc by Week and Treatment';
proc sgplot data=QTc_Mean_Group;
  styleattrs datasymbols=(circlefilled trianglefilled) datalinepatterns=(solid shortdash);
  format week qtcmean.;
  format n 3.0;
  series x=week y=mean2 / group=drug groupdisplay=cluster clusterwidth=0.5;
  scatter x=week y=mean / yerrorupper=high yerrorlower=low group=drug name='a' 
          groupdisplay=cluster clusterwidth=0.5 markerattrs=(size=7) filledoutlinedmarkers
          markerfillattrs=graphwalls;
  xaxistable n / class=drug colorgroup=drug location=inside valueattrs=(size=5 weight=bold) 
            labelattrs=(size=6 weight=bold) title='Number of Subjects at Visit' titleattrs=(size=8)
            separator;
  refline 26 / axis=x;
  refline 0  / axis=y lineattrs=(pattern=shortdash);
  xaxis type=linear values=(0 1 2 4 8 12 16 20 24 28) max=29 valueshint display=(nolabel);
  yaxis label='Mean change (msec)' values=(-6 to 3 by 1);
  keylegend 'a' / title='Drug: ' location=inside position=top;
  run;
title;
footnote;







