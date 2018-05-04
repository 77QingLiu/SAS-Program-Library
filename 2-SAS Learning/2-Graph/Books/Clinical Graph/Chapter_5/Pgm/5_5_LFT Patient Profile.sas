%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods listing style=htmlblue image_dpi=&dpi gpath=&gpath; 
ods html close;

data Safety (keep=patient days sdays alat biltot alkph asat dval);
  length patient $50;
  label alat="ALAT";
  label biltot="BILTOT";
  label alkph="ALKPH";
  label asat="ASAT";
  label days="Days";
  label dval="Study Days";

  patient="Patient:5152 White Male Age: 48; Drug: A";
  do days = -25 to 175 by 25;
    alat = 1 + 1.5 * sin(3.14 * (days+25) / 360.0); 
    asat = 1 + 1.4 * sin(3.14 * (days+25) / 400.0);
    alkph = 1 + 1.2 * sin(3.14 * (days+25) / 540.0);
    biltot = 1 + 1 * sin(3.14 * (days+25) / 320.0);
    dval=-0.5;
        sdays=days;
        if days < 0 or days > 160 then do;
      dval = .;
          sdays=.;
        end;
    output;
    end;

  patient="Patient:6416 White Male Age: 64; Drug: A";
  do days = -25 to 70 by 15;
    alat = 1.5 + 2 * sin(3.14 * (days+25) / 540.0); 
    asat = 1.0 + 1 * sin(3.14 * (days+25) / 540.0);
    alkph = 0.75 + 2 * sin(3.14 * (days+25) / 360.0);
    biltot = 1.5 + 1 * sin(3.14 * (days+25) / 360.0);
    dval=-0.5;
        sdays=days;
        if days < 0 or days > 60 then do;
      dval = .;
          sdays=.;
        end;
    output;
    end;

  patient="Patient:6969 White Female Age: 48; Drug: B";
  do days = -25 to 175 by 25;
    alat = 0.75 + 1.5 * sin(3.14 * (days+25) / 540); 
    asat = 0.9 + 1.2 * sin(3.14 * (days+25) / 480);
    alkph = 0.8 + 1 * sin(3.14 * (days+25) / 600);
    biltot = 0.7 + 1 * sin(3.14 * (days+25) / 500);
    dval=-0.5;
        sdays=days;
        if days < 0 or days > 160 then do;
      dval = .;
          sdays=.;
        end;;
    output;
    end;
  run;

ods graphics / reset reset attrpriority=color width=5in height=2.25in imagename="5_5_1_LFT_Patient_Profile";
title "LFT Patient Profile";
footnote1 j=l h=0.7 "For ALAT, ASAT and ALKPH, the Clinical Concern Level is 2 ULN;";
footnote2 j=l h=0.7 "For BILTOT, the CCL is 1.5 ULN: where ULN is the Upper Level of Normal Range";
proc sgpanel data=Safety;
  panelby patient / novarname columns=3 headerattrs=(size=6);
  series x=days y=alat / markers;
  series x=days y=asat / markers;
  series x=days y=alkph / markers;
  series x=days y=biltot / markers;
  series x=days y=dval / lineattrs=graphdatadefault(thickness=2px);
  refline 1 1.5 2 / axis=Y lineattrs=(pattern=shortdash);
  colaxis min=-50 max= 200 valueattrs=(size=7) labelattrs=(size=9) grid;
  rowaxis max=4 label="LFT (/ULN)" valueattrs=(size=7) labelattrs=(size=9) grid;
  keylegend / noborder linelength=25;
  run;
title;
footnote;

/*=============*/
/*--Figure 8A--*/
/*=============*/

title "LFT Patient Profile";
footnote1 j=l h=0.7 "For ALAT, ASAT and ALKPH, the Clinical Concern Level is 2 ULN;";
footnote2 j=l h=0.7 "For BILTOT, the CCL is 1.5 ULN: where ULN is the Upper Level of Normal Range";
ods graphics / reset attrpriority=color width=5in height=2.25in imagename="5_5_2_LFT_Patient_Profile";
proc sgpanel data=Safety cycleattrs;
  panelby patient / novarname columns=3 headerattrs=(size=6);
  series x=days y=alat / markers  name='a';
  series x=days y=asat / markers  name='b';
  series x=days y=alkph / markers  name='c';
  series x=days y=biltot / markers  name='d';
  series x=days y=dval / lineattrs=graphdatadefault(thickness=2px) name='e';
  band x=sdays lower=dval upper=4.5 / fillattrs=graphdatadefault transparency=0.6;
  refline 1 1.5 2 / axis=Y lineattrs=(pattern=dash);
  colaxis min=-50 max= 200 valueattrs=(size=7) labelattrs=(size=9) grid;
  rowaxis max=4 label="LFT (/ULN)" valueattrs=(size=7) labelattrs=(size=9) grid;
  keylegend 'a' 'b' 'c' 'd' 'e' / linelength=25;
  run;
title;
footnote;
