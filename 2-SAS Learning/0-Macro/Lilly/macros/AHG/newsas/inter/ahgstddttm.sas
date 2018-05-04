%macro AHGstddttm(date/*2008/11/13 06:19:48*/,shift=-8,outdate=);
  data _null_;
    date="&date";
    hour=substr(date,12,2)+0;

    if hour&shift<0 then datepart=input(substr(date,1,10),yymmdd10.)-1; 
    else if hour&shift>23 then datepart=input(substr(date,1,10),yymmdd10.)+1;
    else datepart=input(substr(date,1,10),yymmdd10.);

    hour=mod(hour+24&shift,24);
    substr(date,1,10)=put(datepart,yymmdd10.);
    substr(date,12,2)=put(hour,z2.);
    date=tranwrd(date,'-','/');
    put date=;
    %if &outdate ne %then call symput("&outdate",date);;
    
  run;

/*    format datetime datetime20.;*/
/*    date=input(substr("&date",1,10),yymmdd10.);*/
/*    time=input(substr("&date",12,8),time8.);*/
/*    datetimestr=put(date,date9.)||put(time,time8.);*/
/*    datetime=input(datetimestr,datetime20.);*/
/*    datetime=intnx('hour',datetime,&shift);*/
/*    str=put(datetime,);*/
/*    put datetimestr= datetime= ;*/
/*  run;*/

%mend;
