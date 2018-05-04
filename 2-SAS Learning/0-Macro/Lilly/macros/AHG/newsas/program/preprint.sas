
%macro prePrint;

%local adict adict2;
proc sql noprint;
  select distinct put(mv,5.1), cv into :adict, :adict2
  from
  (
  select distinct max(input(tranwrd(adict,'MedDRA v',''),best.)) as mv, put(left(tranwrd(adict2,'CTCAE','')),$3.) as cv
  from adam.adae
  
  )
  ;
  quit;
title ;footnote;

data meta_tfl_dict;
  set specs.meta_tfl;
  where strip(upcase(display_identifier))=strip(upcase("&spec_name"));
  ABBREVIATIONS_FOOTNOTE=PRXCHANGE("s/(MedDRA\s*Version\s*)x+\.x+/\1&adict/i",-1,ABBREVIATIONS_FOOTNOTE);
  ABBREVIATIONS_FOOTNOTE=PRXCHANGE("s/(CTC(AE)?\s*Version\s*)x+\.x+/\1&adict2/i",-1,ABBREVIATIONS_FOOTNOTE);
/*  ABBREVIATIONS_FOOTNOTE=tranwrd(ABBREVIATIONS_FOOTNOTE,'CTCAE version X.X',"CTCAE Version &adict2");*/
/*  ABBREVIATIONS_FOOTNOTE=PRXCHANGE("s/(CTCAE\s*version\s*)x\.x/\1&adict2/i",-1,ABBREVIATIONS_FOOTNOTE);*/
  DISPLAY_FOOTNOTES=PRXCHANGE("s/(MedDRA\s*Version\s*)x+\.x+/\1&adict/i",-1,DISPLAY_FOOTNOTES);
  DISPLAY_FOOTNOTES=PRXCHANGE("s/(CTC(AE)?\s*Version\s*)x+\.x+/\1&adict2/i",-1,DISPLAY_FOOTNOTES);
/*  DISPLAY_FOOTNOTES=PRXCHANGE("s/(CTCAE\s*version\s*)x\.x/\1&adict2/i",-1,DISPLAY_FOOTNOTES);*/
                                  
run;

%local tflN;
proc sql noprint;
  select count(*) into :tfln
  from meta_tfl_dict
  ;quit;


/*%if &tflN<=0 %then*/
/*%do;*/
/*data meta_tfl_dict;*/
/*  set specs.dummy_tfl_meta;*/
/*  where strip(upcase(display_identifier))=strip(upcase("&spec_name"));*/
/*  ABBREVIATIONS_FOOTNOTE=PRXCHANGE("s/(MedDRA\s*Version\s*)x\.x/\1&adict/i",-1,ABBREVIATIONS_FOOTNOTE);*/
/*  ABBREVIATIONS_FOOTNOTE=PRXCHANGE("s/(CTC{AE}?\s*Version\s*)x\.x/\1&adict2/i",-1,ABBREVIATIONS_FOOTNOTE);*/
/*  ABBREVIATIONS_FOOTNOTE=tranwrd(ABBREVIATIONS_FOOTNOTE,'CTCAE version X.X',"CTCAE Version &adict2");*/
/*  DISPLAY_FOOTNOTES=PRXCHANGE("s/(MedDRA\s*Version\s*)x\.x/\1&adict/i",-1,DISPLAY_FOOTNOTES);*/
/*  DISPLAY_FOOTNOTES=PRXCHANGE("s/(CTC\s*Version\s*)x\.x/\1&adict2/i",-1,DISPLAY_FOOTNOTES);*/
/*  DISPLAY_FOOTNOTES=PRXCHANGE("s/(CTCAE\s*version\s*)x\.x/\1&adict2/i",-1,DISPLAY_FOOTNOTES);*/
/*                                  */
/*run;*/
/*%end;*/



%tfnote(specd=meta_tfl_dict);
footnote1 "ahuige_BeginingOfFootnote_";
/*data _null_;*/
/*  set footnote;*/
/*  if not missing(realft) then call execute('footnote'||strip(put(_N_,best.))||' "'||trim(realft)||'";' );*/
/*run;*/

%local customftn;
  proc sql noprint;
  select strip(put(count(*),best.)) into :customftn
  from footnote
  ;quit;

options ps=%eval(%sysfunc(getoption(ps)) - &customftn-6);
filename outfile "&tfl_output.&outfile..rtf";
filename lstfi_ temp;  
proc printto file=lstfi_ new; run;
filename NEWTB temp;; 


%mend;
