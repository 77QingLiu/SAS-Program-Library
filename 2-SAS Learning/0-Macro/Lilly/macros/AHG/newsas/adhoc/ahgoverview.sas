%macro AHGoverview(dir=,study= ,drive=g:,N=9999,allrtf=,include=,except=,mask=0,keepall=0);
%if %length(&drive)=1 %then %let drive=&drive:;
%AHGmkdir(%AHGtempdir);
%if %AHGblank(&study) %then %let study=%AHGrdm;
dm 'clear log';
%local delimit alldsn;
%if %AHGblank(&allrtf) %then
%do;
%if %AHGblank(&dir) %then %let dir=&out1st; 
%AHGfilesInDir(&dir,mask='%.rtf',into=allrtf,except=&except,include=&include);
%end;
%else %if not %index(&allrtf,@) %then %let allrtf=%AHGaddcomma(&allrtf,comma=@);
%AHGpm(allrtf);

data allrtf;
run;
%let delimit=%AHGdelimit;

%local onertf i;
data seperator;
  format line $200.;
  line=repeat('*',140);
  output;
  line=repeat('*',140);
  output;
  line='';
  output;
run;
%do i=1 %to  %SYSFUNC(MIN(%AHGcount(&allrtf,dlm=@),&N))
/*2*/
;

%let onertf=%scan(&allrtf,&i,%str(@));
%AHGrtftotxt(&dir&delimit&oneRTF,onertf,%AHGtempdir&delimit&oneRTF..txt,tailor=0);
data onePiece;
run;

%local figure;
%let figure=0;
data onePiece;
  %if not &keepall %then if page=-1 then stop;;
  page+1;
  format line $200. rtf $50. link $500.;
  set oneRTF;
  if index(line,'00000000000000000000000000000') then 
  do;
  call symput('figure','1');
  stop;
  end;
  rtf="&onertf";
  drop rtf page;
/*  line=substr(line,1,index(line,'   '));*/
  select (_n_);
     when (-1)
     do;
     line="[&onertf]:  "||line;
     link="file:///"||"&dir&delimit&oneRTF";
     end;
     when (-2) line="["||trim(line)||"]";
/*     when (3,4,5) x=x*100;*/
     otherwise;
  end;
put line=;
if index(upcase(tranwrd(line,'\\','/')),upcase('/lillyce/')) then 
  do;
  line=left(tranwrd(line,'\\','/'));
  if upcase(line)=:upcase('Data') and index(line,'/ly') and index(upcase(line),upcase('/lillyce/')) then page=-1;
  put theline=;
  line=substr(line,index(upcase(line),upcase('/lillyce/')) );
  line=tranwrd(line,'/','\');
  line=tranwrd(line,'\lillyce\',"file:///&drive\lillyce\");
  end;
output;

run;


%if not &figure %then
  %do;
  data allrtf(where=(not missing(line)));
    set allrtf seperator onePiece;
    keep line;
    %if &mask %then if not index(line,'file://') then line=translate(line,'0000000000','0987654321');;
  run;
  %end;
  
%end;




%local xls;
%let xls=%AHGtempdir\Overview_of_&STUDY..xls;

x del "&xls";

proc export data=allrtf outfile="&xls"
dbms=excel;
sheet='RTF LINKS';
run;

x "start &xls";

%getout:
%mend;
