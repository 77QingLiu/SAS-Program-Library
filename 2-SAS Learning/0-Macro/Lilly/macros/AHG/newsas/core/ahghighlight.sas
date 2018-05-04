%macro ahghighlight(text,type,thepath=&__snapshot);
%if not %AHGblank(&text) %then  %let type=rtf;
%else %let type=lst;

%macro ah_message_js(pre,file=) ; 
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
  format  line $8200.;
  input line 1-200 ;
run;
%mend;


%macro ah_addone(path,file);
/*%local loop;*/
/*%let loop=0*/
/*%AHGincr(loop);*/
%AHGreadline(file=&path\&file..&type,out=&file);
%AHGpm(type);
%if &type=rtf %then
%do;
data &file;
  set &file;
  line=prxchange('s/(.*\\b\\f\d\d\\fs\d\d )(.*)/\2/',1,line);
  output;
  if prxmatch('m/Data.*Location:.*data/',line) then stop;
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
set &html &nameline &file(in=inone);
if inone then &type="&file..&type";
run;

/*%if  &wanted %then*/
/*%do;*/
/**/
/*data smallhtml;*/
/*format line $150.;*/
/*set smallhtml nameline one(in=inone);*/
/*if inOne then loop=&loop;*/
/*run;*/
/*%end;*/

%mend;


/*%let __snapshot=\\mango\sddext.grp\SDDEXT056\qa\ly2835219\i3y_mc_jpbm\dmc_blinded4;*/

/*%let __snapshot=\\mango\awe.grp\SDDEXT112\qa\ly2835219\i3y_mc_jpbo\arsep2015;*/

%macro ah_onepath(path);
%let alllst=;
%AHGfilesindir(&path,dlm=%str( ) ,mask="%.&type",into=alllst,case=0,print=1); 
%let alllst=%sysfunc(tranwrd(&alllst,.&type,%str())); 

%AHGpm(alllst);
%AHGfuncloop(%nrbquote( ah_addone(&path,ahuige) ) ,loopvar=ahuige,loops=&alllst);

%mend;


%if %AHGblank(&text) %then
%do;
%ah_onepath(&thepath\replica_programs\adam\system_files);
%ah_onepath(&thepath\replica_programs\tfl\system_files);
%ah_onepath(&thepath\replica_programs\sdtm\system_files);
/**/
%ah_onepath(&thepath\programs_stat\adam\system_files);
%ah_onepath(&thepath\programs_stat\tfl\system_files);
%ah_onepath(&thepath\programs_stat\sdtm\system_files);
%end;
%else %if %upcase(&type)=RTF %then %ah_onepath(&thepath\programs_stat\tfl_output);



data &html ;
set &html;
id=_n_;
/*by loop;*/
retain flagme 0;


line=tranwrd(line,'"','""');
/*line=compress(line,byte(13)||byte(17)||'"');*/
if keep=-1 then url='''<h3><a href="'||strip(&type)||'">#### '||strip(&type)||' ####</a></h3>''';
else 
%if %AHGblank(&text) %then
%do;
if  
not flagme then
  do;
  if 
  prxmatch('m/not exactly equal/i',line) 
  or prxmatch('m/Unequal:\s*[123456789]/i',line) 
  then do;url='<h3 style=""color:red;""><pre>'||line||'</pre></h3> '; keep=1;end;
  else url='<h3 style=""color:green""><pre>'||line||'</pre></h3> ';
  end;

else 
  do;
  if prxmatch('m/.*\s{4}[123456789]\d*\s*$/i',line) 


  then do;url='<h3 style=""color:red;""><pre>'||line||'</pre></h3> '; keep=1;end;
  else url='<h3 style=""color:green""><pre>'||line||'</pre></h3> ';
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
    then do;url='<h3 style=""color:red;""><pre>'||line||'</pre></h3> '; keep=1;end;
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
  quit;


;

data _null_;
set &smallhtml;
call symput('url'||%AHGputN(_n_,BEST.),TRIM(url));
call symput('url_N',_N_);
run;


option nomprint nosymbolgen;
%ah_message_js(alink url,file=%AHGtempdir\js.html);


%AHGtime(2);
%AHGinterval(1,2);
%mend;

