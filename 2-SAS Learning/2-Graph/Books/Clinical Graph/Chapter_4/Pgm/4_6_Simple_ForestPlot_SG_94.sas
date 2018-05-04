%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods html close;
ods listing style=analysis image_dpi=&dpi gpath=&gpath;
option missing=' ';

data forest;
  input Study $1-16 grp OR LCL UCL Wt Lbl $46-61;
  format wt percent5. or lcl ucl 5.3;
  format Q1 Q3 4.2 ;

  study=translate(study, 'A0'x, ',');
  ObsId=_N_;
  or2=or;
  if grp=1 then do;
    wt=wt*.05;
    Q1=or-or*wt;      
    Q3=or+or*wt;
        or2=.;
  end;

  if lbl='Favors Treatment' then xlbl=0.1;
  else if lbl='Favors Placebo' then xlbl=10;

  datalines;
Modano  (1967)    1  0.590 0.096 3.634  1
Borodan (1981)    1  0.464 0.201 1.074  3.5
Leighton (1972)   1  0.394 0.076 2.055  2
Novak   (1992)    1  0.490 0.088 2.737  2
Stawer  (1998)    1  1.250 0.479 3.261  3
Truark   (2002)   1  0.129 0.027 0.605  2.5
Fayney   (2005)   1  0.313 0.054 1.805  2
Modano  (1969)    1  0.429 0.070 2.620  2
Soloway (2000)    1  0.718 0.237 2.179  3
Adams   (1999)    1  0.143 0.082 0.250  4
Truark2  (2002)   1  0.129 0.027 0.605  2.5
Fayney2  (2005)   1  0.313 0.054 1.805  2
Modano2 (1969)    1  0.429 0.070 2.620  2
Soloway2(2000)    1  0.718 0.237 2.179  3
Adams2   (1999)   1  0.143 0.082 0.250  4
Overall           2  0.328 .     .      .
,                 2  .     .     .      .    Favors Treatment
,                 2  .     .     .      .    Favors Placebo
;
run;
/*proc print data=forest; run;*/

/*--Simple Forest Plot using AxisTable--*/
ods listing style=analysis;
ods graphics / reset width=5in height=3in  imagename="4_6_1_Simple_Forest_SG_V94";
title "Impact of Treatment on Mortality by Study";
title2 h=8pt 'Odds Ratio and 95% CL';
proc sgplot data=forest noautolegend nocycleattrs;
  styleattrs datasymbols=(squarefilled diamondfilled);
  scatter y=study x=or / xerrorupper=ucl xerrorlower=lcl group=grp;
  yaxistable or lcl ucl wt / y=study location=inside position=right;
  refline 1 100  / axis=x noclip;
  refline 0.01 0.1 10 / axis=x lineattrs=(pattern=shortdash) transparency=0.5 noclip;
  text y=study x=xlbl text=lbl  / position=center contributeoffsets=none;
  xaxis type=log  max=100 minor display=(nolabel)  valueattrs=(size=7);
  yaxis display=(noticks nolabel)  fitpolicy=none reverse valueshalign=left
        colorbands=even colorbandsattrs=Graphdatadefault(transparency=0.8)  valueattrs=(size=7);
run;
title;

/*--Simple Forest Plot using AxisTable--*/
ods listing style=analysis;
ods graphics / reset width=5in height=3in  imagename="4_6_2_Simple_Forest_Wt_SG_V94";
title "Impact of Treatment on Mortality by Study";
title2 h=8pt 'Odds Ratio and 95% CL';
proc sgplot data=forest noautolegend nocycleattrs nowall noborder;
  styleattrs axisextent=data;
  scatter y=study x=or2 / markerattrs=graphdata2(symbol=diamondfilled);
  highlow y=study low=lcl high=ucl / type=line;
  highlow y=study low=q1 high=q3 / type=bar barwidth=0.6;
  yaxistable study / y=study location=inside position=left labelattrs=(size=7);
  yaxistable or lcl ucl wt / y=study location=inside position=right 
             labelattrs=(size=7);
  refline 1  / axis=x noclip;
  refline 0.01 0.1 10 100 / axis=x lineattrs=(pattern=shortdash) transparency=0.5 noclip;
  text y=study x=xlbl text=lbl  / position=center contributeoffsets=none;
  xaxis type=log  max=100 minor display=(nolabel)  valueattrs=(size=7);
  yaxis display=none fitpolicy=none reverse valueshalign=left 
        colorbands=even colorbandsattrs=Graphdatadefault(transparency=0.8)  valueattrs=(size=7);
run;
title;

/*--Simple Forest Plot using AxisTable with markers width sized by weight Journal--*/
ods graphics / reset width=5in height=3in  imagename="4_6_3_Simple_Forest_Journal_SG_V94";
ods listing style=journal;
title "Impact of Treatment on Mortality by Study";
title2 h=8pt 'Odds Ratio and 95% CL';
proc sgplot data=forest noautolegend nocycleattrs nowall noborder;
  styleattrs axisextent=data;
  scatter y=study x=or2 / markerattrs=graphdata2(symbol=diamondfilled);
  highlow y=study low=lcl high=ucl / type=line;
  highlow y=study low=q1 high=q3 / type=bar barwidth=0.6;
  yaxistable study / y=study location=inside position=left labelattrs=(size=7);
  yaxistable or lcl ucl wt / y=study location=inside position=right 
             labelattrs=(size=7);
  refline 1  / axis=x noclip;
  refline 0.01 0.1 10 100 / axis=x lineattrs=(pattern=shortdash) transparency=0.5 noclip;
  text y=study x=xlbl text=lbl  / position=center contributeoffsets=none;
  xaxis type=log  max=100 minor display=(nolabel)  valueattrs=(size=7);
  yaxis display=none fitpolicy=none reverse valueshalign=left 
        colorbands=even colorbandsattrs=Graphdatadefault(transparency=0.8)  valueattrs=(size=7);
run;
title;


