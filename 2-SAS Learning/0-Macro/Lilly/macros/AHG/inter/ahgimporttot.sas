%macro AHGimporttot(file,dlm=^);
%if not %sysfunc(fileExist(&file))  %then %let file=&projectpath\tools\&file;
%local tempfile;
%AHGgettempfilename(tempfile);
data _null_;
    file "&localtemp\&tempfile";
    infile "&file" dlm="&dlm" truncover;
    length letstring $400 mac $50 value $300;
    input mac value;
    put ';%global ' mac ';';
  run;

  %inc "&localtemp\&tempfile";
    data _null_;
      length envar $ 200. enval $ 800.;

      infile "&file" pad   lrecl=1000 missover delimiter="&dlm" end=last;
      input envar $ enval $;

      if trim(left(envar)) ^= '' then do;
         call symput(envar,trim(enval));
      end;

      if last then do;
         rc = fclose(1);
      end;

    run;
%mend;
