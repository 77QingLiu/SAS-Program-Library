%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods html close;
ods listing style=htmlblue gpath=&gpath image_dpi=&dpi;

/*--Fig 2.09 Distribution--*/
ods graphics / reset attrpriority=color noborder width=2.7in height=2in imagename='2_6_2_Dist';
title 'Distribution of Cholesterol';
proc sgplot data=sashelp.heart;
  histogram cholesterol;
  density cholesterol;
  density cholesterol / type=kernel;
  keylegend / location=inside position=topright across=1 linelength=20;
  xaxis display=(nolabel) max=500;
  yaxis offsetmin=0;
run;
title;

