%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods listing style=htmlblue image_dpi=&dpi gpath=&gpath; 
ods html close;

data forest;
  input Study $1-16 Grp OddsRatio LowerCL UpperCL Weight;
  format weight percent5.;
  format Q1 Q3 4.2;
  format oddsratio lowercl uppercl 5.3;

  if grp=1 then do;
    weight=weight*.05;
    Q1=OddsRatio*(1.0-weight);      
    Q3=OddsRatio*(1.0+weight);
  end;

  datalines;
Modano  (1967)    1  0.590 0.096 3.634  1
Borodan (1981)    1  0.464 0.201 1.074  3.5
Leighton (1972)   1  0.394 0.076 2.055  2
Novak   (1992)    1  0.490 0.088 2.737  2
Stawer  (1998)    1  1.250 0.479 3.261  3
Truark   (2002)   1  0.129 0.027 0.605  2.5
Fayney   (2005)   1  0.313 0.054 1.805  2
Modano  (1969)    1  0.429 0.070 2.620  2
Soloway (2000)    1  0.718 0.237 2.179  3
Adams   (1999)    1  0.143 0.082 0.250  4
Overall           2  0.328 .     .      .
;
run;

/*ods html;*/
/*proc print data=forest(firstobs=7 obs=11);*/
/*var Study Grp OddsRatio LowerCL UpperCL Weight Q1 Q3; */
/*run;*/
/*ods html close;*/

proc template;
  define statgraph Fig_8_5_Forest_Plot;
    begingraph / datasymbols=(squarefilled diamondfilled);
      entrytitle "Impact of Treatment on Mortality by Study";
      layout overlay / walldisplay=none
                       yaxisopts=(reverse=true display=none offsetmax=0.05
                                  discreteopts=(colorbands=even colorbandsattrs=(transparency=0.5)))
                       xaxisopts=(type=log logopts=(tickvaluelist=(0.01 0.1 1 10 100) tickvaluepriority=true)
                                  display=(tickvalues) displaysecondary=(label) 
                                  label='Odds Ratio and 95% CL' labelattrs=(size=8) tickvalueattrs=(size=7));
            scatterplot y=study x=oddsratio / group=grp xerrorlower=lowercl xerrorupper=uppercl;
                referenceline x=eval(coln(0.01, 0.1, 10, 100)) / lineattrs=(pattern=shortdash) datatransparency=0.5;
                referenceline x=1 / datatransparency=0.5;
        innermargin / align=left;
              axistable y=study value=study / display=(label) labelattrs=(size=8);
                endinnermargin;

        innermargin / align=right;
              axistable y=study value=Oddsratio / display=(label) labelattrs=(size=8) 
                    showmissing=false valuehalign=center;
                  axistable y=study value=lowercl / display=(label) labelattrs=(size=8)
                    showmissing=false valuehalign=center;
                  axistable y=study value=uppercl / display=(label) labelattrs=(size=8)
                    showmissing=false  valuehalign=center;
                  axistable y=study value=weight / display=(label) labelattrs=(size=8) 
                    showmissing=false  valuehalign=center;
                endinnermargin;

                drawtext textattrs=(size=8) 'Favors Placebo' / x=1.2 y=0 xspace=datavalue yspace=wallpercent anchor=left width=50;
                drawtext textattrs=(size=8) 'Favors Treatment' / x=0.8 y=0 xspace=datavalue yspace=wallpercent anchor=right width=50;

          endlayout;
        endgraph;
  end;
run;

ods graphics / reset attrpriority=none width=5in height=2.5in imagename='8_5_Forest_Plot_V94';
proc sgrender data=forest template=Fig_8_5_Forest_Plot;
  run;
