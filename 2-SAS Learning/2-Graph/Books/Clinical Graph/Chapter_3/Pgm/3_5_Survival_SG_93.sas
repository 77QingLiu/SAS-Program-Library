%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods html close;
ods listing style=htmlblue image_dpi=&dpi gpath=&gpath; 

/*--Get survival plot data from LIFETEST procedure--*/
ods graphics on;
ods output Survivalplot=SurvivalPlotData;
proc lifetest data=sashelp.BMT plots=survival(atrisk=0 to 2500 by 500);
   time T * Status(0);
   strata Group / test=logrank adjust=sidak;
   run;

ods html;
proc print data=SurvivalPlotData;run;
ods html close;

/*--Anno data set for outer table--*/
data anno_out;
  retain Function 'text' Y1Space 'graphpercent' Anchor 'Center';
  retain  TextSize 7;
  length TextColor $25 Label $100 X1Space $12 TextWeight $6;
  set SurvivalPlotData(keep=tAtRisk atRisk Stratum Stratumnum) end=last;

  Width=10; Anchor='center'; X1Space='datavalue'; TextWeight='Normal';
  if tAtRisk ne . then do;
    Label=put(atRisk, 5.0); X1=tatrisk;
    if stratumnum=1 then do; Y1=12; TextColor='GraphData1:contrastcolor'; end;
    else if stratumnum=2 then do; Y1=8; TextColor='GraphData2:contrastcolor'; end;
    else do; Y1=4; TextColor='GraphData3:contrastcolor'; end;
    output;
  end;

  if last then do;
    Width=20; TextSize=7; TextWeight='Bold';
    X1Space='wallpercent'; X1=-1; Anchor='Right';
    Y1=12; TextColor='GraphData1:contrastcolor'; Label='ALL'; output; 
    Y1=8; TextColor='GraphData2:contrastcolor'; Label='AML-High Risk'; output;
    Y1=4; TextColor='GraphData3:contrastcolor'; Label='AML-Low Risk'; output;
  end;
run;

ods html;
proc print data=anno_out(obs=3);
  var function x1space y1space x1 y1 label textcolor textsize textweight Anchor;
run;

proc print data=anno_out(firstobs=19 obs=21);
  var function x1space y1space x1 y1 label textcolor textsize textweight Anchor;
run;

ods html close;

/*--Survival Plot with outer Risk Table using Annotate--*/
ods graphics / reset width=5in height=3in imagename='3_5_1_1_Survival Plot_SG_Out_Table_V93';
title 'Product-Limit Survival Estimates';
title2  h=0.8 'With Number of AML Subjects at Risk';
proc sgplot data=SurvivalPlotData sganno=anno_out pad=(bottom=15pct left=6pct);
  step x=time y=survival / group=stratum lineattrs=(pattern=solid) name='s';
  scatter x=time y=censored / markerattrs=(symbol=plus) name='c';
  scatter x=time y=censored / markerattrs=(symbol=plus) GROUP=stratum;
  keylegend 'c' / location=inside position=topright;
  keylegend 's';
run;

/*--Survival Plot without table--*/
ods graphics / reset width=5in height=3in imagename='3_5_1_2_Survival Plot_No_Table_SG_V93';
title 'Product-Limit Survival Estimates';
title2  h=0.8 'With Number of AML Subjects at Risk';
proc sgplot data=SurvivalPlotData pad=(bottom=15pct);
  step x=time y=survival / group=stratum lineattrs=(pattern=solid) name='s';
  scatter x=time y=censored / markerattrs=(symbol=plus) name='c';
  scatter x=time y=censored / markerattrs=(symbol=plus) GROUP=stratum;
  keylegend 'c' / location=inside position=topright;
  keylegend 's';
run;

