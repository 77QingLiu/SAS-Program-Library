%macro AHGreportby(dsn,by,ls=123,ps=45,flow=flow,widthmax=50,which=,
whichlength=,sort=0,groupby=0,groupto=0,topline=,showby=0,
option=nowd nocenter headline,labelopt=%str(option label;));
  %local rptdsn;
  %if %AHGblank(&by) %then %let by=0; 
  %AHGgettempname(rptdsn);
  data &rptdsn;
  %if &by=0 %then
  %do;
  ahuige34xbege5435='_';
  %let by=ahuige34xbege5435;
  %let showby=0;
  %end;
  set &dsn;
run;


  %local i varlist showlist;
  &labelopt;
/*  %if not &showby %then %let showlist=%AHGremoveWords(&varlist,&by,dlm=%str( ));*/
/*  %else %let showlist=&varlist;*/
  %if &sort %then
  %do;
  proc sort data=&rptdsn ; by &by;run;
  %end;
  %AHGvarlist(&rptdsn,Into=varlist,dlm=%str( ),global=0);
  data deletefromithere;
  %AHGvarinfo(&rptdsn,out=varinfo34589,info= name  length);
  data writetofilefromithere;

  %local infostr;
  %AHGcolumn2mac(varinfo34589,infostr,name length);
  %local rdm;
  %let rdm=%AHGrandom;
  %AHGcreatehashex(my&rdm.hash,&infostr);
  %put #####################;
  %let showlist=%AHGremoveWords(&varlist,&by,dlm=%str( ));
  &labelopt;
  
  proc report data=&rptdsn &option ;
    column
    %if %AHGblank(&topline) %then  &by &showlist;
    %else %if %index( %bquote(&topline) , %str( %( )    ) %then &topline;
    %else ( &topline &by &showlist );
    ;
    %do i=1 %to  %AHGcount(&by);
    %if &showby %then
    %do;
    define %scan(&by,&i)/order
    %if not &groupby %then display &flow;
    %else group;
    %end;
    %else  define %scan(&by,&i)/order noprint;

    
    ;
    %end;
    %local loop;
    %let loop=0;
    %do i=1 %to %AHGcount(&showlist);
    %local mylength;
    %local handle thePos;
    %let handle=%scan(&showlist,&i);
    %let mylength=%AHGhashvalue(my&rdm.hash,&handle);
/*    %if &mylength>&widthmax %then %let  mylength=*/
    %let mylength=%sysfunc(min(&widthmax,%sysfunc(max(&mylength,%length(&handle)))));
    define  %scan(&showlist,&i)  /
        %if %sysfunc(indexw(&which,&i))  %then %do;%let loop=%eval(&loop+1);width=%scan(&whichlength,%AHGindex(&which,&i))   %end;
    %else %str(width=)&mylength;
        %if &i<=&groupto %then group;
        %else display &flow;
          ;
    %end;
    by &by;


/*  compute before _page_ ;*/
/*        line @1 &ls.*"_";*/
/*    line @1 " ";*/
/*    endcomp;*/
/**/
/*  compute after _page_;*/
/*        line @1 &ls.*"_";*/
/*    endcomp;    */
  run;
  
%mend;
