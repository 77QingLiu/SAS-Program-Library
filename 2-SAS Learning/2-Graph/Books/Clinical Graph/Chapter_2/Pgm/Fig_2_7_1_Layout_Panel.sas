%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods html close;
ods listing gpath=&gpath image_dpi=&dpi;

/*--Fig 2.7.1 Panel Scatter--*/
ods graphics / reset attrpriority=color noborder width=4in height=3in imagename='2_7_1_Data_Panel_Scatter';
title 'Cholesterol by Systolic';
proc sgpanel data=sashelp.heart(where=(ageatstart > 45 and weight_status ne 'Underweight')) noautolegend;
panelby sex weight_status / layout=panel novarname headerattrs=(size=7);
  scatter x=cholesterol y=systolic / markerattrs=graphdata1(symbol=circlefilled) transparency=0.7;
  reg x=cholesterol y=systolic / degree=2 nomarkers lineattrs=graphfit;
  rowaxis valueattrs=(size=7);
  colaxis valueattrs=(size=7);
run;
title;

/*--Fig 2.7.2 Panel Histogram--*/
ods graphics / reset attrpriority=color noborder width=4in height=3in imagename='2_7_1_Data_Panel_Hist';
title 'Distribution of Cholesterol';
proc sgpanel data=sashelp.heart(where=(ageatstart > 45 and weight_status ne 'Underweight')) noautolegend;
panelby sex weight_status / layout=panel novarname headerattrs=(size=7);
  histogram cholesterol;
  density cholesterol;
  rowaxis valueattrs=(size=7) labelattrs=(size=8);
  colaxis valueattrs=(size=7) labelattrs=(size=8);
run;
title;


