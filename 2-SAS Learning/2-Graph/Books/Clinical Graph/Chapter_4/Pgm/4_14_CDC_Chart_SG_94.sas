%let gpath='.';     /*--Put your Folder Name here--*/
%let dpi=300;
ods html close;
filename CDC_Data '4_14_CDC_Cleaned.csv';  /*--Put file name for data here--*/

proc format;
  value sex 
    1='Male'
        2='Female';
        run;

proc format;
  value age 
    1='Birth'
        run;

proc template;
   define style styles.cdc;
      parent = Styles.listing;

          style color_list from color_list
             "Abstract colors used in graph styles" /
                 'bgA'   = cxe0e7ef;
   end;
run;


/*proc print data=data.cdc_merged (where=(sex=1));*/
/*run;*/
/*proc print;run;*/

/*--Read data from CSV file--*/
proc import datafile=CDC_Data
                        out=cdc_data
            dbms=csv replace;
/*            dbms=csv;*/
run;

/*ods html;*/
/*proc print noobs;*/
/*  var sex agemos W5 w25 w75 w95 h5 h25 h75 h95;*/
/*run;*/
/*ods html close;*/

data cdc_cleaned;
  label agemos='Age in Months';
  set cdc_data;
  format sex sex.;
  run;

/*ods html;*/
/*proc print noobs;*/
/*  var sex agemos W5 w25 w75 w95 h5 h25 h75 h95;*/
/*run;*/
/*ods html close;*/

/*--Add labels to the last point--*/
data cdc_cleaned_plus;
    set cdc_cleaned (where=(sex=1)) end=last;
    
    if last then do;
          l5='..5'; l10='10'; l25='25'; l50='50'; l75='75'; l90='90'; l95='95';
      l5=translate(l5, 'A0'x, '.');
          output;
        end;
        else do;
          output;
        end;
  run;
/*proc print;run;*/

/*--Create some patient data--*/
data patient;
  input Sex Age Height Weight;
  datalines;
1  0  52  3.5
1  3  63  6.5
1  6  68  8.5
1  9  72  9.5
1 12  75 10.5
2  0  52  3.5
2  3  63  6.5
2  6  68  8.5
2  9  72  9.5
2 12  75 10.5
;
run;


data Chart_Patient;
  set cdc_cleaned_plus patient;
  run;

/*ods html;*/
/*proc print data=Chart_Patient(firstobs=36 obs=39);*/
/*  var sex agemos W5 w50 w95 h5 h50 h95 age height weight;*/
/*run;*/
/*ods html close;*/

