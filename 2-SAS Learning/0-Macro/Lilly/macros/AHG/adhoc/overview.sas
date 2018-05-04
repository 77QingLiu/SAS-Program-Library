%macro overview(dir=,study=study,drive=g:,N=9999,allrtf= );
dm 'clear log';
%local delimit alldsn;
%if %AHGblank(&allrtf) %then
%do;
%if %AHGblank(&dir) %then %let dir=&out1st; 
%AHGfilesInDir(&dir,extension=rtf,into=allrtf);
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
%AHGrtftotxt(&dir&delimit&oneRTF,onertf,%mysdd(&out2nd&delimit&oneRTF..txt),tailor=0);
data onePiece;
run;


data onePiece;
  if page=-1 then return;
  page+1;

  format line $200. rtf $50. link $500.;
  
  set oneRTF;
  

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
if index(upcase(line),upcase('Dataset Location:')) then page=-1;
put line=;
if index(upcase(tranwrd(line,'\','/')),upcase('//lillyce/')) then 
  do;
  put theline=;
  line=tranwrd(line,'\\','/');
  line=substr(line,index(upcase(line),upcase(' //lillyce/')) );
  line=tranwrd(line,'/','\');
  line=tranwrd(line,' \\lillyce\',"file:///&drive\lillyce\");
  end;
output;

run;

data allrtf;
  set allrtf seperator onePiece;
run;
  
%end;






x del "%mysdd(&projectpath\Overview_of_&STUDY..xls)";

proc export data=allrtf outfile="%mysdd(&projectpath\Overview_of_&STUDY..xls)"
dbms=excel;
sheet='RTF LINKS';
run;

x "start %mysdd(&projectpath\Overview_of_&STUDY..xls)";


%mend;
