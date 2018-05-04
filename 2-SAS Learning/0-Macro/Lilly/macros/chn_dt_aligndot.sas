%macro chn_dt_aligndot(data = , out = , var = );
  %local rdn;
  %let rdn = dkfjlajgajweofjlsdjfla;
  data &rdn.d0;
    set &data;
  run;
  %local mvar prefix separator i;
  %let mvar = &var;
  %let prefix = var;
  %let separator = %quote( );
  %let i = 1;
  %do %while(%length(%qscan(&mvar, &i, &separator)));
    %local &prefix&i;
    %let &prefix&i = %sysfunc(strip(%qscan(&mvar, &i, &separator)));
    %put &prefix&i = &&&prefix&i;
    %let i = %eval(&i + 1);
  %end;
  %local n&prefix;
  %let n&prefix = %eval(&i - 1);
  %put n&prefix = &&n&prefix;

  %do i = 1 %to &nvar;
    data &rdn.d1;
      set &rdn.d0;
      &&var&i = left(&&var&i);
      format integer $200.;
      if index(&&var&i, '.') and index(&&var&i, '(') and index(&&var&i, ',') then
        do;
          integer = scan(&&var&i, 1, '.');
        end;
      else if index(&&var&i, '(') and index(&&var&i, ',') then
        do;
          integer = scan(&&var&i, 1, ',');
        end;
      else if index(&&var&i, '.') and index(&&var&i, '(') then
        do;
          if index(scan(&&var&i, 1, '('), '.') then
            do;
              integer = scan(&&var&i, 1, '.');
            end;
          else
            do;
              integer = scan(&&var&i, 1, '(');
            end;
        end;
      else if index(&&var&i, '.') then
        do;
          integer = scan(&&var&i, 1, '.');
        end;
      else if index(&&var&i, ',') then
        do;
          integer = scan(&&var&i, 1, ',');
        end;
      else
        do;
          integer = &&var&i;
        end;
    run;

    data &rdn.d2;
      set &rdn.d1;
      integerlength = length(integer);
    run;
    %local maxlength;
    proc sql noprint;
      select max(integerlength) into :maxlength separated by " "
        from &rdn.d2
      ;
    quit;
    %put maxlength = &maxlength;
    data &rdn.d3;
      set &rdn.d2;
      lengthdiff = &maxlength - integerlength;
    run;
    data &rdn.d0 (drop = integer integerlength lengthdiff);
      set &rdn.d3;
      if lengthdiff > 0 then &&var&i = repeat(' ', lengthdiff - 1) || &&var&i;
    run;
  %end;

  data &out;
    set &rdn.d0;
  run;
%mend ;
