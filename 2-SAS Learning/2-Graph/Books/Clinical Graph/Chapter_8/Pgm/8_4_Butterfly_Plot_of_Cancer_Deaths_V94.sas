%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods listing style=htmlblue image_dpi=&dpi gpath=&gpath; 
ods html close;

data cancer;
   infile datalines;
   format MCases FCases MDeaths FDeaths Deaths comma8.;
   input Cause $ 1-20 mcases fcases mdeaths fdeaths;
   Deaths=mdeaths + fdeaths;
   Cases=mcases+fcases;
   datalines;
Lung Cancer         114760  98620  89510  70880
Colorectal Cancer    55290  57050  26000  26180
Breast Cancer         2030 178480    450  40460
Pancreatic Cancer    18830  18340  16840  16530
Prostate Cancer     218890      0  27050      0
Leukemia             24800  19440  12320   9470
Lymphoma             38670  32710  10370   9360
Liver Cancer         13650   5510  11280   5500
Ovarian Cancer           0  22430      0  15280
Esophageal Cancer    12130   3430  10900   3040
Bladder Cancer       50040  17120   9630   4120
Kidney Cancer        31590  19600   8080   4810
;
run;

proc sort data=cancer out=cancerByCases;
  by descending cases;
run;

/*ods html;*/
/*proc print data=cancerByCases(obs=4);*/
/*  var cause MCases FCases MDeaths FDeaths Cases;*/
/*run;*/
/*ods html close;*/

proc template;
  define statgraph Fig_8_4_Butterfly_Plot_Of_Cancer_Deaths;
    dynamic _title;
    begingraph;
          
      entrytitle "Leading Cause of Cancer in USA for 2007 by Gender and " _title;
      layout lattice / columns=2 columnweights=(0.45 0.55) rowdatarange=union;

            layout overlay / xaxisopts=(reverse=true tickvalueattrs=(size=7) label='Males' 
                                    display=(tickvalues) griddisplay=on) 
                         yaxisopts=(display=none reverse=true) walldisplay=none;
                  barchart category=cause response=mcases / fillattrs=graphdata1(transparency=0.7) orient=horizontal 
                   name='mc' legendlabel='Male Cases';
                  barchart category=cause response=mdeaths / fillattrs=graphdata1(transparency=0.3)  
                   barwidth=0.6 orient=horizontal dataskin=pressed name='md' legendlabel='Male Deaths';
        endlayout;

            layout overlay / xaxisopts=(tickvalueattrs=(size=7)  label='Females' display=(tickvalues) griddisplay=on) walldisplay=none
                         yaxisopts=(tickvaluehalign=center display=(tickvalues line) reverse=true tickvalueattrs=(size=7));
                  barchart category=cause response=fcases / fillattrs=graphdata2(transparency=0.7) orient=horizontal
                   name='fc' legendlabel='Female Cases';
                  barchart category=cause response=fdeaths / fillattrs=graphdata2(transparency=0.3) 
                   barwidth=0.6 orient=horizontal dataskin=pressed name='fd' legendlabel='Female Deaths';
        endlayout;
                sidebar / spacefill=false;
                  discretelegend 'mc' 'fc' 'md' 'fd' / across=2 itemsize=(fillheight=10px fillaspectratio=golden);
                endsidebar;
          endlayout;
    endgraph;
  end;
run;

ods graphics / reset width=5in height=2.5in imagename='8_4_1_Butterfly_Plot_Of_Cancer_By_Cases_V94';
proc sgrender data=cancerByCases template=Fig_8_4_Butterfly_Plot_Of_Cancer_Deaths;
  dynamic _title='Cases';
  run;

proc sort data=cancer out=cancerByDeaths;
  by descending deaths;
run;

/*ods html;*/
/*proc print data=cancerByDeaths(obs=4);*/
/*  var cause MCases FCases MDeaths FDeaths Deaths;*/
/*run;*/
/*ods html close;*/

ods graphics / reset width=5in height=2.5in imagename='8_4_2_Butterfly_Plot_Of_Cancer_By_Deaths_V94';
proc sgrender data=cancerByDeaths template=Fig_8_4_Butterfly_Plot_Of_Cancer_Deaths;
  dynamic _title='Deaths';
  run;

