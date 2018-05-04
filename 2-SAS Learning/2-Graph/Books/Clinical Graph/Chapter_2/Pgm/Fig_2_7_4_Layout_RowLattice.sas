%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods html close;
ods listing style=htmlblue gpath=&gpath image_dpi=&dpi;

/*--Fig 2.7.4 Row Lattice--*/
ods graphics / reset noborder width=3in height=4in imagename='2_7_4_Row_Lattice';
title h=0.8 'Distribution of Cholesterol by Sex';
proc sgpanel data=sashelp.heart noautolegend;
  panelby sex / layout=rowlattice onepanel novarname headerattrs=(size=7);
  histogram cholesterol;
  density cholesterol;
  density cholesterol / type=kernel;
  colaxis display=(nolabel) labelattrs=(size=8) valueattrs=(size=6);
  rowaxis grid labelattrs=(size=8) valueattrs=(size=6);
run;
title;

