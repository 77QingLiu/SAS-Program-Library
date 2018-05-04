%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods html close;
ods listing gpath=&gpath image_dpi=&dpi;

/*--Fig 2.2 Panel--*/
ods graphics / reset attrpriority=color width=4in height=3in imagename='2_2_1_Panel';
title 'Cholesterol by Systolic';
proc sgpanel data=sashelp.heart(where=(ageatstart > 45 and weight_status ne 'Underweight')) noautolegend;
panelby sex weight_status / layout=panel novarname headerattrs=(size=5);
  scatter x=cholesterol y=systolic / markerattrs=graphdata1(symbol=circlefilled) transparency=0.7;
  reg x=cholesterol y=systolic / degree=2 nomarkers;
run;
title;

/*--Fig 2.3 Lattice--*/
ods graphics / reset attrpriority=color width=4in height=3in imagename='2_2_2_Lattice';
title 'Cholesterol by Systolic';
proc sgpanel data=sashelp.heart(where=(ageatstart > 45 and weight_status ne 'Underweight')) noautolegend;
panelby sex weight_status / layout=lattice novarname;
  scatter x=cholesterol y=systolic / markerattrs=(symbol=circlefilled) transparency=0.7;
  reg x=cholesterol y=systolic / degree=2 nomarkers;
run;
title;
