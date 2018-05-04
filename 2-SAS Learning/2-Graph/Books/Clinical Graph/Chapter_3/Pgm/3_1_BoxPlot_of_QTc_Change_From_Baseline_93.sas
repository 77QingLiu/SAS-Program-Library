%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods listing style=htmlblue image_dpi=&dpi gpath=&gpath; 

option missing=' ';

ods html close;
ods listing;

data QTcData;
  drop i;
  do Week=1, 2, 4, 8, 12, 16, 20, 24, 28;
        QTc=90-180*ranuni(2); Risk=floor(280-5*week*ranuni(2)); Drug='Drug A'; output;
        QTc=90-180*ranuni(2); Risk=floor(410-6*week*ranuni(2)); Drug='Drug B'; output;
        Risk=.;
    do i=1 to 10;
          QTc=90-180*ranuni(2); Drug='Drug A'; output;
          QTc=90-180*ranuni(2); Drug='Drug B'; output;
        end;
    do i=1 to 20;
          QTc=90-60*ranuni(2); Drug='Drug A'; output;
          QTc=90-90*ranuni(2); Drug='Drug B'; output;
        end;
  end;
run;

/*ods html;*/
/*proc print data=qtcdata noobs;*/
/*var Week Drug QTc Risk;*/
/*run;*/
/*ods html close;*/

proc format;
  value qtcweek 
    28='Max';
        ;
run;

/*--Annotate data set for outer Risk Table--*/
data annoOut;
  set QTcData(keep=week drug risk) end=last;
  length Label $100 X1Space Y1Space $12 TextWeight $10 Anchor $8;
  Function='Text'; X1Space='DataValue'; Y1Space='GraphPercent'; TextSize=5; TextWeight='Bold';
  if drug='Drug A' then 
  do; Y1=11; TextColor='GraphData1:ContrastColor'; end;
  else do; Y1=8; TextColor='GraphData2:ContrastColor'; end;
  if risk ne . then do;
    X1=week; Label=strip(put(risk,3.0)); output;
  end;
  if last then do;
    Width=20; WidthUnit='Percent';
        Anchor='Right'; TextSize=5; TextWeight='Bold'; 
    X1Space='WallPercent'; 
    X1=-1; Y1=11; TextColor='GraphData1:ContrastColor'; Label='Drug A'; output;
        X1=-1; Y1=8;  TextColor='GraphData2:ContrastColor'; Label='Drug B'; output;

    X1Space='WallPercent'; 
    Anchor='Left'; TextSize=7; TextwEIGHT='Normal'; 
    X1=-6.5; Y1=14; TextColor='Black'; Label='Subjects At-Risk'; output; 

        X1Space='GraphPercent'; Width=100; 
    Anchor='Left'; TextSize=9; TextwEIGHT='Normal';
    x1=1; y1=4; TextColor='Black'; Label="Note:  Increase < 30 msec 'Normal' 30-60 msec 'Concern', > 60 msec 'High'"; output;
  end;
run;

ods html;
proc print data=annoOut(obs=5);
var function X1Space Y1Space x1 y1 TextSize TextWeight TextColor Label;
run;

proc print data=annoOut(firstobs=19 obs=22);
var function X1Space Y1Space x1 y1 TextSize TextWeight TextColor Label Anchor;
run;
ods html close;

/*--QTc Graph with Outer Axis Table--*/
ods listing style=htmlblue; 
ods graphics / reset width=5in height=3in imagename='3_1_1_1_QTc_SG_RiskTable_Out_V93';
title 'QTc Change from Baseline by Week and Treatment';
proc sgplot data=QTcData  sganno=annoOut pad=(bottom=15pct);
  format week qtcweek.;
  vbox qtc / category=week group=drug groupdisplay=cluster nofill;
  refline 26 / axis=x;
  refline 0 30 60 / axis=y lineattrs=(pattern=shortdash);
  xaxis type=linear values=(1 2 4 8 12 16 20 24 28) max=29 valueshint display=(nolabel);
  yaxis label='QTc change from baseline' values=(-120 to 90 by 30);
  keylegend / title='';
  run;
title;
footnote;

/*--QTc Graph without Table--*/
ods listing style=htmlblue; 
ods graphics / reset width=5in height=3in imagename='3_1_1_2_QTc_V93';
title 'QTc Change from Baseline by Week and Treatment';
proc sgplot data=QTcData pad=(bottom=15pct);
  format week qtcweek.;
  vbox qtc / category=week group=drug groupdisplay=cluster nofill;
  refline 26 / axis=x;
  refline 0 30 60 / axis=y lineattrs=(pattern=shortdash);
  xaxis type=linear values=(1 2 4 8 12 16 20 24 28) max=29 valueshint display=(nolabel);
  yaxis label='QTc change from baseline' values=(-120 to 90 by 30);
  keylegend / title='';
  run;
