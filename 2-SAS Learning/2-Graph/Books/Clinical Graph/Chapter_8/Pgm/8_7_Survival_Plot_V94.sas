%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods listing style=htmlblue image_dpi=&dpi gpath=&gpath; 
ods html close;

/*--Get survival plot data from LIFETEST procedure--*/
ods graphics on;
ods output Survivalplot=SurvivalPlotData;
proc lifetest data=sashelp.BMT plots=survival(atrisk=0 to 2500 by 500);
   time T * Status(0);
   strata Group / test=logrank adjust=sidak;
   run;

/*ods html;*/
/*proc print data=SurvivalPlotData(obs=4);*/
/*run;*/
/*ods html close;*/

/*--Define templage for Survival Plot--*/
proc template;
  define statgraph Fig_8_7_Survival_plot_out;
    begingraph  / axislineextent=data;
      entrytitle 'Product-Limit Survival Estimates';
      entrytitle 'With Number of AML Subjects at Risk' / textattrs=(size=8);
          layout lattice / columns=1 columndatarange=union rowweights=preferred rowgutter=10px;
        layout overlay / walldisplay=none
                       xaxisopts=(labelattrs=(size=8) tickvalueattrs=(size=7))
                       yaxisopts=(labelattrs=(size=8) tickvalueattrs=(size=7) display=(ticks tickvalues line));
          stepplot x=time y=survival / group=stratum name='s';
          scatterplot x=time y=censored / markerattrs=(symbol=plus) name='c';
          scatterplot x=time y=censored / markerattrs=(symbol=plus) GROUP=stratum;
                  discretelegend 'c' / location=inside halign=right valign=top valueattrs=(size=7);
          discretelegend 's' / valueattrs=(size=7);

                  /*--Draw the Y axis label closer to the axis--*/
                  drawtext textattrs=(size=8) 'Survival Probability' / x=-6 y=50 anchor=bottom 
                   xspace=wallpercent yspace=wallpercent rotate=90 width=50;
        endlayout;

        layout overlay / walldisplay=none xaxisopts=(display=none);
              /*--Subjects at risk--*/
          axistable x=tatrisk value=atrisk / class=stratum colorgroup=stratum
                     labelattrs=(size=7) valueattrs=(size=7)
                     title='Subjects At Risk' titleattrs=(size=7);
                endlayout;

          endlayout;
    endgraph;
  end;
run;

ods graphics / reset width=5in height=2.5in imagename='8_7_1_Survival_plot_out_V94';
proc sgrender data=SurvivalPlotData template=Fig_8_7_Survival_plot_out;
  run;


/*--Define templage for Survival Plot--*/
proc template;
  define statgraph Fig_8_7_Survival_plot_in;
    begingraph;
      entrytitle 'Product-Limit Survival Estimates';
      entrytitle 'With Number of AML Subjects at Risk' / textattrs=(size=8);
          layout overlay / walldisplay=none
                       xaxisopts=(labelattrs=(size=8) tickvalueattrs=(size=7))
                       yaxisopts=(labelattrs=(size=8) tickvalueattrs=(size=7));
        stepplot x=time y=survival / group=stratum  name='s';
        scatterplot x=time y=censored / markerattrs=(symbol=plus) name='c';
        scatterplot x=time y=censored / markerattrs=(symbol=plus) GROUP=stratum;
                discretelegend 'c' / location=inside halign=right valign=top valueattrs=(size=7);
        discretelegend 's' / valueattrs=(size=7);

            /*--Subjects at risk--*/
        innermargin / align=bottom;
          axistable x=tatrisk value=atrisk / class=stratum colorgroup=stratum
                     labelattrs=(size=7) valueattrs=(size=7) 
                     title='Subjects At Risk' titleattrs=(size=7) ;
            endinnermargin;
          endlayout;
    endgraph;
  end;
run;

ods graphics / reset width=5in height=2.5in imagename='8_7_2_Survival_plot_in_V94';
proc sgrender data=SurvivalPlotData template=Fig_8_7_Survival_plot_in;
  run;
