%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods html close;
ods listing style=analysis image_dpi=&dpi gpath=&gpath;
%let pid=xx-xxx-xxxx;

/*------------------------------------------*/
/*--Use AE data previously subset for PID --*/
/*------------------------------------------*/
data ae_1217;
  input aestdtc $1-10 aeseq aedecod $18-51 aesev $53-60 aeout $62-73 aeendtc $75-84 aestdy aeendy;
  datalines;
2013-03-06    1  Dizziness                          Moderate RESOLVED     2013-03-06    3       4
2013-03-20    2  Cough                              Mild     NOT RESOLVED              17       .
2013-03-27    3  Dizziness                          Mild     RESOLVED     2013-03-27   24      26
2013-03-30    4  Electrocardiogram T Wave Inversion Mild     NOT RESOLVED              27       .
2013-04-01    5  Dizziness                          Mild     RESOLVED     2013-04-11   29      39
2013-03-26    6  Application Site Dermatitis        Moderate NOT RESOLVED 2013-06-18   23     107
2013-05-17    7  Headache                           Mild     RESOLVED     2013-05-18   75      76
2013-05-27    8  Pruritus                           Moderate RESOLVED     2013-06-18   85     107
;
run;

/*ods html;*/
/*proc print data=ae_1217(obs=4); */
/*  var aeseq  aedecod aesev aestdtc aeendtc ;*/
/*run;*/
/*ods html close;*/

/*--Clean data and find extents--*/
data ae1;
  set ae_1217 end=last;
  keep  aeseq  aesev  aestdtc aeendtc aestdate aeendate aedecod;
  format aestdate aeendate mindate maxdate YYMMDD10.;
  retain mindate maxdate;

  /*--Get start and end dates--*/
  aestdate = input(substr(aestdtc, 1, 10), YYMMDD10.);
  aeendate = input(substr(aeendtc, 1, 10), YYMMDD10.);

  if ( _n_ = 1) then do;
     mindate=aestdate;
         maxdate=ifn(aeendate, aeendate, aestdate);
  end;

  mindate=min(mindate, aestdate);
  maxdate=max(maxdate, aeendate);
  
  if last then do;
    call symputx('mindate', mindate);
    call symputx('maxdate', maxdate);
  end;

run;

/*ods html;*/
/*proc print; */
/*  var aeseq  aesev  aestdtc aeendtc aestdate aeendate aestdy aeendy aedecod;*/
/*run;*/
/*ods html close;*/

data ae2;
  set ae1 nobs=nobs end=last;
  format stdate endate date9.;
  label aesev='Severity';
  retain minday 1e10 maxday 0;

  /*--Clean start and end DATE--*/
  stdate=aestdate;
  endate=ifn(aeendate, aeendate, &maxdate);
  if aeendate eq . then highcap='FilledArrow';

  /*--Compute start and end DAY--*/
  stday=aestdate-&mindate;
  enday=endate-&mindate+1;   /*--End Day incremented by 1--*/

  minday=min(minday, stday);
  maxday=max(maxday, enday);

  if aesev = 'Mild' then sev=1;
  else if aesev = 'Moderate' then sev=2;
  else if aesev = 'Severe' then sev=3;
  else sev=4;

  if last then do;
    call symputx('minday', minday);
    call symputx('maxday', maxday);
  end;
  run;

/*--Sort by aedecode and stday--*/
proc sort data=ae2 out=ae2s;
  by aedecod stday;
  run;
/*proc print data=ae2s ; run;*/

/*--Add labels for only the first aedecod--*/
data a2s_label;
  set ae2s;
  by aedecod;
  if first.aedecod then lowlabel=aedecod;
  run;

/*proc print data=a2s_label ;*/
/*var stday  aedecod lowlabel;*/
/*run;*/

/*--Sort by stday and aedecod--*/
proc sort data=a2s_label out=ae2_stday;
  by stday aedecod;
  run;
/**/
/*ods html;*/
/*proc print data=ae2_stday; */
/*  var aeseq aedecod aesev sev stdate endate stday enday highcap lowlabel;*/
/*run;*/
/*ods html close;*/

/*%put &minday &maxday &mindate &maxdate;*/

/*--Define Attribute Map for Fill and data label colors--*/
data attrmap;
  retain Id 'Severity' Show 'Attrmap';
  length Value $10 Fillcolor $15 Linecolor $15;
  input value $ fillcolor $ linecolor $;
  datalines;
Mild       lightgreen   darkgreen 
Moderate   gold         cx9f7f00
Severe     lightred     darkred
;
run;

/*ods html;*/
/*proc print data=attrmap; */
/*  var id show value fillcolor linecolor;*/
/*run;*/
/*ods html close;*/

/*--AE graph--*/
ods listing style=analysis gpath=&gpath image_dpi=&dpi;
ods graphics / reset  width=5.5in height=3in imagename="4_8_1_AE_Timeline_SG_V94";
title "Adverse Event Timeline Graph for Patient Id = &pid";
proc sgplot data=ae2_stday dattrmap=attrmap;
  format stdate date7.;
  refline 0 / axis=x lineattrs=(color=black);
  highlow y=aedecod low=stday high=enday / type=bar group=aesev lineattrs=(color=black pattern=solid) 
                  barwidth=0.8 lowlabel=lowlabel highcap=highcap attrid=Severity
                  labelattrs=(color=black size=7);
  scatter y=aedecod x=stdate / x2axis markerattrs=(size=0);
  xaxis grid display=(nolabel) valueattrs=(size=7) values=(&minday to &maxday by 2) offsetmax=0.02 ;  
  x2axis display=(nolabel) type=time valueattrs=(size=7) values=(&mindate to &maxdate) offsetmax=0.02; 
  yaxis reverse  display=(noticks novalues nolabel) discreteorder=data;
  run;
title;
footnote;

/*--Define Attribute Map for Fill and data label colors--*/
data attrmap_pattern;
  retain Id 'Severity' Show 'Attrmap' LineThickness 2;
  length Value $10 Fillcolor $15 LinePattern $15 ;
  input value $ fillcolor $ LinePattern $;
  datalines;
Mild       lightgreen   shortdash 
Moderate   gold         dash
Severe     lightred     solid
;
run;

/*ods html;*/
/*proc print data=attrmap_pattern; */
/*  var id show value fillcolor LinePattern LineThickness;*/
/*run;*/
/*ods html close;*/

/*--AE grap Grayscaleh--*/
ods listing style=journal gpath=&gpath image_dpi=&dpi;
ods graphics / reset  width=5.5in height=3in imagename="4_8_2_AE_Timeline_Grayscale_SG_V94";
title "Adverse Event Timeline Graph for Patient Id = &pid";
proc sgplot data=ae2_stday dattrmap=attrmap_pattern;
  format stdate date7.;
  refline 0 / axis=x lineattrs=(color=black);
  highlow y=aedecod low=stday high=enday / type=line group=aesev 
                  lowlabel=lowlabel highcap=highcap attrid=Severity
                  labelattrs=(size=7);
  scatter y=aedecod x=stdate / x2axis markerattrs=(size=0);
  xaxis grid display=(nolabel) valueattrs=(size=7) values=(&minday to &maxday by 2) offsetmax=0.02 ;  
  x2axis display=(nolabel) type=time valueattrs=(size=7) values=(&mindate to &maxdate) offsetmax=0.02; 
  yaxis reverse  display=(noticks novalues nolabel);
  run;

title;
footnote;

ods _all_ close;
ods listing;