title;
footnote;

/*--Annotate data set for Inner Risk Table--*/
data AnnoIn;
  set QTcData(keep=week drug risk) end=last;
  length Label $100 X1Space Y1Space $12 TextWeight $10 Anchor $8;
  Function='Text'; X1Space='DataValue'; Y1Space='WallPercent'; TextSize=5; TextWeight='Bold';
  if drug='Drug A' then 
  do; Y1=7; TextColor='GraphData1:ContrastColor'; end;
  else do; Y1=3; TextColor='GraphData2:ContrastColor'; end;
  if risk ne . then do;
    X1=week; label=strip(put(risk,3.0)); output;
  end;
  if last then do;
    Width=20; WidthUnit='Percent';
    X1Space='WallPercent'; 
    Anchor='Left'; TextSize=6; TextWeight='Normal'; 
    X1=1; Y1=12; TextColor='Black'; Label='Subjects At-Risk'; output;

        Anchor='Right'; TextSize=5; TextWeight='Bold'; 
    X1=-1; Y1=7; TextColor='GraphData1:ContrastColor'; Label='Drug A'; output;
        X1=-1; Y1=3; TextColor='GraphData2:ContrastColor'; Label='Drug B'; output;
  end;
run;

ods html;
proc print data=AnnoIn(obs=3);
var function X1Space Y1Space x1 y1 TextSize TextWeight TextColor Label;
run;

proc print data=AnnoIn(firstobs=19 obs=21);
var function X1Space Y1Space x1 y1 TextSize TextWeight TextColor Anchor Label;
run;
ods html close;


/*--QTc Graph with Inner Axis Table--*/
ods listing style=htmlblue; 
ods graphics / reset width=5in height=3in imagename='3_1_2_1_QTc_SG_RiskTable_In_V93';
title 'QTc Change from Baseline by Week and Treatment';
footnote j=l "Note:  Increase < 30 msec 'Normal', "
             "30-60 msec 'Concern', > 60 msec 'High' ";
proc sgplot data=QTcData sganno=annoIn;
  format week qtcweek.;
  vbox qtc / category=week group=drug groupdisplay=cluster nofill name='a';
  refline 26 / axis=x;
  refline 0 30 60 / axis=y lineattrs=(pattern=shortdash);
  refline -120 / axis=y;
  xaxis type=linear values=(1 2 4 8 12 16 20 24 28) valueshint min=1 max=29 display=(nolabel);
  yaxis label='QTc change from baseline' values=(-120 to 90 by 30) offsetmin=0.14;
  keylegend 'a' / title='Treatment:';
  run;
title;
footnote;



/*--QTc Graph with Inner Axis Table Journal--*/
ods listing style=journal; 
ods graphics / reset width=5in height=3in imagename='3_1_3_1_QTc_SG_Journal_In_V93';
title 'QTc Change from Baseline by Week and Treatment';
footnote j=l "Note:  Increase < 30 msec 'Normal', "
             "30-60 msec 'Concern', > 60 msec 'High' ";
proc sgplot data=QTcData sganno=annoIn;
  format week qtcweek.;
  vbox qtc / category=week group=drug groupdisplay=cluster nofill name='a';
  refline 26 / axis=x;
  refline 0 30 60 / axis=y lineattrs=(pattern=shortdash);
  refline -120 / axis=y;
  xaxis type=linear values=(1 2 4 8 12 16 20 24 28) valueshint min=1 max=29 display=(nolabel);
  yaxis label='QTc change from baseline' values=(-120 to 90 by 30) offsetmin=0.14;
  keylegend 'a' / title='Treatment:';
  run;
title;
footnote;

