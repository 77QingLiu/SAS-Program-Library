%macro AHGprot2prot(from,to
,files/*macros abc.sas xyz.sas@ tools Mac.meta Tod.meta*/
,execute=1
);
%local j i;
%do i=1  %to %AHGcount(&files,dlm=@);
	%local line folder ;
	%let line=%scan(&files,&i,@);
	%let folder=%AHGleft(line);
	%do j=1 %to %AHGcount(&line);
	%if not &execute %then 
	    %do;
	    %put AHGsubmitRcommand(chkout &to/&folder/%scan(&line,&j,%str( )));
		%put AHGsubmitRcommand(cp -f &from/&folder/%scan(&line,&j,%str( )) &to/&folder/%scan(&line,&j,%str( )));
		%put AHGsubmitRcommand(chkin &to/&folder/%scan(&line,&j,%str( )) copy from &from) ;
		%end;
	%else
	    %do;
	    %AHGsubmitRcommand(cmd=chkout &to/&folder/%scan(&line,&j,%str( )));
		%AHGsubmitRcommand(cmd=cp -f &from/&folder/%scan(&line,&j,%str( )) &to/&folder/%scan(&line,&j,%str( )));
		%AHGsubmitRcommand(cmd=chkin &to/&folder/%scan(&line,&j,%str( )) copy from &from) ;
		%end;
	%end;
%end;

%mend;

