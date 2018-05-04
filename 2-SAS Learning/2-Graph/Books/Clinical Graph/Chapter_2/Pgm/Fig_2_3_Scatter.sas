%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods html close;
ods listing gpath=&gpath image_dpi=&dpi;

/*--Fig 2.3.1 Compare--*/
title 'Variable Comparison';
footnote;
ods graphics / reset attrpriority=color width=4in height=3in imagename='2_3_1_Compare';
proc sgscatter data=sashelp.heart;
  compare y=(systolic diastolic) x=(cholesterol weight) /
          markerattrs=graphdata2(symbol=circlefilled) transparency=0.95;
  run;

/*--Fig 2.3.2 Matrix--*/
title 'Variable Associations';
footnote;
ods graphics / reset attrpriority=color width=4in height=3in imagename='2_3_2_Matrix';
proc sgscatter data=sashelp.heart;
  matrix systolic diastolic cholesterol weight /
          markerattrs=graphdata3(symbol=circlefilled) transparency=0.95;
  run;

