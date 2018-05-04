%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods listing style=htmlblue image_dpi=&dpi gpath=&gpath; 
ods html close;

data labs_data (keep=drug alat biltot alkph asat
     palat pbiltot palkph pasat visitnum);
  label alat="ALAT (/ULN)";
  label biltot="BILTOT (/ULN)";
  label alkph="ALKPH (/ULN)";
  label asat="ASAT (/ULN)";
  visitnum=1;
  do i= 1 to 100;
    palat = min (4, 2.5 * (abs(rannor(123))) / 3.0);
    pbiltot = min (4, 2.5 * (abs(rannor(123))) / 3.0);
    palkph = min (4, 2.5 * (abs(rannor(123))) / 3.0);
    pasat = min (4, 2.5 * (abs(rannor(123))) / 3.0);
    alat = min (4, 2.5 * (abs(rannor(345))) / 3.0);
    biltot = min (4, 2.5 * (abs(rannor(345))) / 3.0);
    alkph = min (4, 2.5 * (abs(rannor(345))) / 3.0);
    asat = min (4, 2.5 * (abs(rannor(345))) / 3.0);
      j =  rannor(345);
      if j > 0 then drug = "A";
      else drug="B";
      output;
   end;
  visitnum=2;
  do i= 1 to 100;
    palat = min (4, 2.5 * (abs(rannor(789))) / 3.0);
    pbiltot = min (4, 2.5 * (abs(rannor(789))) / 3.0);
    palkph = min (4, 2.5 * (abs(rannor(789))) / 3.0);
    pasat = min (4, 2.5 * (abs(rannor(789))) / 3.0);
    alat = min (4, 2.5 * (abs(rannor(567))) / 3.5);
    biltot = min (4, 2.5 * (abs(rannor(567))) / 3.5);
    alkph = min (4, 2.5 * (abs(rannor(567))) / 3.5);
    asat = min (4, 2.5 * (abs(rannor(567))) / 3.5);
      j =  rannor(567);
      if j > 0 then drug = "A";
      else drug="B";
      output;
   end;
  visitnum=3;
  do i= 1 to 100;
    palat = min (4, 2.5 * (abs(rannor(321))) / 3.0);
    pbiltot = min (4, 2.5 * (abs(rannor(321))) / 3.0);
    palkph = min (4, 2.5 * (abs(rannor(321))) / 3.0);
    pasat = min (4, 2.5 * (abs(rannor(321))) / 3.0);
    alat = min (4, 2.5 * (abs(rannor(975))) / 2.5);
    biltot = min (4, 2.5 * (abs(rannor(975))) / 2.5);
    alkph = min (4, 2.5 * (abs(rannor(975))) / 2.5);
    asat = min (4, 2.5 * (abs(rannor(975))) / 2.5);
      j =  rannor(975);
      if j > 0 then drug = "A";
      else drug="B";
      output;
   end;
run;

proc format;
value wk
  1='1 Week'
  2='3 Months'
  3='6 Months';
value lab
  1='ALAT'
  2='Bilirubin Total'
  3='Alk Phosphatase'
  4='ASAT';
value $trt
  "A"="Drug A (N=240)"
  "B"="Drug B (N=195)";
run;

data labs (keep=visitnum drug labtest baseline study ref);
format visitnum wk. labtest lab. drug $trt.;
set labs_data end=last;
  baseline=palat; labtest=1; study=alat; output;
  baseline=pbiltot; labtest=2; study=biltot; output;
  baseline=palkph; labtest=3; resstudyult=alkph; output;
  baseline=pasat; labtest=4; study=asat; output;

  /*--add refline data--*/
  if last then do;
    call missing (visitnum, drug, labtest, baseline, study, ref);
    do visitnum=1 to 3;
      labtest=1; ref=1; output;
          ref=2; output;
      labtest=2; ref=1; output;
          ref=1.5; output;
      labtest=3; ref=1; output;
          ref=2; output;
      labtest=4; ref=1; output;
          ref=2; output;
        end;
  end;
run;
/*proc print;run;*/

/*ods html;*/
/*proc print data=labs(obs=5) noobs;run;*/
/*ods html close;*/

ods listing style=htmlblue; 
ods graphics / reset width=6in height=2.7in  imagename='5_3_1_LFT_Safety_Panel';
title 'LFT Safety Panel, Baseline vs. Study';
footnote j=l italic height=8pt
    "* For ALAT, ASAT and Alkaline Phosphatase,"
    " the Clinical Concern Level is 2 ULN;";
footnote2 j=l italic height=8pt
     " For Bilirubin Total, the CCL is 1.5 ULN: "
     "where ULN is the Upper Level of Normal";

proc sgpanel data=labs(where=(visitnum ne 1));
panelby labtest visitnum / layout=lattice onepanel novarname;
  scatter x=baseline y=study/ group=drug markerattrs=(size=9) nomissinggroup;
  refline ref / axis=Y lineattrs=(pattern=shortdash);
  refline ref / axis=X lineattrs=(pattern=shortdash);
  rowaxis integer min=0 max=4 label='Study (/ULN)' valueattrs=(size=7);
  colaxis integer min=0 max=4 label='Baseline (/ULN) *' valueattrs=(size=7);;
  keylegend/title=" " noborder;
run;

ods listing style=journal; 
ods graphics / reset width=6in height=2.7in  imagename='5_3_2_LFT_Safety_Panel_Journal';
proc sgpanel data=labs(where=(visitnum ne 1));
panelby labtest visitnum / layout=lattice onepanel novarname;
  scatter x=baseline y=study/ group=drug markerattrs=(size=9) nomissinggroup;
  refline ref / axis=Y lineattrs=(pattern=shortdash);
  refline ref / axis=X lineattrs=(pattern=shortdash);
  rowaxis integer min=0 max=4 label='Study (/ULN)' valueattrs=(size=7);
  colaxis integer min=0 max=4 label='Baseline (/ULN) *' valueattrs=(size=7);;
  keylegend/title=" " noborder;
run;
