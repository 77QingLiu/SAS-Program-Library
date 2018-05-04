%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods listing style=htmlblue image_dpi=&dpi gpath=&gpath; 
ods html close;

data immune;
format sival f6.3;
input trt $ 1-8 cyc $ 10-18 pt lbparm $ xval sival;
cards;
Drug A   Cycle 1   1   C3  1   1.120
Drug A   Cycle 1   1   C4  1   0.147
Drug A   Cycle 1   1   C3  2   1.080
Drug A   Cycle 1   1   C4  2   0.131
Drug A   Cycle 1   1   C3  3   0.887
Drug A   Cycle 1   1   C4  3   0.113
Drug A   Cycle 2   1   C3  4   1.440
Drug A   Cycle 2   1   C4  4   0.278
Drug A   Cycle 2   1   C3  5   1.180
Drug A   Cycle 2   1   C4  5   0.234
Drug A   Cycle 2   1   C3  6   1.360
Drug A   Cycle 2   1   C4  6   0.281
Drug A   Cycle 3   1   C3  7   1.190
Drug A   Cycle 3   1   C4  7   0.282
Drug A   Cycle 3   1   C3  8   1.000
Drug A   Cycle 3   1   C4  8   0.228
Drug A   Cycle 3   1   C3  9   1.040
Drug A   Cycle 3   1   C4  9   0.228
Drug A   Cycle 4   1   C3 10   0.917
Drug A   Cycle 4   1   C4 10   0.163
Drug A   Cycle 4   1   C3 11   0.789
Drug A   Cycle 4   1   C4 11   0.136
Drug A   Cycle 4   1   C3 12   0.861
Drug A   Cycle 4   1   C4 12   0.148
Drug A   Cycle 1   2   C3  1   1.180
Drug A   Cycle 1   2   C4  1   0.264
Drug A   Cycle 1   2   C3  2   0.942
Drug A   Cycle 1   2   C4  2   0.184
Drug A   Cycle 1   2   C3  3   1.010
Drug A   Cycle 1   2   C4  3   0.160
Drug A   Cycle 2   2   C3  4   1.050
Drug A   Cycle 2   2   C4  4   0.134
Drug A   Cycle 2   2   C3  5   0.980
Drug A   Cycle 2   2   C4  5   0.120
Drug A   Cycle 2   2   C3  6   1.020
Drug A   Cycle 2   2   C4  6   0.126
Drug A   Cycle 3   2   C3  7   0.961
Drug A   Cycle 3   2   C4  7   0.110
Drug A   Cycle 3   2   C3  8   0.859
Drug A   Cycle 3   2   C4  8   0.091
Drug A   Cycle 3   2   C3  9   0.928
Drug A   Cycle 3   2   C4  9   0.097
Drug A   Cycle 4   2   C3 10   1.380
Drug A   Cycle 4   2   C4 10   0.330
Drug A   Cycle 4   2   C3 11   1.210
Drug A   Cycle 4   2   C4 11   0.281
Drug A   Cycle 4   2   C3 12   1.180
Drug A   Cycle 4   2   C4 12   0.278
Drug A   Cycle 1   3   C3  1   1.180
Drug A   Cycle 1   3   C4  1   0.269
Drug A   Cycle 1   3   C3  2   1.010
Drug A   Cycle 1   3   C4  2   0.213
Drug A   Cycle 1   3   C3  3   1.040
Drug A   Cycle 1   3   C4  3   0.200
Drug A   Cycle 2   3   C3  4   1.200
Drug A   Cycle 2   3   C4  4   0.332
Drug A   Cycle 2   3   C4  5   0.371
Drug A   Cycle 2   3   C4  6   0.316
Drug A   Cycle 3   3   C4  7   0.271
Drug A   Cycle 3   3   C3  8   1.050
Drug A   Cycle 3   3   C4  8   0.246
Drug A   Cycle 3   3   C3  9   1.100
Drug A   Cycle 3   3   C4  9   0.248
Drug A   Cycle 4   3   C3 10   1.090
Drug A   Cycle 4   3   C4 10   0.234
Drug A   Cycle 4   3   C3 11   0.937
Drug A   Cycle 4   3   C3 12   0.980
Drug A   Cycle 1   4   C3  1   1.220
Drug A   Cycle 1   4   C4  1   0.182
Drug A   Cycle 1   4   C3  2   0.983
Drug A   Cycle 1   4   C4  2   0.132
Drug A   Cycle 1   4   C3  3   0.979
Drug A   Cycle 1   4   C4  3   0.128
Drug A   Cycle 2   4   C3  4   1.190
Drug A   Cycle 2   4   C4  4   0.134
Drug A   Cycle 2   4   C3  5   1.010
Drug A   Cycle 2   4   C4  5   0.076
Drug A   Cycle 2   4   C3  6   1.100
Drug A   Cycle 2   4   C4  6   0.083
Drug A   Cycle 3   4   C3  7   1.140
Drug A   Cycle 3   4   C4  7   0.108
Drug A   Cycle 3   4   C3  8   1.140
Drug A   Cycle 3   4   C4  8   0.104
Drug A   Cycle 3   4   C3  9   1.120
Drug A   Cycle 3   4   C4  9   0.083
Drug B   Cycle 1   5   C3  1   1.130
Drug B   Cycle 1   5   C4  1   0.220
Drug B   Cycle 1   5   C3  2   0.910
Drug B   Cycle 1   5   C4  2   0.131
Drug B   Cycle 1   5   C3  3   0.879
Drug B   Cycle 1   5   C4  3   0.053
Drug B   Cycle 2   5   C3  4   1.590
Drug B   Cycle 2   5   C4  4   0.100
Drug B   Cycle 2   5   C3  5   1.380
Drug B   Cycle 2   5   C4  5   0.077
Drug B   Cycle 2   5   C3  6   1.330
Drug B   Cycle 2   5   C4  6   0.071
Drug B   Cycle 3   5   C3  7   0.888
Drug B   Cycle 3   5   C4  7   0.071
Drug B   Cycle 3   5   C3  8   0.873
Drug B   Cycle 3   5   C4  8   0.065
Drug B   Cycle 4   5   C3 10   0.920
Drug B   Cycle 4   5   C4 10   0.113
Drug B   Cycle 4   5   C3 11   0.795
Drug B   Cycle 4   5   C4 11   0.102
Drug B   Cycle 1   6   C3  1   1.330
Drug B   Cycle 1   6   C4  1   0.197
Drug B   Cycle 1   6   C3  2   1.210
Drug B   Cycle 1   6   C4  2   0.169
Drug B   Cycle 1   6   C3  3   0.987
Drug B   Cycle 1   6   C4  3   0.127
Drug B   Cycle 2   6   C3  4   1.220
Drug B   Cycle 2   6   C4  4   0.214
Drug B   Cycle 2   6   C3  5   1.010
Drug B   Cycle 2   6   C4  5   0.157
Drug B   Cycle 2   6   C3  6   1.050
Drug B   Cycle 2   6   C4  6   0.167
Drug B   Cycle 3   6   C3  7   1.520
Drug B   Cycle 3   6   C4  7   0.262
Drug B   Cycle 3   6   C3  8   1.450
Drug B   Cycle 3   6   C4  8   0.304
Drug B   Cycle 3   6   C3  9   1.420
Drug B   Cycle 3   6   C4  9   0.281
Drug B   Cycle 4   6   C3 10   1.120
Drug B   Cycle 4   6   C4 10   0.147
Drug B   Cycle 4   6   C3 11   0.995
Drug B   Cycle 4   6   C4 11   0.129
Drug B   Cycle 4   6   C3 12   0.955
Drug B   Cycle 4   6   C4 12   0.121
Drug B   Cycle 1   7   C3  1   1.170
Drug B   Cycle 1   7   C3  2   0.861
Drug B   Cycle 1   7   C3  3   0.780
Drug B   Cycle 2   7   C3  4   1.030
Drug B   Cycle 2   7   C4  4   0.114
Drug B   Cycle 2   7   C3  5   0.944
Drug B   Cycle 2   7   C4  5   0.094
Drug B   Cycle 2   7   C3  6   1.010
Drug B   Cycle 2   7   C4  6   0.087
Drug B   Cycle 3   7   C3  7   0.932
Drug B   Cycle 3   7   C4  7   0.090
Drug B   Cycle 3   7   C3  8   0.830
Drug B   Cycle 3   7   C4  8   0.081
Drug B   Cycle 3   7   C3  9   0.896
Drug B   Cycle 3   7   C4  9   0.075
Drug B   Cycle 4   7   C3 10   1.030
Drug B   Cycle 4   7   C4 10   0.162
Drug B   Cycle 4   7   C3 11   0.931
Drug B   Cycle 4   7   C4 11   0.143
Drug B   Cycle 4   7   C3 12   1.100
Drug B   Cycle 4   7   C4 12   0.181
Drug B   Cycle 1   8   C3  1   1.220
Drug B   Cycle 1   8   C3  2   1.090
Drug B   Cycle 1   8   C3  3   1.040
Drug B   Cycle 2   8   C3  4   .
Drug B   Cycle 2   8   C3  5   0.607
Drug B   Cycle 2   8   C4  5   0.145
Drug B   Cycle 2   8   C3  6   1.110
Drug B   Cycle 2   8   C4  6   0.199
Drug B   Cycle 3   8   C3  7   1.070
Drug B   Cycle 3   8   C4  7   0.097
Drug B   Cycle 3   8   C3  8   0.930
Drug B   Cycle 3   8   C4  8   0.060
Drug B   Cycle 3   8   C3  9   0.941
Drug B   Cycle 3   8   C4  9   0.054
Drug B   Cycle 4   8   C3 10   1.130
Drug B   Cycle 4   8   C4 10   0.253
Drug B   Cycle 4   8   C3 11   1.130
Drug B   Cycle 4   8   C4 11   0.220
Drug B   Cycle 4   8   C3 12   1.030
Drug B   Cycle 4   8   C4 12   0.196
;
run;


