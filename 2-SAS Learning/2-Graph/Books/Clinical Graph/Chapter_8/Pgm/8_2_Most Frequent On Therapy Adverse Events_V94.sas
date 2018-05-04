%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods listing style=htmlblue image_dpi=&dpi gpath=&gpath; 
ods html close;

data ae;
  input AE $1-30 A B Low Mean High;
  label a='Percent';
  label b='Percent';
  datalines;
Arthralgia                    1   3    1    7     48
Nausea                        4   18   2    4     8  
Anorexia                      2   3    0.9  3.8   16
Hematuria                     2   4    0.8  3.2   15
Insomnia                      3   5.5  1.1  3.0   7
Vomiting                      3.5 6    1.2  2.5   6
Dyspepsia                     4   10   1.1  2.4   4.5
Weight Decrease               1.5 3    0.5  2.0   4.2
Respiratory Disorder          3   4    0.4  1.4   4
Headache                      7   10   0.8  1.1   2
Gastroesophageal Reflux       3   4    0.5  1.05  3.8
Back Pain                     5   6    0.8  1.04  2
Chronic Obstructive Airway    22  38   0.6  0.7   0.8
Dyspnea                       7   2.5  0.13 0.3   0.7
;
run;

%let na=216;
%let nb=431;

proc sort data=ae out=ae2;
  by mean;
  run;

/*ods html;*/
/*proc print data=ae2(obs=5);*/
/*var ae a b mean low  high;*/
/*run;*/
/*ods html close;*/


proc template;
  define statgraph Fig_8_2_Most_Frequent_On_Therapy_Adverse_Events;
    begingraph;
          
      entrytitle "Most Frequent On-Therapy Adverse Events Sorted by Relative Risk";
      layout lattice / columns=2 rowdatarange=union columnweights=(0.4 0.6)
             columngutter=10px;
            rowaxes;
                  rowaxis / griddisplay=on display=(ticks tickvalues line) tickvalueattrs=(size=7);
                endrowaxes;

            layout overlay / xaxisopts=(labelattrs=(size=8) tickvalueattrs=(size=7));
                  scatterplot x=a y=ae / markerattrs=graphdata1(symbol=circlefilled) name='a' legendlabel="Drug A (N=&na)";
                  scatterplot x=b y=ae / markerattrs=graphdata2(symbol=trianglefilled) name='b' legendlabel="Drug B (N=&nb)";
                  discretelegend 'a' 'b' / valueattrs=(size=6) border=true;
        endlayout;
            layout overlay / xaxisopts=(label='Relative Risk with 95% CL'
                                    labelattrs=(size=8) tickvalueattrs=(size=7)
                                    type=log logopts=(base=2 viewmin=0.125 viewmax=64 
                                    tickintervalstyle=logexpand));
                  scatterplot x=mean y=ae / xerrorlower=low xerrorupper=high markerattrs=(symbol=circlefilled);
                  referenceline x=1 / lineattrs=graphdatadefault(pattern=shortdash);
                endlayout;
          endlayout;
    endgraph;
  end;
  run;

ods graphics / reset width=5in height=2.5in imagename='8_2_Most_Frequent_On_Therapy_Adverse_Events_V94';
proc sgrender data=ae2 template=Fig_8_2_Most_Frequent_On_Therapy_Adverse_Events;
  run;



