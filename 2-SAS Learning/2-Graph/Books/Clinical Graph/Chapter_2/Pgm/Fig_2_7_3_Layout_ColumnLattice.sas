%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods html close;
ods listing style=htmlblue gpath=&gpath image_dpi=&dpi;

/*--Fig 2.7.3 Column Lattice--*/
ods graphics / reset noborder width=5.7in height=2in imagename='2_7_3_Col_Lattice';
title 'Distribution of Cholesterol by Weight Status';
proc sgpanel data=sashelp.heart noautolegend;
  panelby weight_status / layout=columnlattice onepanel novarname;
  histogram cholesterol;
  density cholesterol;
  density cholesterol / type=kernel;
  colaxis display=(nolabel) max=500;
  rowaxis offsetmin=0 grid;
run;
title;

