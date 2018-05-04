%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods listing style=htmlblue image_dpi=&dpi gpath=&gpath; 
ods html close;
option missing=' ';

/*--Format for Week--*/
proc format;
  value wk 
    28='Max';
run;

/*--Build simulated data set--*/
data asat;
  format Week wk.;
  label ASAT='ASAT (/ULN)';
  drop i;

  do Week=0,1,2,4,8,12,24;
    count=.;
    do i=1 to 20;
          Drug='A'; ASAT=0.3+0.4*ranuni(2); DrugGT='>2(A)'; 
      count=int(ifn(i=1,220*(1-week/56), .)); gt2=int(ifn(i=1,2*ranuni(3), .)); output;
          Drug='B'; asat=0.4+0.5*ranuni(2); DrugGT='>2(B)'; 
      count=int(ifn(i=1,430*(1-week/56), .)); gt2=int(ifn(i=1,3*ranuni(3), .));output;
        end;
    do i=1 to 5;
          Drug='A'; asat=1+1*ranuni(2); count=.; output;
          Drug='B'; asat=1.2+0.8*ranuni(2); count=.; output;
        end;
  end;

  week=28;
  do i=1 to 20;
        Drug='A'; asat=0.3+0.4*ranuni(2); count=int(ifn(i=1,220, .)); DrugGT='>2(A)'; gt2=int(ifn(i=1,2, .)); output;
        Drug='B'; asat=0.4+0.5*ranuni(2); count=int(ifn(i=1,430, .)); DrugGT='>2(B)'; gt2=int(ifn(i=1,3, .)); output;
  end;
  do i=1 to 5;
        Drug='A'; asat=1+1*ranuni(2);     count=.;  output;
        Drug='B'; asat=1.2+0.8*ranuni(2); count=.;  output;
  end;
run;

/*ods html;*/
/*proc print data=asat(obs=5);*/
/*var Week Drug asat Count DrugGT Gt2;*/
/*run;*/
/*ods html close;*/

/*--Define template for graph--*/
proc template;
  define statgraph Fig_8_1_ASAT_By_Time_and_Trt;
    begingraph;
      entrytitle 'Distribution of ASAT by Time and Treatment';
      layout overlay / xaxisopts=(type=linear 
                                  linearopts=(tickvaluelist=(0 2 4 8 12 24 28)
                                  viewmax=29))
                       yaxisopts=(offsetmax=0.1);
            boxplot x=week y=asat / group=drug name='a' groupdisplay=cluster
                display=(mean median outliers);
                referenceline x=25;
                referenceline y=1 / lineattrs=(pattern=shortdash);
        referenceline y=2 / lineattrs=(pattern=dash);
        discretelegend 'a' / itemsize=(linelength=20) location=inside 
                             halign=center valign=top;
                innermargin / separator=true;
                  axistable x=week value=count / class=drug colorgroup=drug
                    valueattrs=(size=5 weight=bold) labelattrs=(size=7);
                endinnermargin;
                innermargin / separator=true align=top;
                  axistable x=week value=gt2 / class=drugGT colorgroup=drugGT
                    valueattrs=(size=5 weight=bold) labelattrs=(size=7);
                endinnermargin;
          endlayout;
        endgraph;
  end;
run;

/*--Render the Graph--*/
ods graphics / reset width=5in height=3in imagename='8_1_ASAT_By_Time_and_Trt_V94';
proc sgrender data=asat template=Fig_8_1_ASAT_By_Time_and_Trt;
run;



