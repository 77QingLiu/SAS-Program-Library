%let gpath='.';    /*--Put your Folder Name here--*/
%let dpi=300;
ods listing style=listing image_dpi=&dpi gpath=&gpath; 
ods html close;

/*--Create Forest Plot data--*/
data forestWithSubgroups;
  input Indent Subgroup $5-29 Count Percent Mean  Low  High
        PCIGroup Group PValue;
  format PCIGroup Group PValue 7.2 Indent 3.1;
  label PCIGroup='PCI Group' group='Therapy Group';

  zero=0;
  PCIGrpLbl='PCI Group';
  GrpLbl='Therapy';
  PCILbl='PCI';
  if indent = 0 then Type='G'; else Type=' ';
  if count ne . then
      CountPct=put(count, 4.0) || "(" || put(percent, 3.0) || ")";

  /*--Separate Subgroups from Values--*/
  if indent=0 then do;
    indentsub=indent; indentval=.;
  end;
  else do;
    indentsub=.; indentval=indent;
  end;

  datalines;
0   Overall                  2166  100  1.3   0.9   1.5  17.2  15.6  .
0   Age                      .     .    .     .     .    .     .     0.05
1   <= 65 Yr                 1534   71  1.5   1.05  1.9  17.0  13.2   .
2.0 > 65 Yr                   632   29  0.8   0.6   1.25 17.8  21.3   .
0   Sex                      .     .    .     .     .    .     .     0.13
1   Male                     1690   78  1.5   1.05  1.9  16.8  13.5   .
1   Female                    476   22  0.8   0.6   1.3  18.3  22.9   . 
0   Race or ethnic group     .     .    .     .     .    .     .     0.52
1   Nonwhite                  428   20  1.05  0.6   1.8  18.8  17.8   .
1   White                    1738   80  1.2   0.85  1.6  16.7  15.0   . 
0   From MI to Randomization .     .    .     .     .    .     .     0.81
1   <= 7 days                 963   44  1.2   0.8   1.5  18.9  18.6   .
2.0 > 7 days                 1203   56  1.15  0.75  1.5  15.9  12.9   .
;
run;
/*proc print;run;*/
/* Add in reference "band" data */
data forestWithSubgroups2;
  set forestWithSubgroups;
  if mod(_N_-1, 6) in (1, 2, 3) then Ref=subGroup;
run;

/*proc print;run;*/

ods html;
proc print data=forestWithSubgroups2(obs=6);
var Indent Subgroup Count Percent CountPct Mean  Low  High PCIGroup Group PValue ref type;
/*var Study Grp OddsRatio LowerCL UpperCL Weight Q1 Q3; */
run;
ods html close;
/*proc print;run;*/

/*--Define templage for Forest Plot--*/
/*--Template uses a Layout Lattice of 5 columns--*/
proc template;
  define statgraph Fig_7_6_Forest_Plot_with_Subgroups;
    dynamic _color;
    begingraph;
      entrytitle 'Forest Plot of Hazard Ratios by Patient Subgroups ';

      layout lattice / columns=4 columnweights=(0.25 0.10 0.35 0.3) rowdatarange=union;

            /*--Column headers--*/
        sidebar / align=top;
          layout lattice / columns=4 columnweights=(0.22 0.23 0.27 0.28);
            entry textattrs=(size=8) halign=left "    Subgroup";
            entry textattrs=(size=8) halign=left " No.of Patients (%)";
            entry textattrs=(size=8) halign=left "Hazard Ratio";
            entry halign=left textattrs=(size=8) "4-Yr Cumulative Event Rate";
          endlayout;
        endsidebar;

                 /*--First column showing Subgroups--*/
            layout overlay / xaxisopts=(offsetmin=0 offsetmax=0 
                                    display=none linearopts=(viewmin=0 viewmax=20))
                         yaxisopts=(reverse=true display=none offsetmax=0.1) walldisplay=none;
          referenceline y=ref / lineattrs=(thickness=14 color=_color);
          highlowplot y=subgroup low=zero high=indentsub / highlabel=subgroup lineattrs=(thickness=0)
                      labelattrs=(weight=bold);
          highlowplot y=subgroup low=zero high=indentval / highlabel=subgroup lineattrs=(thickness=0);
                endlayout;

                 /*--Second column showing Counts--*/
            layout overlay / xaxisopts=(display=none)
                         yaxisopts=(reverse=true display=none offsetmax=0.1) walldisplay=none;
          referenceline y=ref / lineattrs=(thickness=14 color=_color);
          scatterplot y=subgroup x=indent / markercharacter=countpct;
                endlayout;

                 /*--Third column showing odds ratio graph--*/
            layout overlay / xaxisopts=(display=(ticks tickvalues line)
                                    tickvalueattrs=(size=7) linearopts=(tickvaluepriority=true 
                                    tickvaluelist=(0.0 0.5 1.0 1.5 2.0 2.5)))
                         yaxisopts=(reverse=true display=none offsetmax=0.1) walldisplay=none;
                    /*--Draw color Bands--*/
            referenceline y=ref / lineattrs=(thickness=14 color=_color);
                    referenceline x=1;

                /*--Draw Hazard Ratios--*/
            highlowplot y=subgroup low=low high=high;
            scatterplot y=subgroup x=mean / markerattrs=(symbol=squarefilled);

                    /*--Draw axis labels--*/
            drawtext textattrs=(size=6) '< PCI Better'  / x=0.9 y=1 
                     xspace=datavalue yspace=wallpercent anchor=bottomright width=50;
                    drawtext textattrs=(size=6) 'Therapy Better >' / x=1.1 y=1 
                     xspace=datavalue yspace=wallpercent anchor=bottomleft width=50;
          endlayout;

                  /*--Fourth column showing table of values--*/
                  layout overlay / yaxisopts=(reverse=true display=none offsetmax=0.1) 
                           x2axisopts=(display=(tickvalues) tickvalueattrs=(size=7)) 
                           walldisplay=none;
                referenceline y=ref / lineattrs=(thickness=14 color=_color);
            scatterplot y=subgroup x=PCIGrpLbl / markercharacter=pcigroup xaxis=x2;
            scatterplot y=subgroup x=grpLbl / markercharacter=group xaxis=x2;
            scatterplot y=subgroup x=PCILbl / markercharacter=pvalue xaxis=x2;
                endlayout;
          endlayout;
    endgraph;
  end;
run;

ods graphics / reset width=5in height=2.5in imagename='7_6_Forest_Plot_with_Subgroups_V93';
proc sgrender data=forestWithSubgroups2 template=Fig_7_6_Forest_Plot_with_Subgroups;
  dynamic _color='cxf0f0f0';
  run;
