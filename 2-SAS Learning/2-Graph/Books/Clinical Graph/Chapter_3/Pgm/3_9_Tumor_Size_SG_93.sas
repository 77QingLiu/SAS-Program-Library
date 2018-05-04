%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods html close;
ods listing gpath=&gpath image_dpi=&dpi;

data TumorSize;
  length Cid $ 3;
  label Change='Change from Baseline (%)';
  do Id=1 to 25;
    cid=put(id, 2.0);
    change=30-120*ranuni(2);
        Group=ifc(int(ranuni(2)+0.5), 'Treatment 1', 'Treatment 2');
        if mod(id, 5) = 1 then Label='C';
        if mod(id, 5) = 2 then label='R';
        if mod(id, 5) = 3 then label='S';
        if mod(id, 5) = 4 then label='P';
        if mod(id, 5) = 0 then label='N';
        output;
  end;
run;

/*ods html;*/
/*proc print data=TumorSize(obs=5);*/
/*run;*/
/*ods html close;*/

/*--Sort data by change--*/
proc sort data=TumorSize out=TumorSizeSorted;
  by  descending change;
  run;
proc print;run;

/*--Derive style--*/
%modstyle(name=waterfall_1, parent=listing, type=CLM, numberofgroups=2, 
          colors=black black, fillcolors=cxbf0000 cx4f4f4f);

/*--Change in Tumor Size--*/
ods listing style=Waterfall_1;
ods graphics / reset width=5in height=3in imagename='3_9_1_TumorSize_SG_V93';
title 'Change in Tumor Size';
title2 'ITT Population';
proc sgplot data=TumorSizeSorted;
  vbar cid / response=change group=group datalabel=label 
             datalabelattrs=(size=5 weight=bold) groupdisplay=cluster clusterwidth=1;
  refline 20 -30 / lineattrs=(pattern=shortdash);
  xaxis display=none discreteorder=data;
  yaxis values=(60 to -100 by -20);
  inset ("C="="CR" "R="="PR" "S="="SD" "P="="PD" "N="="NE") / title='BCR' 
        position=bottomleft border textattrs=(size=6 weight=bold) titleattrs=(size=7);
  keylegend / title='' location=inside position=topright across=1 border;
run;
title;

proc sort data=TumorSize out=TumorSizeDesc;
  by descending change;
run;

/*--Derive style--*/
%modstyle(name=waterfall_2, parent=listing, type=CLM, numberofgroups=2, 
          colors=black black, fillcolors=cxbf0000 gold);

ods listing style=waterfall_2;
ods graphics / reset width=5in height=3in imagename='3_9_3_TumorSize_SG_V93';
title 'Change in Tumor Size';
title2 'ITT Population';
proc sgplot data=TumorSizeSorted ;
  band x=cid upper=20 lower=-30 / transparency=0.5 fill nooutline legendlabel='Confidence';
  vbarparm category=cid  response=change / group=group datalabel=label
             datalabelattrs=(size=5 weight=bold) dataskin=pressed;
  xaxis display=none;
  yaxis values=(60 to -100 by -20) grid;
  inset ("C="="CR" "R="="PR" "S="="SD" "P="="PD" "N="="NE") / title='BCR'
        position=bottomleft border textattrs=(size=6 weight=bold) titleattrs=(size=7);
  keylegend / title='' location=inside position=topright across=1 border;
run;
title;
