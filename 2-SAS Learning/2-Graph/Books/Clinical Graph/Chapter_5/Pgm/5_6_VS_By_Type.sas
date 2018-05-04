%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods listing style=htmlblue image_dpi=&dpi gpath=&gpath; 
ods html close;

libname data '.';   /*--Put your Data Folder Name here--*/

/*--Extract Lying Down data--*/
data vs;
  set data.vs_1217(where=(vstpt = 'AFTER LYING DOWN FOR 5 MINUTES')); 
  keep  vsdy vsstresn vstest2 vsdate label id;
  length vstest2 $9;

  if vstestcd eq 'SYSBP' or vstestcd eq 'DIABP' or vstestcd eq 'PULSE';

  if vstest eq 'Systolic Blood Pressure' then do; vstest2='Systolic'; id=1; end;
  else if vstest eq 'Diastolic Blood Pressure' then do; vstest2='Diastolic'; id=2; end;
  else if vstest eq 'Pulse' then do; vstest2='Pulse'; id=3; end; 
  output;
run;

/*proc print;run;*/

/*--Sort by ID--*/
proc sort data=vs out=vss;
  by id;
run;
/*proc print;run;*/

/*--Vital Signs Panel--*/
ods graphics / reset  attrpriority=color width=5in height=2.25in imagename="5_6_1_VS";
title "Vital Statistics for Patient Id = xx-xxx-xxxx"; 
proc sgpanel data=vss noautolegend nocycleattrs;
  panelby vstest2 / onepanel layout=rowlattice uniscale=column novarname spacing=10 sort=data;
  refline 0 / axis=x lineattrs=(thickness=1 color=black);
  series x=vsdy y=vsstresn / group=vstest2 lineattrs=(thickness=3) nomissinggroup name='bp';
  scatter x=vsdy y=vsstresn / group=vstest2 markerattrs=(symbol=circlefilled size=11);
  scatter x=vsdy y=vsstresn / group=vstest2 markerattrs=(symbol=circlefilled size=5 color=white);
  keylegend 'bp' / title='Vitals:' across=3  linelength=20;
  rowaxis grid display=(nolabel) valueattrs=(size=7) labelattrs=(size=8);
  colaxis grid label='Study Days' valueattrs=(size=7) labelattrs=(size=8);
  run;

  /*--Vital Signs Panel with Inset--*/
ods graphics / reset  attrpriority=color width=5in height=2.25in imagename="5_6_1_VS_Inset";
title "Vital Statistics for Patient Id = xx-xxx-xxxx"; 
proc sgpanel data=vss noautolegend nocycleattrs;
  panelby vstest2 / onepanel layout=rowlattice uniscale=column novarname spacing=10 noheader sort=data;
  refline 0 / axis=x lineattrs=(thickness=1 color=black);
  series x=vsdy y=vsstresn / group=vstest2 lineattrs=(thickness=3) nomissinggroup name='bp';
  scatter x=vsdy y=vsstresn / group=vstest2 markerattrs=(symbol=circlefilled size=11);
  scatter x=vsdy y=vsstresn / group=vstest2 markerattrs=(symbol=circlefilled size=5 color=white);
  inset vstest2 / nolabel position=topright textattrs=(size=9);
  keylegend 'bp' / title='Vitals:' across=3 linelength=20;
  rowaxis grid display=(nolabel) valueattrs=(size=7) labelattrs=(size=8);
  colaxis grid label='Study Days' valueattrs=(size=7) labelattrs=(size=8);
  run;