/*--Annotate data set for Inner Risk Table and Legend--*/
data AnnoInLegend;
  set QTcData(keep=week drug risk) end=last;
  length Function $10 Label $100 X1Space Y1Space $12 TextWeight $10 Anchor $8;
  Function='Text'; X1Space='DataValue'; Y1Space='WallPercent'; TextSize=5; TextWeight='Bold';
  if drug='Drug A' then 
  do; Y1=7; TextColor='GraphData1:ContrastColor'; end;
  else do; Y1=3; TextColor='GraphData2:ContrastColor'; end;
  if risk ne . then do;
    X1=week; label=strip(put(risk,3.0)); output;
  end;
  if last then do;
    Width=20; WidthUnit='Percent';
    X1Space='WallPercent'; 
    Anchor='Left'; TextSize=6; TextWeight='Normal'; 
    X1=1; Y1=12; TextColor='Black'; Label='Subjects At-Risk'; output;

        Anchor='Right'; TextSize=5; TextWeight='Bold'; 
    X1=-1; Y1=7; TextColor='GraphData1:ContrastColor'; Label='Drug A'; output;
        X1=-1; Y1=3; TextColor='GraphData2:ContrastColor'; Label='Drug B'; output;

        /*--Legend Box--*/
        call missing(label, textsize, textweight, textcolor, anchor);
        Function='Rectangle'; X1Space='WallPercent'; Y1Space='GraphPercent';
        Display='Outline'; X1=50; Y1=14; width=34; height=6; 
    linethickness=1; anchor='center'; output;

        /*--Legend Title--*/
        TextSize=7; TextWeight='Normal'; textcolor='Black';
        Function='Text'; X1Space='WallPercent'; Y1Space='GraphPercent';
        X1=X1-16; Y1=14; anchor='left';  
    Label='Treatment: '; output;

        /*--1st Legend Item--*/
    call missing(label, textsize, textweight, textcolor, anchor);
        Function='Oval'; X1Space='WallPercent'; Y1Space='GraphPercent';
        X1=X1+12; Y1=14; width=8; height=8; 
    linethickness=1; anchor='center'; widthunit='Pixel'; heightunit='Pixel'; output;

    TextSize=7; TextWeight='Normal'; textcolor='Black';
    Function='Text'; X1Space='WallPercent'; Y1Space='GraphPercent';
        Width=20; WidthUnit='Percent';
    X1=X1+1; Y1=14; anchor='left';  
    Label='Drug A'; output;

        /*--2nd Legend Item--*/
        call missing(label, textsize, textweight, textcolor, anchor);
    Function='Line'; linethickness=1;
    X1Space='WallPercent'; Y1Space='GraphPercent';  X2Space='WallPercent'; Y2Space='GraphPercent'; 
    X1=X1+9; Y1=14; X2=X1+1.5; Y2=14; ; output;
        X1=X1+0.75; Y1=15; X2=X1; Y2=13; ; output;

    TextSize=7; TextWeight='Normal'; textcolor='Black';
    Function='Text'; X1Space='WallPercent'; Y1Space='GraphPercent';
        Width=20; WidthUnit='Percent';
    X1=X1+2; Y1=14; anchor='left';  
    Label='Drug B '; output;
  end;
run;

ods html;
proc print data=AnnoInLegend(firstobs=22);
var function X1Space Y1Space x1 y1 TextSize TextWeight TextColor Anchor Label;
run;
ods html close;

/*--QTc Graph with Inner Axis Table Journal Annotated Legend--*/
ods listing style=journal; 
ods graphics / reset width=5in height=3in imagename='3_1_3_2_QTc_SG_Journal_AnnoLegend_V93';
title 'QTc Change from Baseline by Week and Treatment';
footnote h=20pt j=l " ";
footnote2 j=l "Note:  Increase < 30 msec 'Normal', "
             "30-60 msec 'Concern', > 60 msec 'High' ";
proc sgplot data=QTcData sganno=AnnoInLegend noautolegend;
  format week qtcweek.;
  vbox qtc / category=week group=drug groupdisplay=cluster nofill name='a'
       lineattrs=(pattern=solid) whiskerattrs=(pattern=solid) meanattrs=(size=5)
       outlierattrs=(size=5);
  refline 26 / axis=x;
  refline 0 30 60 / axis=y lineattrs=(pattern=shortdash);
  refline -120 / axis=y;
  xaxis type=linear values=(1 2 4 8 12 16 20 24 28) valueshint min=1 max=29 display=(nolabel);
  yaxis label='QTc change from baseline' values=(-120 to 90 by 30) offsetmin=0.14;
  run;
title;
footnote;

/*--QTc Graph with Inner Axis Table Journal Annotated Legend--*/
/*ods listing style=journal; */
/*ods graphics / reset width=5in height=3in imagename='3_1_6_QTc_SG_Journal_Whisker_V93';*/
/*title 'QTc Change from Baseline by Week and Treatment';*/
/*footnote2 j=l "Note:  Increase < 30 msec 'Normal', "*/
/*             "30-60 msec 'Concern', > 60 msec 'High' ";*/
/*proc sgplot data=QTcData noautolegend  sganno=annoIn;*/
/*  format week qtcweek.;*/
/*  vbox qtc / category=week group=drug groupdisplay=cluster nofill name='a'*/
/*       lineattrs=(pattern=solid) meanattrs=(size=5)*/
/*       outlierattrs=(size=5);*/
/*  refline 26 / axis=x;*/
/*  refline 0 30 60 / axis=y lineattrs=(pattern=shortdash);*/
/*  refline -120 / axis=y;*/
/*  xaxis type=linear values=(1 2 4 8 12 16 20 24 28) valueshint min=1 max=29 display=(nolabel);*/
/*  yaxis label='QTc change from baseline' values=(-120 to 90 by 30) offsetmin=0.14;*/
/*  keylegend 'a' / title='Treatment:';*/
/*  run;*/
/*title;*/
/*footnote;*/

