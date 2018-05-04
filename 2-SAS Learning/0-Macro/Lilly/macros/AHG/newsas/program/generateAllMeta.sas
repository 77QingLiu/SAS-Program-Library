
%macro onemeta(file,indir=,into=outmeta);
%let file=%sysfunc(compress(%sysfunc(tranwrd(%lowcase(&file),.sas,)))).sas;
%local one;
%AHGgettempname(one);
%AHGreadline(file=&indir\&file,out=&one);
data one;
  set &one;
  format drvr $50. word $30.;
  keep word;
  retain match change;
  IF _N_ = 1 THEN match = PRXPARSE('/\%[aA][hH][gG][\w]*/');
  IF _N_ = 1 THEN change = PRXPARSE('s/\%[aA][hH][gG][\w]*/ /');
  do while (prxmatch(match,  line)); 
   
  CALL PRXSUBSTR (match, line, position ,length);  

  word=lowcase(substr(line,position+1,length-1))||'.sas';
  drvr="&file";
  output;
  line=prxchange(change,1, line); 
  end;
 
run;

%local metawords;
proc sql;
  select distinct word into :metawords separated by ' '
  from one
  group by   word
  ;quit;
%let &into=&metawords;

data meta;
  format drvr $50. macros $1000.;
  drvr="&file" ;
  macros="&metawords";
run;


%uptouser;

%mend;
%AHGclearlog;
/*%onemeta(ahgmkdir,indir=d:\newsas\inter );*/

%macro uptouser;
  %if %sysfunc(exist(sasuser.macmeta)) %then
  %do;
  data sasuser.macmeta;
    set sasuser.macmeta meta;
  run;
  %end;
  %else 
  %do;
  data sasuser.macmeta;
    set meta;
  run;
  %end;
%mend;

%macro onepath(path);
%local files;
%AHGfileInDir(%bquote(d:\newsas\&path),ext=sas,into=files,dlm=%str( ));

%AHGfuncloop(%nrbquote(onemeta(ahuige,indir=d:\newsas\&path ) ) ,loopvar=ahuige,loops=&files);

%mend;


/*%AHGfuncloop(%nrbquote( onepath(ahuige) ) ,loopvar=ahuige,loops=core inter adhoc );*/




%macro onefileMetaInto(file,dir);
%local themeta finalmeta;
%onemeta(&file,indir=&dir,into=themeta);
/*%AHGpm(themeta);*/
/*%macro onemeta(file,indir=,into=outmeta);*/
%AHGfindallmeta(&themeta,into=finalmeta);
/*%AHGpm(finalmeta);*/
%LET allmeta=&allmeta &finalmeta;
%mend;

%let allmeta=;
/*%let thedir=\\mango\sddext.grp\SDDEXT056\qa\ly2835219\i3y_mc_jpbm\dmc_blinded2\programs_stat\adam;*/
/*%AHGfuncloop(%nrbquote( onefileMetaInto(ahuige,&thedir) ) ,loopvar=ahuige,loops=adae admh adcm adds);*/

%let thedir=\\mango\sddext.grp\SDDEXT056\qa\ly2835219\i3y_mc_jpbm\dmc_blinded3\programs_stat\tfl;
%AHGfuncloop(%nrbquote( onefileMetaInto(ahuige,&thedir) ) ,loopvar=ahuige,loops=teae_diarrhoea_bycycle_bygrade);


/**/
/*%let thedir=h:\cdk46;*/
/*%AHGfuncloop(%nrbquote( onefileMetaInto(ahuige,&thedir) ) ,loopvar=ahuige,loops=trtdisctaedth_l);*/



%AHGsortWords(&allmeta,into=allmeta,dlm=%str( ),length=100,nodup=1);
%AHGpm(allmeta);


/**/
/*%macro newsastodir(files,fromdir=,d:\newsas,todir=,into=);*/
/*%local i;*/
/*%do i=1 %to %AHGcount(&files);*/
/*  %if %sysfunc(exist(&fromdir\core\%left(%scan(&files,&i)))) and not %sysfunc(exist(&todir\core\%left(%scan(&files,&i)))) */
/*    %then %put &todir\core\%left(%scan(&files,&i));*/
/*%end;*/
/*%mend;*/
/**/
/*%newsastodir();*/
