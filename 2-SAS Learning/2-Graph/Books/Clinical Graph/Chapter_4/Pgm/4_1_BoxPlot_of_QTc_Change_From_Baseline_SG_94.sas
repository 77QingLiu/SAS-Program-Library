%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods html close;
ods listing style=htmlblue image_dpi=&dpi gpath=&gpath; 
option missing=' ';


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

proc format;
  value qtcweek 
    28='Max';
        ;
run;

/*ods html;*/
/*proc print data=qtcdata noobs;*/
/*var Week Drug QTc Risk;*/
/*run;*/
/*ods html close;*/

/*--QTc Graph with Outer Axis Table--*/
ods listing style=htmlblue; 
ods graphics / reset width=5in height=3in imagename='4_1_1_QTc_SG_AxisTable_Out_V94';
title 'QTc Change from Baseline by Week and Treatment';
footnote j=l "Note:  Increase < 30 msec 'Normal', "
             "30-60 msec 'Concern', > 60 msec 'High' ";
proc sgplot data=QTcData;
  format week qtcweek.;
  vbox qtc / category=week group=drug groupdisplay=cluster nofill;
  xaxistable risk / class=drug colorgroup=drug valueattrs=(size=6 weight=bold) 
             labelattrs=(size=6 weight=bold);
  refline 26 / axis=x;
  refline 0 30 60 / axis=y lineattrs=(pattern=shortdash);
  xaxis type=linear values=(1 2 4 8 12 16 20 24 28) max=29 valueshint display=(nolabel);
  yaxis label='QTc change from baseline' values=(-120 to 90 by 30);
  keylegend / title='' linelength=20;
  run;
title;
footnote;

data QTcBand;
  length Label $8;
  set QTcData end=last;
  output;
  call missing (Week, Drug, QTc, Risk);
  if last then do;
    wk=36; Drug='Drug A'; Qtc=.;output;
        wk=36; Drug='Drug B'; Qtc=.;output;
        call missing (QTc, Risk);
    Wk=0;  L0=0; L30=30; L60=60; L90=120; output;
        Wk=30; L0=0; L30=30; L60=60; L90=120; output;
        call missing (L0, L30, L60, L90);
        Wk=14; YLabel=-60;  Label='Normal'; output;
        Wk=14; YLabel=45;   Label='Concern'; output;
        Wk=14; YLabel=75;   Label='High'; output;
  end;
run;

/*ods html;*/
/*proc print data=QTcBand noobs;*/
/*var Week Drug QTc Risk;*/
/*run;*/
/*ods html close;*/

/*--QTc Graph with Inner Axis Table and Bands--*/
ods listing style=htmlblue; 
ods graphics / reset width=5in height=3in imagename='4_1_2_QTc_SG_AxisTable_In_Band_Label_V94';
title 'QTc Change from Baseline by Week and Treatment';
proc sgplot data=QTcBand;
  format week qtcweek.;
  band x=wk lower=L0  upper=L30 / fill legendlabel='Normal'
       fillattrs=(color=white transparency=0.6) ;
  band x=wk lower=L30 upper=L60 / fill legendlabel='Concern'
       fillattrs=(color=gold transparency=0.6) ;
  band x=wk lower=L60 upper=L90 / fill legendlabel='High'
       fillattrs=(color=pink transparency=0.6);
  vbox qtc / category=week group=drug groupdisplay=cluster nofill name='a';
  text x=wk y=ylabel text=label / contributeoffsets=none;
  xaxistable risk / class=drug colorgroup=drug valueattrs=(size=6 weight=bold) 
             labelattrs=(size=6 weight=bold) location=inside;
  refline 26 / axis=x;
  xaxis type=linear values=(1 2 4 8 12 16 20 24 28) valueshint min=1 max=29 display=(nolabel) 
        colorbands=odd colorbandsattrs=(transparency=1);
  yaxis label='QTc change from baseline' values=(-120 to 90 by 30);
  keylegend 'a' / title='Treatment:' linelength=20;
  run;
title;
footnote;

/*--QTc Graph with Inner Axis Table and Bands and Markers in Legend--*/
ods listing style=journal;
ods graphics / reset width=5in height=3in imagename='4_1_3_QTc_SG_AxisTable_Journal_Marker_V94';
title 'QTc Change from Baseline by Week and Treatment';
proc sgplot data=QTcBand;
  format week qtcweek.;
  styleattrs datalinepatterns=(solid);
  band x=wk lower=L0  upper=L30 / fill legendlabel='Normal'
       fillattrs=(color=white transparency=0.6);
  band x=wk lower=L30 upper=L60 / fill  legendlabel='Concern'
       fillattrs=(color=lightgray transparency=0.6);
  band x=wk lower=L60 upper=L90 / fill legendlabel='High'
       fillattrs=(color=gray transparency=0.6) ;
  vbox qtc / category=week group=drug groupdisplay=cluster nofill;
  scatter x=wk y=QTc / group=drug name='a' nomissinggroup;
  text x=wk y=ylabel text=label / contributeoffsets=none;
  xaxistable risk / class=drug colorgroup=drug valueattrs=(size=6 weight=bold) 
             labelattrs=(size=6 weight=bold) location=inside;
  refline 26 / axis=x;
  xaxis type=linear values=(1 2 4 8 12 16 20 24 28) valueshint min=1 max=29 display=(nolabel) 
        colorbands=odd colorbandsattrs=(transparency=1);
  yaxis label='QTc change from baseline' values=(-120 to 90 by 30);
  keylegend 'a' / title='Treatment:' linelength=20;
  run;
title;
footnote;