proc sort data=immune out=immune2;
by xval;
run;

/*--Immunology Panel--*/
ods graphics / reset width=6in height=2.7in  imagename="5_2_1_Immunology";
title "Immunology Profile";
proc sgpanel data=immune2;
  panelby trt lbparm / layout=lattice novarname uniscale=column;
  block x=xval block=cyc / transparency = .75 filltype=alternate valueattrs=(size=8);
  series x=xval y=sival / group=pt name='a' markers
          lineattrs=(thickness=2) markerattrs=(symbol=circlefilled);    

  colaxis values=(1 to 12 by 1) integer label='Cycle Day'
          valuesdisplay=("0" "15" "30" "0" "15" "30" "0" "15" "30" "0" "15" "30");
  rowaxis offsetmax=.1 label="Values Converted to SI Units " grid;

  keylegend 'a' / title="Patient:";
  run;

/*--Immunology Panel Journal--*/
ods graphics / reset width=6in height=2.7in  imagename="5_2_2_Immunology_Journal";
ods listing style=journal;
title "Immunology Profile";
proc sgpanel data=immune2;
  styleattrs datasymbols=(circlefilled trianglefilled diamondfilled triangledownfilled
                          circle triangle diamond triangledown);
  panelby trt lbparm / layout=lattice novarname uniscale=column;
  block x=xval block=cyc / filltype=alternate valueattrs=(size=8)
        altfillattrs=(color=white);
  series x=xval y=sival / group=pt name='a' markers lineattrs=(pattern=solid)
         markerattrs=(size=8 color=cx2f2f2f);    

  colaxis values=(1 to 12 by 1) integer label='Cycle Day'
          valuesdisplay=("0" "15" "30" "0" "15" "30" "0" "15" "30" "0" "15" "30");
  rowaxis offsetmax=.1 label="Values Converted to SI Units " grid;

  keylegend 'a' / title="Patient:";
  run;


