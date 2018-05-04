%macro overview;
%local allrtf delimit;
%let allrtf=;
%AHGfileInDir(&out1st,ext=rtf,into=allrtf);
%AHGpm(allrtf);

data allrtf;
run;
%let delimit=%AHGdelimit;

%local onertf i;
%do i=1 %to  
%AHGcount(&allrtf);
/*2;*/

%let onertf=%scan(&allrtf,&i,%str( ));
%AHGrtftotxt(&out1st&delimit&oneRTF,onertf,%mysdd(&out2nd&delimit&oneRTF..txt),tailor=0);
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
/*  if _n_<=2 then output;*/

run;

data allrtf;
  set allrtf onePiece;
run;
  
%end;



x del "d:\temp\hyper.xls";

proc export data=allrtf outfile='d:\temp\hyper.xls'
dbms=excel;
sheet='RTF LINKS';
run;

x "start d:\temp\hyper.xls";


%mend;

%overview;
