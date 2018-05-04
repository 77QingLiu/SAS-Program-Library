%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods listing style=htmlblue image_dpi=&dpi gpath=&gpath; 
ods html close;

proc format;
  value $drug
    'A'='Drug A (N=209)'
    'B'='Drug B (N=405)';
run;

/*--Generate some data--*/
data LFTShift;
  keep Base Max Test Drug;
  retain absmax 0;
  length Test $8;
  label Base="Baseline (/ULN)";
  label Max= "Maximum (/ULN)";

  do Test= 'ALAT', 'ALKPH', 'ASAT', 'BILTOT';
    do i=1 to 40;
      Drug = "A";
      Base= (rannorm(2));
      Max=  (rannorm(2));
          absmax=max(absmax, max(abs(base), abs(max)));
      output;

      drug = "B";
      base= (rannorm(2));
      max=  (rannorm(2));
          absmax=max(absmax, max(abs(base), abs(max)));
      output;
        end;
  end;
  call symput ("absmax", absmax);
run;

/*--Normalize data--*/
data LFTShiftNorm;
  keep Base Max Test Drug;
/*  format Drug $drug.;*/
  set LFTShift;
  base=1+base/&absmax;
  max=1+max/&absmax;
  run;

/*ods html;*/
/*proc print data=LFTShiftNorm(obs=5) noobs;*/
/*var test drug base max;*/
/*run;*/
/*ods html close;*/

/*--Panel with constant ref lines--*/
ods graphics / reset width=6in height=2.7in  imagename="5_1_1_Panel_of_LFT_Shift";
title "Panel of LFT Shift from Baseline to Maximum by Treatment";
footnote1 j=l "For ALAT, ASAT and ALKPH, the Clinical Concern Level is 2 ULN;";
footnote2 j=l "For BILTOT, the CCL is 1.5 ULN: where ULN is the Upper Level of Normal Range";
proc sgpanel data=LFTShiftNorm;
  format Drug $drug.;
  panelby Test / layout=panel columns=4 spacing=10 novarname;
  scatter x=base y=max / group=drug;
  refline 1 1.5 2 / axis=Y lineattrs=(pattern=dash); 
  refline 1 1.5 2 / axis=X lineattrs=(pattern=dash);
  rowaxis integer min=0 max=4;
  colaxis integer min=0 max=4;
  keylegend / title="" noborder;
  run;

/*--Add reference lines to data by test--*/
data LFTShiftNormRef;
  set LFTShiftNorm;
  by test;
  base2=max*ranuni(2);
  if first.test then do;
    Ref=1; output;
        Ref=2; 
    if test eq 'BILTOT' then Ref=1.5; output;
  end;
  else output;
run;

/*ods html;*/
/*proc print data=LFTShiftNormRef(obs=5) noobs; run;*/
/*ods html close;*/

/*--Panel with varying ref lines--*/
ods graphics / reset width=6in height=2.7in  imagename="5_1_2_Panel_of_LFT_Shift_Ref";
title "Panel of LFT Shift from Baseline to Maximum by Treatment";
footnote1 j=l "For ALAT, ASAT and ALKPH, the Clinical Concern Level is 2 ULN;";
footnote2 j=l "For BILTOT, the CCL is 1.5 ULN: where ULN is the Upper Level of Normal Range";
proc sgpanel data=LFTShiftNormRef;
  format Drug $drug.;
  panelby Test / layout=panel columns=4 spacing=10 novarname;
  lineparm x=0 y=0 slope=1 / lineattrs=graphgridlines; 
  scatter x=base2 y=max / group=drug;
  refline ref / axis=Y lineattrs=(pattern=dash); 
  refline ref / axis=X lineattrs=(pattern=dash);
  rowaxis integer min=0 max=4;
  colaxis integer min=0 max=4;
  keylegend / title="" noborder;
  run;

title;
footnote;
