%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods listing style=htmlblue image_dpi=&dpi gpath=&gpath; 
ods html close;

/*--Most Frequent Adverse Events sorted by Relative Risk with NNT--*/
data final;
  input AEDECOD $1-20 PCT0 PCTR Risk LRisk URisk RiskCI $66-84 NNT;
  datalines;
Back pain            0.10227 0.057471 -0.044801 -0.13623 0.04663 -0.04 (-0.14, 0.05) -22.3207
Insomnia             0.04545 0.011494 -0.033960 -0.09434 0.02641 -0.03 (-0.09, 0.03) -29.4462
Headache             0.09091 0.057471 -0.033438 -0.12232 0.05545 -0.03 (-0.12, 0.06) -29.9063
Respiratory disorder 0.00000 0.022989  0.022989 -0.01993 0.06591 0.02 (-0.02, 0.07)   43.5000
Weight decrease      0.00000 0.022989  0.022989 -0.01993 0.06591 0.02 (-0.02, 0.07)   43.5000
Dyspepsia            0.01136 0.034483  0.023119 -0.03259 0.07883 0.02 (-0.03, 0.08)   43.2542
Vomiting             0.01136 0.034483  0.023119 -0.03259 0.07883 0.02 (-0.03, 0.08)   43.2542
Hematuria            0.02273 0.045977  0.023250 -0.04209 0.08859 0.02 (-0.04, 0.09)   43.0112
Nausea               0.00000 0.034483  0.034483 -0.01529 0.08425 0.03 (-0.02, 0.08)   29.0000
Arthralgia           0.02273 0.068966  0.046238 -0.02687 0.11935 0.05 (-0.03, 0.12)   21.6271
;
run;

/*ods html;*/
/*proc print data=final(obs=5);*/
/*run;*/
/*ods html close;*/

/*--Template--*/
proc template;
   define statgraph Fig_8_3_Most_Frequent_On_Therapy_Adverse_Events;
   begingraph;
      entrytitle "Treatment Emergent Adverse Events with Largest Risk Difference";
          entryfootnote halign=left "Number needed to treat = 1/riskdiff." / textattrs=(size=7);

          /* Define a Lattice layout with two columns and one common external y-axis */
      layout lattice / columns=2 columnweights=(0.4 0.6) rowdatarange=union columngutter=10px;
        rowaxes;
             rowaxis / griddisplay=on  display=(tickvalues) tickvalueattrs=(size=7);
            endrowaxes;

            /* Left cell with incidence values */
        layout overlay / xaxisopts=(label="Proportion"  
                                    tickvalueattrs=(size=7) labelattrs=(size=8));
          scatterplot y=aedecod x=pct0 / markerattrs=(symbol=circlefilled color=bib size=8)
                                                name='drga' legendlabel='Drug A (N=90)';
          scatterplot y=aedecod x=pctr / markerattrs=(symbol=trianglefilled color=red size=8)
                                                            name='drgb' legendlabel='Drug B (N=90)';
        endlayout;
            /* Right cell with risk differences and NNT */
        layout overlay / xaxisopts=(label="Risk Difference with 95% CI" griddisplay=on
                                    gridattrs=(color=cxf7f7f7) tickvalueattrs=(size=7) labelattrs=(size=8) 
                                    linearopts=(tickvaluefitpolicy=none viewmin=-0.2 viewmax=0.2
                                     tickvaluelist=(-0.20 -0.1  0 0.1 0.20)))
                           x2axisopts=(label="Number needed to treat"  
                                   tickvalueattrs=(size=7) labelattrs=(size=8) 
                                   linearopts=(tickvaluefitpolicy=none viewmin=-0.2 viewmax=0.2 
                                     tickvaluelist=(-0.20 -0.1  0 0.1 0.20)
                                   tickdisplaylist=('-5' '-10' "(*ESC*){unicode '221e'x}"  '10' '5')));

          scatterplot y=aedecod x=risk / markerattrs=(symbol=diamondfilled color=black size=8)
                                                    xerrorlower=lrisk
                                                                            xerrorupper=urisk;
                  scatterplot y=aedecod x=risk / xaxis=x2 datatransparency=1;
                  innermargin / align=right;
            axistable y=aedecod value=riskci / class=origin display=(label) labelposition=min labelattrs=(size=8);
              endinnermargin;
          referenceline x=0 / lineattrs=(pattern=shortdash color=black);
        endlayout;

            /* Bottom-centered sidebar with legend */
        sidebar / align=bottom spacefill=false;
          discretelegend 'drga' 'drgb' / autoitemsize=true valueattrs=(size=8);
        endsidebar;
      endlayout;
    endgraph;
  end;
run;

/*--Plot the graph--*/
ods graphics on / reset width=5in height=2.5in 
                  imagename='8_3_Most_Frequent_On_Therapy_Adverse_Events_with_NNT_V94';
proc sgrender data=final template=Fig_8_3_Most_Frequent_On_Therapy_Adverse_Events;
run;



