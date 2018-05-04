%macro ahghighlightex(text,fully=0,type=,thepath=&__snapshot,folder=adam sdtm tfl iradam irasdtm irtfl);
%AHGKILL;
%let thepath=%AHGremoveslash(&thepath);
%if not %AHGblank(&text) %then  %let type=rtf;
%else %let type=lst;

%macro ah_message_js(dsns,file=) ; 
data _null_ ; 
  file "&file"; 
  put "&html1";
  put "&html2";
  put "&html3";
  %local i J one;
  %do j=1 %to %AHGcount(&dsns);
  do i=1 to nobs;
  set   %scan(&dsns,&j) nobs=nobs;
  put pp @;
  put url ; 
  end;
  %end;
  put "&html4";
  put "&html5";
run ; 
x "start CALL ""&file""";
%mend  ; 
option mprint;
%local alink %AHGwords(html,5);
%let html1=<!DOCTYPE html>;
%let html2=<html>;
%let html3=<body>;
%let html4=</body>;
%let html5=</html> ;

/* <script> */
/*window.clipboardData.setData( 'Text', '%AHGpmlike(sys);'); */
/*</script>*/

%let alink=%str(<style type=""text/css"">
body {background-color:white;}
h3 {
    font-family: "" Courier New, monospace"";
}

</style>
);
/*%message_js(js,file=%AHGtempdir\js.html);*/
%AHGdel(url,like=1);

/*%str(&__snapshot.programs_stat\adam\system_files)*/

%AHGtime(1);
%local html smallhtml nameline;
%AHGgettempname(html);
%AHGgettempname(smallhtml);

data &html &smallhtml;run;
%macro AHGreadline(file=,out=readlineout);
data &out;
  filename inf   "&file" ;
  infile inf truncover;;
  format  line $200.;
  input line 1-200 ;
run;
%mend;

%LOCAL ONE;
%AHGgettempname(one);

%macro ah_addone(path,file);
/*%local loop;*/
/*%let loop=0*/
/*%AHGincr(loop);*/
%AHGreadline(file=&path\&file..&type,out=&one);
 
%if &type=rtf %then
%do;
data &one;
  set &one;
  line=prxchange('s/(.*\\b\\f\d\d\\fs\d\d )(.*)/\2/',1,line);
  output;
  %if not &fully %then 
  %do;
  if prxmatch('m/Data.*Location:.*data/',line) then stop;
  %end;
run;
%end;
%local wanted;
%let wanted=0;

%AHGgettempname(nameline);
data &nameline;
  keep=-1;
  format &type $150.;
  &type="&path\&file..&type";
  line="##################    &file..&type   ########################";output;
run;

data &html;
format line $150. &type $150.;
set &html &nameline &one(in=inone);
if inone then &type="&file..&type";
run;

%mend;



%macro ah_onepath(path);
%let alllst=;
%AHGfilesindir(&path,dlm=%str( ) ,mask="%.&type",into=alllst,case=0,print=1); 
%let alllst=%sysfunc(tranwrd(&alllst,.&type,%str())); 

%AHGpm(alllst);
%AHGfuncloop(%nrbquote( ah_addone(&path,ahuige) ) ,loopvar=ahuige,loops=&alllst);

%mend;


%if %AHGblank(&text) %then
%do;
%if %sysfunc(indexw(%lowcase(&folder),iradam)) %then %ah_onepath(&thepath\replica_programs\adam\system_files);
%if %sysfunc(indexw(%lowcase(&folder),irtfl)) %then %ah_onepath(&thepath\replica_programs\tfl\system_files);
%if %sysfunc(indexw(%lowcase(&folder),irsdtm)) %then %ah_onepath(&thepath\replica_programs\sdtm\system_files);
/**/
%if %sysfunc(indexw(%lowcase(&folder),adam)) %then %ah_onepath(&thepath\programs_stat\adam\system_files);
%if %sysfunc(indexw(%lowcase(&folder),tfl)) %then %ah_onepath(&thepath\programs_stat\tfl\system_files);
%if %sysfunc(indexw(%lowcase(&folder),sdtm)) %then %ah_onepath(&thepath\programs_stat\sdtm\system_files);
%end;
%else %if %upcase(&type)=RTF %then %ah_onepath(&thepath\programs_stat\tfl_output);



data &html ;
set &html;
format url $1000.;
id=_n_;
/*by loop;*/
retain flagme 0;


