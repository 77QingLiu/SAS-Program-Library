%macro AHGoverviewAWE(dir=,study= ,drive=g:,N=9999,allrtf=,include=,except=,mask=0,keepall=0);
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
  line=repeat(' ',160);
  output;
  line=repeat('',160);
  output;
  line='';
  output;
run;
%do i=1 %to  %SYSFUNC(MIN(%AHGcount(&allrtf,dlm=@),&N))
/*2*/
;

%let onertf=%scan(&allrtf,&i,%str(@));
%AHGrtftotxt(&dir&delimit&oneRTF,onertf,%AHGtempdir&delimit&oneRTF..txt,tailor=0);

DATA save;
  set onertf;
run;



%AHGdel(ahgrtfarr,like=1);

data onePiece;
run;

%local figure;
%let figure=0;
data onePiece;
  %if not &keepall %then 
  %do;
  if page=-1 then 
    do;
/*    line='';output;output;*/
    stop;;
    end;
  %end;
  page+1;
  format line $250. rtf $50. link $500.;
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

if 1<=_n_<=4 then 
DO;
line=substr(line,1,index(line,'       '));
output;
END;

if index(line,'sddext.grp') and index(line,'mango') then 
  do;

/*  line=left(tranwrd(line,'\\','/'));*/
/*  if upcase(line)=:upcase('Data') and index(line,'/ly') and index(upcase(line),upcase('/lillyce/')) then page=-1;*/
  if upcase(left(line))=:upcase('Data') and index(line,'sddext.grp') and index(line,'mango') then page=-1;
  if upcase(left(line))=:upcase('Output Location') and index(line,'sddext.grp') and index(line,'mango') then 
    do;
    put theline=;
    line=left(tranwrd(line,'/','\'));
    line=substr(line,index(upcase(line),upcase('\\')) );
    linkname=scan(trim(scan(line,-1,'\')),1,'.')||'.rtf';
  /*  line='=hyperline("'||trim(line)||'","'||trim(scan(line,-1,'\'))||'");';*/
/*    link='=HYPERLINK(MID(CELL("filename"),1,FIND("[",CELL("filename"))-1)&"'||trim(linkname)||'","'||trim(linkname)||'")';*/

    LINE='^S={URL=""'||trim(linkname)||'""} ^S={FOREGROUND=blue} '||trim(linkname); 
    output;
    line=repeat('-',90);
    output;
    end;
  end;

keep line;
run;





%if not &figure   %then
  %do;
  data allrtf(where=(not (missing(line)  )));
    set allrtf seperator onePiece;
    label line ='TFL table of content';
    keep line  ;
    %if &mask %then if not index(line,'file://') then line=translate(line,'0000000000','0987654321');;
  run;
  %end;
  
%end;

data _null_;
  set allrtf;
  call symput('ahgrtfarr'||left(put(_n_,best.)),'ODS RTF TEXT="'||trim(line)||'"');
  %local theN;
  call symput('theN',_n_);
run;



ODS ESCAPECHAR='^'; 
%local rtf;
%let rtf=D:\TOC.rtf;
ODS RTF FILE="&rtf"; 


ODS RTF TEXT=" "; 
%macro dosomething;
%local i;
%do i=1 %to &theN;
 &&ahgrtfarr&i;
%end;

%mend;
%doSomething


ODS RTF TEXT="" ; 
ODS RTF CLOSE; 

OPTION NOXWAIT;
X "start &rtf"; 


/*%local xls;*/
/*%let xls=%AHGtempdir\Overview_of_&STUDY..xls;*/
/**/
/*x del "&xls";*/
/**/
/*proc export data=allrtf outfile="&xls" */
/*dbms=excel;*/
/*sheet='RTF LINKS';*/
/*run;*/
/**/
/*x "start &xls";*/

%getout:
%mend;
