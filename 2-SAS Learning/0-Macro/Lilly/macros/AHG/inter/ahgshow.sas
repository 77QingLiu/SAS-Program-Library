%macro AHGshow(words);
/*%local id;*/
/*%let id=%sysfunc(translate(%sysfunc(normal(0)),12,.-));*/
/*%window AHG&id  color=white*/
/*           #5 @28 "&words" attr=highlight*/
/*              color=red ;*/
/*%display AHG&id;*/

data _null_;
   window start
          #5 @28 'A message to read'
          #12 @30 "&words";
   display start;
/*   stop;*/
run;

%mend;


