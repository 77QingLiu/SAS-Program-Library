
%macro AHGcolorEx(dsn,flag=flag,file=,label=,show=label,out=,open=1) ; 
%local alink %AHGwords(html,5);
%let html1=<!DOCTYPE html>;
%let html2=%str(<html> 
<head>
/*   <style>*/
/*   */
/*   table {background-color: Azure   ;border-collapse:collapse; table-layout:auto; width:310px;}*/
/*   table td {border:solid 1px black; width:100px; word-wrap:break-word;}*/
/*   </style>*/
/*   <script src=""h:\jq.js""></script>*/
</head>
);
%let html3=%nrstr(<body><table style='width:100%'>);
%let html4=%nrstr(</table></body>);
%let html5=%nrstr(</html>) ;
/*%let html6=*/

%local rdm tempdir varlist;
%let rdm=%AHGrdm;
%let tempdir=%AHGtempdir;




/*%AHGtrimdsn(&dsn,out=new&rdm);*/

%AHGvarlist(&dsn,Into=varlist,dlm=%str( ),global=0);

%let varlist=%AHGremoveWords(&varlist,ahgcolor ahglink,dlm=%str( ));
data name&rdm;
%local i;
%do i=1 %to %AHGcount(&varlist);
  %scan(&varlist,&i)="%scan(&varlist,&i)";
%end;
run;

%AHGalltocharNew(&dsn,out=Char&rdm,rename=&sysmacroname,width=4000);



%AHGrenamekeep(Char&rdm,out=,pos=,names=&varlist,keepall=0);

data null&rdm;
  set char&rdm;
  stop;
run;

data char&rdm;
  set  null&rdm name&rdm char&rdm;
run;

%if %AHGblank(&file) %then %let file=&tempdir%str(\)&rdm..html;
%local ahtml;
%let ahtml=%AHGtempdir\%AHGrdm.html;
data null ; 
  format ahgcolor $10. link ahglink $2000.;
  array htmltag(10) $1000.  _temporary_;
  file "&ahtml"; 
  if _n_=1 then
  do;
  put "&html1";
  put "&html2";
  put "&html3";
  end;
/*  do i=1 to tillthelast;*/
  set char&rdm end=myend888;
/*  if missing(%scan(&varlist,2)) then return;*/
  output;
  put '<tr>';
  %local i;
  %do i=1 %to %AHGcount(&varlist);
  if _n_=1 then
    do;
    if  not index(%scan(&varlist,&i),'`') then  put '<td>';
    else  put '<td >'; 
/*    style=''width:'  '%''*/
    end;
  else  put '<td>';
/*  if left(ahgcolor)='9' then put '<strong style=''color:red;''>  ';*/
/*  '<a href="http://www.w3schools.com"> ';*/
  if not index(%scan(&varlist,&i),'`') then put %scan(&varlist,&i);
  else 
    do;
    do i=1 to 10;
    htmltag(i)=scan(%scan(&varlist,&i),i,'`','M');
/*    if "%scan(&varlist,&i)"="link" then put htmltag(i);*/
    end;

    if htmltag(2)='9'   then put '<strong style=''font-style: italic;color:red;''>  ';
    else if htmltag(2)='2'   then put '<strong style=''font-style: italic;color:BROWN;''>  ';
    else if htmltag(2)='3'   then put '<strong style=''font-style: italic;color:blue;''>  ';
    else if htmltag(2)='1'   then put '<strong style=''font-style: italic;color:DeepPink ;''>  ';
/*    else if htmltag(2)=''   then put '<strong style=''color:bla;''>  ';*/
/*    ahglink=;*/
    format onetag $100.;
    onetag=scan(htmltag(5),1,' ');
    put onetag;
    if missing(htmltag(3)) then     put htmltag(1);
    else put  '<a href="' htmltag(3) '">' htmltag(1)   '</a>';
    onetag=scan(htmltag(5),2,' ');
    put onetag;
    if not missing(htmltag(2)) %*color; then put '</strong>  ';
    
    end;
/*  if left(ahgcolor)='9' then put '</a></strong>';*/
  put '</td>';
  %end;
  put '</tr>';
  if myend888 then
  do;
  put "&html4";
  put "&html5";
  end;
run ; 
%macro AHGreadline(file=,out=readlineout);
data &out;
  filename inf   "&file" ;
  infile inf truncover;;
  format  line $char800.;
  input line 1-800  ;
run;
%mend;

%AHGreadline(file=&ahtml,out=body_&rdm);


%if %AHGnonblank(&out) %then
%do;
data &out;
  set body_&rdm;
  retain out&rdm 0;
  if line="&html4" then out&rdm=0;
  if out&rdm then output;
  if line="&html3" then out&rdm=1;

run;
%end;

option noxwait;
x "copy &ahtml ""&file"" /y ";
%if &open %then x "start call ""&file""";;

/*dm "FILEOPEN ""&file"" ";*/




%mend  ; 