/*--Anno data set for Inner table--*/
data anno_in;
  retain Function 'text' Y1Space 'wallpercent' Anchor 'Center';
  retain  TextSize 6;
  length TextColor $25 Label $100 X1Space $12 TextWeight $6;
  set SurvivalPlotData(keep=tAtRisk atRisk Stratum Stratumnum) end=last;

  Width=10; Anchor='center'; X1Space='datavalue'; TextWeight='Normal';
  if tAtRisk ne . then do;
    Label=put(atRisk, 5.0); X1=tatrisk;
    if stratumnum=1 then do; Y1=15; TextColor='GraphData1:contrastcolor'; end;
    else if stratumnum=2 then do; Y1=10; TextColor='GraphData2:contrastcolor'; end;
    else do; Y1=5; TextColor='GraphData3:contrastcolor'; end;
    output;
  end;

  if last then do;
    Width=20; TextSize=6; TextWeight='Bold';
    X1Space='wallpercent'; X1=-1; Anchor='Right';
    Y1=15; TextColor='GraphData1:contrastcolor'; Label='ALL'; output; 
    Y1=10; TextColor='GraphData2:contrastcolor'; Label='AML-High Risk'; output;
    Y1=5;  TextColor='GraphData3:contrastcolor'; Label='AML-Low Risk'; output;
  end;
run;

ods html;
proc print data=SurvivalPlotData;
run;

proc print data=anno_in(obs=3);
  var function x1space y1space x1 y1 label textcolor textsize textweight Anchor;
run;

proc print data=anno_in(firstobs=19 obs=21);
  var function x1space y1space x1 y1 label textcolor textsize textweight Anchor;
run;

ods html close;

/*--Survival Plot Inner Table without table--*/
/*ods graphics / reset width=5in height=3in imagename='3_5_3_Survival Plot_SG_V93';*/
/*title 'Product-Limit Survival Estimates';*/
/*title2  h=0.8 'With Number of AML Subjects at Risk';*/
/*proc sgplot data=SurvivalPlotData;*/
/*  step x=time y=survival / group=stratum lineattrs=(pattern=solid) name='s';*/
/*  scatter x=time y=censored / markerattrs=(symbol=plus) name='c';*/
/*  scatter x=time y=censored / markerattrs=(symbol=plus) GROUP=stratum;*/
/*  refline 0.2;*/
/*  yaxis offsetmin=0.2;*/
/*  keylegend 'c' / location=inside position=topright;*/
/*  keylegend 's';*/
/*run;*/

/*--Survival Plot with inner Risk Table using Annotate--*/
ods graphics / reset width=5in height=3in imagename='3_5_2_Survival Plot_SG_In_Table_V93';
title 'Product-Limit Survival Estimates';
title2  h=0.8 'With Number of AML Subjects at Risk';
proc sgplot data=SurvivalPlotData sganno=anno_in pad=(left=6pct);
  step x=time y=survival / group=stratum lineattrs=(pattern=solid) name='s';
  scatter x=time y=censored / markerattrs=(symbol=plus) name='c';
  scatter x=time y=censored / markerattrs=(symbol=plus) GROUP=stratum;
  refline 0.2;
  yaxis offsetmin=0.2;
  keylegend 'c' / location=inside position=topright;
  keylegend 's';
run;


/*--Survival Plot with inner Risk Table using AxisTable Journal--*/
ods listing style=journal;
ods graphics / reset width=5in height=3in imagename='3_5_3_Survival Plot_Inner_Journal_SG_V93';
title 'Product-Limit Survival Estimates';
title2  h=0.8 'With Number of AML Subjects at Risk';
proc sgplot data=SurvivalPlotData sganno=anno_in pad=(left=6pct);
  step x=time y=survival / group=stratumnum lineattrs=(pattern=solid) curvelabel name='s';
  scatter x=time y=censored / name='c' markerattrs=(symbol=circlefilled size=4);
  keylegend 'c' / location=inside position=top;
  inset ("1:"="ALL" "2:"="AML-High Risk" "3:"="AML-Low Risk") / border;
  refline 0.2;
  yaxis offsetmin=0.2;
run;







