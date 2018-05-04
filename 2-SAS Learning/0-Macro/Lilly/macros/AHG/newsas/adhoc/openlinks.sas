%macro openLinks;

%macro htmlarr(allhtml,htmlarr,dlm=|);

%local i ;
%global &htmlarr._n;
%let &htmlarr._n=%AHGcount(&allhtml,dlm=&dlm);
%do i=1 %to &&&htmlarr._n;
  %global &htmlarr.&i;
  %let  &htmlarr&i=%scan(&allhtml,&i,&dlm);
%end;


%mend;


%htmlarr(
|<!DOCTYPE html>
|<html>
|<body>
|</body>
|</html> 
,ADFDSFDShtml_
);


%local p1 p2;
%let p1=<p>;
%let p2=</p> ;
;





%macro message_js(pre,file=) ; 
 
 data _null_ ; 
 file "&file"; 
 put "&ADFDSFDShtml_1";
 put "&ADFDSFDShtml_2";
 put "&ADFDSFDShtml_3";
 %local i J one;
 %do j=1 %to %AHGcount(&pre);
   %let one=%scan(&pre,&j,%str( ));
   %if %substr(&one,1,1)=%str(<) %then  put "&one"; 
   %else %if  %bquote(%substr(&one,1,1))=%str(%') or %bquote(%substr(&one,1,1))=%str(%") %then   put &one ; 
   %else %if not %symexist(&one._n) %then
     %do;
     %if %bquote(%sysfunc(rank(%substr(%bquote(&&&one),1,1))))=34 
         or %bquote(%sysfunc(rank(%substr(%bquote(&&&one),1,1))))=39 %then put %unquote(&&&one);
     %else put "%unquote(&&&one)";
     %end;
   %else 
     %do i=1 %to  &&&one._n ;
     %put ############### &&&one&i;
     %if %bquote(%sysfunc(rank(%substr(%bquote(&&&one&i),1,1))))=34 
         or %bquote(%sysfunc(rank(%substr(%bquote(&&&one&i),1,1))))=39  %then put %unquote(&&&one&i);
     %else put "%unquote(&&&one&i)";
     put;
     %end;
   ;
 %end;
 put "&ADFDSFDShtml_4";
 put "&ADFDSFDShtml_5";
 run ; 

 x "start &file";
%mend message_js ; 



proc sql;
  select '''<a href="'||trim(path)||'">'||compress(libname)||'</a>'''  into :urlasfdassadfljAll separated by '|'
  from sashelp.vlibnam
  WHERE not libname in ( 'SASHELP','SASUSER','MAPS') and  index('EDS ADAM  DICT  SDTM WORK',trim(libname) );
;
quit;


%htmlarr(
|&urlasfdassadfljAll
,urlasfdassadflj
);


%htmlarr(
|<script> 
|function windowClose() { 
|window.open('','_parent','') 
|window.close()
|} 
|</script>
,myhead348257849357
);


/*%local closebtn;*/
/*%let closebtn='<input type="button" value="Close this window" onclick="windowClose();">';*/


%macro dosomething(arr);
%AHGdel(&arr,like=1);
%local i s  j all sub;
%if %symexist(__snapshot)  %then
%do;
  %let all=  programs_stat replica_programs  ;
  %let sub=sdtm adam tfl tfl_output;
  %let j=0;
  %do i=1 %to %AHGcount(&all);
    %do s=1 %to %AHGcount(&sub);
      %if %sysfunc(fileexist(&__snapshot%scan(&all,&i,%str( ))\%scan(&sub,&s,%str( )))) %then 
        %DO;
        %AHGincr(j);
        %local &arr&j;
        %let &arr&j=%bquote('<p><a href="&__snapshot%scan(&all,&i,%str( ))\%scan(&sub,&s,%str( ))">%scan(&all,&i,%str( ))\%scan(&sub,&s,%str( ))</a></p>');
        %AHGpm(&arr&j);
        %LET &ARR._N=&j;
        %END;
    %end;
  %END;
  
%end;



%message_js(p1 urlasfdassadflj p2 myhead348257849357 %if %symexist(__snapshot)  %then &arr; 
 %if %symexist(__snapshot)  %then __snapshot;     

,file=%AHGtempdir\js.html);
/*&arr*/
%mend;
%doSomething(APATH33);


%AHGfuncloop(%nrbquote( AHGdel(ahuige,like=1) ) ,loopvar=ahuige,loops=urlasfdassadflj ADFDSFDShtml_ myhead348257849357 );



%exit:

%mend;




 
