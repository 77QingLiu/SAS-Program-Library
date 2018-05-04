%macro chn_ut_status(showall=0);

%local namelist sdtmall sdtmInDir SDTMstatus rdm;
%let rdm=_%AHGrdm(6);



%if %sysfunc(exist(specs.trackingsheet)) %then
  %do;
  data sdtmAll&rdm;
    format Category  name $100.;
    set specs.trackingsheet(rename=(output_name=name));
    keep name category insheet insheet;
    name=lowcase(name);
    category=upcase(category);
    if indexw('sdtm',trim(lowcase(category)));
    inSheet=1;
  run;
  %end;






%AHGpspipe(%str(ls |select  Name, @{Name='LastWriteTime';
Expression={$_.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')}}),path=&sdtm,out=sdtmInDir&rdm);

data sdtmInDir&rdm;
  set sdtmInDir&rdm; drop line;
  WHERE index(line,'.sas7bdat');
  format   name $100. FileDate $500.;
  name=scan(scan(line,1,' '),1,'.');
  FileDate=left(substr(line,index(line,' ')));
  sdtm=1;
run;

%local nobs;

%AHGnobs(SDTMAll&rdm,into=nobs);

%AHGmergedsn(sdtmAll&rdm,sdtmInDir&rdm,sdtmstatus&rdm,by=name,joinstyle=full);

%macro dummy;
%if &nobs>0 %then %AHGmergedsn(sdtmAll&rdm,sdtmInDir&rdm,sdtmstatus&rdm,by=name,joinstyle=left/*left right full matched*/);
%else %AHGmergedsn(sdtmAll&rdm,sdtmInDir&rdm,sdtmstatus&rdm,by=name,joinstyle=right/*left right full matched*/);
%mend;
/* 
#####################################3
*/ 

%if %sysfunc(exist(specs.trackingsheet)) %then
  %do;
data adamAll&rdm;
  format Category  name $100.;
  set specs.trackingsheet(rename=(output_name=name));
  keep name category insheet;
  name=lowcase(name);
  category=upcase(category);
  if indexw('adam',trim(lowcase(category)));
  insheet=1;
run;
  %end;




%AHGpspipe(%str(ls |select  Name, @{Name='LastWriteTime';
Expression={$_.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')}}),path=&adam,out=adamInDir&rdm);

data adamInDir&rdm;
  set adamInDir&rdm; drop line;
  WHERE index(line,'.sas7bdat');
  format name $100. FileDate $500.;
  name=scan(scan(line,1,' '),1,'.');
  FileDate=left(substr(line,index(line,' ')));
  adam=1;
run;


%local nobs;

%AHGnobs(SDTMAll&rdm,into=nobs);

%AHGmergedsn(adamAll&rdm,adamInDir&rdm,adamstatus&rdm,by=name,joinstyle=full);


%macro dummy;
%if &nobs>0 %then %AHGmergedsn(adamAll&rdm,adamInDir&rdm,adamstatus&rdm,by=name,joinstyle=left/*left right full matched*/);
%else %AHGmergedsn(adamAll&rdm,adamInDir&rdm,adamstatus&rdm,by=name,joinstyle=right/*left right full matched*/);
%mend;

/* 
#####################################3
*/ 


%if %sysfunc(exist(specs.trackingsheet)) %then
  %do;
data tflAll&rdm;
  format Category  name $100.;
  set specs.trackingsheet(rename=(output_name=name ));
  keep name category insheet program_name display_id;
  name=lowcase(name);
  program_name=scan(program_name,1,'.');
  if missing(name) then name=program_name;
  category=upcase(category);
  if missing(name) then delete;
  if  not indexw('adam sdtm setup',trim(lowcase(category)));
  insheet=1;
run;
  %end;


%AHGpspipe(%str(ls  |select  Name, @{Name='LastWriteTime';
Expression={$_.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')}}),path=&tfl_output,out=TFLInDir&rdm);

data TFLInDir&rdm;
  set TFLInDir&rdm; drop line;
  WHERE index(line,'.rtf');
  format  name $100. FileDate $500.;
  name=scan(scan(line,1,' '),1,'.');
  FileDate=left(substr(line,index(line,' ')));
run;



%local nobs;

%AHGnobs(TFLAll&rdm,into=nobs);

%AHGmergedsn(TFLAll&rdm,TFLInDir&rdm,TFLstatus&rdm,by=name,joinstyle=full);


%macro dummy;
%if &nobs>0 %then %AHGmergedsn(TFLAll&rdm,TFLInDir&rdm,TFLstatus&rdm,by=name,joinstyle=left/*left right full matched*/);
%else  %AHGmergedsn(TFLAll&rdm,TFLInDir&rdm,TFLstatus&rdm,by=name,joinstyle=right/*left right full matched*/);
%mend;


data AllFile&rdm one;
  set adamstatus&rdm sdtmstatus&rdm tflstatus&rdm;;
  if missing(FileDate) then FileDate='-NA-';
  if not missing(program_name) then name=program_name;
run;

%AHGpspipe(%str(ls *.lst |select  Name, @{Name='LastWriteTime';
Expression={$_.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')}}),path=&__snapshot.programs_stat\sdtm\system_files,out=sdtmlog&rdm);

data sdtmlog&rdm;
  set sdtmlog&rdm; drop line;
  WHERE index(line,'.lst');
  format   name $100. LstDate $500.;
  name=scan(scan(line,1,' '),1,'.');
  LstDate=left(substr(line,index(line,' ')));
  if substr(name,1,1)='_' or name='' OR LstDate='LastWriteTime' then delete;
  output;
  if length(name)=2 then
  do;
  name='supp'||name;
  output;
  name=compress(tranwrd('relrec'||name,'supp',''));
  output;
  end;
run;


%AHGpspipe(%str(ls *.lst |select  Name, @{Name='LastWriteTime';
Expression={$_.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')}}),path=&__snapshot.programs_stat\adam\system_files,out=adamlog&rdm);

data adamlog&rdm;
  set adamlog&rdm; drop line;
  format  name $100. LstDate $500.;
  name=scan(scan(line,1,' '),1,'.');
  LstDate=left(substr(line,index(line,' ')));
  if substr(name,1,1)='_' or name='' OR LstDate='LastWriteTime' then delete;
  
run;

%AHGpspipe(%str(ls *.lst |select  Name, @{Name='LastWriteTime';
Expression={$_.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')}}),path=&__snapshot.programs_stat\tfl\system_files,out=tfllog&rdm);
 
data tfllog&rdm;
  set tfllog&rdm; drop line;
  format   name $100. LstDate $500.;
  if 'lst' ne scan(scan(line,1,' '),2,'.') then delete;
  name=scan(scan(line,1,' '),1,'.');
  LstDate=left(substr(line,index(line,' ')));
  if substr(name,1,1)='_' or name='' OR LstDate='LastWriteTime' then delete;
run;




data allLog&rdm;
  set adamlog&rdm sdtmlog&rdm tfllog&rdm ;;
run;



%AHGmergedsn( AllFile&rdm ,allLog&rdm, AllFile&rdm, by =name,joinstyle=left);


%AHGpspipe(%str(ls |select  Name, @{Name='LastWriteTime';
Expression={$_.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')}}),path=&__snapshot.replica_programs\sdtm\system_files,out=sdtm2nd&rdm);

data sdtm2nd&rdm;
  set sdtm2nd&rdm; drop line;
  WHERE index(line,'.lst');
  format   name $100. QCdate $500.;
  name=substr(scan(scan(line,1,' '),1,'.'),4);
  QCdate=left(substr(line,index(line,' ')));
  OUTPUT;
  name='supp'||name;
  output;
run;



%AHGpspipe(%str(ls |select  Name, @{Name='LastWriteTime';
Expression={$_.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')}}),path=&__snapshot.replica_programs\adam\system_files,out=adam2nd&rdm);

data adam2nd&rdm;
  set adam2nd&rdm; drop line;
  WHERE index(line,'.lst');
  format   name $100. QCdate $500.;
  name=substr(scan(scan(line,1,' '),1,'.'),4);
  QCdate=left(substr(line,index(line,' ')));
run;




%AHGpspipe(%str(ls |select  Name, @{Name='LastWriteTime';
Expression={$_.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')}}),path=&__snapshot.replica_programs\tfl\system_files,out=tfl2nd&rdm);

data tfl2nd&rdm;
  set tfl2nd&rdm; drop line;
  WHERE index(line,'.lst');
  format   name $100. QCdate $500.;
  name=substr(scan(scan(line,1,' '),1,'.'),4);
  QCdate=left(substr(line,index(line,' ')));
run;


data allval&rdm;
  set  sdtm2nd&rdm  adam2nd&rdm  tfl2nd&rdm;
run;
  



%AHGmergedsn(AllFile&rdm , allval&rdm,AllFile&rdm ,by=name,joinstyle=left/*left right full matched*/);

%local edslatest sdtmlatest adamlatest ;

/*%AHGpspipe(%str(ls *.sas7bdat|select  Name, @{Name='LastWriteTime';*/
/*Expression={$_.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')}}),path=&eds,out=eds&rdm);*/
/**/
/*data eds&rdm;*/
/*  set eds&rdm; drop line;*/
/*  array maxdate $15. _temporary_;*/
/*  WHERE index(line,'.sas7bdat');*/
/*  format Category  name $100. QCdate $100.;*/
/*  name=substr(scan(scan(line,1,' '),1,'.'),4);*/
/*  QCdate=left(substr(line,index(line,' ')));*/
/*run;*/



proc sql noprint;
  select distinct max(filedate) into :sdtmlatest
  from allfile&rdm
  where %AHGeqv(category,'sdtm') and not %AHGeqv(filedate,'-NA-');
  ;

  select distinct max(filedate) into :adamlatest
  from allfile&rdm
  where %AHGeqv(category,'adam')  and not %AHGeqv(filedate,'-NA-');
  ;
quit;


proc format ;
  value colorcd
  0=' '
  1='Log out-of-date /Not Done'
  2='QC out-of-date /Not Done'
  3='Source Dataset updated'
  9='File Not Created'
  ;
run;

data AllFile&rdm;
  set AllFile&rdm;
  array alldate filedate lstdate qcdate;

  /*File is created not by batch run*/
  do over alldate;
  if missing(alldate) then alldate='-NA-';
  end;



  do over alldate;
  alldate=trim(ALLDATE)||'``';
  end;


  if LstDate<FileDate then flag=1;

  /*QC is out-of-date*/
  if lstdate>QCdate and not (prxmatch('/\d{5}.*\d{5}/',name))then flag=2;

  /*adam is earlier than sdtm*/
  if (%AHGeqv(category,'adam') and Filedate<"&sdtmlatest")  or 
( folder='tfl' and (Filedate<"&adamlatest") )then flag=3;

  /*    File is not created*/
  if missing(FileDate) or FileDate='-NA-' then flag=9;

  FLAG=max(flag,0);
  format comment $50.;
  comment=put(flag,colorcd.);

  format str $200. folder;

  drop program_name str  INSHEET SDTM ADAM loc ext folder ;
  if category='SDTM' THEN  category='  SDTM' ;
  if category='ADAM' THEN  category=' ADAM' ;
  if prxmatch('/relrec\w+/',name) then delete;
/*  label filedate='Created' lstdate='Log Created by Batch run' qcdate='Validation Date'; */
  if (not insheet) and sdtm then category='~  SDTM';
  if (not insheet) and adam then category='~ ADAM';


  format loc $100. folder $50. ext $20.;
  IF INDEX(category,'SDTM') then folder='sdtm';
  else if INDEX(category,'ADAM') then folder='adam';
  else folder='tfl';

  if folder='tfl' then ext='rtf     ';
  else ext='sas7bdat';

  if folder='tfl' then loc='programs_stat\\tfl_output';
  else loc='data\\'||folder;;

    str= "s/([^`]*)`([^`]*)`([^`]*)/\1`\2`%sysfunc(tranwrd(&__snapshot,\,\\))"||trim(loc)||"\\"||trim(name)||'.'||trim(ext)||'/';;
    filedate=prxchange(trim(str),1,filedate);
    str= "s/([^`]*)`([^`]*)`([^`]*)/\1`\2`%sysfunc(tranwrd(&__snapshot,\,\\))programs_stat\\"||trim(folder)||"\\system_files\\"||trim(name)||'.lst/';;
    lstdate=prxchange(trim(str),1,lstdate);
    str= "s/([^`]*)`([^`]*)`([^`]*)/\1`\2`%sysfunc(tranwrd(&__snapshot,\,\\))replica_programs\\"||trim(folder)||"\\system_files\\ir_"||trim(name)||'.lst/';;
    qcdate=prxchange(trim(str),1,qcdate);


/*  comment=trim(comment)||'`'||%AHGputn(flag)||'`';*/

/*  if flag=2 then QCdate=prxchange('s/([^`]*)`([^`]*)`([^`]*)/\1`2`\3/',1,QCdate);*/
/*  ELSE if flag=3 then filedate=prxchange('s/([^`]*)`([^`]*)`([^`]*)/\1`3`\3/',1,filedate);*/
/*  ELSE if flag=9 then filedate=prxchange('s/([^`]*)`([^`]*)`([^`]*)/\1`9`\3/',1,filedate);*/

  %if not &showall %then if (not insheet)  then delete;;
  if   missing(name) then delete;
  order=category;
  if not ( index(lowcase(category),'sdtm') or index(lowcase(category),'adam')) then order='TFL';
run;

%AHGalltocharNew(AllFile&rdm);

data sdtmlabel&rdm;
  format label $500.;
  set specs.meta_table:;
  keep name label  ;
  name=lowcase(dataset);
  where not missing(dataset);
run;

%AHGmergedsn(AllFile&rdm,sdtmlabel&rdm,AllFile&rdm,by=name,joinstyle=left/*left right full matched*/);


data adamlabel&rdm;
  set specs.meta_adam_table:;
  keep name label  ;
  name=lowcase(dataset);
  where not missing(dataset);
run;

%AHGmergedsn(AllFile&rdm,adamlabel&rdm,AllFile&rdm,by=name,joinstyle=left/*left right full matched*/);

data tfllabel&rdm;
  set specs.meta_tfl;
  keep display_id  DESCRIPTION  ;
  display_id= DISPLAY_IDENTIFIER;
  rename DESCRIPTION=label;
  where not missing(DISPLAY_IDENTIFIER);
run;

%AHGmergedsn(AllFile&rdm,tfllabel&rdm,AllFile&rdm,by=display_id,joinstyle=left/*left right full matched*/);



%AHGdatasort(data = AllFile&rdm, by =order category name);

data AllFile&rdm;
  retain id 0;
  set AllFile&rdm;
  by order category name;
  array cols  LABEL  NAME  CATEGORY  COMMENT  ;
  do over cols;
  cols=trim(cols)||'`'||trim(flag)||'`';
  end;
  
  if first.order then id=1;
  else id+1;
run;

%AHGordvar(AllFile&rdm,id label name category filedate lstdate qcdate comment,out=,keepall=0);



option formdlim=' ' mprint;

/*%ahgcolorex(AllFile&rdm,flag=flag,file=,label=%str(  filedate='File Date' lstdate='Log Date' qcdate='Validation Date'  )) ; */

%ahgcolorex(AllFile&rdm,flag=flag,file=,label=%str(  filedate='File Date' lstdate='Log Date' qcdate='Validation Date'  )) ; 
 
%mend;


