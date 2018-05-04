%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods listing style=htmlblue image_dpi=&dpi gpath=&gpath; 
ods html close;

libname eye '.';    /*--Put your data Folder Name here--*/

/*proc format lib=work cntlin=eye.fmt1;*/

proc format;
picture abs 
        low-<0='000'
        0<-high='000';
value fmt1_f
        1='Pla'
                2='A'
                3='B';
value fmt2_f
        0='Baseline'
                1='Week 1'
                2='Week 2'
                3='Week 4'
                4='Week 6'
                5='Week 8'
                6='End Point';
value fmt3_f
        1='Eyes Itchy/Gritty'
        2='Eyes Redness'
        3='Eyes Tearing';
value fmt4_f
        0='None'
                1='Mild'
                2='Moderate'
                3='Severe'
                4='Very Severe';
run;


/*proc print data=jnj.jnj1;run;*/
/*proc contents data=jnj.jnj1;run;*/

data eye;
  set eye.eye_data;
  label value="Visit Assessment";
  if value > 1 then percent=-percent;
  run;

/*proc print;run;*/

options nobyline;
ods listing style=listing;
ods graphics / reset attrpriority=color width=5in height=2.25in imagename='5_7_1_Eye_Irritation';
title "Subjects with Eye Irritation Over Time by Severity and Treatment";
proc sgpanel data=eye;
  where param=1;
  format percent abs.;
  panelby time / layout=columnlattice onepanel noborder colheaderpos=bottom novarname
          headerattrs=(size=7) noheaderborder;
  styleattrs datacolors=(darkgreen lightgreen gold orange red);
  vbar trtgrp / response=percent group=value outlineattrs=(color=cx4f4f4f) dataskin=pressed;
  colaxis display=(nolabel noticks) valueattrs=(size=7);
  rowaxis values=(-100 to 100 by 20) grid offsetmax=0.025 valueattrs=(size=7) labelattrs=(size=9);
  keylegend / valueattrs=(size=7) titleattrs=(size=8) fillheight=2pct fillaspect=golden;
  run;

ods listing style=journal3;
ods graphics / reset width=5in height=2.25in imagename='5_7_2_Eye_Irritation';
title "Subjects with Eye Irritation Over Time by Severity and Treatment";
proc sgpanel data=eye;
  where param=1;
  format percent abs.;
  panelby time / layout=columnlattice onepanel noborder colheaderpos=bottom novarname
          headerattrs=(size=7) noheaderborder;
  vbar trtgrp / response=percent group=value outlineattrs=(color=cx4f4f4f) dataskin=pressed;
  colaxis display=(nolabel noticks) valueattrs=(size=7);
  rowaxis values=(-100 to 100 by 20) grid offsetmax=0.025 valueattrs=(size=7) labelattrs=(size=9);
  keylegend / valueattrs=(size=7) titleattrs=(size=8) fillheight=3pct fillaspect=golden;
  run;


*ods rtf close;



