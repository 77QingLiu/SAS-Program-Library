
dm "endsas";



%macro align(allvar);%local var i;
  %do i=1 %to %AHGcount(&allvar);
  %let var=%scan(&allvar,&i);
  &var=PRXCHANGE('s/\s*(\d+)\s*\((\d+\.?\d*)\s*\)/\1 (\2)/',-1,&var);
  &var=PRXCHANGE('s/(\b\d\b)/  \1/',-1,&var);
  &var=PRXCHANGE('s/(\b\d\d\b)/ \1/',-1,&var);
  &var=PRXCHANGE('s/(\.\s*)/./',-1,&var);
  %end;
%mend;

data beer;
  money=14;
  total=0;
  lid=0;
  bottle=0;
  do until ((money<2) and (lid<4) and (bottle<2));
  money=money+floor(lid/4)*2;
  lid=mod(lid,4);
  money=money+floor(bottle/2)*2;
  bottle=mod(bottle,2);
  buysome=floor(money/2);
  total=total+buysome;
  money=mod(money,2);
  lid=lid+buysome;
  bottle=bottle+buysome;
  put _all_;
  end;
run;

option xwait; 

option symbolgen;

sashelp.class

%AHGopendsn(sashelp.class);

x "c:\";

=HLOOKUP(1,A2:A3,2,TRUE)

%AHGopenmac(ahgreadline);

%AHGopenmac(chn_ut_highlight)

%AHGopenmac(ahgwords)

wcut;submit '%one'; wpaste;


%AHGclearlog;
%AHGkill;
%metaspec(specs.meta_adae,subjid);


%macro backuptoh(file,h=d:\backup);
%local dt hfile hdir;
%AHGfiledt(&file,into=dt,dtfmt=mmddyy10.);

