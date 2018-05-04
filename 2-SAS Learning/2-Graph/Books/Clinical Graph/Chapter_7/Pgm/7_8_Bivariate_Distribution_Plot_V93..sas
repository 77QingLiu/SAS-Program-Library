%let gpath='.';    /*--Put your Folder Name here--*/
%let dpi=300;
ods listing style=htmlblue image_dpi=&dpi gpath=&gpath; 
ods html close;

ods html;
proc print data=sashelp.heart(obs=4);
  var Weight Cholesterol Systolic Diastolic Sex;
run;
ods html close;

/*--Define templage for Survival Plot--*/
proc template;
  define statgraph Fig_7_8_Bivariate_Distribution_Plot;
    begingraph;
          dynamic _XVar _YVar _Type _Title;
      entrytitle _Title _YVar ' By ' _XVar ;
      entrytitle 'With Univariate Distributions of Each Variable' / textattrs=(size=8);

          layout lattice / columns=3 columndatarange=union rowweights=(0.2 0.15 0.65) rowgutter=10px
                       rows=3 rowdatarange=union columnweights=(0.74 0.06 0.2) columngutter=10px;
        columnaxes;
                  columnaxis / display=(tickvalues label) griddisplay=on tickvalueattrs=(size=7) labelattrs=(size=7);
                  columnaxis / display=none;
                  columnaxis / display=(tickvalues) griddisplay=on tickvalueattrs=(size=7) labelattrs=(size=7);;
                endcolumnaxes;

        rowaxes;
                  rowaxis / display=(tickvalues)  griddisplay=on tickvalueattrs=(size=7) labelattrs=(size=7);;
                  rowaxis / display=none;
                  rowaxis / display=(tickvalues label)  griddisplay=on tickvalueattrs=(size=7) labelattrs=(size=7);;
                endrowaxes;
                
                /*--Top Left--*/
        layout overlay / walldisplay=none;
                  histogram _xvar; 
                endlayout;
  
        /*--Top--*/
                entry ' ';
  
        /*--Top Right--*/
                entry ' ';
  
        /*--Middle Left--*/
        layout overlay / walldisplay=none;
                   boxplot y=_XVar / orient=horizontal boxwidth=0.9;
                endlayout;
  
        /*--Middle--*/
                entry ' ';
  
        /*--Middle Right--*/
            entry ' ';
  
        /*--Bottom Left--*/
        layout overlay / walldisplay=none;
                  if (_type = 'heatmap')
                    heatmap x=_xvar y=_yvar / xbins=100 ybins=50;
                  else
                    scatterplot x=_xvar y=_yvar / markerattrs=(symbol=circlefilled) datatransparency=0.95;
                  endif;
                  regressionplot x=_xvar y=_yvar / degree=2 lineattrs=graphdatadefault;
                endlayout;
  
        /*--Bottom--*/
        layout overlay / walldisplay=none;
                  boxplot y=_YVar / boxwidth=0.9;
                endlayout;
  
        /*--Bottom Right--*/
        layout overlay / walldisplay=none;
                  histogram _yvar / orient=horizontal;
                endlayout;
  
          endlayout;
    endgraph;
  end;
run;

/*--Render graph with Scatter Plot--*/
ods listing style=htmlblue;
ods graphics / reset antialiasmax=10000 width=5in height=2.5in 
               imagename='7_8_1_Bivariate_Distribution_Plot_Scatter_V93';
proc sgrender data=sashelp.heart template=Fig_7_8_Bivariate_Distribution_Plot;
  dynamic _XVar='Weight' _YVar='Systolic' _Type='scatter' 
          _Title='A Scatter Plot of the Joint Bivariate Distribution of ';
  run;

/*--Define a Style with Blue-Yellow-Red fill ramp--*/
proc template;   
   define style RampListing;                                              
      parent = styles.listing; 
      style GraphColors from GraphColors /                                                
         'gramp3cend' = cxDF0000                                              
         'gramp3cneutral' = cxEFDF00                                          
         'gramp3cstart' = cx4f7fCF
                 ;
   end;  
run;

/*--Render graph with Heatmap using RampListing style--*/
ods listing style=RampListing;
ods graphics / reset antialiasmax=5300 width=5in height=2.5in 
               imagename='7_8_2_Bivariate_Distribution_Plot_Scatter_Heatmap';
proc sgrender data=sashelp.heart template=Fig_7_8_Bivariate_Distribution_Plot;
  dynamic _XVar='Weight' _YVar='Systolic' _Type='heatmap' 
          _Title='A Heat Map of the Joint Bivariate Distribution of ';
  run;

/*--Layout grid--*/
proc template;
  define statgraph Fig_7_8_Bivariate_Distribution_Grid;
    begingraph;
      entrytitle 'Graph Layout' / textattrs=(size=8);

          layout lattice / columns=3 columndatarange=union rowweights=(0.2 0.15 0.65) rowgutter=10px
                       rows=3 rowdatarange=union columnweights=(0.74 0.06 0.2) columngutter=10px;
        columnaxes;
                  columnaxis / display=none;
                  columnaxis / display=none;
                  columnaxis / display=none;
                endcolumnaxes;

        rowaxes;
                  rowaxis / display=none;
                  rowaxis / display=none;
                  rowaxis / display=none;
                endrowaxes;
                
                /*--Top Left--*/
        layout overlay / border=true;
          entry ' Histogram of X';
                endlayout;
  
        /*--Top--*/
        layout overlay / border=true;
          entry ' ';
                endlayout;
  
        /*--Top Right--*/
        layout overlay / border=true;
          entry ' ';
                endlayout;
  
        /*--Middle Left--*/
        layout overlay / border=true;
           entry ' Boxplot of X';
                endlayout;
  
        /*--Middle--*/
        layout overlay / border=true;
           entry ' ';
                endlayout;
  
        /*--Middle Right--*/
        layout overlay / border=true;
          entry ' ';
                endlayout;
  
        /*--Bottom Left--*/
        layout overlay / border=true walldisplay=none;
          scatterplot x=weight y=systolic / datatransparency=1;
          entry ' Scatter Plot of Y by X';
                endlayout;
  
        /*--Bottom--*/
        layout overlay / border=true;
          entry ' Boxplot of Y' / rotate=90;
                endlayout;
  
        /*--Bottom Right--*/
        layout overlay / border=true;
          entry ' Histogram of Y' / rotate=90;
                endlayout;
  
          endlayout;
    endgraph;
  end;
run;

ods graphics / reset width=5in height=2.5in imagename='7_8_3_Bivariate_Distribution_Grid_V93';
proc sgrender data=sashelp.heart template=Fig_7_8_Bivariate_Distribution_Grid;
  run;
