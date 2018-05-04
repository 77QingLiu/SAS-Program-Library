%macro overview(study=study,drive=g:);
dm 'clear log';
%local allrtf delimit alldsn;
%let allrtf=;
%AHGfilesInDir(&out1st,extension=rtf,into=allrtf);
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
%do i=1 %to  
%AHGcount(&allrtf,dlm=@)
/*2*/
;

%let onertf=%scan(&allrtf,&i,%str(@));
%AHGrtftotxt(&out1st&delimit&oneRTF,onertf,%mysdd(&out2nd&delimit&oneRTF..txt),PTN=h\f11\fs16,tailor=0);
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
     when (1)
     do;
     line="[&onertf]:  "||line;
     link="file:///"||"&out1st&delimit&oneRTF";
     end;
     when (2) line="["||trim(line)||"]";
/*     when (3,4,5) x=x*100;*/
     otherwise;
  end;
if index(upcase(line),upcase('Dataset Location:')) then page=-1;
if index(upcase(line),upcase(' //lillyce/')) then 
  do;
  line=substr(line,index(upcase(line),upcase(' //lillyce/')),500);
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

%macro mySDD(dir,pre=);
	%if %AHGblank(&pre) %THEN %let pre=%substr(&localtemp,1,2);
  %local start;
  %Let dir=%sysfunc(compress(&dir));
  %let dir=%AHGanySlash(&dir,toslash=\);

  %let start=%AHGpos(&dir,lillyce\);
  %let dir=&pre\lillyce\%substr(&dir,&start+8);
  &dir
%mend;
option noxwait;
%let localtemp=e:\temp;
%let projectpath=e:\temp;
%let out1st=K:\lillyce\prd\ly2189265\h9x_cr_gbdk\intrm1\programs_nonsdd\tfl_output;
%let out2nd=&localtemp;
%overview(drive=k:);
