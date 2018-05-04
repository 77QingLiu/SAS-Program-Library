%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods listing style=htmlblue image_dpi=&dpi gpath=&gpath; 
ods html close;
option missing=' ';

proc format;
  value wk 
    28='Max';
run;

data asat;
  format Week wk.;
  label ASAT='ASAT (/ULN)';
  do Week=0,1,2,4,8,12,24;
    count=.;
    do i=1 to 20;
          Drug='A'; ASAT=0.3+0.4*ranuni(2); DrugGT='>2(A)'; 
      count=int(ifn(i=1,220*(1-week/56), .)); gt2=int(ifn(i=1,2*ranuni(3), .)); output;
          Drug='B'; asat=0.4+0.5*ranuni(2); DrugGT='>2(B)'; 
      count=int(ifn(i=1,430*(1-week/56), .)); gt2=int(ifn(i=1,3*ranuni(3), .));output;
        end;
    do i=1 to 5;
          Drug='A'; asat=1+1*ranuni(2); count=.; output;
          Drug='B'; asat=1.2+0.8*ranuni(2); count=.; output;
        end;
  end;

  week=28;
  do i=1 to 20;
        Drug='A'; asat=0.3+0.4*ranuni(2); count=int(ifn(i=1,220, .)); DrugGT='>2(A)'; gt2=int(ifn(i=1,2, .)); output;
        Drug='B'; asat=0.4+0.5*ranuni(2); count=int(ifn(i=1,430, .)); DrugGT='>2(B)'; gt2=int(ifn(i=1,3, .)); output;
  end;
  do i=1 to 5;
        Drug='A'; asat=1+1*ranuni(2);     count=.;  output;
        Drug='B'; asat=1.2+0.8*ranuni(2); count=.;  output;
  end;
run;
/*proc print;run;*/

/*--Distribution of ASAT by Time and Treatment--*/
ods graphics / reset width=5in height=3in imagename="4_3_1_Distribution_of_ASAT_AxisTable_SG_V94";
title 'Distribution of ASAT by Time and Treatment';
proc sgplot data=asat;
  vbox asat / category=week group=drug name='box' nofill;
  xaxistable gt2 / class=drugGT colorgroup=drugGT position=top location=inside separator 
             valueattrs=(size=6) labelattrs=(size=7);
  xaxistable count / class=drug colorgroup=drug position=bottom location=inside separator 
             valueattrs=(size=6) labelattrs=(size=7);
  refline 1 / lineattrs=(pattern=shortdash);
  refline 2 / lineattrs=(pattern=dash);
  refline 25 / axis=x;
  xaxis type=linear values=(0 2 4 8 12 24 28) offsetmax=0.05 valueattrs=(size=8) labelattrs=(size=9);
  yaxis offsetmax=0.1 valueattrs=(size=8) labelattrs=(size=9);
  keylegend 'box' / location=inside position=top linelength=20 valueattrs=(size=8);
run;

data asat2;
  set asat end=last;
  output;
  if last then do;
    call missing(asat, week, drug, gt2, count, i);
        week=.; Drug='A'; asat2=0; output;
        week=.; Drug='B'; asat2=0; output;
  end;
run;
/*proc print;run;*/

/*--Journal Style--*/
ods listing style=journal;
ods graphics / reset width=5in height=3in imagename="4_3_2_Distribution_of_ASAT_AxisTable_Journal_SG_V94";
title 'Distribution of ASAT by Time and Treatment';
proc sgplot data=asat2;
  styleattrs datalinepatterns=(solid);
  vbox asat / category=week group=drug nofill;
  scatter x=week y=asat2 / group=drug name='s';
  xaxistable gt2 / class=drugGT colorgroup=drugGT position=top location=inside separator 
             valueattrs=(size=6) labelattrs=(size=7);
  xaxistable count / class=drug colorgroup=drug position=bottom location=inside separator 
             valueattrs=(size=6) labelattrs=(size=7);
  refline 1 / lineattrs=(pattern=shortdash);
  refline 2 / lineattrs=(pattern=dash);
  refline 25 / axis=x;
  xaxis type=linear values=(0 2 4 8 12 24 28) offsetmax=0.05 valueattrs=(size=8) labelattrs=(size=9);
  yaxis offsetmax=0.1 valueattrs=(size=8) labelattrs=(size=9);
  keylegend 's' / location=inside position=top linelength=20 valueattrs=(size=8);
run;


