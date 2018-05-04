%let gpath='.';    /*--Put your Folder Name here--*/
%let dpi=300;
ods listing style=htmlblue image_dpi=&dpi gpath=&gpath; 
ods html close;

proc template;
  define statgraph Histogram;
    begingraph;
      entrytitle 'Distribution of Cholesterol';
      layout overlay;
        histogram cholesterol;
      endlayout;
    endgraph;
  end;
run;

ods graphics / reset width=2.4in  noborder imagename='6_2_Histogram';
proc sgrender data=sashelp.heart template= Histogram;
run;
