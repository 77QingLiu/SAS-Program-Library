
%let gpath='.';    /*--Put your Folder Name here--*/
%let dpi=300;
ods listing style=listing image_dpi=&dpi gpath=&gpath; 
ods html close;

/*--Panel--*/
proc template;
  define statgraph Fig_7_0_Panel;
    begingraph;
      entrytitle "Characteristics of Subjects in the Study";
      layout lattice / columns=2 columnweights=(0.6 0.4) columngutter=10px;
            sidebar / spacefill=false;
                  discretelegend 'a';
            endsidebar;
            layout overlay;
          scatterplot x=cholesterol y=systolic / group=sex name='a'
                      markerattrs=(symbol=circlefilled) datatransparency=0.5;
        endlayout;
                layout lattice / rows=2 columndatarange=union;
                  columnaxes;
                    columnaxis / discreteopts=(tickvaluefitpolicy=stagger) tickvalueattrs=(size=6);
                  endcolumnaxes;
              layout overlay / yaxisopts=(labelattrs=(size=8) tickvalueattrs=(size=6) 
                                      label='Weight(mean)' offsetmin=0)
                           xaxisopts=(labelattrs=(size=8) tickvalueattrs=(size=6));
            barchart x=deathcause y=weight / group=sex groupdisplay=cluster stat=mean
                     baselineattrs=(thickness=0) fillattrs=(transparency=0.2) outlineattrs=(color=black);
          endlayout;
              layout overlay / yaxisopts=(labelattrs=(size=8) tickvalueattrs=(size=6)) 
                           xaxisopts=(labelattrs=(size=8) tickvalueattrs=(size=6));
            boxplot y=diastolic x=deathcause / group=sex groupdisplay=cluster
                    fillattrs=(transparency=0.2) meanattrs=(size=5 color=black) outlineattrs=(color=black);
          endlayout;
                endlayout;
          endlayout;
        endgraph;
  end;
run;

/*--Rename some values--*/
data heart;
  set sashelp.heart(keep=Cholesterol Systolic Diastolic Deathcause Sex Weight);
  if deathcause="Cerebral Vascular Disease" then deathcause="CVD";
  else if deathcause="Coronary Heart Disease" then deathcause="CHD";
  else deathcause=deathcause;
run;

ods listing;
ods graphics / reset width=6in height=2.4in  imagename="7_0_Panel_V93";
proc sgrender data=heart template=Fig_7_0_Panel;
run;

title;
footnote;
