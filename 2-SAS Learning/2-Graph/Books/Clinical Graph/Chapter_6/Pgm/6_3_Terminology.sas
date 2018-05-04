%let gpath='.';    /*--Put your Folder Name here--*/
%let dpi=300;
ods listing style=listing image_dpi=&dpi gpath=&gpath; 
ods html close;

/*--Figure 2.4.1 - Graph Terminology--*/
proc template;
  define statgraph Terminology;
    dynamic _var;
    begingraph;
      entrytitle 'Distribution of Systolic Blood Pressure';
          entryfootnote halign=left 'For Age at Start > 50' / textattrs=(size=7);

      layout lattice / rowweights=(0.8 0.2) columns=1
                 columndatarange=union;
        columnaxes;
          columnaxis / display=(ticks tickvalues line);
        endcolumnaxes;

        layout overlay;
          histogram _var / binaxis=false;
          densityplot _var / name='n' legendlabel='Normal';
          densityplot _var / kernel() lineattrs=graphfit2(pattern=solid)
                      name='k' legendlabel='Kernel';
          discretelegend 'n' 'k' / location=inside halign=right valign=top across=1
                                   itemsize=(linelength=20);
        endlayout;

        layout overlay;
          boxplot y=_var / orient=horizontal boxwidth=0.8;
        endlayout;

      endlayout;

    endgraph;
  end;
run;

ods graphics / reset  noborder width=4in imagename='6_3_Terminology';
proc sgrender data=sashelp.heart(where=(ageatstart > 50)) template=Terminology;
dynamic _var='Systolic';
run;