line=tranwrd(line,'"','""');
/*line=compress(line,byte(13)||byte(17)||'"');*/
if keep=-1 then url='<h4><a href="'||strip(&type)||'">#### '||strip(&type)||' ####</a></h4>';
else 
%if %AHGblank(&text) %then
%do;
if  
not flagme then
  do;
  if 
  prxmatch('m/not exactly equal/i',line) 
  or prxmatch('m/unequal:\s*[123456789]/i',line) 
  or prxmatch('m/Values of the following/i',line)   
  then do;url='<span style="color:red;"><pre>'||line||'</pre></span> '; keep=1;found=1;end;
  else url='<span style="color:green"><pre>'||line||'</pre></span> ';
  end;

else 
  do;
  if prxmatch('m/.*\s{4}[123456789]\d*\s*$/i',line) 


  then do;url='<span style="color:red;"><pre>'||line||'</pre></span> '; keep=1;end;
  else url='<span style="color:green"><pre>'||line||'</pre></span> ';
  end;
%end;
%else 
  %do;
  %local i prx;
  %do i=1 %to %AHGcount(&text);
  %if &i=1 %then %let prx=%scan(&text,1,%str( ));
  %else %let prx=&prx\s+%scan(&text,&i,%str( ));
  %end;
  do;               
    if prxmatch("m/&prx/i",line) 
    then do;url='<span style="color:red;"><pre>'||line||'</pre></span> '; keep=1;end;
    else url='ahuige delete me';
  end;
  %end;
if index(line,"Searched Message  ") then flagme=1;
if index(line,'_ERROR_=1             ') then flagme=0;


run;

proc sql noprint;
  create table &smallhtml as
  select *
  from &html
  where not url='ahuige delete me'
  group by &type
  having max(keep)=1 or keep=-1
  order by id
  ;

  create table some as
  select distinct LST as entry ,1 AS red
  from &smallhtml
  group by lst
  having count(lst)>1
  ;
  quit;
;

data &smallhtml;
  set &smallhtml;
  ord=_n_;
  if index(line,'#####') then entry=scan( lst,-1,'\');
run;
/*https://ajax.googleapis.com/ajax/libs/jquery/1.12.0/jquery.min*/

%AHGmergedsn(&smallhtml,some,&smallhtml,by=entry,joinstyle=left/*left right full matched*/);

data &smallhtml; 
  set &smallhtml;
  if missing(entry) then entry=lst;
  if red=1 then 
  do;
  url=tranwrd(url,'<h4>','<h4> <button id="'||scan(entry,1,'.')||'btn" ><font  color="red">Finding </font></button> ');
  output;
url=' <script>
$("#'||scan(entry,1,'.')||'btn'||'").click(function(){
    $("#'||scan(entry,1,'.')||'").show();
    });
</script>';
  output;
  end;
/*   $("#'||scan(entry,1,'.')||'").show();*/
  else output;

  /*  if red=1 then url=tranwrd(url,'<h4>','<h4><font  color="red"> !Findings </font> ');*/

  


run;

%AHGdatasort(data =&smallhtml , out = , by = ord);

data header;
  FORMAT url $500.;
  url='
<style type="text/css">
body {background-color:white;}
h3 {
    font-family: " Courier New, monospace";
    }
</style>
<script src="h:\jq.js"></script>
<script>
$(document).ready(function(){
    $("#hide").click(function(){
        $("span").hide();
    });
    $("#show").click(function(){
        $("span").show();
    });

    $("body").dblclick(function(){
    $("strong").hide();
    });


     $("strong").hide();;
});
</script>

';
run;

/*<button id="hide">Hide</button>*/
/*<button id="show">Show</button>*/


/*data _null_;*/
/*set &smallhtml;*/
/*call symput('url'||%AHGputN(_n_,BEST.),TRIM(url));*/
/*call symput('url_N',_N_);*/
/*run;*/

data  &smallhtml;
set header &smallhtml(in=inhtml);
  retain lagkeep .;

  if lagkeep=-1 and keep=. then pp='<strong id="'||scan(entry,1,'.')||'">  ';
  if lagkeep ne -1 and keep=-1 then pp='</strong>';
  lagkeep=keep;
  if not inhtml then pp='';

run;


option mprint nosymbolgen;
%ah_message_js( &smallhtml
,file=%AHGtempdir\js.html);


%AHGtime(2);
%AHGinterval(1,2);
%mend;


