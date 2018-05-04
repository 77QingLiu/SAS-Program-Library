
%macro prePrint;


%global big1 big2 big3;
data adsl;
  set adam.adsl;
  keep usubjid trt;
  where saffl='Y' and trt01an in (1,2);
  trt=TRT01AN;
  output;
  trt=3;
  output;
run;
proc sql noprint;
  select count(*) as cnt into :big1-:big3
  from  adsl
  group by trt
  order by trt
  ;quit;

%local adict adict2;
proc sql noprint;
  select distinct put(tranwrd(adict,'MedDRA',''),$7.), put(left(tranwrd(adict2,'CTCAE','')),$3.)into :adict, :adict2
  from adam.adae
  ;
  quit;

title ;footnote;

data meta_tfl_dict;
  set specs.meta_tfl;
  where strip(upcase(display_identifier))=strip(upcase("&spec_name"));
  ABBREVIATIONS_FOOTNOTE=PRXCHANGE("s/(MedDRA\s*Version\s*)x\.x/\1&adict/i",-1,ABBREVIATIONS_FOOTNOTE);
  ABBREVIATIONS_FOOTNOTE=PRXCHANGE("s/(CTC{AE}?\s*Version\s*)x\.x/\1&adict2/i",-1,ABBREVIATIONS_FOOTNOTE);
  DISPLAY_FOOTNOTES=PRXCHANGE("s/(MedDRA\s*Version\s*)x\.x/\1&adict/i",-1,DISPLAY_FOOTNOTES);
  DISPLAY_FOOTNOTES=PRXCHANGE("s/(CTC\s*Version\s*)x\.x/\1&adict2/i",-1,DISPLAY_FOOTNOTES);
  DISPLAY_FOOTNOTES=PRXCHANGE("s/(CTCAE\s*version\s*)x\.x/\1&adict2/i",-1,DISPLAY_FOOTNOTES);
                                  
run;


%titlefootnote(specd=meta_tfl_dict);
data _null_;
  set footnote;
  array myft ft:;
  do over myft;
    id+1;
    if not missing(myft) then call execute('footnote'||strip(put(id,best.))||' "'||trim(myft)||'";' );
  end;
run;


%global _pstot_ __nooffoot ls;
%let ls=133;

%let _pstot_=%eval(&_pstot_ - &__nooffoot);
%put ---new page size is :&_pstot_;
options ps=&_pstot_;
filename outfile "&tfl_output.&outfile..rtf";
filename lstfi_ temp;  
proc printto file=lstfi_ new; run;
filename NEWTB temp;; 


%mend;
