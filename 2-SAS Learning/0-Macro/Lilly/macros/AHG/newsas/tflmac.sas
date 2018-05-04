%macro ahg1(m,str);
    %if not %AHGblank(&m) %then &str;
%mend;




%macro AHGaddcomma(mac,comma=%str(,) );
%if %AHGnonblank(&mac) %then %sysfunc(tranwrd(     %sysfunc(compbl(&mac)),%str( ),&comma       ))   ;
%mend;




%macro AHGallchar(dsn,into=);
%local allchar ;
%AHGgettempname(allchar);
data deletefromithere;
%AHGvarinfo(&dsn,out=&allchar,info= name  type );

data &allchar;
  set &allchar(where=(type='C'));
run;

%AHGdistinctValue(&allchar,name,into=&into,dlm=%str( ));
data writetofilefromithere;


%mend;




%macro AHGalltocharnew(dsn,out=%AHGbasename(&dsn),rename=,zero=0,width=100);
%local i varlist informat nobs varinfo  %AHGwords(cmd,100);
%AHGgettempname(varinfo);
 
%AHGvarinfo(&dsn,out=&varinfo,info= name  type  length num);
data deletefromithere;
data _null_;
  set &varinfo;
  format cmd $200.;
  if type='N' then cmd='input(left(put('||name||',best.)),$'||"&width"||'.) as '||name;
  else cmd=name ;
    call symput('cmd'||%AHGputn(_n_),cmd);
  call symput('nobs',%AHGputn(_n_));
run;
data writetofilefromithere;

/*%AHGdatadelete(data=&varinfo);*/

proc sql noprint;
  create table &varinfo(drop= AHGdrop) as
  select ' ' as AHGdrop 
    %do i=1 %to &nobs;
    %local zeroI;
    %if &zero %then %let zeroI=%AHGzero(&i,z&zero.);
    %else %let zeroI=&i;
  ,&&cmd&i %if not %AHGblank(&rename) %then as &rename&zeroI;
  %end;
  from &dsn
  ;quit;

%AHGrenamedsn(&varinfo,&out);

%mend;








%macro AHGbareName(dsn);
	%ahgbasename(%ahgpurename(&dsn))
%mend;




