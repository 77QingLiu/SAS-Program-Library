%macro AHGdel(mac,like=0,startwith=1);
%local i;
%if not &like %then
	%do i=1 %to %AHGcount(&mac);
		%symdel %scan(&mac,&i);
	%end;
%else
	%do ;
	   %local oneStr onetype  j;
	   %let mac=%upcase(&mac);
	   %do j=1 %to %AHGcount(&mac);
	       %let  oneStr=%scan(&mac,&j);  
	       %let oneType=;
	       proc sql noprint;
	        select name into :onetype separated by ' '
	        from sashelp.vmacro
	        where upcase(name) like %if &startwith %then "&oneStr%";%else "%"||"&oneStr%"; 
	        order by name
	        ;quit;

	      %local i onemac;
	      %do i=1 %to %AHGcount(&onetype);
	        %let Onemac=%scan(&onetype,&i);
	        %if not %AHGblank(&onemac) %then  %symdel &onemac;
	      %end;
	  %end;
	%end;
%mend;
