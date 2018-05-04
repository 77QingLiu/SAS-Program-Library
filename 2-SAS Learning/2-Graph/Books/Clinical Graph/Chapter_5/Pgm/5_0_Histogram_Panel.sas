%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods listing style=htmlblue image_dpi=&dpi gpath=&gpath; 
ods html close;

/*--Panel with varying ref lines--*/
ods graphics / reset width=6in height=2.4in  imagename="5_0_Panel";
title "Distribution of Systolic Blood Pressure by Weight Status";
proc sgpanel data=sashelp.heart;
  panelby weight_status / layout=panel columns=3 spacing=10 novarname;
  histogram systolic;
  colaxis display=(nolabel) max=250;
  rowaxis grid;
  run;

title;
footnote;
