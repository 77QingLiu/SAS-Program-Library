
%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods html close;
ods listing style=htmlblue image_dpi=&dpi gpath=&gpath; 

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
  
  or_lbl='OR';
  lcl_lbl='LCL';
  ucl_lbl='UCL';
  wt_lbl='Wt';

  if mod(_n_, 2) = 0 then study_lbl=study;
  if study eq 'A0'x then study_lbl=''; 

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

ods html;
proc print data=forest(obs=4); 
var study grp or lcl ucl wt or_lbl lcl_lbl ucl_lbl wt_lbl study_lbl;
run;
ods html close;

/*--Derive style--*/
%modstyle(name=forest, parent=analysis, type=CLM, markers=squarefilled diamondfilled);

/*--Simple Forest Plot using Left Side--*/
ods listing style=forest;
ods graphics / reset width=5in height=3in  imagename="3_6_1_2_Simple_Forest_SG_Left_V93";
title "Impact of Treatment on Mortality by Study";
title2 h=8pt 'Odds Ratio and 95% CL';
proc sgplot data=forest noautolegend;
  scatter y=study x=or / xerrorupper=ucl xerrorlower=lcl group=grp;
  refline 1 100  / axis=x noclip;
  refline 0.01 0.1 10 / axis=x lineattrs=(pattern=shortdash) transparency=0.5 noclip;
  scatter y=study x=xlbl / markerchar=lbl;
  xaxis type=log  max=100 minor display=(nolabel) valueattrs=(size=7) offsetmin=0.05 offsetmax=0.3;
  yaxis display=(noticks nolabel) reverse;
run;
title;

/*--Simple Forest Plot using Full--*/
ods listing style=forest;
ods graphics / reset width=5in height=3in  imagename="3_6_1_1_Simple_Forest_SG_Full_V93";
title "Impact of Treatment on Mortality by Study";
title2 h=8pt 'Odds Ratio and 95% CL';
proc sgplot data=forest noautolegend;
  refline study_lbl / transparency=0.95 lineattrs=(thickness=13px color=darkgreen);
  scatter y=study x=or / xerrorupper=ucl xerrorlower=lcl group=grp;
  refline 1 100  / axis=x noclip;
  refline 0.01 0.1 10 / axis=x lineattrs=(pattern=shortdash) transparency=0.5 noclip;
  scatter y=study x=xlbl / markerchar=lbl ;
  scatter y=study x=or_lbl  / markerchar=or  x2axis markercharattrs=(size=6);
  scatter y=study x=lcl_lbl / markerchar=lcl x2axis markercharattrs=(size=6);
  scatter y=study x=ucl_lbl / markerchar=ucl x2axis markercharattrs=(size=6);
  scatter y=study x=wt_lbl  / markerchar=wt  x2axis markercharattrs=(size=6);
  xaxis type=log  max=100 minor display=(nolabel) valueattrs=(size=7) offsetmin=0.05 offsetmax=0.3;
  yaxis display=(noticks nolabel) valueattrs=(size=7) reverse;
  x2axis display=(noticks nolabel) valueattrs=(size=7) offsetmin=0.75 offsetmax=0.05;
run;
title;

ods html;
proc print data=forest(obs=4); 
var study grp or lcl ucl wt or_lbl lcl_lbl ucl_lbl wt_lbl wt q1 q3;
run;
ods html close;

/*--Weighted Forest Plot using scatter with Markerchar--*/
ods listing style=forest;
ods graphics / reset width=5in height=3in  imagename="3_6_2_Simple_Forest_Wt_SG_V93";
title "Impact of Treatment on Mortality by Study";
title2 h=8pt 'Odds Ratio and 95% CL';
proc sgplot data=forest noautolegend nocycleattrs;
  refline study_lbl / transparency=0.95 lineattrs=(thickness=13px color=darkgreen);
  scatter y=study x=or2 / markerattrs=graphdata2(symbol=diamondfilled);
  highlow y=study low=lcl high=ucl / type=line lineattrs=(pattern=solid);
  highlow y=study low=q1 high=q3 / type=bar barwidth=0.6 fillattrs=graphdata1;
  refline 1 100  / axis=x noclip;
  refline 0.01 0.1 10 / axis=x lineattrs=(pattern=shortdash) transparency=0.5 noclip;
  scatter y=study x=xlbl / markerchar=lbl ;
  scatter y=study x=or_lbl  / markerchar=or  x2axis markercharattrs=(size=6);
  scatter y=study x=lcl_lbl / markerchar=lcl x2axis markercharattrs=(size=6);
  scatter y=study x=ucl_lbl / markerchar=ucl x2axis markercharattrs=(size=6);
  scatter y=study x=wt_lbl  / markerchar=wt  x2axis markercharattrs=(size=6);
  xaxis type=log  max=100 minor display=(nolabel) valueattrs=(size=7) offsetmin=0.05 offsetmax=0.3;
  yaxis display=(noticks nolabel) valueattrs=(size=7) reverse;
  x2axis display=(noticks nolabel) valueattrs=(size=7) offsetmin=0.75 offsetmax=0.05;
run;
title;

/*--Weighted Forest Plot using scatter with Markerchar and Journal--*/
ods listing style=journal;
ods graphics / reset width=5in height=3in  imagename="3_6_3_Simple_Forest_Wt_Journal_SG_V93";
title "Impact of Treatment on Mortality by Study";
title2 h=8pt 'Odds Ratio and 95% CL';
proc sgplot data=forest noautolegend nocycleattrs;
  refline study_lbl / transparency=0.95 lineattrs=(thickness=13px color=darkgreen);
  scatter y=study x=or2 / markerattrs=graphdata2(symbol=diamondfilled);
  highlow y=study low=lcl high=ucl / type=line lineattrs=(pattern=solid);
  highlow y=study low=q1 high=q3 / type=bar barwidth=0.6 fillattrs=graphdata1;
  refline 1 100  / axis=x noclip;
  refline 0.01 0.1 10 / axis=x lineattrs=(pattern=shortdash) transparency=0.5 noclip;
  scatter y=study x=xlbl / markerchar=lbl ;
  scatter y=study x=or_lbl  / markerchar=or  x2axis markercharattrs=(size=6);
  scatter y=study x=lcl_lbl / markerchar=lcl x2axis markercharattrs=(size=6);
  scatter y=study x=ucl_lbl / markerchar=ucl x2axis markercharattrs=(size=6);
  scatter y=study x=wt_lbl  / markerchar=wt  x2axis markercharattrs=(size=6);
  xaxis type=log  max=100 minor display=(nolabel) valueattrs=(size=7) offsetmin=0.05 offsetmax=0.3;
  yaxis display=(noticks nolabel) valueattrs=(size=7) reverse;
  x2axis display=(noticks nolabel) valueattrs=(size=7) offsetmin=0.75 offsetmax=0.05;
run;
title;

