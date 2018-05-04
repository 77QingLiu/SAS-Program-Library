%macro AHGfiledt(file,into=,dtfmt=yymmdd10.,tmfmt=time5.);
  %local date time datetime  thetime;
  %if %sysfunc(fileexist(&file)) %then
  %do;
  %AHGpipe(dir &file /tw,rcmac=thetime,start=6,end=6);
  %let date=%sysfunc(putn(%sysfunc(inputn(%substr(%bquote(&thetime),1,10),&dtfmt)),yymmdd10.));
  %let time=%sysfunc(putn(%sysfunc(inputn(%substr(%bquote(&thetime),11,6),&tmfmt)),time5.));

  %let &into=%sysfunc(translate(&date &time,___,:-%str( )));
  %end; 
%mend;

