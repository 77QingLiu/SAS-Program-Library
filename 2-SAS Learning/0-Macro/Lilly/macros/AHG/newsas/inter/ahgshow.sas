%macro AHGshow(words);
/*%local id;*/
/*%let id=%sysfunc(translate(%sysfunc(normal(0)),12,.-));*/
/*%window AHG&id  color=white*/
/*           #5 @28 "&words" attr=highlight*/
/*              color=red ;*/
/*%display AHG&id;*/
%let words=%sysfunc(compbl(&words));
%local i LineNum word lg lineCount;
%let lg=%length(&words);
%let lineCount=%sysfunc(ceil(&lg/60));
/*%do i=1 %to %eval(&lineCount+1);*/
/*%end;*/


data _null_;
   window start
          #5 @28 '  '
            
%do i=0 %to  %eval(&lineCount-1);
%if &i ne &linecount-1 %then #%eval(12+&i) @10 "%substr(&words,%eval(&i*60+1),60)";
%else #%eval(12+&i) @1 "%substr(&words,%eval(&i*60+1))";

%end;
;
          
   display start;
/*   stop;*/
run;

%mend;
 
