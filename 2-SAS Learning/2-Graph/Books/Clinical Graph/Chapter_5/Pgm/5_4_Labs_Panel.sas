%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods listing style=htmlblue image_dpi=&dpi gpath=&gpath; 
ods html close;
libname gtldata '.';

proc format;
value visitnum
   1='PreRx'
   2='Week 1'
   3='Week 2'
   4='Week 3'
   5='Week 5'
   6='Week 6';
value labname
   1="WBC x 10(*ESC*){Unicode '00b3'x} /uL"
   2='Neutrophils %'
   3='Lymphocytes %'
   4='Monocytes %'
   5='Eosinophils %'
   6='Basophils %'
   7='Hgb g/dL (M)'
   8='Hgb g/dL (F)';
run;

/*proc print data=gtldata.labs (where=(patid ne ' '));*/
/*run;*/

data labs (keep = patid visitnum testname result normlow normhi ordname line);
set gtldata.labs (where=(patid ne ' '));
format  visitnum visitnum. line labname.;
select(visitid);
    when('SCR') visitnum = 1;
    when('W1')  visitnum = 2;
    when('W2')  visitnum = 3;
    when('W3')  visitnum = 4;
    when('W5')  visitnum = 5;
    when('W6')  visitnum = 6;
  otherwise end;

  select(testname);
    when ('WBC')             line=1;
        when ('Neutrophils (%)') line=2;
    otherwise delete;
  end;
run;

proc sort data=labs;
  by line visitnum;
  run;

data labs2;
  format numlow best8. numhi best8.;
  format  label labname.;
  set labs;
  by line;
  if first.line or last.line then do;  
    if line=1 then do; numlow=   3.8;  numhi=  10.7; end;
        if line=2 then do; numlow = 40.5;  numhi = 75.0; end;
        if line=3 then do; numlow = 15.4;  numhi = 48.5; end;
        if line=4 then do; numlow =  2.6;  numhi = 10.1; end;
        if line=5 then do; numlow =  0.0;  numhi = 6.8;; end;
        if line=6 then do; numlow =  0.0;  numhi = 2.0;  end;
  end;

  if first.line then label=line;
run;

/*ods html;*/
/*proc print data=labs2(obs=5) noobs;run;*/
/*ods html close;*/

footnote;
option nobyline;

/*--Panel with reference lines--*/
ods graphics / reset width=5in height=2.25in imagename='5_4_1_WBC_Panel_Ref';
title 'WBC and Differential: Weeks 1-6';
proc sgpanel data=labs2;
  panelby line / onepanel uniscale=column layout=rowlattice novarname;
  refline numlow / label noclip;
  refline numhi / label noclip;
  scatter x=visitnum y=result / jitter transparency=0.5;
  rowaxis display=(nolabel) valueattrs=(size=7) grid gridattrs=(pattern=dash);
  colaxis display=(nolabel) offsetmax=0.1 valueattrs=(size=7) type=discrete;
run;

/*--Panel with Class labels--*/
ods graphics / reset width=5in height=2.25in imagename='5_4_2_WBC_Panel_Band_Box_NoHeader';
title 'WBC and Differential: Weeks 1-6';
proc sgpanel data=labs2 noautolegend;
  panelby line /onepanel uniscale=column layout=rowlattice noheader;
  band x=visitnum lower=numlow upper=numhi / transparency=0.9 
       fillattrs=(color=yellow) legendlabel='Limits';
  refline numlow / label noclip lineattrs=(color=cxdfdfdf) labelattrs=(size=7);
  refline numhi / label noclip  lineattrs=(color=cxdfdfdf) labelattrs=(size=7);
  scatter x=visitnum y=result / transparency=0.9 jitter;
  vbox result / category=visitnum nofill nooutliers;
  inset label / position=topleft nolabel textattrs=(size=9);
  rowaxis display=(nolabel) offsetmax=0.15 valueattrs=(size=7) grid gridattrs=(pattern=dash);
  colaxis display=(nolabel)  valueattrs=(size=7);
run;

title;
footnote;

