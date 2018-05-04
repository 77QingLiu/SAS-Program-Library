%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods html close;
ods listing gpath=&gpath image_dpi=&dpi;

data swimmer;
  input Item Stage $4-12 Low High Highcap $25-40 Status $40-60 Start End Durable;
  Startline=start; Endline=end;
  if status ne ' ' then do;
    if end eq . then endline=high-0.3;
    if start eq . then startline=low+0.3;
  end;
  if stage eq ' ' then durable=.;
  Xmin=0; 
  if item then xmin=.;
  datalines;
1  Stage 1  0  18.5                     Complete response      6.5  13.5  -0.25
2  Stage 2  0  17.0                     Complete response     10.5  17.0  -0.25
3  Stage 3  0  14.0     FilledArrow     Partial response       2.5   3.5  -0.25
3           0  14.0     FilledArrow     Partial response       6.0     .  -0.25
4  Stage 4  0  13.5     FilledArrow     Partial response       7.0  11.0     .
4           0  13.5     FilledArrow     Partial response      11.5     .     .
5  Stage 1  0  12.5     FilledArrow     Complete response      3.5   4.5  -0.25
5           0  12.5     FilledArrow     Complete response      6.5   8.5  -0.25
5           0  12.5     FilledArrow     Partial response      10.5     .  -0.25
6  Stage 2  0  12.6     FilledArrow     Partial response       2.5   7.0     .
6           0  12.6     FilledArrow     Partial response       9.5     .     .
7  Stage 3  0  11.5                     Complete response      4.5  11.5  -0.25
8  Stage 1  0   9.5                     Complete response      1.0   9.5  -0.25
9  Stage 4  0   8.3                     Partial response       6.0     .     .
10 Stage 2  0   4.2     FilledArrow     Complete response      1.2     .     .
.           0   4.2                     Complete response      .       .     .
;
run;

/*ods html;*/
/*proc print;run;*/
/*ods html close;*/

data attrmap;
length ID $ 9 LineColor MarkerColor $ 20 LinePattern $10;
input id $ Value $10-30 linecolor $ markercolor linepattern $;
datalines;
statusC   Complete response    darkred   darkred solid
statusC   Partial response     blue      blue    solid
statusJ   Complete response    black     black   solid
statusJ   Partial response     black     black   shortdash
;
run;

/*ods html;*/
/*proc print;run;*/
/*ods html close;*/

/*--Swimmer Graph--*/
ods listing style=HTMLBlue;
ods graphics / reset width=5in height=3in imagename="4_13_1_Swimmer_SG_V94";
footnote  J=l h=0.8 'Each bar represents one subject in the study.  Right arrow cap indicates continued response.';
footnote2 J=l h=0.8 'A durable responder is a subject who has confirmed response for at least 183 days (6 months).';
title 'Tumor Response for Subjects in Study by Month';
proc sgplot data= swimmer dattrmap=attrmap nocycleattrs;
  highlow y=item low=low high=high / highcap=highcap type=bar group=stage fill nooutline
          lineattrs=(color=black) name='stage' barwidth=1 nomissinggroup transparency=0.3;
  highlow y=item low=startline high=endline / group=status lineattrs=(thickness=2 pattern=solid) 
          name='status' nomissinggroup attrid=statusC;
  scatter y=item x=start / markerattrs=(symbol=trianglefilled size=8 color=darkgray) name='s' legendlabel='Response start';
  scatter y=item x=end / markerattrs=(symbol=circlefilled size=8 color=darkgray) name='e' legendlabel='Response end';
  scatter y=item x=xmin / markerattrs=(symbol=trianglerightfilled size=12 color=darkgray) name='x' legendlabel='Continued response ';
  scatter y=item x=durable / markerattrs=(symbol=squarefilled size=6 color=black) name='d' legendlabel='Durable responder';
  scatter y=item x=start / markerattrs=(symbol=trianglefilled size=8) group=status attrid=statusC;
  scatter y=item x=end / markerattrs=(symbol=circlefilled size=8) group=status attrid=statusC;
  xaxis display=(nolabel) label='Months' values=(0 to 20 by 1) valueshint;
  yaxis reverse display=(noticks novalues noline) label='Subjects Received Study Drug';
  keylegend 'stage' / title='Disease Stage';
  keylegend 'status' 's' 'e' 'd' 'x'/ noborder location=inside position=bottomright 
             across=1 linelength=20;
  run;
footnote;

/*--Swimmer Graph Grayscale--*/
ods listing style=journal;
ods graphics on / reset height=3.5in width=6in imagename='4_13_2_Swimmer_SG_V94'; 
footnote  J=l h=0.8 'Each bar represents one subject in the study.  Right arrow cap indicates continued response.';
footnote2 J=l h=0.8 'A durable responder is a subject who has confirmed response for at least 183 days (6 months).';
title 'Tumor Response for Subjects in Study by Month';
proc sgplot data= swimmer dattrmap=attrmap nocycleattrs;
  styleattrs datalinepatterns=(solid shortdash);
  highlow y=item low=low high=high / highcap=highcap type=bar group=stage fill nooutline
          lineattrs=(color=black) fillattrs=(color=lightgray) name='stage' barwidth=1 
          nomissinggroup;
  highlow y=item low=startline high=endline / group=status lineattrs=(thickness=2) 
          name='status' nomissinggroup  attrid=statusJ;
  scatter y=item x=start / markerattrs=(symbol=trianglefilled size=8) name='s' legendlabel='Response start';
  scatter y=item x=end / markerattrs=(symbol=circlefilled size=8) name='e' legendlabel='Response end';
  scatter y=item x=xmin / markerattrs=(symbol=trianglerightfilled size=12 color=darkgray) name='x' legendlabel='Continued response ';
  scatter y=item x=durable / markerattrs=(symbol=squarefilled size=6 color=black) name='d' legendlabel='Durable responder';
  scatter y=item x=start / markerattrs=(symbol=trianglefilled size=8) group=status attrid=statusJ;
  scatter y=item x=end / markerattrs=(symbol=circlefilled size=8) group=status attrid=statusJ;
  yaxistable stage / location=inside position=left nolabel;
  xaxis display=(nolabel) label='Months' values=(0 to 20 by 1) valueshint;
  yaxis reverse display=(noticks novalues noline) label='Subjects Received Study Drug';
  keylegend 'status' 's' 'e' 'd' 'x' / noborder location=inside position=bottomright 
             across=1 linelength=20;
  run;
footnote;


title;
footnote;

