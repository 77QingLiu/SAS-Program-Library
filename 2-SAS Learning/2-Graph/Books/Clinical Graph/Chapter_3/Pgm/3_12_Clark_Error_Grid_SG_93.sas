%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods html close;
ods listing gpath=&gpath image_dpi=&dpi;

/*ods html close;*/
/*ods listing style=blueBG gpath=&gpath image_dpi=&dpi;*/

/*--Generate grid and point data--*/
data Grid;
  drop i pi;
  pi=constant('PI');
  label x='Reference Blood Glucose';
  label y='Sensor Blood Glucose';

  /*--Zone A--*/
  id=1; rfbg=70;  sbg=0; output;
  id=1; rfbg=70;  sbg=70; output;
  id=1; rfbg=0;   sbg=70; output;
  /*--Zone D - Y--*/
  id=2; rfbg=70;  sbg=70; output;
  id=2; rfbg=70;  sbg=180; output;
  id=2; rfbg=0;   sbg=180; output;
  /*--Zone E - Y--*/
  id=3; rfbg=70;  sbg=180; output;
  id=3; rfbg=70;  sbg=400; output;
  id=3; rfbg=0;   sbg=400; output;
  /*--Zone E - X--*/
  id=4; rfbg=180;  sbg=0; output;
  id=4; rfbg=180;  sbg=70; output;
  id=4; rfbg=400;  sbg=70; output;
  /*--Zone D - X--*/
  id=5; rfbg=240;  sbg=70; output;
  id=5; rfbg=240;  sbg=180; output;
  id=5; rfbg=400;  sbg=180; output;
  /*--Zone C - Low--*/
  id=6; rfbg=130;  sbg=0; output;
  id=6; rfbg=180;  sbg=70; output;
  /*--Zone C - High--*/
  id=7; rfbg=70;  sbg=180; output;
  id=7; rfbg=290; sbg=400; output;
  /*--Zone B - High--*/
  id=8; rfbg=58.3; sbg=70; output;
  id=8; rfbg=333;  sbg=400; output;
  /*--Zone B - Low--*/
  id=9; rfbg=70;   sbg=58.3; output;
  id=9; rfbg=400; sbg=333; output;

  run;
proc print;run;

/*--Add data points--*/
data Plot;
  set grid end=last;
  drop i pi;
  pi=constant('PI');

  output;

  /*--Add simulated data--*/
  if last then do;

    id=.; rfbg=.;  sbg=.;

    /*--Add data in lower zone A--*/
    do i=1 to 200;
      x=40+30*ranuni(2);  y=40+40*ranuni(2); output;
    end;

    /*--Add data all over--*/
    do i=1 to 50;
      x=400*ranuni(2);  y=400*ranuni(2); output;
    end;

    /*--Add data in the middle fan--*/
    do i=1 to 1000;
      x=40+360*ranuni(2);  
          y=x+(x-50)*2*tan(pi/4 *ranuni(2) -pi/8);
          y=ifn(y>400 or y<0, ., y);
      output;
    end;
  end;
run;
/*proc print;run;*/

/*--Assign zones to data points--*/
data plotZone;
  length zone $1;
  label  zone='Clark Error Grid Zone'; 
  drop x1 y1 x2 y2 m1 m2 m3 m4;
  set plot end=last;

  m1=(7/5)*(x-130);  *used for identifying Zone C;
  m2=x+110;          *used for identifying Zone C;

  x1=58.3; y1=70; x2=333;y2=400;
  m3=(y2-y1)/(x2-x1);

  x1=70; y1=58.3; x2=400;y2=333;
  m4=(y2-y1)/(x2-x1);

  if x ne . and y ne . then do;
    if x and y then zone='A';
    if y > m2 then zone='C';
    if y < m2 and y > m3*x then zone='B';
    if y < m4*x then zone='B';
 
    if (130<=x<=180 and y<m1) then zone='C';
    if (x<70 and 70<y<180) or (x>240 and 70<y<180) then zone='D';
    if (x<=70 and y>=180) or (x>=180 and y<=70) then zone='E';
    if x < 70 and y < 70 then zone='A';
    if y < m3*x and y > m4*x then zone='A';
  end;
  output;
run;
/*proc print;run;*/

