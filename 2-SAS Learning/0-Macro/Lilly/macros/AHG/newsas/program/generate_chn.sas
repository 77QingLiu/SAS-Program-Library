

                %macro copyallmac;
                %global rdm rootnewsas;
                %let rootnewsas=d:\newsas;
                %let rdm=%AHGrdm;
                x "mkdir %AHGtempdir\MAC&RDM";
                X "COPY &ROOTNEWSAS\core\*.sas %AHGtempdir\MAC&RDM\ /y";
                X "COPY &ROOTNEWSAS\inter\*.sas %AHGtempdir\MAC&RDM\ /y";
                X "COPY &ROOTNEWSAS\adhoc\*.sas %AHGtempdir\MAC&RDM\ /y";
                %mend;

/*%copyallmac;*/



%macro main(thename,sa=0);
%let thename=%sysfunc(tranwrd(&thename,.sas,%str( )));
%let thename=%substr(&thename,4);


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
/*%onemeta(ahgmkdir,indir=&rootnewsas\inter );*/

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

                                      %macro onepath;
                                      %local files;
                                      %AHGfileInDir(%bquote(%AHGtempdir\MAC&RDM),ext=sas,into=files,dlm=%str( ));

                                      %AHGfuncloop(%nrbquote(onemeta(ahuige,indir=%AHGtempdir\MAC&RDM) ) ,loopvar=ahuige,loops=&files);

                                      %mend;

/* refresh meta dataset from mac&rdm area */                                      
%onepath;

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

%local allmeta;                                        
%let allmeta=;
/*%let thedir=\\mango\sddext.grp\SDDEXT056\qa\ly2835219\i3y_mc_jpbm\dmc_blinded2\programs_stat\adam;*/
/*%AHGfuncloop(%nrbquote( onefileMetaInto(ahuige,&thedir) ) ,loopvar=ahuige,loops=adae admh adcm adds);*/


%AHGfuncloop(%nrbquote( onefileMetaInto(ahuige,&thedir) ) ,loopvar=ahuige,loops=AHG&thename..sas);


/*%let thedir=\\mango\sddext.grp\SDDEXT056\qa\ly2835219\i3y_mc_jpbm\dmc_blinded3\programs_stat\tfl;*/
/*%AHGfuncloop(%nrbquote( onefileMetaInto(ahuige,&thedir) ) ,loopvar=ahuige,loops=teae_diarrhoea_bycycle_bygrade);*/
/**/

/**/
/*%let thedir=h:\cdk46;*/
/*%AHGfuncloop(%nrbquote( onefileMetaInto(ahuige,&thedir) ) ,loopvar=ahuige,loops=trtdisctaedth_l);*/



%AHGsortWords(&allmeta,into=allmeta,dlm=%str( ),length=100,nodup=1);
/*%AHGpm(allmeta);*/


%let cmdstr=%bquote(cd %AHGtempdir\MAC&RDM);

%AHGpm(cmdstr);
x "%unquote(&cmdstr)";


%let afile=%AHGtempdir\MAC&RDM\ahg&thename..sas;

%AHGreadline(file=&afile,out=mcr);
%local md;
%let md=ut;
proc sql;
  select trim(md) into :md
  from module
  where left(upcase(macro))=upcase("&thename")
  ;
  quit;

data mcr1 mcr2;
  set mcr;
  line=prxchange("s/ahg&thename/chn_%trim(&md)_&thename/i",-1,line);
  retain getheader 0;
  if not getheader then output mcr1;
  else output mcr2;
  if index(line,';') then getheader=1;
run;

data _null_;
  filename mcr1 "%AHGtempdir\mcr1.sas" new;
  file mcr1 ;
  set  mcr1;
  put line;
run;

data _null_;
  filename mcr2 "%AHGtempdir\mcr2.sas" new;
  file mcr2 ;
  set  mcr2;
  put line;
run;



%let cmdstr=%bquote(copy %AHGaddcomma(%AHGtempdir\mcr1.sas &allmeta %AHGtempdir\mcr2.sas,comma=%str(+))   %AHGtempdir\chn\chn_%trim(&md)_&thename..ahgsas);


x "cd %AHGtempdir\MAC&RDM";

option xsync noxwait;
%AHGmkdir( %AHGtempdir\chn);
X " %unquote(&cmdstr )";
%local prg the3;
%let the3=%AHGrdm(3);
%AHGgettempname(prg);
%AHGreadline(file=%AHGtempdir\chn\chn_%trim(&md)_&thename..ahgsas,out=&prg);

data _null_;
  set &prg;
  file
  %if &sa=1 %then "S:\SA\Macro library\Macro learning tool\macros\chn_%trim(&md)_&thename..sas";
  %else "%AHGtempdir\chn\chn_%trim(&md)_&thename..sas";
  ;
  line=prxchange("s/[aA][hH][gG]/_&the3/",-1,line);
  put line;
run;

%if &sa=1 %then ;


/**/
/*%macro newsastodir(files,fromdir=,&rootnewsas,todir=,into=);*/
/*%local i;*/
/*%do i=1 %to %AHGcount(&files);*/
/*  %if %sysfunc(exist(&fromdir\core\%left(%scan(&files,&i)))) and not %sysfunc(exist(&todir\core\%left(%scan(&files,&i)))) */
/*    %then %put &todir\core\%left(%scan(&files,&i));*/
/*%end;*/
/*%mend;*/
/**/
/*%newsastodir();*/

%mend;



%let names=;
option nomlogic mprint nosymbolgen;
%AHGfilesindir(&rootnewsas\core,dlm=%str( ),fullname=0,extension=,mask='%%.sas',include=,except=,
into=names,case=0,print=0);    


%AHGpm(names);

data module;
  format macro md  $30.;
  input macro md;
  cards;
  reportby rp
  count ut
  ordvar dt
  setprint dt
  mergeprint dt
  trimdsn dt
  ;

run;

/*%AHG(dsns,out=setprint,print=1);*/

%let thedir=d:\newsas\core;


%AHGfuncloop(%nrbquote(main(ahuige,sa=1) ) ,loopvar=ahuige,loops=
ahgreportby


);


proc printto log="%trim(%AHGtempdir)\chn.log" print="%trim(%AHGtempdir)\chn.lst" new;
run;


%let thedir=d:\newsas\core;

%AHGfuncloop(%nrbquote(main(ahuige,sa=1) ) ,loopvar=ahuige,loops=
ahghighlightex

);



proc printto;run;
x "start %AHGtempdir\chn.log";

/*%AHGfuncloop(%nrbquote( main(ahuige) ) ,loopvar=ahuige,loops=&names);*/