%macro AHGbasename(dsn);
	%if %index(&dsn,.) %then %scan(&dsn,2,%str(.%());
	%else %scan(&dsn,1,%str(.%());
%mend;




%macro AHGblank(string);
	%if %length(%bquote(&string)) %then 0 ;
	%else 1;
%mend;




%macro AHGclearglobalmac(begin=);
%local allmac len;
%if %AHGblank(&begin) %then %let len=0;
%else %let len=%length(&begin);
%AHGgettempname(allmac);
data deletefromithere; 
  data &allmac;
    set sashelp.vmacro(keep=name scope);
    where scope='GLOBAL' and (substr(upcase(name),1,&len)=upcase("&begin") or %AHGblank(&begin));
  run;  
  
  

    %local drvrmacs;    
    proc sql noprint;
    select '/* clear '||name||'*/'||' %symdel '|| name || '/NOWARN ;' into :drvrmacs separated by ' '
    from &allmac
    ;
    quit;
    %PUT %NRBQUOTE(&DRVRMACS);
    &drvrmacs;
data writetofilefromithere;
%mend;




%macro AHGcolumn2Mac(dsn,mac,vars,global=0);
	%if &global %then %global &mac;
	%local i ahuige456436;
	%let ahuige456436=sdksf4543534534;
  data deletefromithere; 
	data _null_;
		format  &ahuige456436 $10000.;
		retain &ahuige456436 '';
		set &dsn end=end;
		%do i=1 %to %AHGcount(&vars);
		&ahuige456436=Trim(&ahuige456436)||' '||%scan(&vars,&i);
		%end;

		if end then call symput("&mac",compbl(&ahuige456436));
	
	run;
  data writetofilefromithere;
%mend;




%macro AHGcount(line,dlm=%str( ));
  %local i AHG66TheEnd;
  %let i=1;
  %do %until(&AHG66TheEnd=yes);
      %if  %qscan(%bquote(&line),&i,&dlm) eq %str() %then
      %do;
      %let AHG66TheEnd=yes;
      %eval(&i-1)
      %end;
    %else %let i=%eval(&i+1);
  %end;

%mend;




%macro 	AHGcreateHashex(HashID,Pairs,dlm=%str( ),dlm2=%str( ));
%AHGclearglobalmac(begin=&hashID);
%local i;
%global &hashid.list;
%let &hashid.list=;

%if &dlm ne %str( ) or &dlm2 ne %str( ) %then
	%do i= 1 %to %AHGcount(&pairs,dlm=&dlm);
	%let &hashid.list=&&&hashid.list %AHGscan2(&pairs,&i,1,dlm=&dlm,dlm2=&dlm2);
	%local id;
	%let id=&hashid&i;
	%global  &id;
	%let &id=%AHGscan2(&pairs,&i,2,dlm=&dlm,dlm2=&dlm2);
	%end;
%else
	%do;
		%local localpairs;
		%let localpairs=&pairs;
		%let i=0;
		%do %while(not %AHGblank(&localpairs));
		%AHGincr(i);
		%local id;
		%let &hashid.list=&&&hashid.list %AHGleft(localpairs);
		%let id= &hashID&i ;
		%global &id;
		%let &id=%AHGleft(localpairs);
		%end;
	%end;

%mend;




%macro ahgD(d=%str(,));
%if &i ne 1 %then &d; 
%MEND;





%macro AHGdatadelete(lib = , data = );
  proc datasets 
    %if %length(&lib) %then %do; lib = &lib %end;
    %else %do; lib = work %end;
    %if not %length(&data) %then %do; kill %end;
    memtype = data nolist   nodetails
  ;
		%if %length(&data) %then %do; delete &data; %end;
	run;
	quit;
%mend ;





%macro AHGdatasort(data = , out = , by = );
  %if %AHGblank(&out) %then %let out=%AHGbarename(&data);
  proc sort 
    %if %length(&data) %then data = &data;
    %if %length(&out) %then out = &out;
  ;
    by &by;


  run;
%mend ;




%macro AHGdistinctvalue(dsn,var,sort=1,into=,dlm=@,quote=0);
%local item varIsNum ;
%let varIsnum=1;

%if   &quote %then %AHGvarisnum(&dsn,&var,into=varIsNum);

%let item=&var;
%if %eval(&quote and not &varIsNum )%then %let item=quote(&var);

%if not &sort %then
  %do;
  data _null_;
    format line&var $32333.;
    retain line&var;
    set &dsn(keep=&var) end=end;
    line&var=catx("&dlm",line&var,&var);
    if end then call symput("&into",line&var);
  run;
  %end;
%else 
    %do;
    proc sql noprint;
    select distinct 

    &item 
    into :&into separated by "&dlm"
    from &dsn
    ;quit;
    %end;
%let &into=%trim(&&&into);

%mend;




%macro AHGequalmactext(text1,text2);
	(%upcase(&text1)=%upcase(&text2))
%mend;




%macro AHGequaltext(text1,text2);
	(upcase(&text1)=upcase(&text2))
%mend;




%macro AHGfreeloop(dsn,byvars
,cmd=
,out=outAhuige
,in=Ahuige
,url=
,bydsn=&url.BY
,execute=1
,del=1
,addLoopVar=0
,low=0
,up=99999999
,printstr=dataset:&dsn @cmd:&cmd @ by:&byvars);
/*
1 New dsn: &url.by(1)  &url&outone.&i (N*O)
2  New Mac: &url.N

*/
%if %AHGblank(&url) %then %let url=_%substr(%AHGrandom,1,3);
%if %AHGblank(&cmd) %then %let cmd= put abc ;
%let cmd=%nrstr(%%)&cmd;
/*%AHGdatadelete(data=&url:);   */
%global &url.N;    
%let &url.N=0;


proc sql noprint;
  create table &bydsn as
  select distinct %AHGaddcomma(&byvars)
  from &dsn
  order by  %AHGaddcomma(&byvars)
  ;quit;
%local i byn;

%AHGnobs(&bydsn,into=&url.N);

data
%do i=1 %to &&&url.N;
&url&i
%end;
;
  set &bydsn;
  %do i=1 %to &&&url.N;
  if _n_=&i then output &url&i ;
  %end;
run;

%do i=1 %to &&&url.N;

%if &del %then
  %do;
  %AHGmergedsn(&url&i,&dsn,&in,by=&byvars,joinstyle=left/*left right full matched*/);
  %end;
%else
  %do;
  /* if not del then the temp &url&i dsn is there */
  %AHGmergedsn(&url&i,&dsn,&url&i,by=&byvars,joinstyle=left/*left right full matched*/);
  data &in ;
    set  &url&i;
  run;
  %end;


%AHGpm(cmd);
%if &execute=1 %then
  %do;
  %put ######################freeloopNo&i;
  %put &printstr;
  %if %eval(&low<=&i) and %eval(&i<=&up) %then
    %do;
    %unquote(&cmd);
    %local j OneOut;
      %do j=1 %to %AHGcount(&out);
        %let OneOut=%scan(&out,&j);
        data &url&OneOut&i;
          set  &OneOut;
          %if &addLoopVar %then
          %do;
          point=&i;
          set &bydsn point=point;
          %end;
        run;
      %end;
    %end;
  
  
  %end;
  
  
%end;


/*%AHGdatadelete(data=&in &out  %if &del %then %do i=1 %to &&&url.N; &url&i %end;);*/

%mend;





%macro AHGfreqCore(dsn,var,by=,out=,print=0,rename=1,
keep=cell frequency percent,tran=
,tranBy=
,cell=put(frequency,4.)||' ('||left(put(percent,5.1))||')'
);
%if %AHGblank(&out) %then %let out=&sysmacroname;
ods listing close;
proc freq data=&dsn(keep=&var &by  );
    table &var;
    %if not %AHGblank(&by) %then by &by;;
    ods output OneWayFreqs=&out(keep=&var  CUMFREQUENCY percent  frequency &by);
run;
ods listing;

%if %AHGpos(&keep,cell) %then 
%do;
data &out;
  set &out;
  cell=&cell;
run;
%end;

%if &rename %then 
%do;
data &out;
  set &out(rename=(&var=value));
run;
%end;


%if not %AHGblank(&tran) %then 
%do;

data &out.Notran;
  set &out;
run;
%if not %AHGblank(&TranBy) %then %AHGdatasort(data =&out , out = , by =&TranBy ) ;

proc transpose data=&out out=&out(drop=_name_);
  var 
  %if %AHGpos(&keep,cell)  %then cell;
  %else 
%AHGremoveWords(&keep,value &var,dlm=%str( )) ;
  ;
  id &tran;
  ;
  %if not %AHGblank(&TranBy) %then by &TranBy; ;
run;

%end;
%else 
  %do;
  data &out;
    set &out(keep=&keep &by %if not &rename %then &var; %else value;);
  run;
  %end;



%if &print %then %AHGprt;
%mend;




%macro AHGfuncloop(func,loopvar=ahuige,loops=,dlm=%str( ),execute=yes,pct=1);
  %local i j cmd perccmd;
  %let j=%AHGcount(&loops,dlm=&dlm);
  %do i=1 %to &j;
  %let cmd=%sysfunc(tranwrd(&func,&loopvar,%scan(&loops,&i,&dlm)));
  %if &pct %then %let perccmd=%nrstr(%%)&cmd;
  %else %let perccmd=&cmd;
  %if &execute=yes or &execute=y %then %unquote(&perccmd);
  %else %put &perccmd;
  %end;
%mend;




%macro AHGgettempname(tempname,start=,useit=0);
  
  %if %AHGblank(&start) %then %let start=T_&tempname;
  %if %length(&start)>10 %then %let start=%substr(&start,1,10);
  %local  ahg9rdn  i;
  %do %until (not %sysfunc(exist(&&&tempName))  );
  %let ahg9rdn=;
  %do i=1 %to 7;
  %let ahg9rdn=&ahg9rdn%sysfunc(byte(%sysevalf(65+%substr(%sysevalf(%sysfunc(ranuni(0))*24),1,2))) ); 
  %end;
  %let &tempname=&start._&ahg9rdn;
  %end;
  %put &tempname=&&&tempname;
  %if &useit %then
  %do;
  data &&&tempname;
  run;
  %end;


%mend;




%macro AHGhashvalue(hashid,handle);
	%local idx out;
	%let indx=%AHGindex(&&&hashid.list,&handle);
	%let  out=&&&hashid&indx;
	&out
%mend;




%macro AHGincr(mac,by=1);
	%let &mac=%eval(&by+&&&mac);
%mend;




%macro AHGindex(full,sub,dlm=%str( ),case=0,lastone=0);
	%local index i;
	%if not &case %then
		%do;
		%let full=%upcase(&full);
		%let sub=%upcase(&sub);
		%end;
	%let  index=0;
	%do i=1 %to %AHGcount(&full,dlm=&dlm);
	%if %scan(&full,&i,&dlm)=&sub %then 
		%do;
		%let index=&i;
		%if not &lastone %then %goto indexExit;
		%end;
	%end;
	%indexExit:
	&index
%mend;




%macro AHGleft(arrname,mac,dlm=%str( ),global=0);
  %let &arrname=%sysfunc(left(%str(&&&arrname)));

  %local i count localmac;
  %let count=%AHGcount(&&&arrname,dlm=&dlm);
  %if &count<=1 %then 
    %do;
    %let localmac=&&&arrname;
    %let  &arrname=;
    %end;
  %else
    %do;
    %let localmac=%scan(&&&arrname,1,&dlm);
    %let &arrname=%substr(&&&arrname,%index(&&&arrname,&dlm)+1);
    %end;
  %if &global %then %global &mac;   
  %if %AHGblank(&mac) %then &localmac;
  %else %let &mac=&localmac;
%mend;




%macro AHGmergedsn(dsn1,dsn2,outdsn,by=,rename=1,joinstyle=full/*left right full matched*/);
%local mergedsn1 mergedsn2;
%if &rename %then
%do;
%AHGGetTempName(mergedsn1,start=%sysfunc(tranwrd(%scan(&dsn1,1,%str(%()),.,_))_);
%AHGGetTempName(mergedsn2,start=%sysfunc(tranwrd(%scan(&dsn2,1,%str(%()),.,_))_);
%end;
%else
%do;
%let mergedsn1=&dsn1;
%let mergedsn2=&dsn2;
%end;
%AHGdatasort(data =&dsn1 , out =&mergedsn1 , by =&by );
%AHGdatasort(data =&dsn2 , out =&mergedsn2 , by =&by );
%local ifstr;
%if %lowcase(&joinstyle)=full %then %let ifstr=%str(ind1 or ind2);
%if %lowcase(&joinstyle)=matched %then %let ifstr=%str(ind1 and ind2);
%if %lowcase(&joinstyle)=left %then %let ifstr=%str(ind1 );
%if %lowcase(&joinstyle)=right %then %let ifstr=%str(ind2 );
data &outdsn;
    merge  &mergedsn1(in=ind1) &mergedsn2(in=ind2) ;
    by &by;
    if &ifstr;
run;
%AHGdatadelete(data=&mergedsn1 &mergedsn2);
/*
%local i;
%if %lowcase(&joinstyle)=matched %then %let joinstyle=;
proc sql noprint;
    create table &outdsn as
    select *
    from &dsn1 as l &joinstyle join &dsn2 as r
    on 1 %do i=1 %to %AHGcount(&by);
       %bquote( and L.%scan(&by,&i)=r.%scan(&by,&i)   )
       %end;
       ;quit;
 */
%mend;




%macro AHGmergeprintEx(
dsns
,by=
,keep=
,drop=,
label=label
,out=mergeprintout,print=1
,prefix=ahuigecol
,clean=1
);

%local i dsnN  J ;
%let dsnN=%AHGcount(&dsns);
%local %AHGwords(Printing,&dsnN);


%do i=1 %to &dsnN;
%let printing&i=;
%AHGgettempName(printing&i);
%end;
%do i=1 %to &dsnN;
%local varlist;
%let varlist=;
%AHGvarlist(%scan(&dsns,&i,%str( )),Into=varlist);
%AHGpm(printing&i);
data &&printing&i;
    set %scan(&dsns,&i,%str( ))
( 
drop=&drop 
%do j=1 %to %AHGcount(&varlist);
%if not %sysfunc(indexw(%upcase(&by &keep &drop),%upcase(%scan(&varlist,&j))  )  )
	 and  %lowcase(%scan(&varlist,&j)) ne ahuigebylabel
	%then rename=(%scan(&varlist,&j)=&prefix._%sysfunc(putn(&i,z2.))_%sysfunc(putn(&j,z2.))    ) ;
%end;
);
/*%do j=1 %to %AHGcount(&varlist);*/
/*label &prefix._%sysfunc(putn(&i,z2.))_%sysfunc(putn(&j,z2.))="%scan(&varlist,&j)";*/
/*%end;*/

run;

%end;
data &out;
	set &printing1;
run;
 %do i=2 %to &dsnN;
%AHGmergedsn(&out,&&printing&i  ,&out,by=&by,joinstyle=full/*left right full matched*/);
%end;   ;



%if &clean %then 
%do;
%AHGdatadelete(data=
%do i=1 %to &dsnN;
 &&printing&i  
 %end;
 );
%end;

%if &print %then
%do;
proc print &label noobs;
run;
%end;


%mend;





%macro AHGname(stats,but=);
%local out final;
%let out=%sysfunc(translate(%bquote(&stats),__,%str(%')%str(%")));
%let out=%sysfunc(compress(&out));
%local i one rank;
%do i=1 %to %length(&out);
%let one=%bquote(%substr(&out,&i,1));
%if %SYSFUNC(NOTALNUM(%bquote(&one))) and not %index(&but,%bquote(&one)) %then %let final=&final._;
%else %let final=&final.%bquote(&one);
%end;
&final
%mend; 




%macro AHGnobs(dsn,into=);
  %if %sysfunc(exist(&dsn)) %then
  %do;
  proc sql noprint;
  select count(*) into :&into
  from &dsn
  ;quit;
  %end; 
  %else %let &into=0;
%mend;




%macro AHGnonblank(str);
  not %AHGblank(&str)
%mend;




%macro AHGordvar(dsn,vars,out=,keepall=0);
%local sql;
%AHGgettempname(sql);
%if &keepall %then
  %do;
  %local restvardsn ;
  %let restvardsn=;
  %AHGgettempname(restvardsn);  
  
  data &restvardsn;
    set &dsn(drop=&vars);
  run;
  %end;
%if %AHGblank(&out) %then %let out=%AHGbasename(&dsn);
proc sql;
  create table &sql as
  select %AHGaddcomma(&vars)
  from  &dsn(keep=&vars)
;quit;



%if &keepall %then
%do;

data &sql ;
  merge &sql &restvardsn;
run;
%end;
%else 
%do;
data &out;
  set &sql;
run;
%end;


%mend;




%macro AHGpm(Ms);
  %local Pmloop2342314314 mac;
  %do Pmloop2342314314=1 %to %AHGcount(&Ms);
    %let mac=%scan(&Ms,&Pmloop2342314314,%str( ));
    %put &mac=&&&mac;
  %end;
%mend;





%macro AHGpos(string,word);
	%let string=%upcase(&string);
	%let word=%upcase(&word);
	%index(&string,&word)
%mend;




%macro AHGprt(dsn=_last_,label=label);
proc print data=&dsn noobs &label;run;
%mend;




%macro AHGpureName(dsn);
	%if %index(&dsn,%str(%()) %then %scan(&dsn,1,%str(%());
	%else &dsn;
%mend;




%macro ahgputn(var,fmt);
%if %AHGblank(&fmt) %then %let fmt=best.;
left(put(&var,&fmt))
%mend;




%macro AHGrandom;
  %local  rdn ;
  %let rdn=%sysfunc(normal(0));
	%let rdn=%sysfunc(translate(&rdn,00,.-));
  &rdn
  %put random=&rdn;
%mend;




%macro AHGrdm(length,seed=0);
%local i rdn;
%if %AHGblank(&length) %then %let length=5;
%do i=1 %to &length;
  %let rdn=&rdn%sysfunc(byte(%sysevalf(65+%substr(%sysevalf(%sysfunc(ranuni(&seed))*24),1,2))) ); 
%end;
&rdn
%mend;





%macro AHGremovewords(sentence,words,dlm=%str( ));
	%local i j CountS CountW final found itemS ;
	%let sentence=%bquote(&sentence);
	%let words=%bquote(&words);
	%let  CountS=%AHGcount(&sentence,dlm=&dlm);
	%let  CountW=%AHGcount(&words,dlm=&dlm);

	%let final=&dlm;
	%do i=1 %to &Counts;
		%let found=0;
		%let itemS=%scan(&sentence, &i,&dlm);
		%let j=0;
		%do %until (&j=&countW or &found) ;
		    %AHGincr(j)
	
			%if %upcase(&itemS)= %upcase(%scan(&words, &j,&dlm)) %then %let found=1;
		%end;
		%if &found=0 %then %let final=&final&dlm&itemS;
	%end;
	%let final=%sysfunc(tranwrd(&final,&dlm&dlm,));
	 &final
%mend;




%macro AHGrenamedsn(dsn,out);
%if not %sysfunc(exist(&out)) %then
  %do;
  %if not %index(&dsn,.) %then %let dsn=work.&dsn;
  %local lib ds dsout;
  %let lib=%scan(&dsn,1);
  %let ds=%scan(&dsn,2);
  proc datasets library=&lib;
     change &ds=%scan(&out,%AHGcount(&out,dlm=.));
  run;
  %end;
%else 
  %do; data %scan(&out,%AHGcount(&out,dlm=.));set &dsn;run;  %end; 


%mend;




%macro AHGrenamekeep(dsn,out=,pos=,names=,prefix=col,keepall=0);
  %if %AHGblank(&names) %then %let names=%AHGwords(&prefix,400);
  %if %AHGblank(&out) %then %let out=%AHGbarename(&dsn);
  %local varlist count;
  %AHGvarlist(&dsn,Into=varlist,dlm=%str( ),global=0);
  %let count=%sysfunc(min(%AHGcount(&varlist),%AHGcount(&names)));
  option symbolgen;
  %if %AHGblank(&pos) %then %let pos=%AHGwords(%str( ),&count);
  %AHGpm(pos);
  option nosymbolgen;
  
  data &out;
    set &dsn;
    %local i;
    %if not &keepall %then
      %do;
      keep
      %do i=1 %to &count;
        %scan(&varlist, %scan(&pos,&i))
      %end;
      ;
      %end;
    rename
    %do i=1 %to &count;
    %scan(&varlist, %scan(&pos,&i))=%scan( &names,&i)
    %end;
    ;
  run;
%mend;




%macro AHGreportby(dsn,by,ls=123,ps=45,flow=flow,widthmax=50,which=,
whichlength=,sort=0,groupby=0,groupto=0,topline=,showby=0,
option=nowd nocenter headline,labelopt=%str(option label;));
  %local rptdsn;
  %if %AHGblank(&by) %then %let by=0; 
  %AHGgettempname(rptdsn);
  data &rptdsn;
  %if &by=0 %then
  %do;
  ahuige34xbege5435='_';
  %let by=ahuige34xbege5435;
  %let showby=0;
  %end;
  set &dsn;
run;


  %local i varlist showlist;
  &labelopt;
/*  %if not &showby %then %let showlist=%AHGremoveWords(&varlist,&by,dlm=%str( ));*/
/*  %else %let showlist=&varlist;*/
  %if &sort %then
  %do;
  proc sort data=&rptdsn ; by &by;run;
  %end;
  %AHGvarlist(&rptdsn,Into=varlist,dlm=%str( ),global=0);
  data deletefromithere;
  %AHGvarinfo(&rptdsn,out=varinfo34589,info= name  length);
  data writetofilefromithere;

  %local infostr;
  %AHGcolumn2mac(varinfo34589,infostr,name length);
  %local rdm;
  %let rdm=%AHGrandom;
  %AHGcreatehashex(my&rdm.hash,&infostr);
  %put #####################;
  %let showlist=%AHGremoveWords(&varlist,&by,dlm=%str( ));
  &labelopt;
  
  proc report data=&rptdsn &option ;
    column
    %if %AHGblank(&topline) %then  &by &showlist;
    %else %if %index( %bquote(&topline) , %str( %( )    ) %then &topline;
    %else ( &topline &by &showlist );
    ;
    %do i=1 %to  %AHGcount(&by);
    %if &showby %then
    %do;
    define %scan(&by,&i)/order
    %if not &groupby %then display &flow;
    %else group;
    %end;
    %else  define %scan(&by,&i)/order noprint;

    
    ;
    %end;
    %local loop;
    %let loop=0;
    %do i=1 %to %AHGcount(&showlist);
    %local mylength;
    %local handle thePos;
    %let handle=%scan(&showlist,&i);
    %let mylength=%AHGhashvalue(my&rdm.hash,&handle);
/*    %if &mylength>&widthmax %then %let  mylength=*/
    %let mylength=%sysfunc(min(&widthmax,%sysfunc(max(&mylength,%length(&handle)))));
    define  %scan(&showlist,&i)  /
        %if %sysfunc(indexw(&which,&i))  %then %do;%let loop=%eval(&loop+1);width=%scan(&whichlength,%AHGindex(&which,&i))   %end;
    %else %str(width=)&mylength;
        %if &i<=&groupto %then group;
        %else display &flow;
          ;
    %end;
/*    by &by;*/
/*  compute before _page_ ;*/
/*        line @1 &ls.*"_";*/
/*    line @1 " ";*/
/*    endcomp;*/
/**/
/*  compute after _page_;*/
/*        line @1 &ls.*"_";*/
/*    endcomp;    */
  run;
  
%mend;




%macro AHGscan2(mac,i,j,dlm=\,dlm2=#);
	%scan(%scan(&mac,&i,&dlm),&j,&dlm2)
%mend;




%macro AHGsetstatfmt(statfmt=);
%local i statement allstatfmt;
%let allstatfmt=n\5. std\6.2 mean\6.1 median\6.1 min\6.1 max\6.1 lclm\6.2 uclm\6.2 p25\6.2 p50\6.2 p75\6.2;
%do i=1 %to %AHGcount(&statfmt);
  %if %index(%scan(&statfmt,&i,%str( )),\) %then %let allstatfmt=&allstatfmt %scan(&statfmt,&i,%str( ));
%end;
%do i=1 %to %AHGcount(&allstatfmt);
%let statement=%nrstr(%global) formatof%scan(%scan(&allstatfmt,&i,%str( )),1,\);
%unquote(&statement);
%if %AHGblank(%scan(%scan(&allstatfmt,&i,%str( )),2,\)) %then %let formatof%scan(%scan(&allstatfmt,&i,%str( )),1,\)=6.2;
%else %let formatof%scan(%scan(&allstatfmt,&i,%str( )),1,\)=%scan(%scan(&allstatfmt,&i,%str( )),2,\);

%end;

%mend;




%macro AHGsortWords(words,into=,dlm=%str( ),length=100,nodup=1);
  %local i sortdsn;
  %AHGgettempname(sortdsn);

  data &sortdsn;
    length word $&length.;
    %do i=1 %to %AHGcount(&words,dlm=&dlm);
    word=scan("&words",&i,"&dlm");
    output;
    %end;
  run;

  proc sql noprint;
  select %if &nodup %then distinct; trim(word) as word into :&into separated by "&dlm"
  from &sortdsn
  order by word
  ;
  quit;

  %AHGdatadelete(data=&sortdsn);

%mend;






%macro AHGsumextrt(dsn,var,by=,trt=,out=stats,print=0,alpha=0.05
,stats=n mean median  min max
 /* min\4. median\5.1 max\4. */
 /*n @ min '-' max*/
,orie=vert
,labels=
,left=left
,statord=
);
%local thedsn byflag;
%if %AHGblank(&statord) %then %let statord=ahgdummy%AHGrdm(10);
%AHGgettempname(thedsn);
%if %AHGblank(&by) %then 
%do;
%let byflag=missing;
%let by=%AHGrdm(10);
%end;
data &thedsn;
  set &dsn;
 %if &byflag=missing %then  &by=1; ;
run;



%local fn;
%let fn=ahgxxxyyyzzz;
%macro ahgxxxyyyzzz(one);
  %IF not  (%index(&one,%str(%")) or %index(&one,%str(%'))) %THEN 1;
  %ELSE 0;
%mend;
/*%local finallabel;*/
/*%let finallabel=%AHGname(&stats,but=@);*/

%if %index(&stats,@)=0 %then %let stats=%AHGaddcomma(&stats,comma=@);
%macro dosomething;
%local i j one;
%do i=1 %to %AHGcount(&stats,dlm=@);
  %let one=%scan(&stats,&i,@);
  %let labels=&labels@;
  %do j=1 %to %AHGcount(&one);
    %let labels=&labels %AHGscan2(&one,&j,1,dlm=%str( ),dlm2=\);
  %end;
%end;
%let labels=%substr(&labels,2);
%mend;
%if %AHGblank(&labels) %then %doSomething ;
%if not %AHGblank(&labels) and not %index(&labels,@) %then %let labels=%AHGaddcomma(&labels,comma=@);
%local finallabel;
%let finallabel=%AHGname(&labels,but=@);
%AHGpm(finallabel);
%let finallabel=%sysfunc(tranwrd(&finallabel,@,%str( )));
%AHGpm(finallabel);

/*if no explicit definition of orientation then use @ as criteria*/
%if   %AHGblank(&orie)  %then   %if %index(&stats,@) %then %let orie=vert ;%else  %let orie=hori;
%local localstats;
%let localstats=&stats;
%let stats=%sysfunc(tranwrd(&stats,@,%str( )));
%local statN single %AHGwords(mystat,20)
  %AHGwords(myformat,20) %AHGwords(ISstat,20);
%local i sortdsn mystats;
%AHGgettempname(sortdsn);


%do i =1 %to %AHGcount(&stats);
  %let single=%scan(&stats,&i,%str( ));
  %if %&fn(&single) %then %let mystats=&mystats &single ; /*mystats are real stats*/
%end;

%AHGsetstatfmt(statfmt=&mystats);
%let statN=%AHGcount(&stats);

%do i=1 %to &statN;
  %let single=%scan(&stats,&i,%str( ));
  %let mystat&i=%scan(&single,1,\);
  %let myformat&i=%scan(&single,2,\);
  %if %AHGblank(&&myformat&i) and %&fn(&&mystat&i) %then 
  %do;
  %global formatof&&mystat&i;
  %let myformat&i=&&&&formatof&&mystat&i;
  %if %AHGblank(&&myformat&i) %then %let myformat&i=7.2;
  %end;
  %if %&fn(&&mystat&i)  %then %AHGpm(mystat&i myformat&i);
%end;

%AHGdatasort(data =&thedsn , out = , by = &by &trt);

  proc means data=&thedsn noprint %if %AHGnonblank(&alpha) %then alpha=&alpha;;
    var &var;
    by &by &trt;
    output 
    /**/
    %local everyone;
    %let everyone= %str(out=&out ) ;
    %do i=1 %to  &statN;
    %if %&fn(&&mystat&i) %then  %let everyone=&everyone &&mystat&i  %bquote(=)  &&mystat&i;
    %end;
    &everyone
    ;
  run;

%macro ahgD(d=%str(,));
%if &i ne 1 %then &d; 
%MEND;

  proc sql noprint;
    create table temp&out as
    select
    %do i=1 %to  %AHGcount(&stats);
      %if %&fn(&&mystat&i) %then %AHGd &left(put(&&mystat&i, &&myformat&i)) as  &&mystat&i ;
      %else  %AHGd &&mystat&i;
    %end;
    %AHG1(&by,%bquote(,%AHGaddcomma(&by)))
    %AHG1(&trt,%str(,&trt))
    from &out
    ;
    create table &out as
    select *
    from temp&out

    ;quit;

%if %substr(&sysmacroname,1,3)=AHG %then  
%do;

%local varlist varN bigsingle statement;
%AHGvarlist(&out,Into=varlist,dlm=%str( ),global=0);
%local  num indx  ;
%let indx=0;
%let varN=%AHGcount(&localstats,dlm=@);
%AHGpm(varN);
%do i=1 %to &varN;
  %let bigsingle=%scan(&localstats,&i,@);
  %do num=1 %to %AHGcount(&bigsingle);
  %let indx=%eval(&indx+1);
  %if &num=1 %then %let statement= &statement   %str(theVerticalvar&i=compbl%() %scan(&varlist,&indx);
  %else  %let statement= &statement ||'  '|| %scan(&varlist,&indx);
  %if &num=%AHGcount(&bigsingle) %then  %let  statement= &statement %str(%););
  %end;
%end;

%local vertdsn;
%AHGgettempname(vertdsn);

data &vertdsn;
  set &out;
  keep   %AHG1(&trt,&trt) &BY %do i=1 %to  &varN; theVerticalvar&i  %end;  ;
    %unquote(&statement);
run;

data hori&out;
  set &out;
run;

data &out;
  set &vertdsn;
  keep &BY  
  %AHG1(&labels,label) 
  %AHG1(&statord,&statord) 
  %AHG1(&trt,&trt)
  stat;
  array allvar(1:&varN) theVerticalvar1-theVerticalvar&varN;
  do i=1 to dim(allvar);
  %if not %AHGblank(&labels) %then label=left(scan("%sysfunc(compress(&labels,%str(%'%")))",i,'@'));;
  %if not %AHGblank(&statord) %then &statord=i; ;
  stat=input(allvar(i),$50.);

  output;
  end;  
run;
%if not %AHGblank(&trt) %then
  %do;
  %AHGdatasort(data =&out , out = sort&out, by =&by &statord  label &trt );

  proc transpose data=sort&out out=&out(drop=_name_);
    var stat;
    by &BY  
    &statord
    %if not %AHGblank(&labels) %then label;   
    ;
    id &trt;
  run;

  %local myvars  entrys IDs;
  %AHGvarlist(&out,Into=myvars );
  %let IDs=%AHGremoveWords(&myvars,&BY &statord label );
  %let entrys=%AHGremoveWords(&myvars,&ids);
  %AHGsortwords(&IDS,into=ids);
  %AHGordvar(&out,&entrys &ids,out=,keepall=0);
  %end;
%end;

%IF %AHGequalmactext(&orie,hori) %then
%do;
data &out;set &vertdsn;run;
%local rdm;
%let rdm=%AHGrdm()_;
%if %AHGblank(&trt) %then %let &rdm.n=1;
%else 
  %do;
  %AHGfreeloop(&out,&trt
  ,cmd=put
  ,in=ahuige
  ,out=ahuige
  ,url=&rdm
  ,addloopvar=0);


  %macro dosomething(dsn);
    data &dsn;
      set &dsn(drop=&trt);
    run;
  %mend;

  %AHGfuncloop(%nrbquote(dosomething(ahuige) ) ,loopvar=ahuige,loops=%AHGwords(&rdm.AHUIGE,&&&rdm.n));


  %AHGmergePrintex(%AHGwords(&rdm.AHUIGE,&&&rdm.n)
  ,by=&by,drop=,out=&out,print=0,prefix=ahuigecol);

  %local varlist;
  %AHGvarlist(&out,Into=varlist);
  %let varlist=&by %AHGremoveWords(&varlist,&by,dlm=%str( ));
  %AHGordvar(&out,&varlist,out=,keepall=0);
  %end;


  %local longlabel;
  %AHGuniq(%do i=1 %to &&&rdm.n;  &finallabel   %end;,longlabel);
    
  %AHGrenamekeep(&out,names=&by &longlabel,out=&out);
%end; 

data &out;
  set &out(drop=%if &byflag=missing %then &by;  
    %if %AHGequalmactext(&orie,vert) and %substr(&statord,1,8)=ahgdummy %then &statord;
);
run;


%if &print %then
%do;
%AHGprt;
%end;
%theexit:
%mend;




%macro AHGsummary(dsn,var,trt=,by=,out=
,stats=n @ mean\9. @ median\9.2 @ min\9.2 '-' max\9.2
,orie=
,labels=
,obs=100
,Print=1
);

%AHGsumextrt(&dsn,&var,by=&by,trt=&trt ,out=&out
,stats=&stats
,orie=&orie
,labels=&labels
);

%AHGalltocharnew(&out);
%AHGtrimdsn(&out);

data &out;
  set &out(obs=&obs);
run;
%local varinfo varlb trtlb bylb;

%AHGgettempname(varinfo)
%AHGvarinfo(%AHGpurename(&dsn),out=&varinfo,info= name label);
%AHGcolumn2mac(&varinfo(where=(upcase(name)=upcase("&var"))),varlb,label)
%AHGcolumn2mac(&varinfo(where=(upcase(name)=upcase("&trt"))),trtlb,label)
%AHGcolumn2mac(&varinfo(where=(upcase(name)=upcase("&by"))),bylb,label)

%AHGpm(varlb trtlb bylb);

title;
title1 "Dataset:  &dsn   ";
title2 "Variable:  &var %AHG1(&varlb,[&varlb])";
title3 "Treatment: %AHG1(&trt,&trt) %AHG1(&trtlb,[&trtlb]) ";
Title4 "By: %AHG1(&by,&by)  %AHG1(&bylb,[&bylb])";
%if &print %then %AHGreportby(&out,0); 
%local sepdsn;
%AHGgettempname(sepdsn);
data &sepdsn;
  format line $200.;
  line=repeat('#',200);output;
  line="End of  Dataset:%AHGpurename(&dsn)    Variable:&var   Treatment:&trt  By:&by";output;
  line=repeat('#',200);output;
run;
%if &print %then %AHGprt;
%mend;




%macro AHGtrimDsn(dsn,out=,min=3,left=1);
%if %AHGblank(&out) %then %let out=%AHGbarename(&dsn);
%local max charlist i count rdn len varlist;

%AHGvarlist(&dsn,Into=varlist,dlm=%str( ),global=0);
/*%AHGgettempname(max);*/

%AHGallchar(&dsn,into=charlist);

%let count=%AHGcount(&charlist);
%let rdn=%AHGrdm(20);

data _null_;
  retain 
  %do i=1 %to &count;
  &rdn.&i 
  %end;
  &min
  ;
  set &dsn end=end;
  %do i=1 %to &count;
  if length(%scan(&charlist,&i))> &rdn.&i then &rdn.&i=length(%scan(&charlist,&i));
  %end;

  keep &rdn:;
  if end then  call symput('len',compbl(''
  %do i=1 %to &count;
   ||put(&rdn.&i,best.)
  %end;
  ))

  ;
run;
%local rdm;
%let rdm=%AHGrdm(25);
data &out(rename=(
%do i=1 %to &count;
  &rdm&i=%scan(&charlist,&i)  
%end;
));
  format
  %do i=1 %to &count;
  &rdm&i $%scan(&len,&i). 
  %end;
  ;
  drop 
  %do i=1 %to &count;
  %scan(&charlist,&i)  
  %end;
  ;
  set &dsn;
  %do i=1 %to &count;
  %if &left %then &rdm&i=left(%scan(&charlist,&i));
  %else &rdm&i=%scan(&charlist,&i);
  ;
  %end;
    
run;

%AHGordvar(&out,&varlist,out=&out,keepall=0);

%mend;





%MACRO AHGuniq(mac,into);
%local i uniq;
%AHGgettempname(uniq);
data &uniq;
  format word $100.;
  %do i=1 %to %AHGcount(&mac);
  word="%lowcase(%scan(&mac,&i))";
  i=&i;
  output;
  %end;
run;


%AHGdatasort(data = &uniq, out = , by =word );

data &uniq;
  set &uniq;
  format ord $3.;
  retain ord;
  by word;
  if first.word then ord='1';
  else ord=%AHGputn(input(ord,best.)+1);
run;

%AHGdatasort(data = &uniq, out = , by =i);

data &uniq;
  set &uniq;
  if ord ne '1' then word=compress(word||'_'||ord);
run;

proc sql noprint;
  select trim(word) into :&into separated by ' '
  from &uniq
  ;
  quit;

%mend;




%macro AHGvarinfo(dsn,out=varinfoout,info= name  type  length num fmt);
%local i ahg3allinfo;
%let ahg3allinfo=name  type   length  format  informat label ;     

data &out(keep=&info);
length dsn $40 name $32  type $4  length 8 format $12  informat $10 label $50  num 8 superfmt fmt $12;
tableid=open("&dsn",'i');
varlist=' ';
dsn="&dsn";
do i=1 to  attrn(tableid,'nvars');
   %do i=1 %to %AHGcount(&ahg3allinfo);
   %if %scan(&ahg3allinfo,&i) ne num 
    and %scan(&ahg3allinfo,&i) ne fmt 
    and %scan(&ahg3allinfo,&i) ne superfmt 
    %then  %scan(&ahg3allinfo,&i)= var%scan(&ahg3allinfo,&i)(tableid,i);;
   %end;
   num=varnum(tableid,varname(tableid,i)) ;
   if type='C' then fmt='$'||compress(put(length,best.))||'.';
   else fmt=compress(put(length,best.))||'.';
   superfmt=format;
   if missing(superfmt) then superfmt=fmt;
   output;
end;
rc=close(tableid);
run;   

%mend;




%macro AHGvarisnum(dsn,var,into=varIsNum);
%local varinfo;
%AHGgettempname(varinfo);
%AHGvarinfo(&dsn,out=&varinfo,info= name type);
data _null_;
  set &varinfo(where=(%AHGequaltext(name,"&var")  ) );
  if type='N' then call symput("&into",'1');
  else call symput("&into",'0');
run;
%mend;




%macro AHGvarlist(dsn,Into=,dlm=%str( ),global=0,withlabel=0,print=0);
%if %sysfunc(exist(&dsn)) %then
%do;
data deletefromithere; 
%if &global %then %global &into;;
data _null_;
length varlist $ 8000;

tableid=open("&dsn",'i');
varlist=' ';
do i=1 to  attrn(tableid,'nvars');
   varlist=trim(varlist)||"&dlm"||varname(tableid,i);
   %if &withlabel %then       varlist=trim(varlist)||"&dlm "||'/*'||trim(varlabel(tableid,i))||'*/';; ;
end;
call symput("&into", varlist);
rc=close(tableid);
run;
%end;
%else %let &into=;
%if &print %then %AHGpm(&into);
data writetofilefromithere;
%mend;




%macro AHGwords(word,n,base=1);
%local AHG4I;
%if not %index(&word,@) %then %let word=&word@;
%if %AHGcount(&n)=1 %then
  %do AHG4I=%eval(&base) %to %eval(&n+&base-1);
  %sysfunc(tranwrd(&word,@,&AHG4i))
  %end;
%else 
  %do AHG4i=1 %to %AHGcount(&n) ;
  %sysfunc(tranwrd(&word,@,%scan(&n,&AHG4i))) 
  %end;

%mend;









%macro AHGzero(n,length);
	%sysfunc(putn(&n,&length))
%mend;




%macro AHGalign(allvar);
  %local var i;
  %do i=1 %to %AHGcount(&allvar);
  %let var=%scan(&allvar,&i);
  &var=PRXCHANGE('s/\s*(\d+)\s*\((\S*)\s*\)/\1 (\2)/',-1,&var);
  &var=PRXCHANGE('s/(\b\d\b)/  \1/',-1,&var);
  &var=PRXCHANGE('s/(\b\d\d\b)/ \1/',-1,&var);
  &var=PRXCHANGE('s/(\.\s*)/./',-1,&var);
  %end;
%mend;