/*--Count points in the zones--*/
data plotZoneCount;
  set plotZone end=last;
  retain a b c d e 0;
  length label $10;
  format ap bp cp dp ep percent5.1;
  drop d1 d2;

  select (zone);
    when ('A') a+1;
        when ('B') b+1;
        when ('C') c+1;
        when ('D') d+1;
        when ('E') e+1;
        otherwise;
  end;
  output;

  /*--Create region labels with counts--*/
  if last then do;
    total=a+b+c+d+e;
        ap=a/total;
        bp=b/total;
        cp=c/total;
        dp=d/total;
        ep=e/total;

    call missing (x, y);
    d1=5; d2=14;

    /*--Location of zone labels, label text and background box--*/
    xl=20; yl=20; label='A'; low=xl-d1; high=xl+d1; size=.; zone='A'; output;
    xl=20; yl=120; label='D'; low=xl-d1; high=xl+d1; size=.; zone='D';  output;
    xl=20; yl=300; label='E'; low=xl-d1; high=xl+d1; size=.; zone='E';  output;
    xl=100; yl=20; label='B'; low=xl-d1; high=xl+d1; size=.; zone='B';  output;
    xl=170; yl=20; label='C'; low=xl-d1; high=xl+d1; size=.; zone='C';  output;
    xl=100; yl=160; label='B'; low=xl-d1; high=xl+d1; size=.; zone='B';  output;
    xl=320; yl=20; label=cats("E=", put(ep, percent6.1)); low=xl-d2; high=xl+d2;  size=10; zone='E'; output;
    xl=320; yl=120; label=cats('D=', put(dp, percent6.1)); low=xl-d2; high=xl+d2; size=10; zone='D';output;
    xl=320; yl=200; label=cats('B=', put(bp, percent6.1)); low=xl-d2; high=xl+d2; size=10; zone='B';output;
    xl=320; yl=340; label=cats('A=', put(ap, percent6.1)); low=xl-d2; high=xl+d2; size=10; zone='A';output;
    xl=100; yl=320; label=cats('C=', put(cp, percent6.1)); low=xl-d2; high=xl+d2; size=10; zone='C';output;
  end;
run;
/*proc print;run;*/

/*--Attributes Map for zones--*/
data attrmap;
  length id $1 value $1 markercolor $10;
  id='A'; value='A'; markercolor='cx00ef7f'; fillcolor='cx00ef7f';  linecolor='black'; output;
  id='A'; value='B'; markercolor='cx00afdf'; fillcolor='cx00afdf'; linecolor='black'; output;
  id='A'; value='C'; markercolor='gray'; fillcolor='gray';  linecolor='black'; output;
  id='A'; value='D'; markercolor='pink'; fillcolor='pink';  linecolor='black'; output;
  id='A'; value='E'; markercolor='red'; fillcolor='red';  linecolor='black'; output;
run;

/*--Style with blue background--*/
proc template;
   define style styles.blueBG;
      parent = Styles.listing;
          style graphbackground  from graphbackground
             "Abstract colors used in graph styles" /
                 color   = cxf0faff;
   end;
run;

/*--Draw the Full Graph with Attrmap--*/
ods listing style=bluebg;
ods graphics / reset width=5in height=3in antialiasmax=5700 imagename="3_12_1_Clark_Error_Grid_AtMap_SG_V93";
title 'Clark Error Grid for Blood Glucose';
proc sgplot data=plotZoneCount noautolegend dattrmap=attrmap;
  scatter x=x y=y / group=zone attrid=A markerattrs=(symbol=circlefilled size=5);
  series x=rfbg y=sbg / group=id nomissinggroup
         lineattrs=graphdatadefault(color=black) ;
  scatter x=xl y=yl / markerchar=label markercharattrs=(weight=bold);
  xaxis min=0 max=400 offsetmin=0 offsetmax=0 label='Reference Blood Glucose';
  yaxis min=0 max=400 offsetmin=0 offsetmax=0 label='Sensor Blood Glucose';
  run;

/*--Derive style--*/
%modstyle(name=Clark, parent=journal, type=CLM, numberofgroups=5, 
          markers=triangle circle square diamond triangledown);
ods listing style=Clark;
ods graphics / reset width=5in height=3in imagename="3_12_2_Clark_Error_Grid_Journal_SG_V93";
title 'Clark Error Grid for Blood Glucose';
proc sgplot data=plotZoneCount noautolegend /*dattrmap=attrmap*/;
  scatter x=x y=y / group=zone attrid=A markerattrs=(size=5);
  series x=rfbg y=sbg / group=id lineattrs=graphdatadefault(color=black) nomissinggroup;
  bubble x=xl y=yl size=size / bradiusmin=14 bradiusmax=15 fillattrs=(color=white);
  scatter x=xl y=yl / markerchar=label markercharattrs=(size=5 weight=bold);
  xaxis min=0 max=400 offsetmin=0 offsetmax=0 label='Reference Blood Glucose';
  yaxis min=0 max=400 offsetmin=0 offsetmax=0 label='Sensor Blood Glucose';
  run;

title;
footnote;

