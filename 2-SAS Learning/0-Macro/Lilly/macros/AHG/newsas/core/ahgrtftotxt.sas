%macro AHGRTFtotxt(rtf,out,txt,ptn=\b\f2\fs16,tailor=1);
  %if %AHGblank(&txt) %then %let txt=%tempdir\____SDD_OUTPUT.txt;
  %local theout ___  leadlen;
  %let ___='_____________________________________________';
  %if not %AHGblank(&out) %then %let theout=&out;
  %else %AHGgettempname(theout);
  %AHGreadline(file=&rtf,out=&theout);
data &theout;
    set &theout;
    drop one newline delete i;
    line=tranwrd(line,'\\','\');
    if prxmatch( '/.*\\b\\f\d\d\\fs\d\d(.*)/',line) then    line=prxchange('s/.*\\b\\f\d\d\\fs\d\d(.*)/\1/',-1,line);
    else return;
    output;
    return;
run;


  %if &tailor %then
  %do;
  data tailored foot;
    set &theout;
    if index(line,'\page') then newpage=1;
    retain newpage 0;
    if index(line,&___) then linecount+1;
    if linecount<3 then output tailored;
    else if mod(linecount,3)=2 and not missing(line) and not index(line,&___) then output tailored;
    keep line;
    if linecount=3 and not newpage then output foot;
  run;

  data &theout;
    set tailored foot;
    file "&txt";
    put line;
  run;
  %end;



%mend;



