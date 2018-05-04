
%macro AHGdatadelete(lib = , data = );
  proc datasets 
    %if %length(&lib) %then %do; lib = &lib %end;
    %else %do; lib = work %end;
    %if not %length(&data) %then %do; kill %end;
    memtype = data nolist   nodetails
  ;
		%if %length(&data) %then %do; delete &data; %end;
	run;
	quit;
%mend ;
