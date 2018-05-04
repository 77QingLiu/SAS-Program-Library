%macro AHGRTFtotxt(rtf,out,txt,ptn=\b\f2\fs16,tailor=1);
  %if %AHGblank(&txt) %then %let txt=&%AHGtempdir\____SDD_OUTPUT.txt;
  %local theout ___  leadlen;
  %let leadlen=%length(&ptn);
  %let ___='_____________________________________________';
  %if not %AHGblank(&out) %then %let theout=&out;
  %else %AHGgettempname(theout);
  %AHGreadline(file=&rtf,out=&theout);
  data _null_;
    set &theout;
    format leadingstr $255.;
    if index(line,'\par \pard\plain') then 
    do;
    leadingstr=scan(line,1,' ')||' '||scan(line,2,' ')||' '||scan(line,3,' ')||' '||scan(line,4,' ');
    call symput('ptn',trim(leadingstr));
    call symput('leadlen',length(trim(leadingstr)));
    put leadingstr=;
    return;
    end;
  run;
  data &theout;
    set &theout;
    line=compress(line,byte(160));
    if not index(line,"&ptn")    then delete;
    else; 
    do  while(index(line,"&ptn")  );
    line=substr(line,index(line,"&ptn")+&leadlen);
    end;
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



