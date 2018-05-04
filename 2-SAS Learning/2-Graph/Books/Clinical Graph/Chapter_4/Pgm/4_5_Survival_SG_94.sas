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

/*--Survival Plot with outer Risk Table using AxisTable--*/
ods graphics / reset width=5in height=3in imagename='4_5_1_Survival Plot_SG_V94';
title 'Product-Limit Survival Estimates';
title2  h=0.8 'With Number of AML Subjects at Risk';
proc sgplot data=SurvivalPlotData;
  step x=time y=survival / group=stratum lineattrs=(pattern=solid) name='s';
  scatter x=time y=censored / markerattrs=(symbol=plus) name='c';
  scatter x=time y=censored / markerattrs=(symbol=plus) GROUP=stratum;
  xaxistable atrisk / x=tatrisk location=outside class=stratum colorgroup=stratum;
  keylegend 'c' / location=inside position=topright;
  keylegend 's';
run;

/*--Survival Plot with inner Risk Table using AxisTable--*/
ods listing style=htmlBlue;
ods graphics / reset width=5in height=3in imagename='4_5_2_Survival Plot_Inner_SG_V94';
title 'Product-Limit Survival Estimates';
title2  h=0.8 'With Number of AML Subjects at Risk';
proc sgplot data=SurvivalPlotData;
  step x=time y=survival / group=stratum lineattrs=(pattern=solid) name='s';
  scatter x=time y=censored / markerattrs=(symbol=plus) name='c';
  scatter x=time y=censored / markerattrs=(symbol=plus) GROUP=stratum;
  xaxistable atrisk / x=tatrisk location=inside class=stratum colorgroup=stratum 
             separator valueattrs=(size=7 weight=bold) labelattrs=(size=8);
  keylegend 'c' / location=inside position=topright;
  keylegend 's';
run;

/*--Survival Plot with inner Risk Table using AxisTable Journal--*/
ods listing style=journal;
ods graphics / reset width=5in height=3in imagename='4_5_3_Survival Plot_Inner_Journal_SG_V94';
title 'Product-Limit Survival Estimates';
title2  h=0.8 'With Number of AML Subjects at Risk';
proc sgplot data=SurvivalPlotData;
  step x=time y=survival / group=stratum lineattrs=(pattern=solid) name='s' 
       curvelabel curvelabelattrs=(size=6) splitchar='-';
  scatter x=time y=censored / name='c' markerattrs=(symbol=circlefilled size=4);
  xaxistable atrisk / x=tatrisk location=inside class=stratum colorgroup=stratum 
             separator valueattrs=(size=7 weight=bold) labelattrs=(size=8);
  keylegend 'c' / location=inside position=topright;
run;


