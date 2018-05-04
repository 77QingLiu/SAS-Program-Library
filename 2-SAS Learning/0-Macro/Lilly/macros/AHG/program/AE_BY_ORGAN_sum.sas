/*%AHGdel(ahgtitle,like=1);*/
/*%AHG2arr(AHGtitle);*/
/*cards;*/
/*Summary of Protocol Deviations (Violations) by Type*/
/*All Entered Subjects*/
/*Final Analysis*/
/*I3Y-JE-JPBC*/
/*;*/
/*run;*/
/**/
/*%AHGdel(ahgft,like=1);*/
/*%AHG2arr(AHGft);*/
/*cards4;*/
/*abb*/
/*;;;;*/
/*run;*/
/**/
/*%AHGtitleft;*/
/**/


data dev(keep=id sys term) demog(keep=id TRT);
  do id=1 to 30;
/*  seed=ceil(normal(1254)*100000000);*/
  seed=id;
  call RANTBL(seed,0.2,0.2,0.2,0.2, 0.2,trt); 
  
  do loop=1 to 2;
  call RANTBL(seed,0.5,0.5,type); 
  sys='type'||put(type,1.);
  call RANTBL(seed,0.1,0.2,0.3,0.1, 0.3,value);
  term=sys||put(value,1.);
  if mod(seed,2)=0 then  output dev;
  end;
  output DEMOG;
  end;
run;

%AHGfreqCore(demog,trt ,out=bigN,print=1,keep=value frequency );


proc transpose data=bign out=tranN;
  var frequency;
  id value;
run;

data tranN;
  sys='';
  term='';
  set tranN; drop _name_;
run;


%AHGopendsn();


/**/
/*  %AHGopendsn(dsn=dev);*/
/*  */
/*  %AHGopendsn(dsn=demog);*/


proc sql;
  create table allsys as
  select distinct sys,'' as term
  from dev
  ;
  create table sysdefault as
  select sys,'' as term, id,trt,0 as yesno
  from demog,allsys
  ;

  create table sysYes as
  select distinct sys,'' as term, id,1 as yesno
  from dev
  ;
  quit;

  %AHGmergedsn(sysdefault,sysYes,readysys,by=id sys term,joinstyle=full/*left right full matched*/);

/**/
/*  %AHGopendsn();*/

/**/
/*%AHGopendsn(dsn=class);*/
/*%AHGopendsn(dsn=demog);*/
/**/
%AHGdatasort(data =readySys , out = , by =trt sys term);
%AHGfreqCore(readysys,yesno,by=trt sys term,out=sysfreq,print=0,keep=value frequency percent);


data sysfreq;
   set sysfreq;
   if value=0 and percent=100 then
   do;
   value=1;
   percent=0;
   frequency=0;
   end;
   cell=put(frequency,3.)||'('||put(percent,5.2)||')';
   if value=1;
run;

%AHGdatasort(data = sysfreq, out = , by = sys term);

proc transpose data=sysfreq out=systran(drop=_name_);
  var cell;
  id trt;
  by sys term;
run;



%AHGsetprint(TranN systran,out=syssetprint,print=1);

%AHGopendsn();

proc sql;
  create table allterm as
  select distinct sys, term
  from dev
  ;
  create table termdefault as
  select sys,term, id,trt,0 as yesno
  from demog,allterm
  ;

  create table termYes as
  select distinct sys, term, id,1 as yesno
  from dev
  ;
  quit;

%AHGmergedsn(termdefault,termYes,readyterm,by=id sys term,joinstyle=full/*left right full matched*/);



%AHGdatasort(data =readyterm , out = , by =trt sys term );
%AHGfreqCore(readyterm,yesno,by=trt sys term ,out=termfreq,print=0,keep=value frequency percent);


data termfreq;
   set termfreq;
   if value=0 and percent=100 then
   do;
   value=1;
   percent=0;
   frequency=0;
   end;
   cell=put(frequency,3.)||'('||put(percent,5.2)||')';
   if value=1;
run;

%AHGdatasort(data =termfreq , out = , by =sys term );

proc transpose data=termfreq out=termtran(drop=_name_);
  var cell;
  id trt;
  by sys term;
run;


%AHGsetprint(TranN termtran,out=termsetprint,print=1);

%AHGopendsn();


%AHGsetprint(systran termTran,out=systerm,print=1);
%AHGrenamekeep(sysTerm,out=,pos=,names=sys term c1 c2 c3 c4 c5);
%AHGdatasort(data =systerm , out = , by = sys term);
data systerm;
  set systerm;
  if not missing(term) then sys='';
run;

%AHGsetprint(TranN systerm ,out=systerm,print=1);
%AHGopendsn();
