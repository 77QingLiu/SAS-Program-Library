%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods html close;
ods listing gpath=&gpath image_dpi=&dpi;

data Incidence;
  drop fac c1 c2 c3 c4;
  label Incidence='Incidence of Erythema';

  fac=1;
  c1=ranuni(2); c2=ranuni(2); c3=ranuni(2); c4=ranuni(2);
  do Time= 'Immediate', '10 Min', '20 Min', '30 Min', '60 Min', '2 Hr', '4 Hr', '8 hr', 
           '24 Hr', '72 Hr';
        Group='Cohort 1'; Incidence=c1*(fac*(1+ranuni(2)*0.1)); output;
        Group='Cohort 2'; Incidence=c2*(fac*(1-ranuni(2)*0.1)); output;
        Group='Cohort 3'; Incidence=c3*(fac*(1+ranuni(2)*0.12)); output;
        Group='Cohort 4'; Incidence=c4*(fac*(1-ranuni(2)*0.13)); output;
   
    fac = 0.6*fac;
  end;
run;

/*ods html;*/
/*proc print data=incidence(obs=4);*/
/*var Time Group Incidence;*/
/*run;*/
/*ods html close;*/

/*--Incidence graph--*/
ods graphics / reset width=5in height=3in imagename='4_10_1_Injection_Site_Reaction_SG_V94';
title 'Incidence of Injection-site Reaction by Time and Cohort - Erythema';
title2 'As-treated Population';
ods listing style=listing;
proc sgplot data=Incidence nowall noborder;
  styleattrs datacolors=(gray pink lightgreen lightblue ) datacontrastcolors=(black);
  vbar time / response=incidence group=group groupdisplay=cluster baselineattrs=(thickness=0);
  xaxis discreteorder=data valueattrs=(size=8) fitpolicy=none display=(nolabel);
  yaxis grid display=(noticks);
  keylegend / title='' location=inside position=topright across=1 border autoitemsize valueattrs=(size=8);
run;
title;

/*--Incidence graph Gray scale with fill patterns--*/
ods graphics / reset width=5in height=3in imagename='4_10_2_Injection_Site_Reaction_Journal_SG_V94';
title 'Incidence of Injection-site Reaction by Time and Cohort - Erythema';
title2 'As-treated Population';
ods listing style=Journal2;
proc sgplot data=Incidence nowall noborder;
  styleattrs datacolors=(gray pink lightgreen lightblue ) datacontrastcolors=(black)
             axisextent=data;
  vbar time / response=incidence group=group groupdisplay=cluster 
              baselineattrs=(thickness=0) outlineattrs=(color=gray);
  xaxis discreteorder=data valueattrs=(size=8) fitpolicy=none display=(nolabel);
  yaxis offsetmin=0.04 grid display=(noticks);
  keylegend / title='' location=inside position=topright across=1 border autoitemsize valueattrs=(size=8);
run;
title;

/*--Incidence graph color with fill patterns--*/
ods graphics / reset width=5in height=3in imagename='4_10_3_Injection_Site_Reaction_Axis__SG_V94';
title 'Incidence of Injection-site Reaction by Time and Cohort - Erythema';
title2 'As-treated Population';
ods listing style=Journal3;
proc sgplot data=Incidence nowall noborder;
  styleattrs datacolors=(gray pink lightgreen lightblue ) datacontrastcolors=(black)
             axisextent=data;
  vbar time / response=incidence group=group groupdisplay=cluster 
              baselineattrs=(thickness=0) outlineattrs=(color=gray);
  xaxis discreteorder=data valueattrs=(size=8) fitpolicy=none display=(nolabel);
  yaxis offsetmin=0.04 grid display=(noticks);
  keylegend / title='' location=inside position=topright across=1 border autoitemsize valueattrs=(size=8);
run;
title;


