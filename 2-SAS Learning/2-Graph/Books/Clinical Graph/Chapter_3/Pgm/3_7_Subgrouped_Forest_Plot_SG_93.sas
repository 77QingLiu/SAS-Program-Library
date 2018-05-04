%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods html close;
ods listing style=htmlblue image_dpi=&dpi gpath=&gpath; 

/*--To retain leading and trailing blanks, we must use nbsp instead of blank--*/
/*--For visibility, we have used '.' in place of blanks                     --*/
/*--  Later these '.' values are     changed to nbsp 'A0'x                  --*/
/*--Regular leading blanks will be stripped, losing the indentation         --*/
/*--Add "Id" to identify subgroup headings from values                      --*/
data forest;
  label countpct='No. of Patients (%)';
  input Id Subgroup $3-27 Count Percent Mean  Low  High  PCIGroup Group PValue;
  indentWt=1;
  ObsId=_n_; 
  if count ne . then CountPct=put(count, 4.0) || "(" || put(percent, 3.0) || ")";
  datalines;
1 Overall..................2166  100  1.3   0.9   1.5  17.2  15.6  .
1 Age.......................     .    .     .     .    .     .     0.05
2 ..<= 65 Yr...............1534   71  1.5   1.05  1.9  17.0  13.2   .
2 ..> 65 Yr................ 632   29  0.8   0.6   1.25 17.8  21.3   .
1 Sex.......................     .    .     .     .    .     .     0.13
2 ..Male...................1690   78  1.5   1.05  1.9  16.8  13.5   .
2 ..Female................. 476   22  0.8   0.6   1.3  18.3  22.9   . 
1 Race or ethnic group......     .    .     .     .    .     .     0.52
2 ..Nonwhite............... 428   20  1.05  0.6   1.8  18.8  17.8   .
2 ..White..................1738   80  1.2   0.85  1.6  16.7  15.0   . 
1 From MI to Randomization..     .    .     .     .    .     .     0.81
2 ..<= 7 days.............. 963   44  1.2   0.8   1.5  18.9  18.6   .
2 ..> 7 days...............1203   56  1.15  0.75  1.5  15.9  12.9   .
1 Diabetes..................     .    .     .     .    .     .     0.41
2 ..Yes.................... 446   21  1.4   0.9   2.0  29.3  23.3   .
2 ..No.....................1720   79  1.1   0.8   1.5  14.4  13.5   . 
;
run;
/*ods html;*/
/*proc print;run;*/
/*ods html close;*/

/*--Replace '.' in subgroup with blank--*/
data forest2;
  set forest end=last;
  subgroup=strip(translate(subgroup, ' ', '.'));
  val=mod(_N_-1, 6);
  if val eq 1 or val eq 2 or val eq 3 then ref=obsid;

  /*--Separate Subgroup headers and obs into separate columns--*/
  if id=1 then do;
         indentWt=0;
  end;
  output;
  if last then do;
        xl=1.6; yl=obsid+1; text='Therapy Better-->'; output;
        xl=0.5; yl=obsid+1; text='<--PCI Better'; output; 
        call symput ("Rows", yl+1); 
  end;
  run;

ods html;
proc print;run;
ods html close;

/*--Forest Plot--*/
/*ods graphics / reset width=5in height=3in imagename='3_7_1_Forest_Subgroup_OR_SG_V93';*/
/*proc sgplot data=Forest2 nocycleattrs noautolegend;*/
/*  refline ref / lineattrs=(thickness=15 color=cxf0f0f0);*/
/*  highlow y=obsid low=low high=high; */
/*  scatter y=obsid x=mean / markerattrs=(symbol=squarefilled);*/
/*  scatter y=obsid x=mean / markerattrs=(size=0) x2axis;*/
/*  refline 1 / axis=x;*/
/*  refline &Rows / noclip;*/
/*  scatter y=yl x=xl / markerchar=text;*/
/*  yaxis reverse offsetmax=0 offsetmin=0 display=none;*/
/*  xaxis display=(noline nolabel) values=(0.0 0.5 1.0 1.5 2.0 2.5) offsetmin=0.4 offsetmax=0.2;*/
/*  x2axis label='Hazard Ratio' display=(noline noticks novalues) offsetmin=0.4 offsetmax=0.2;*/
/*run;*/

data anno;
  set forest2(keep= subgroup obsid id countpct PCIGroup group pvalue) end=last;
  length Anchor $10 y1Space $12;
  retain Function 'Text' x1space 'WallPercent' width 50;
  retain TextWeight 'Normal';

  y1=obsid; y1space='datavalue'; 

  /*--Subgroups--*/
  Anno=1; AnnoType='Subgroups';
  label=subgroup;  Anchor='Left'; 
  x1=2; textweight='Bold'; textsize=8;
  if id = 2 then do;
    x1=4; textweight='Normal'; textsize=6;
  end;
  output;

  /*--Count Pct--*/
  Anno=2; AnnoType='CountPct';
  textweight='Normal'; textsize=6;
  label=countpct; x1=40; anchor='Right';
  output;
  
  /*--Values--*/
  Anno=3; AnnoType='PCIGroup';
  textweight='Normal'; textsize=6;
  label=ifc(PCIGroup ne ., strip(put(PCIGroup,4.1)), ''); x1=75; anchor='Left';
  output;

  Anno=4; AnnoType='Group';
  label=ifc(group ne ., strip(put(group,4.1)), ''); x1=83; anchor='Left';
  output;

  Anno=5; AnnoType='PValue';
  label=ifc(pvalue ne ., strip(put(pvalue,4.2)), ''); x1=91; anchor='Left';
  output;

  if last then do;
  Anno=6; AnnoType='Headers';
  y1space='WallPercent'; textweight='Bold'; textsize=8; width=14; anchor='BottomLeft';
  y1=100.8; 
  label='Subgroup'; x1=10; output;
  label='Number of Patients (%)'; x1=30; output;
  label='PCI Group'; x1=73; width=10; output;
  label='Therapy Group'; x1=81; output;
  label='PValue'; x1=90; output;
  end;
run;

proc sort data=anno out=anno2;
by anno;
run;

data annoPrint;
  retain count 0;
  set anno2;
  by anno;
  if first.anno then count=0;
  else count=count+1;
  if count <= 2;
run;
 
ods html;
proc print data=annoPrint;
var Anno AnnoType Function x1space y1space label x1 y1 anchor textweight textsize width;
run;
ods html close;

/*--Forest Plot with annotation--*/
ods graphics / reset width=5in height=3in imagename='3_7_1_Forest_Subgroup_Anno_SG_V93';
proc sgplot data=Forest2 nocycleattrs noautolegend sganno=anno pad=(top=6pct);
  refline ref / lineattrs=(thickness=15 color=cxf0f0f0);
  highlow y=obsid low=low high=high; 
  scatter y=obsid x=mean / markerattrs=(symbol=squarefilled);
  scatter y=obsid x=mean / markerattrs=(size=0) x2axis;
  refline 1 / axis=x;
  refline &Rows / noclip;
  scatter y=yl x=xl / markerchar=text;
  yaxis reverse offsetmax=0 offsetmin=0 display=none;
  xaxis display=(noline nolabel) values=(0.0 0.5 1.0 1.5 2.0 2.5) offsetmin=0.4 offsetmax=0.25;
  x2axis display=(noline noticks novalues) offsetmin=0.4 offsetmax=0.25
         label='          Hazard Ratio' ;
run;