%let hfile=&h\%sysfunc(PRXCHANGE(s/(\\\\+)?(:)?//,-1,&file));
%let hdir=%sysfunc(PRXCHANGE(s/(.*)\\.*/\1/,-1,&hfile)); 
 
 
WORK.T_DSN_TXNCUHF                   
WORK.T_DSN_TXNCUHF
WORK.T_DSN_KTAIORC
WORK.T_DSN_KTAIORC


%AHGmkdir(&hdir);
x "copy &file &hfile..&dt..txt /y";

%AHGpm(hdir hfile dt);

x "start &hdir";

%mend;

%backuptoh(d:\newsas\program\google.sas);


/*%backuptoh(\\mango\sddext.grp\SDDEXT056\qa\ly2835219\i3y_mc_jpbm\dmc_blinded3\programs_stat\tfl\o_ae_pt_soc_bymaxgrad_p24797_t24798.pdf);*/
/*%backuptoh(\\mango\sddext.grp\SDDEXT056\qa\ly2835219\i3y_mc_jpbm\dmc_blinded3\programs_stat\adam\author_component_modules\mergevisitblockid.sas);*/

%backuptoh(\\mango\sddext.grp\SDDEXT056\qa\ly2835219\i3y_mc_jpbm\dmc_blinded3\programs_stat\tfl\teae_diarrhoea_bycycle_bygrade.sas);

OPTION SYMBOLGEN;

sashelp.class

%macro message_js(pre,file=) ; 
 
 data _null_ ; 
 file "&file"; 
 %local i;
 %do i=1 %to &&&pre._n;
 put "&&&pre&i";
 %end;
 run ; 

 x "start &file";
%mend message_js ; 

%AHGdel(js,like=1);
%AHG2arr(js);

%AHGcatch(sashelp.class,"MARY",out=,strict=1,open=1);

cards4;
<!DOCTYPE html>
<html>
<body>

<h1>My First Web Page</h1>
<p>My first paragraph.</p>


</body>
</html> 
;;;;
run;

%message_js(js,file=d:\temp\js.html);


%AHGloopsas(grep ahgtempdir core\*.sas);

%AHGfuncloop(%nrbquote( ls d:\newsas\ahuige\*dt*.sas )  ,loopvar=ahuige,execute=no,pct=0
,loops=
core inter adhoc   draft program
);

%AHGfuncloop(%nrbquote( grep -i wind  d:\newsas\ahuige\*.sas )  ,loopvar=ahuige,execute=no,pct=0
,loops=
core inter adhoc   draft program
);


 ;*';*";*/;quit;run;
      
%AHGoverviewAWE(DIR=D:\lillyce\prd\ly2835219\i3y_mc_jpbm\dmc_blinded2\programs_nonsdd\tfl_output
,allrtf=
patientdisp_v1.rtf smdoseadj.rtf o_ae_pt_soc_bymaxgrad.rtf tfl_ds_l_all_v1.rtf tfl_ae_l_all_ae_v1.rtf tfl_ae_l_dia_ae_v1.rtf tfl_ae_l_dia_ae_bypt.rtf tfl_cm_l_all_meds_v1.rtf 

)
;

%AHGfuncloop(%nrbquote( AHGopendsn(ahuige) ) ,loopvar=ahuige,loops=
&ahgworkdsns1
);


%getcore(
ahgbarename.sas ahgbasename.sas ahgblank.sas ahgcount.sas ahgdatadelete.sas ahgdatasort.sas ahgequaltext.sas ahgeqv.sas ahggettempname.sas ahgmergedsn.sas ahgpurename.sas
);



  do i=1 to 


/*option noxwait;*/
data lb;
  set adlb;
  keep  AVAL  SUBJID  PARAM  LBDY ;
  where PARAM =  "Cancer Antigen 19-9" ;
 "Carcinoembryonic Antigen" 
 "Squamous Cell Carcinoma Antigen" 
 "Alanine Aminotransferase" 
run;

/*%AHGcopylib(radam,ladam);*/
data ae;
  set adam.adae;
  where   aetox ='theuser ORAL';
run;

%AHGopendsn();

data fg;
  set sdtm.eg;
   where  index(usubjid,'01004') and egdtc>='2014-04-02';

RUN;
%AHGopenmac(AHGcatch);

%AHGdatasort(data =fg , out = , by =trta EGTPT  descending aval  );

%AHGopendsn;

%AHGopendsn;
%INC 'S:\SA\Macro library\Macro learning tool\program\init.sas';
%INC '\\gh3nas01\gh3nas_sales.grp\LCDDMAC\STATS\SA\Macro library\Macro learning tool\program\init.sas';


x 'cd ';

%AHGclearlog;

%AHGoverview(DIR=&mydir,N=5);
%AHGoverview(drive=k:,DIR=&mydir,N=5);

g:\lillyce\qa\ly231514\h3e_cr_s131\final\programs_nonsdd\tfl_output

%INC '\\gh3nas01\gh3nas_sales.grp\LCDDMAC\STATS\SA\Macro library\Macro learning tool\program\init.sas';
%AHGclearlog;
%let mydir=%str(g:\lillyce\qa\ly231514\h3e_cr_s131\final\programs_nonsdd\tfl_output);
%AHGoverview(DIR=&mydir,N=5,include=disp );

%AHGoverview(DIR=&mydir,N=2,except= s131 ae_l02 );

%let mydir=G:\lillyce\qa\ly2835219\i3y_je_jpbc\intrm2\programs_stat\tfl_output;
%AHGoverview(DIR=&mydir,N=5,except= s131 ae_l02 );
option xwait; 

x "c:\";

%AHGoverview(DIR=&mydir,N=5,mask=0);
%AHGoverview(DIR=&mydir,N=5,keepall=1);
%AHGoverview(DIR=&mydir,N=5,allrtf= smpkmp111.rtf  smttep111.rtf smmh111.rtf  smpdp111.rtf    smvsp111.rtf);
%AHGoverview(drive=k:,DIR=&mydir,N=5,mask=1);

%AHGoverview(DIR=&out1st,except=gr fg);




%AHGcopylib(rsdtm,lsdtm,n=99999999999);

%AHGkill;

%AHGDataView(dsin=adam.adpk,dsout=,order=original,SameVal=noDelete);

%AHGaddsasautos(d:\newsas\draft);

%AHGexportopen(adam.adae);

%AHGmacandvalue(ahuige|ok haha|joking);

%AHGopenmac(ahgmkdir);
%AHGopenmac(AHGcodecompletion
);

option xwait; 
%let tableid=fqae112;
 x "copy %sdddc(&replication_output\qc_&tableID..txt) %mysdd(&replication_output\qc_&tableID..txt) /y";


x "c:\";
%qcactions(lsvsp11);

%qcactions(smdemf111,actions=downqc downrtf open2output);


%let tfl_output=%sysfunc(tranwrd(&tfl_output,programs_stat,programs_nonsdd));

%qcactions(lsaesf111,actions= downqc downrtf open2output);

%qcactions(smaesf121,actions= downqc  open2output)

%AHGwt(&localtemp\SAS_session_%substr(&SYSPROCESSID,6,20).sas.txt,
str=changehintFile sashelp\cityday.meta.txt);


%let out1st=;
%overview(dir=%str(H:\test tfl));




%AHGdatasort(data = sashelp.class, out =class , by =sex );

%AHGprocMeansby(class,age,sex,out=stats,print=1,alpha=0.05
,stats=n mean median std min max /*n @ min '-' max*/
,split=\
,orie=vert
,labels=n mean median std min max
,left=left
,statord=statord

);

%AHGpm(sysuserid);

 ;*';*";*/;quit;run;

%AHGopenmac(qcactions);

%AHGopenmac(AHGcodeCompletion);
%AHGdistinctValue(dsn,var,into=,dlm=@);

data test;
  set sashelp.class sashelp.cars;
run;

%AHGopendsn;

%AHGkill;
%AHGclearlog;
%AHGcodeCompletion(test); 
%AHGcodeCompletion(sashelp.zipcode); 
%AHGcodeCompletion(sashelp.heart); 
%AHGcodeCompletion(sashelp.class); 
%AHGcodeCompletion(ladam.adex); 
%AHGcodeCompletion(ladam.adeg); 


%AHGcodeCompletion(sasuser.jpbchd); 
%AHGexe;
/*%AHGcodeCompletion(b490.random); */
/*%AHGcodeCompletion(b490.vtls); */

%AHGexe();


data test;
  set qc;
  where   col6='2014-08-13T17:23';
/*and paramcd = "OXYSAT"  and trtan=1  ;;*/
/*  AVISIT = "CYCLE1 DAY8" */

run;

%AHGopendsn();

data test;
  set adam.adVS;
  where visit= "Baseline" and param =  "Diastolic Blood Pressure (mmHg)" ;
/*  AVISIT = "CYCLE1 DAY8" */

run;
data test;
  set adam.adVS;
  where visitnum=     1000   and  trtan =  3  and param =  "Diastolic Blood Pressure (mmHg)" ;
/*  AVISIT = "CYCLE1 DAY8" */


run;

%AHGopendsn();

%AHGexe;

%AHGopendsn();

data adeg;
  set adam.adeg ;
  where subjid='01004' and paramcd in ("INTP" 
)
;
run;

%AHGopendsn();

%AHGDataView(dsin=sdtm.fa,dsout=,order=original,SameVal=noDelete);

%AHGexportopen(adam.adeg,n=99);


%AHGexe;

%overview(study=jpbc);


%AHGuse(tfl.smttep111 );

%AHGcopylib(radam,ladam);


data _null_;
  set tfl;
  put;
  put '########' col2= ;
  do i=1 to length(col2);
  char=substr(col2,i,1);
  rank=rank(char);
  put char= rank=;
  end;
run;

%AHGkill;
%AHGclearlog;

%summary1(adam.adsl,height,age);

%summary1(adam.advs,chg,avisit);

%AHGclearlog;
%AHGlibinfo(ladam);
%AHGopendsn();

%AHGmkdir(H:\lillyce\qa\ly2835219\i3y_je_jpbc\intrm2\replica_programs,drive=h:);
%AHGmkdir(H:\lillyce\qa\ly2835219\i3y_je_jpbc\intrm2\data\shared\adam);


%AHGclearlog;
%put %AHGtempdir;
option nosymbolgen;
%AHGmkdir(D:\lillyce\qa\ly2835219\i3y_je_jpbc\intrm2\programs_stat\tfl_output)
%AHGmkdir(%AHGtempdir)


data ladam.adex;
  set radam.adex;
run;

 ;*';*";*/;quit;run;


%AHGopenmac(qcactions);

%AHGopenmac(AHGcodeCompletion);

 %AHGlookinto(ladam.adeg);


 %AHGopenmac(qcactions);

 %global trtm bym numm;
 %AHGlookinto(ladam.adsl,out=adsl );

 %AHGpm(trtm bym numm);

%AHGkill;
%AHGclearlog; 
%AHGsumextrt(ladam.adlb,%scan(&numm,1),by=%scan(&bym,1),
trt=%scan(&trtm,1),print=1,orie=hori
,stats=n @ mean @ median @ min '-' max);

 %AHGsumextrt(ladam.adlb,%scan(&numm,1),by=%scan(&bym,1),trt=%scan(&trtm,1),print=1);


 %AHGsumextrt(ladam.adlb,%scan(&numm,2),by=%scan(&bym,2),trt=%scan(&trtm,2),print=1);
 %AHGsumextrt(ladam.adlb,%scan(&numm,2),by=%scan(&bym,2),trt=%scan(&trtm,2),print=1,orie=hori);

 %AHGsumextrt(ladam.adlb,%scan(&numm,3),by=%scan(&bym,3),trt=%scan(&trtm,3),print=1);

 %AHGsumextrt(ladam.adlb,%scan(&numm,3),by=%scan(&bym,3),trt=%scan(&trtm,3),print=1,orie=hori);

 %AHGclearlog;
%let sas=;
%AHGfilesindir(G:\lillyce\qa\ly2835219\i3y_je_jpbc\intrm2\replica_programs,mask='v_%.sas',into=sas);
%AHGpm(sas);

%macro dosomething;
%local one i;
%do i=1 %to %AHGcount(%str(&sas),dlm=@);
  %let one=%scan(&sas,&i,@);
  %put   mv &one ir_%scan(&one,2,_)    %str(;);
%end;

%mend;
%doSomething

data sasuser.jpbcnow;
  format rtf $50.;
  do i=1 to %AHGcount(&rtf,dlm=@);
  rtf=scan(scan("&rtf",i,'@'),1);
  output;
  end;
run;
%AHGopendsn();










data jpbc;
  set sasuser.jpbchd;
  where lowcase(category) ne 'adam' and lowcase(category) ne 'macro'
    and lowcase(category) ne 'setup'
    and lowcase(substr(Output_name,1,2)) ne 'gr'
    and lowcase(substr(Output_name,1,2)) ne 'fg';

  
run;

data fg;
  set sasuser.jpbchd;
  where  lowcase(substr(Output_name,1,2)) eq 'gr'
    or lowcase(substr(Output_name,1,2)) eq 'fg';

  
run;

%AHGopendsn();

%AHGexe;
%let allqc=;
%AHGfilesindir(G:\lillyce\qa\ly2835219\i3y_je_jpbc\intrm2\replica_programs\system_files
,dlm=%str( ) ,mask='ir%.log',into=allqc,case=0,print=1);    
%macro dosomething;
data allqc;
format pgm $50.;
%local i;
%do i=1 %to %AHGcount(%str(&allqc));
pgm=scan("&allqc",&i,' ');  
if not index(pgm,'ir_ad') then output;
%end;
run;
%AHGopendsn();
%mend;
%doSomething


data jpbc;
  set sasuser.jpbchd;
  where lowcase(category) ne 'adam' and lowcase(category) ne 'macro'
    and lowcase(category) ne 'setup'
    and lowcase(substr(Output_name,1,2)) ne 'gr'
    and lowcase(substr(Output_name,1,2)) ne 'fg' and not missing(Output_name);
  pgm='ir_'||Output_name;
  
run;


data allqc;
  set allqc;
  pgm=scan(pgm,1,'.');
run;


proc sql;
  create table leftdsn as
  select *
  from jpbc
  where trim(pgm) not in 
  (select trim(pgm) from allqc)
  ;
quit;

proc printto;run;

%AHGopenmac(ahgdsninlib);

%prdqa(adsl.sas7bdat,actions=down comp); /* qc done 2015-05-12*/
%prdqa(adae.sas7bdat,actions=down comp); /* qc done 2015-05-12*/
%global alldsn;
%AHGdsninlib(lib=ladam,list=alldsn,lv=1);
%AHGpm(alldsn);

%AHGfuncloop(%nrbquote( prdqa(ahuige.sas7bdat,actions=down comp); ) ,loopvar=ahuige,loops=&alldsn);


%prdqa(adcm.sas7bdat,actions=down comp);
%prdqa(adpk.sas7bdat,actions=down comp);

/////////////////

%let allrtf=;
%AHGfilesindir(d:\lillyce\prd\ly2835219\i3y_je_jpbc\intrm2\programs_stat\tfl_output
,dlm=%str( ) ,mask='%.rtf',into=allrtf,case=0,print=1);    
%macro dosomething;
data allrtf;
format pgm $50.;
%local i;
%do i=1 %to %AHGcount(%str(&allrtf));
pgm=scan("&allrtf",&i,' ');  
if not index(pgm,'ir_ad') then output;
%end;
run;
 
%mend;
%doSomething


data jpbc;
  set sasuser.jpbchd;
  where lowcase(category) ne 'adam' and lowcase(category) ne 'macro'
    and lowcase(category) ne 'setup'
    and lowcase(substr(Output_name,1,2)) ne 'gr'
    and lowcase(substr(Output_name,1,2)) ne 'fg' and not missing(Output_name);
  pgm='ir_'||Output_name;
  
run;


data allrtf;
  set allrtf;
  pgm=scan(pgm,1,'.');
run;


proc sql;
  create table leftdsn as
  select output_name
  from jpbc
  where trim(Output_name) not in 
  (select trim(pgm) from allrtf)
  ;
quit;
%AHGopendsn();
proc sql;
  create table fig as
  select pgm
  from  allrtf
  where trim(pgm)  not in 
  (select trim(Output_name) from jpbc)
  ;
quit;
%AHGopendsn();
%let ahgrdminc=0;
%macro AHGrdm(length,seed=0,inc=ahgrdminc);
%let &inc=%eval(&&&inc+1);
_&&&inc
%mend;

data class;
  set  AgeCHDdiag ;
run;

data class;
  set  AgeCHDdiag ;
  keep  BP_Status Chol_Status DeathCause Sex Smoking_Status Status Weight_Status ;
  if  BP_Status =  "Optimal"  ;
run;

%macro AHGgettempname(tempname,start=,useit=0);
%let &tempname=&tempname._%AHGrdm;
%mend;




%macro alltflmac(macs);
 
x "cd d:\newsas\core";
x  "copy %AHGaddcomma(&macs,comma=+d:\newsas\draft\blank.sas+)  d:\newsas\tflmac.sas";



%mend;



%alltflmac(ahg1.sas ahgaddcomma.sas ahgallchar.sas ahgalltocharnew.sas ahgbarename.sas ahgbasename.sas ahgblank.sas ahgclearglobalmac.sas
ahgcolumn2mac.sas ahgcount.sas ahgcreatehashex.sas ahgd.sas ahgdatadelete.sas ahgdatasort.sas ahgdistinctvalue.sas ahgequalmactext.sas
ahgequaltext.sas ahgfreeloop.sas ahgfreqcore.sas ahgfuncloop.sas ahggettempname.sas ahghashvalue.sas ahgincr.sas ahgindex.sas ahgleft.sas
ahgmergedsn.sas ahgmergeprintex.sas ahgname.sas ahgnobs.sas ahgnonblank.sas ahgordvar.sas ahgpm.sas ahgpos.sas ahgprt.sas ahgpurename.sas
ahgputn.sas ahgrandom.sas ahgrdm.sas ahgremovewords.sas ahgrenamedsn.sas ahgrenamekeep.sas ahgreportby.sas ahgscan2.sas ahgsetstatfmt.sas
ahgsortwords.sas ahgsumextrt.sas ahgsummary.sas ahgtrimdsn.sas ahguniq.sas ahgvarinfo.sas ahgvarisnum.sas ahgvarlist.sas ahgwords.sas
ahgzero.sas ahgalign.sas
)

x "copy d:\newsas\tflmac.sas \\mango\sddext.grp\SDDEXT056\qa\ly2835219\i3y_mc_jpbm\dmc_blinded3\programs_stat\tfl\author_component_modules\ /y";

x "copy d:\newsas\tflmac.sas h:";

x "copy h:\tflmac.sas \\mango\sddext.grp\SDDEXT056\qa\ly2835219\i3y_mc_jpbm\dmc_blinded3\programs_stat\tfl\author_component_modules\ /y";

x "copy h:\tflmac.sas \\mango\sddext.grp\SDDEXT056\qa\ly2835219\i3y_mc_jpbm\dmc_blinded3\replica_programs\tfl\ir_mac.sas /y";





/*7za a -tzip \\Gh3users\private\H\HUI.L\xlsx.zip \\Gh3users\private\H\HUI.L\*.xlsx*/

%let zippath=\\mango\sddext.grp\SDDEXT056\TRASH;
%let awepath=\\mango\sddext.grp\SDDEXT056\prd\ly2835219\i3y_mc_jpbm\dmc_blinded3;
%LET tpo=A56;
data all;
infile datalines truncover; 
format line $300. SDDtopath $100. proj $4. pref $13.  AWEDescription $100. cmd $1000. awepath $100.;
input line 1-300 ;
SDDtopath=scan(line,1,' ');
proj=scan(line,2,' ');
pref=scan(line,3,' ');
keep cmd;
do i=4 to 20;
AWEDescription=trim(AWEDescription)||' '||scan(line,i,' ');
end;
select (SDDtoPath);
   when ('data/shared/custom') awepath='data\custom';
   when ('data/shared/sdtm') awepath='data\sdtm';
   when ('data/shared/adam') awepath='data\adam';
   when ('program_nonsdd/author_component_modules') awepath='';
   otherwise;
end;
do i=1 to 5;
cmd='""c:\Program Files\7-Zip\7z.exe"" a -tzip '||"&zippath\LBI_P"||proj||"&tpo._.zip &awepath\" ||trim(scan(awepath,i,' '))||"\*.*";
if not missing(scan(awepath,i,' ')) then output;
end;
cmd='';output;

cards;
data/shared/custom                            AC56    LBI_PAC56A56_    data/custom
data/shared/sdtm                              AD56    LBI_PAD56A56_    data/sdtm
data/shared/adam                              AAD1    LBI_PAAD1A56_    data/adam
dev/?data/shared/custom                      AE56    LBI_PAE56A56_    data/eds
program_nonsdd                                PP56    LBI_PPP56A56_    setup.sas
program_nonsdd/author_component_modules       AA56    LBI_PAA56A56_    sdtm/author_component_module, adam/author_component_module, tfl/author_component_module
programs_nonsdd/sdtm                          AP56    LBI_PAP56A56_    sdtm
programs_nonsdd/system_files                  AS56    LBI_PAS56A56_    sdtm/system_file, adam/system_files, tfl/system_files
programs_nonsdd/adam                          AAP1    LBI_PAAP1A56_    adam
programs_nonsdd/tfl                           SP56    LBI_PSP56A56_    tfl
programs_nonsdd/tfl_output                    ATO1    LBI_PATO1A56_    tfl_output
replica_programs_nonsdd                       IP56    LBI_PIP56A56_    sdtm, adam, tfl, irsetup.sas
replica_programs_nonsdd/system_files          IS56    LBI_PIS56A56_    sdtm/system_files, adam/system_files, tfl/system_files



;
run;

%AHGtrimdsn(all);
option ls=256;
%AHGprt;

%macro AHGModClip;
filename ahgclip clear;
filename ahgclip clipbrd;


data _null_;
  infile ahgclip truncover;
  file ahgclip;
  format cmd  line $500.;
  input line 1-500 ;
    do;
    cmd='good '||trim(line);
    put cmd;
    end;     
run;

%mend;

data sasuser.actions;
  format action $200.;
  infile datalines truncover;
  input action 1-200;
  cards4;
AHGmergedsn(dsn1,dsn2,outdsn,by=,joinstyle=full/*left right full matched*/);
AHGpm();
AHGdatasort(data = , out = , by = );

;;;;
run; 

%let AHG_RESULT1=%nrstr(%AHGmergedsn(dsn1,dsn2,outdsn,by=,joinstyle=full/*left right full matched*/););
%let AHG_RESULT2=%nrstr(%AHGdatasort(data = , out = , by = ););

%macro one;
 
filename ahgclip clear;
filename ahgclip clipbrd;


data in;
  infile ahgclip;
  format cmd    $500.;
  input cmd;
  call symput('xxx',cmd); 
run;

filename ahgclip clear;
filename ahgclip clipbrd;



data out;
  file ahgclip;
  format cmd    $500.;
  cmd=compress("&xxx  ok");
  put cmd;   
run;

%mend;


 
 
cat lxz.txt |% { $_ -replace '(.*)(http.+forum.hkej.com.node.[^\"]+)\")(.*)','$2' }   

cat lxz.txt |% { $_ -replace '(.*)(http.+forum.hkej.com.node.)(.*)','$2' }   

|% { $_ -replace '(.*)(http.+forum.hkej.com.node.[^\"]+)\")(.*)','$2' }   




cat lxz.txt | grep  "forum.*hkej.*com.*nod" |% { $_ -replace '(.*)(forum.*hkej.*com.*nod[^;]+)(\&amp.*)','http://$2' }   |% { $_ -replace '%2F' ,'/'}


cat one.txt | grep  "www.*hkej.*com.*dailynews" |% { $_ -replace '(.*)(www1.*hkej.*com.*dailynews[^;]+)(\&amp.*)','http://$2' }   |% { $_ -replace '%2F' ,'/'}


http://www1.hkej.com//dailynews/article/id/701811/


cat one.txt | grep  "www.*hkej.*com.*dailynews" 

<p><a href="http://www.hkej.com/template/dailynews/jsp/detail.jsp?dnews_id=3873&amp;cat_id=6&amp;title_id=644984" target="_blank">??</a></p>