ods listing style=styles.cdc gpath=&gpath image_dpi=&dpi;
ods graphics / reset width=5in height=6in imagename='4_14_1_CDC_SG_V94';
title j=l h=9pt 'Birth to 36 months: Boys' j=r "Name:  John Smith";
title2 j=l h=8pt "Length-for-age and Weight-for-age percentiles" j=r "Record # 12345-67890";
footnote j=l h=7pt "Published May 30, 2000 (modified 4/20/01) CDC";
proc sgplot data=Chart_Patient noautolegend;
  where sex=1;
        refline 3 4 5 6 / axis=y2 lineattrs=graphgridlines;

        /*--Curve bands--*/
    band x=agemos lower=w5  upper=w95 / y2axis fillattrs=graphdata1 transparency=0.9;
    band x=agemos lower=w10 upper=w90 / y2axis fillattrs=graphdata1 transparency=0.8;
    band x=agemos lower=w25 upper=w75 / y2axis fillattrs=graphdata1 transparency=0.8;

        /*--Curves--*/
    series x=agemos y=w5 / y2axis lineattrs=graphdata1 transparency=0.5;
    series x=agemos y=w10 / y2axis lineattrs=graphdata1 transparency=0.7;
    series x=agemos y=w25 / y2axis lineattrs=graphdata1 transparency=0.7;
    series x=agemos y=w50 / y2axis x2axis lineattrs=graphdata1;
    series x=agemos y=w75 / y2axis lineattrs=graphdata1 transparency=0.7;
    series x=agemos y=w90 / y2axis lineattrs=graphdata1 transparency=0.7 ;
    series x=agemos y=w95 / y2axis lineattrs=graphdata1 transparency=0.5;

        /*--Curve labels--*/
        text x=agemos y=w5  text=l5  / y2axis textattrs=graphdata1 position=bottomright;
        text x=agemos y=w10 text=l10 / y2axis textattrs=graphdata1 position=right;
        text x=agemos y=w25 text=l25 / y2axis textattrs=graphdata1 position=right;
        text x=agemos y=w50 text=l50 / y2axis textattrs=graphdata1 position=right;
        text x=agemos y=w75 text=l75 / y2axis textattrs=graphdata1 position=right;
        text x=agemos y=w90 text=l90 / y2axis textattrs=graphdata1 position=right;
        text x=agemos y=w95 text=l95 / y2axis textattrs=graphdata1 position=topright;

        /*--Patient datas--*/
        series x=age y=weight / y2axis lineattrs=graphdata1(thickness=2) 
                            markers markerattrs=(symbol=circlefilled size=11)
                            filledoutlinedmarkers markerfillattrs=(color=white)
                            markeroutlineattrs=graphdata1(thickness=2);

        /*--Curve bands--*/
        band x=agemos lower=h5  upper=h95 / fillattrs=graphdata3 transparency=0.9;
    band x=agemos lower=h10 upper=h90 / fillattrs=graphdata3 transparency=0.8;
    band x=agemos lower=h25 upper=h75 / fillattrs=graphdata3 transparency=0.8;

        /*--Curves--*/
    series x=agemos y=h5 / lineattrs=graphdata3(pattern=solid) transparency=0.5; 
    series x=agemos y=h10 / lineattrs=graphdata3(pattern=solid) transparency=0.7;
    series x=agemos y=h25 / lineattrs=graphdata3(pattern=solid) transparency=0.7;
    series x=agemos y=h50 / x2axis lineattrs=graphdata3(pattern=solid);
    series x=agemos y=h75 / lineattrs=graphdata3(pattern=solid) transparency=0.7;
    series x=agemos y=h90 / lineattrs=graphdata3(pattern=solid)transparency=0.7;
    series x=agemos y=h95 / lineattrs=graphdata3(pattern=solid) transparency=0.5;

        /*--Curve labels--*/
        text x=agemos y=h5  text=l5  / textattrs=graphdata3 position=bottomright;
        text x=agemos y=h10 text=l10 / textattrs=graphdata3 position=right;
        text x=agemos y=h25 text=l25 / textattrs=graphdata3 position=right;
        text x=agemos y=h50 text=l50 / textattrs=graphdata3 position=right;
        text x=agemos y=h75 text=l75 / textattrs=graphdata3 position=right;
        text x=agemos y=h90 text=l90 / textattrs=graphdata3 position=right;
        text x=agemos y=h95 text=l95 / textattrs=graphdata3 position=topright;

        /*--Patient datas--*/
    series x=age y=height / lineattrs=graphdata3(pattern=solid thickness=2) 
                            markers markerattrs=(symbol=circlefilled size=11)
                            filledoutlinedmarkers markerfillattrs=(color=white)
                            markeroutlineattrs=graphdata3(thickness=2);
        /*--Table--*/
    inset "    Date      Age(Mos)   Wt(Kg)  Ln(Cm)"
          "04 May 2010    Birth      3.5     52" 
              "02 Aug 2010      3        6.5     63"
                  "01 Nov 2010      6        8.5     68"
                  "07 Feb 2011      9        9.5     72"
          "02 May 2011     12       10.5     75" / 
           border textattrs=(family='Courier' size=6 weight=bold) position=bottomright;
 
        xaxis grid offsetmin=0  integer values=(0 to 36 by 3);
        x2axis grid offsetmin=0 integer values=(0 to 36 by 3);
        yaxis  grid offsetmin=0.236 offsetmax=0.014 label="Length (Cm)" integer 
               values=(30 to 110 by 5) labelattrs=graphdata3(weight=bold) valueattrs=graphdata3;
        y2axis offsetmin=0.0 offsetmax=0.25 label="Weight (Kg)" integer 
               values=(2 to 18 by 1) labelattrs=graphdata1(weight=bold) valueattrs=graphdata1;
run;
title;
footnote;



