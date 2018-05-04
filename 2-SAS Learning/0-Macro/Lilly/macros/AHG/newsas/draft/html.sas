%macro message_js(pre,file=) ; 
 
 data _null_ ; 
 file "&file"; 
 put "&html1";
 put "&html2";
 put "&html3";
 %local i J one;
 %do j=1 %to %AHGcount(&pre);
   %let one=%scan(&pre,&j,%str( ));
   %if not %symexist(&one._n) %then
     %do;
     %if %bquote(%sysfunc(rank(%substr(%bquote(&&&one),1,1))))=34 
         or %bquote(%sysfunc(rank(%substr(%bquote(&&&one),1,1))))=39 %then put %unquote(&&&one);
     %else put "%unquote(&&&one)";
     %end;
   %else 
     %do i=1 %to &&&one._n;
     %put ############### &&&one&i;
     %if %bquote(%sysfunc(rank(%substr(%bquote(&&&one&i),1,1))))=34 
         or %bquote(%sysfunc(rank(%substr(%bquote(&&&one&i),1,1))))=39  %then put %unquote(&&&one&i);
     %else put "%unquote(&&&one&i)";
     ; 
     put;
     %end;
 %end;
 put "&html4";
 put "&html5";
 run ; 

 x "start &file";
%mend message_js ; 
option mprint;

%AHGdel(html,like=1);

%AHG2arr(html);
cards4;
<!DOCTYPE html>
<html>
<body>
</body>
</html> 
;;;;
run;

/* <script> */
/*window.clipboardData.setData( 'Text', '%AHGpmlike(sys);'); */
/*</script>*/
%AHG2arr(btn);
cards4;
<a href='c:\temp\ahuige'>dd</a>
;;;;
run;

%let alink=<a href='c:\temp\ahuige'>c</a>;




/*%message_js(js,file=%AHGtempdir\js.html);*/
%AHGdel(url,like=1);

proc sql;
  create table html as
  select '''<a href="'||trim(path)||'">'||compress(libname)||'</a>''' as url
  from sashelp.vlibnam
  WHERE not libname in ( 'SASHELP','SASUSER','MAPS');
;
quit;

data _null_;
  set html;
  call symput('url'||%AHGputN(_n_,BEST.),TRIM(url));
  call symput('url_N',_N_);
run;

%AHGpmlike(url);





%macro dosomething(arr);
%AHGdel(&arr,like=1);
%local i j all;
%if %symexist(__snapshot)  %then
%do;
  %let all=  programs_stat replica_programs  ;
  %let j=0;
  %do i=1 %to %AHGcount(&all);
  %PUT GREAT &I;
  %if %sysfunc(fileexist(&__snapshot\%scan(&all,&i,%str( )))) %then 
    %DO;
    %AHGincr(j);
    %let &arr&j=%bquote('<a href="&__snapshot\%scan(&all,&i,%str( ))">%scan(&all,&i,%str( ))</a>');
    %AHGpm(&arr&j);
    %LET &ARR._N=&j;
    %END;
  %END;
  
%end;



%message_js(URL btn alink %if %symexist(__snapshot)  %then &arr;,file=%AHGtempdir\js.html);
/*&arr*/
%mend;
%doSomething(APATH33);



 