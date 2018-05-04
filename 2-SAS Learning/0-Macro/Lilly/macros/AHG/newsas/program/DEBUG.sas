dm "endsas";


%macro dosomething(tfl);
x "start \\mango\sddext.grp\SDDEXT034\prd\ly2835219\i3y_mc_jpbl\dmc_blinded4\programs_stat\tfl_output\&tfl..rtf";
x "start \\mango\sddext.grp\SDDEXT034\prd\ly2835219\i3y_mc_jpbl\dmc_blinded4\programs_stat\tfl\&tfl..sas";


%mend;
%doSomething(lsaemctc);

%AHGHTML(sashelp.class);

%AHGopenfile(%str(&specs)i3y_mc_jpbl_adam_studyspec1.xlsx,copy=1);

%AHGopenfile(\\mango\sddext.grp\SDDEXT034\qa\ly2835219\i3y_mc_jpbl\intrm1\TFL_programming_tracker.xlsx,copy=1);


\\mango\sddext.grp\SDDEXT034\qa\ly2835219\i3y_mc_jpbl\intrm1

%AHGopenfile( \\mango\sddext.grp\SDDEXT056\Documents\adam_spec\i3y_mc_jpbm_adam_studyspec1.xlsx,copy=1);

%AHGDataView(dsin=adam.adae,dsout=,order=original,SameVal=noDelete);

get-childitem -filter "*.xls" | sort LastWriteTime -Descending |select name

%AHGcatch(specs.meta_adae,"SOCCRFL",out=dist,strict=0);
%AHGdatasort(data = dist, out = , by = paramn);
%AHGhtml(dist);

/lrlhps/apps/sas/sas /lillyce-dev/qa/general/other/chinese/New_Test_Files/chnnew.sas encoding='utf-8'

/lrlhps/apps/sas/sas  chnnew.sas -locale Chinese_China encoding=

c:\
dm  "vt &tempdsn99 COLHEADING=NAMES " viewtable:&tempdsn99 view=form   ;;
 
\\Gh3users\private\H\HUI.L

          proc datasets library=stored kill force memtype=catalog;
          run;
          quit;


C:\


  VIEWTABLE %8b."%s".DATA COLHEADING=NAMES


  proc format library=WORK cntlout= cntlfmt;


option  noxwait mprint mrecall; 
%let thework= %sysfunc(getoption(sasuser));
%let stored=%scan( &thework,1,\)\%scan( &thework,2,\)\%scan( &thework,3,\);
x mkdir "\\gh3nas01\gh3nas_sales.grp\LCDDMAC\STATS\SA\Macro library\users\&sysuserid";  
x copy "\\gh3nas01\gh3nas_sales.grp\LCDDMAC\STATS\SA\Macro library\sasmacr.sas7bcat"   
 "&stored" /y;
libname stored "&stored";  
option mstored SASMSTORE=stored noxwait mprint mrecall;  


dm "endsas";

option nomstored ;


\\Gh3users\private\H\HUI.L

option mlogic;

%AHGtrimdsn(allmac);
%AHGexportopen(Renamedsn ,lookup=1,n=20);

%AHGexportopen(Renamedsn ,n=99999);


%AHGclearlog;
%openlinks;

%AHGopenmac(ahgopendsn);

%AHGopendsn();




%AHGfontsize(12);

%AHGexportopen(adam_admh,lookup=1,n=9);

%AHGexportopen(specs.Meta_timepoint,n=9999);

X "copy \\mango\sddext.grp\SDDEXT056\Documents\tfl_spec\*.xlsm h:\jpbm /y";
x "start h:\jpbm";


X 'START C:\';

x "copy \\mango\sddext.grp\SDDEXT056\qa\ly2835219\i3y_mc_jpbm\dmc_blinded3\data\custom\tfl_spec.xlsm h:\jpbm /y";


x "dir h:\jpbm\*.xlsm";

%AHGpipe(rcmac=xlsm,global=1);

%MACRO HONE(NAME);

%MEND;
%AHGopendsn(sdtm.ae);
%AHGopenmac(ahgsupercmp);

\\mango\sddext.grp\SDDEXT056\qa\ly2835219\i3y_mc_jpbm\dmc_blinded4\programs_stat\tfl\author_component_modules

alphgo played one bad move. the commenter said it might be something to do with the M


x "start h:\jpbm\";

=IFERROR(HLOOKUP(1,B2:B3,2,TRUE),"" )

%AHGcatch(dict.dict_meddra,10037086,out=dist,strict=0);

%AHGcatch(sdtm.ae,'01058',out=otrtdisp ,strict=0);

%AHGcatch(adam.adds,'1001',out=otrtdisp ,strict=0);
%AHGcatch(adam.adsl,'104-01700',out=otrtdisp ,strict=0);



%AHGcatch(otrtdisp,'Off treatment',out=out ,strict=0);

data dis;
  set out;
  where index(trtp,'200');
run;

proc freq data=dis;
table usubjid;
run;

%AHGDataView(dsin=dis,dsout=,order=original,SameVal=noDelete);

%AHGcatch(adam.ADDS,'OTRTDISP',out=otrtdisp ,strict=0);

%AHGcatch(adam.adsl,'1101',out= ,strict=0);

data adsl;
  set adam.adsl;
  where saffl='Y';
run;



%AHGcatch(SDTM_DS,'1057',out=admh,strict=0);

%AHGcatch(SDTM.RELRECDS,'1335',out=admh,strict=0);

%AHGcatch(trt,3,out=admh,strict=0);

%AHGcatch(AETMP,'1335',out=admh,strict=0);



%AHGcatch(adam.ADds,'OSTYDISP',strict=0);

%AHGcatch(SDTM.DS,'1370',strict=0);

%AHGcatch(ADAM.ADSL,'1370',strict=0);



%AHGcatch(adam.ADds,'01006',strict=0);


01006


%AHGcatch(sdtm.ds,'death', strict=0);

%AHGcatch(mh,'2019',out=dist,strict=0);
%AHGcatch(cm,'2019',out=dist,strict=0);




sdtm.ae adam.adae
%AHGfuncloop(%nrbquote( AHGcatch(ahuige,'-125-0194',out=dist,strict=0) ) ,loopvar=ahuige,loops= sdtm.sv);

%;




%AHGcatch(qc_adexsum,'Y-MC-JPBM-455-0130',out=newdist,strict=0);
%AHGcatch(adam.adae,'I3Y-MC-JPBM-806-01519',out=dist,strict=0);

%AHGcatch(adam.adae,'01298',out=dist,strict=0);
%AHGcatch(rpt,'I3Y-MC-JPBM-854-01025',out=dist,strict=0);


%AHGcatchall(adam.adds,
'1054' @'1116'
,DLM=@,out=,strict=0,open=1);



%let theindata=sdtm.ds;
%AHGcatch(specs.meta_VALUES,"suppmh",out=mid,strict=0);
%AHGexportopen(mid,lookup=1,n=99);



%AHGcatch(eds.mh8001,1080,out=mid,strict=0);

%AHGcatch(mid,"",out=mid,strict=0);


PROC PRINTto;RUN;

%AHGcatch(tfl.L_LAB_HEP_AE,"905-01304",out=sub,strict=0);
%AHGcatch(tfl.L_LAB_HEP_AE,"905-01304",out=sub,strict=0);

%AHGcatch(HEP_t,"829-01029",out=sub,strict=0);
%AHGcatch(rpt,"829-01029",out=sub,strict=0);

%AHGcatch(ir_HEP_t,"829-01029",out=sub,strict=0);

 




%AHGcatch(adam.adds,"Off post",out=total,strict=0);

PROC SQL;
  CREATE TABLE ONE AS
  SELECT *
  FROM total
  WHERE USUBJID NOT IN (SELECT USUBJID FROM sub)

  ;QUIT;


%AHGcatch(sdtm.RELREC,"1053",out=dist,strict=0);


%AHGcatch( ds,"1023",out=dist,strict=0);

%AHGcatch(tfl.f_lab_hep_ae,"01305",out=dist,strict=0);
%AHGcatch(adam.adds,"I3Y-MC-JPBM-400-01030",out=dist,strict=0);

%AHGcatch(ADAM.ADSL,"I3Y-MC-JPBM-400-01030",out=dist,strict=0);
%AHGcatch(bigtest1_5,"I3Y-MC-JPBM-400-01030",out=dist,strict=0);

%AHGcatch(bigtest2,"I3Y-MC-JPBM-400-01030",out=dist,strict=0);





%AHGcatch(rpt,"01000",out=dist,strict=0);




%AHGcatch(tfl.L_lab_hep_ae,"1031",out=dist,strict=0);


%AHGcatch(allhepa,"Subjects with >= 1 Hepatic TE",out= ,strict=0);



%AHGvarlist(dist,Into=distvars,dlm=%str( ),global=1);
proc transpose data=dist out=tran;
  var &distvars;
run;

%let html=%AHGtempdir\%AHGrdm.html;

ods html file="&HTML";  

%AHGreportby(tran,0);

ods html close;   



option noxwait;

x "start &html";

option xwait; 



option noxwait;

x "start sas";

option noxwait;
x "start c:\";
option xwait; 
\\Gh3users\private\H\HUI.L


%macro backuptoh(file,h=h:);
%local dt hfile hdir ext;
%AHGfiledt(&file,into=dt,dtfmt=mmddyy10.);

%let ext=%sysfunc(PRXCHANGE(s/.+\.([^\.]+)/\1/,-1,&file));

%let hfile=&h\%sysfunc(PRXCHANGE(s/(\\\\+)?(:)?//,-1,&file));
%let hdir=%sysfunc(PRXCHANGE(s/(.*)\\.*/\1/,-1,&hfile));

%AHGmkdir(&hdir);
x "copy &file &hfile..&dt..&ext /y";
x "start &hdir";

%AHGpm(hdir hfile dt ext);
%mend;


%backuptoh(
\\mango\sddext.grp\SDDEXT034\qa\ly2835219\i3y_mc_jpbl\intrm1\programs_stat\adam\adae.sas

);


%backuptoh(\\mango\sddext.grp\SDDEXT056\qa\ly2835219\i3y_mc_jpbm\dmc_blinded4\programs_stat\tfl\teae_diarrhoea.sas);





%backuptoh(\\mango\sddext.grp\SDDEXT056\Documents\adam_spec\i3y_mc_jpbm_adam_studyspec1.xlsx);


%backuptoh(\\mango\sddext.grp\SDDEXT056\qa\ly2835219\i3y_mc_jpbm\dmc_blinded3\replica_programs\tfl\ir_t_ecg_s.sas);


%backuptoh(\\mango\awe.grp\SDDEXT112\qa\ly2835219\i3y_mc_jpbo\dsur1\replica_programs\tfl\ir_ae_rel_pt_soc_v1.sas);
%backuptoh(\\mango\sddext.grp\SDDEXT056\qa\ly2835219\i3y_mc_jpbm\dmc_blinded3\programs_stat\setup.sas);


option xwait; 


%AHGclearlog;
%AHGkill;
%metaspec( meta_adae,areln);

%AHGvarlist(sdtm.dm,Into=dmVar,dlm=%str( ),global=1);
%AHGvarlist(qc_dm,Into=qcdmvar,dlm=%str( ),global=1);

%put %AHGremoveWords(&dmvar,&qcdmvar,dlm=%str( ));
%put %AHGremoveWords(&qcdmvar,&dmvar,dlm=%str( ));

%AHGclearlog;
%AHGkill;
%mergeVisit(dsn=eds.eg3001,out=eg,pre=EGDAT );
%AHGopendsn(eg);

proc sort data=sdtm.sv out=sv;
  by subjid;
run;

%AHGopendsn(sv);

%AHGDataView(dsin=adam.adds,dsout=,order=original,SameVal=noDelete);


%let mask=;
%AHGdsnInLib(lib=specs,list=dsnlist,mask=%bquote('%_define_%'));
%AHGpm(mask);
option xwait;
%metaspecall(meta_adae);

AEENRF

~catch

option xwait; 
%openlinks;

%AHGopenmac( ahgclip);

%AHGfontsize(12);

TE done
DS
RELRECDS
SE
TA 
TI done
TS done
VS


option noxwait xsync; X "C:\";
option noxwait xsync; x "start sas";


option xwait;
%inc "\\Gh3users\private\H\HUI.L\setupwithpath.sas";
%setupwithpath(\\mango\sddext.grp\SDDEXT056\qa\ly2835219\i3y_mc_jpbm\dmc_blinded1\programs_stat\sdtm\dummy.sas);



/*%AHGfilesindir(\\mango\sddext.grp\SDDEXT056\qa\ly2835219\i3y_mc_jpbm\dmc_blinded1\programs_stat\tfl*/
/*dlm=%str( ) ,mask='%.sas',into=allfile,case=0,print=1);    */


%AHGreadline(file=%AHGtempdir\1st.txt,out=allfile);

data word;
  format word $100.;
  input word @@;
  word=scan(word,1);
  cards;
ae_pt_soc_v1.sas ae_rel_pt_soc_v1.sas aemissctc_l.sas c_vs_figure_boxwhisker_p14144_t14581.sas dm_l.sas
o_ae_pt_p14144_t14534.sas o_ae_pt_soc_bymaxgrad_p14144_t14149.sas o_ae_rel_pt_p14144_t14553.sas
o_ae_rel_pt_soc_bymaxgrad_p14144_t14150.sas o_dm_summary_p14144_t14242.sas patientdisp_v1.sas relsae_pt_bymaxgrad_s.sas
sae_pt_bymaxgrad_s.sas t_ecg_s.sas t_lab_bymaxgrad_s.sas t_smex_s.sas   trtdisctaedth_l.sas
;
run;

data _null_;
  set word;
  do i=1 to 6;
    set allfile point=i;
    if i ne 2 then put line;
    else 
      do;
      line=trim(line)||word;
      put line;
      end;
  end;
  put;
run;


/*%AHGopendsn();*/

/*data line*/
/*@echo off*/
/*set pgm=ta*/
/*@echo on*/
/**/
/*"%saspath%\sas.exe" %CD%\%pgm%.sas -noxwait -PRINT "%loc%\%pgm%.lst" -LOG "%loc%\_%pgm%.log"*/
/*ping -n 2 localhost > nul*/


333333333333
LIBNAME temp "%AHGtempdir";

%macro subit(dsn,where);
data temp.%scan(&dsn,2);
  set &dsn;
  uid=input(scan(usubjid,5,'-'),best.);
  where &where;
run;
%mend;

%subit(adamr.adae,%str(1092>=input(scan(usubjid,5,'-'),best.)>=1089));

%subit(adamr.adsl,%str(1092>=input(scan(usubjid,5,'-'),best.)>=1089));


filename mprint "%AHGtempdir\mfile.sas";
option mprint mfile;

VSELTM VSTPTREF VSRFTDTC


%AHGkill;
%AHGclearlog;

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
  where   aetox ='MUCOSITIS ORAL';
run;

%AHGopendsn();

data fg;
  set sdtm.eg;
   where  index(usubjid,'01004') and egdtc>='2014-04-02';

RUN;
%AHGopendsn();

%AHGdatasort(data =fg , out = , by =trta EGTPT  descending aval  );

%AHGopendsn;

%AHGopendsn;
%INC 'S:\SA\Macro library\Macro learning tool\program\init.sas';
%INC '\\gh3nas01\gh3nas_sales.grp\LCDDMAC\STATS\SA\Macro library\Macro learning tool\program\init.sas';

smdmf111   unfound
smdemf121 draft
smdemf122 pop
smdemf123 pop
smaesf111 draft
smaesf121
smaesf131
smaesf132
smaesf133
smaesf134
smaesf135
smaesf136
smaesf141
smaesf151
nbhypf111
nbhypf112
nbhypf113
smlabf111
smlabf121
smexpf111
option xwait;
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

%AHGopenmac(ahgtime);
%AHGopenmac(AHGcodecompletion
);

option xwait; 
%let tableid=fqae112;
 x "copy %sdddc(&replication_output\qc_&tableID..txt) %mysdd(&replication_output\qc_&tableID..txt) /y";


x "c:\";
%qcactions(lsvsp11);

%qcactions(smdemf111,actions=downqc downrtf open2output);


%let tfl_output=%sysfunc(tranwrd(&tfl_output,programs_stat,programs_nonsdd));

%qcactions(smlabf111,actions= downqc downrtf open2output);

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

%AHGDataView(dsin=Select_terminology,dsout=st,order=original,SameVal=noDelete);
%AHGDataView(dsin=SDTMR.ds,dsout=st,order=original,SameVal=noDelete);

%AHGopendsn(Define_terminology(where=(dataset='ADDS')));
%AHGopendsn(Define_UPCASE(where=(dataset='ADDS')));


x "copy &";


%AHGkill;
%AHGclearlog;
%AHGcodeCompletion(test); 
%AHGcodeCompletion(sashelp.zipcode); 
%AHGcodeCompletion(sashelp.heart); 
%AHGcodeCompletion(sashelp.class); 
%AHGcodeCompletion(adam.adds,metadir=h:\meta); 
%AHGcodeCompletion(adam.adsl,metadir=h:\meta); 
%AHGcodeCompletion(adam.adexsum,metadir=h:\meta); 
%AHGcodeCompletion(adam.axex,metadir=h:\meta); 
%AHGcodeCompletion(adam.adeg,metadir=h:\meta); 
%AHGcodeCompletion(adam.adlb,metadir=h:\meta); 
%AHGcodeCompletion(adam.advs,metadir=h:\meta); 
%AHGcodeCompletion(adam.adae,metadir=h:\meta); 


%let studypath=
%AHGcodeCompletion(sdtmr.ae,metadir=h:\meta\jpbm); 
%AHGcodeCompletion(sdtmr.suppae,metadir=h:\meta\jpbm); 


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





%downme(nbhypf111cn);

%downme(nbhypf111jp);

%downme(nbhypf111kr);

%downme(nbhypf111tr);


%downme(nbhypf112cn);
%downme(nbhypf112jp);

%downme(nbhypf112kr);

%downme(nbhypf112tr);

%downme(nbhypf113cn);
%downme(nbhypf113jp);

%downme(nbhypf113kr);

%downme(nbhypf113tr);


%downme(smdemf121cn);
%downme(smdemf121jp);
%downme(smdemf121kr);
%downme(smdemf121tr);

%downme(smdemf122cn);
%downme(smdemf122jp);
%downme(smdemf122kr);
%downme(smdemf122tr);

%downme(smdemf123cn);
%downme(smdemf123jp);
%downme(smdemf123kr);
%downme(smdemf123tr);






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
%AHGopendsn(Select_terminology(WHERE=(DATASET='ADDS')));

%AHGvarlist(select_terminology,Into=varlist,dlm=%str( ),print=1);
%AHGclearlog;


data ds;
  set ds sdtmr.ds;
  if input(subjid,best.) eq input(reverse(scan(reverse(usubjid),1,'-')),best.);
run;

%AHGopendsn();

%AHGclearlog;
filename mprint "%AHGtempdir\mfile.sas";
option mprint mfile;
%let ahgrdminc=0;


%AHGordvar(adam.adae,  USUBJID  TRTA allt  AETERM  ATOXGR ,out=ae(where=(missing(allt))),keepall=0);
%AHGtrimdsn(ae);
%AHGreportby(ae,0);

%AHGindent(%AHGtempdir\mfile.sas);


option ls=250;
%macro AHGpm(Ms);
  %local Pmloop2342314314 mac;
  %do Pmloop2342314314=1 %to %AHGcount(&Ms);
    %let mac=%scan(&Ms,&Pmloop2342314314,%str( ));
    %put &mac=&&&mac;
  %end;
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

%AHGpm(execpath  currentpath production_status pgmname  bumlib  
eds sdtm adam  log logname prg specs timepts  spec1 
spec2 design ftimepts gls dict  tfl_output  execpath rptfile  rptindat maclib)
;
%macro up(dir,n=1);
data _null_;
  format dir $500.;
  infile pipe   "";
  filename pip  pipe "dir /d y:\SDDEXT056\qa\ly2835219\i3y_mc_jpbm\dmc_blinded1\replica_programs\sdtm" ;
  infile pip truncover lrecl=32767 end=eof;
  input dir;
  put dir=;
run;
%mend;

%up(&currentpath);

%macro dosomething(str);
%local i;
%do i=1 %to %AHGcount(&str);
%put %nrbquote(%)put %scan(&str,&i)=%nrstr(&)%scan(&str,&i)%str(;);
%end;

%mend;
%doSomething(execpath  currentpath production_status pgmname  bumlib  
eds sdtm adam  log logname prg specs timepts  spec1 
spec2 design ftimepts gls dict  tfl_output  execpath rptfile  rptindat maclib)
;

%AHGvarlist(specs.meta_admh,Into=admh,dlm=%str( ),print=1);


%let one=adcm;

data &one;
  set specs.meta_&one;
  where missing(remove);
  keep  VARIABLE SOURCE_DATASET ANALYSIS_ALGORITHM   SASTYPE  BUSINESS_RULE;
run;

%AHGtrimdsn(&one);

%AHGexportopen(&one,n=999);

x "copy %AHGtempdir\&one..xls h:\&one..xls";

%macro ns(str,s);
%sysfunc(prxchange(s/(.*)\\$/\1/,-1,&str))&s
%mend;

%put %ns(\\mango\sddext.grp\SDDEXT056\qa\ly2835219\i3y_mc_jpbm\dmc_blinded2\programs_stat\adam,\);
%put %ns(\\mango\sddext.grp\SDDEXT056\qa\ly2835219\i3y_mc_jpbm\dmc_blinded2\programs_stat\adam\,\);
%put %ns(\\mango\sddext.grp\SDDEXT056\qa\ly2835219\i3y_mc_jpbm\dmc_blinded2\programs_stat\adam);
%put %ns(\\mango\sddext.grp\SDDEXT056\qa\ly2835219\i3y_mc_jpbm\dmc_blinded2\programs_stat\adam\);


 

%let alltfl=
c_lb_figure_boxwhisker_p24830_t25388.sas
trtdisctaedth_l.sas
tfl_spec2sas_auto.sas
o_ex_adjustment_summary_p24830_t25401.sas
f_lab_hep_ae.sas
c_ae_pt_soc_p24830_t28593.sas
l_lab_hep_ae.sas
t_sdoseomi_s.sas
o_ae_rel_pt_p24830_t24832.sas
o_ae_rel_pt_soc_bymaxgrad_p24830_t24837.sas
c_vs_figure_boxwhisker_p24830_t24833.sas
o_dm_summary_p24830_t24831.sas
o_ae_pt_p24830_t24834.sas
creat_neut_diar.sas
o_ex_exposure_summary_p24830_t26921.sas
o_ex_exposure_summary_p24830_t26928.sas
patientdisp_v1.sas
dm_l.sas
rel_sae_pt_bymaxgrad_s.sas
ae_rel_pt_soc_v1.sas
t_ecg_s.sas
t_lab_bymaxgrad_s.sas
teae_diarrhoea.sas
tfl_ae_l_dia_ae_bypt.sas
tfl_ae_l_dia_ae_v1.sas
tfl_cm_l_all_meds_v1.sas
teae_hepatic.sas
tfl_ae_l_all_ae_v1.sas
o_ex_exposure_summary_p24830_t26625.sas
sae_pt_bymaxgrad_s.sas
o_ae_pt_soc_bymaxgrad_p24830_t24835.sas
aemissctc_l.sas
conmed_diarrhoeaae.sas
creat_sum.sas

;
%let myalltfl=%sysfunc(tranwrd(&alltfl,.sas,%str()));


%let puretfl=%AHGremoveWords(&myalltfl,tfl_spec2sas_auto  ,dlm=%str( ));

%AHGpm(puretfl);

%let allir_tfl=
ir_l_lab_hep_ae.sas
ir_mac.sas
ir_dm_l.sas
ir_f_lab_hep_ae.sas
ir_t_lab_bymaxgrad_s.sas
ir_tfl_ae_l_all_ae_v1.sas
ir_tfl_cm_l_all_meds_v1.sas
ir_tfl_ae_l_dia_ae_v1.sas
ir_tfl_ae_l_dia_ae_bypt.sas
ir_taffy_outputs.sas
ir_teae_diarrhoea.sas
ir_teae_hepatic.sas
ir_conmed_diarrhoeaae.sas
ir_creat_sum.sas
ir_creat_neut_diar.sas
ir_trtdisctaedth_l.sas
ir_patientdisp_v1.sas
ir_aemissctc_l.sas
ir_sae_pt_bymaxgrad_s.sas
ir_ae_rel_pt_soc_v1.sas
ir_t_ecg_s.sas
ir_tfl_comp.sas
ir_t_sdoseomi_s.sas

;
%let myallir_tfl=%sysfunc(tranwrd(&allir_tfl,.sas,%str()));


%let pureir_tfl=%AHGremoveWords(&myallir_tfl,ir_mac ir_taffy_outputs ir_tfl_comp  ,dlm=%str( ));

%let pureir_tfl=%sysfunc(tranwrd(&pureir_tfl,ir_,%str()));


%AHGpm(pureir_tfl);

proc sql;
  create table ib as
  select *, min(awe_path) as path
  from ibsheet
  group by project
  order by sdd_location, calculated path,awe_path
  ;quit;



PROC EXPORT DATA= ib 
            OUTFILE= "H:\ibsheet.xls" 
            DBMS=EXCEL REPLACE;
     SHEET="AWE2SDD"; 
RUN;


x "start H:\ibsheet.xls";

PROC IMPORT 
DATAFILE=<'filename'>|DATATABLE=<'tablename'> 
<DBMS>=<data-source-identifier> 
<OUT>=<libref.SAS data-set-name> <SAS data-set-option(s)> 
<REPLACE>; 

PROC IMPORT OUT= sasuser.addsnew 
            DATAFILE= "H:\cdk46\Core_ADaM_ADDS_V8.xlsx" 
            DBMS=EXCEL REPLACE;
     SHEET="columns"; 
RUN;

PROC IMPORT OUT= sasuser.addsold 
            DATAFILE= "\\mango\sddext.grp\SDDEXT056\Documents\adam_spec\i3y_mc_jpbm_adam_studyspec1.xlsx" 
            DBMS=EXCEL REPLACE;
     SHEET="adds"; 
RUN;



DATA new;
  SET SASUSER.ADDSnew;
  keep order VARIABLE ANALYSIS_ALGORITHM DATATYPE DISPLAY_FORMAT LABEL SASTYPE BUSINESS_RULE ;
RUN;

DATA old;
  format business_rule $387.;
  SET SASUSER.ADDSold;
  keep order VARIABLE ANALYSIS_ALGORITHM DATATYPE DISPLAY_FORMAT LABEL SASTYPE BUSINESS_RULE ;
RUN;

/*data skeleton;*/
/*  set new;*/
/*  stop;*/
/*run;*/
/**/
/*data oldagain;*/
/*  set skeleton old;*/
/*run;*/

/*%AHGordvar(new,  VARIABLE ANALYSIS_ALGORITHM BUSINESS_RULE ,out=,keepall=0);*/
/*%AHGordvar(old, VARIABLE ANALYSIS_ALGORITHM BUSINESS_RULE ,out=,keepall=0);*/
/**/
/*proc sql;*/
/*  create table changed as*/
/*  select variable,ANALYSIS_ALGORITHM*/
/*  from old*/
/*  except*/
/*  select variable,ANALYSIS_ALGORITHM*/
/*  from new*/
/*  ;*/
/*quit;*/
/**/
/*%AHGopendsn();*/
/**/
/*%AHGprt;*/


%AHGdatasort(data = old, out = , by = ORDER);

proc transpose data=old out=tran;
  BY ORDER;
  var VARIABLE ANALYSIS_ALGORITHM DATATYPE DISPLAY_FORMAT LABEL SASTYPE BUSINESS_RULE;
run;

DATA tran(WHERE=(not missing(col1)));
  set tran;
  by order;
  DROP ORDER _LABEL_;
  output;
  if last.order then
  do;
  call missing(_NAME_ ,_LABEL_ ,COL1);
  COL1='********************************************';OUTPUT;
  end;
run;

ods html file="&HTML";  

%AHGreportby(tran,0);

ods html close;  


data ahuige;
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




%let xlsx=https://lillynetcollaboration.global.lilly.com/sites/GCDMLibraryManagementTeam/Documents/Document%20Library/Core_TFL_DS_StudyDisp_ONC_V1.xlsx
;

FILENAME website HTTP
"&xlsx";
data file;
  n=-1;
  infile website recfm=s nbyte=n length=len;
  input Analysis Results Identifier	Analysis Result Description	Level	Condition	Source Data	PARAM Value	PARAMCD Value	Analysis Variable	Selection Criteria	Study Treatment	Documentation	Programming Statements	Display Label	Display Options/Format																																																																																																	

  file  "%AHGtempdir\http.xls" recfm=n;
  put _infile_ $varying32767. len;
  run;
PROC IMPORT OUT= http
            DATAFILE= "%AHGtempdir\http.xls"
            DBMS=Excel REPLACE;
 
      sheet="Analysis Results Metadata";
      getnames=yes;
RUN;

proc sql;
  create table n as
  select *
  from adam.adds
  where INDEX(PARAMCD,'TRTREAS') AND usubjid
  in 
  (
  select usubjid
  from adam.adds
  where saffl='N'
  )
  ;quit;

proc sql;
  create table more as
  select *
  from meddra
  group by lltcd
  having count(*)>1
  ;
  quit;



  %macro AHGcopypath;
  %local pgmname execpath currentpath; %local up;
  %let execpath=%sysfunc(GetOption(SYSIN));
  %IF %length(&execpath)=0 %then %let execpath=%sysget(SAS_EXECFILEPATH);
  %let pgmname=%qscan(%bquote(&execpath),-2,/\.);
  %let currentpath=%sysfunc(PRXCHANGE(s/(.*)\\.*/\1/,-1,&execpath));
  %let up=%sysfunc(PRXCHANGE(s/(.*)\\.*/\1/,-1,&currentpath));

filename ahgclip clear;
filename ahgclip clipbrd;
 
data _null_;
  file ahgclip;
  put "&currentpath";
run;

%mend 


%macro AHGforceFormat(dsn,vars,out=,pref=att_length_);
%macro ___type(dsn,var);
%local did;
%let did=  %sysfunc(open(&dsn,in));
%if %sysfunc(vartype(&did,%sysfunc(varnum(&did,&var))))=C %then $;
%mend;

%macro ___Def(vars);
  %local count i temp ;
  %do i=1 %to %AHGcount(&vars);
    %let temp=&pref%scan(&vars,&i);
    %if %symexist(&temp) %then LENGTH %scan(&vars,&i)  &&&temp ;;
  %end;
%mend;

%macro ___rename(vars,comma );
  %local count i temp ;
  %do i=1 %to %AHGcount(&vars);
    %scan(&vars,&i)=_%scan(&vars,&i)_ %bquote(&comma)
  %end;
%mend;

%if %AHGblank(&out) %then %let out=%AHGbarename(&dsn);
data &out;
  %___def(    MHDECOD  MHLLT MHHLT   MHHLGT       MHBODSYS   MHSOC   );
  set &dsn(rename=(%___rename(  &vars  )));

  %local count i temp ;
  %do i=1 %to %AHGcount(&vars);
  %let temp=&pref%scan(&vars,&i)%str(.);
  %let temp=&&&temp;
   drop _%scan(&vars,&i)_;
   %scan(&vars,&i)=input(left(put(_%scan(&vars,&i)_,%___type(&dsn,%scan(&vars,&i))20. )),%unquote(&temp));
  %end;

run;

%mend;


%macro dosomething(dsn,id1 ,id2); *disaefl ;

proc sql;
  create table &id1&id2 as
  select *
  from &dsn
  where index(%upcase("&id1 &id2"),trim(idvar) )
  group by subjid,relid
  having count(*)=2 and max(idvar) ne min(idvar)
  ;

%AHGdatasort(data =&id1&id2 , out = , by =subjid relid);

proc transpose data=&id1&id2 out=tran&id1&id2 ;
  var IDVARVAL;
  id IDVAR;
  by subjid relid;
run;


%AHGforceFormat(tran&id1&id2,&id1 &id2);


data dsseq;
  set tran&id1&id2;
  DISAEFLAG='Y';
run;




%mend;
%doSomething(sdtm.relrecds,DSSEQ,AEGRPID);


%macro AHGModClip ;
filename ahgclip clear;
filename ahgclip clipbrd;

data ahuige;
  infile ahgclip truncover;
  format cmd  line $500.;
  input line 1-500 ;
  cmd=trim(line);
run;



data _null_;
  set ahuige;
  file ahgclip;
  format cmd    $500.;
  cmd="ok "||line;
  put cmd;   
run;


%mend;





/*proc sql;*/
/*  create table ds as*/
/*  select * */
/*  from  sdtm.ds*/
/*  where DSSCAT="STUDY DISPOSITION"*/
/*  group by subjid, dsstdtc*/
/*  having dsstdtc=min(dsstdtc)*/
/*  ;*/
/*  quit;*/
/**/
/*%AHGmergedsn(ds,dsseq,ds,by=subjid dsseq,joinstyle=matched);*/
/**/
/**/
/*data dsori;*/
/*  format disaeflAG $1.;*/
/*  set ds(keep=subjid AEGRPid DISAEFLAG dsstdtc);*/
/*run;*/
/**/
/*proc sql;*/
/*  create table ds as*/
/*  select * */
/*  from dsori*/
/*  group by subjid, AEGRPid ,DISAEFLAG ,dsstdtc*/
/*  having dsstdtc=min(dsstdtc)*/
/*  ;*/
/*  quit;*/
/**/
/*%AHGmergedsn(ds,adae,adae,by=subjid AEGRPid,joinstyle=right );*/
/**/
/*%AHGdatasort(data = adae, out = , by =subjid  aegrpid descending aestdtc );*/


PROC IMPORT OUT= tracking
DATAFILE= "H:\tfl_specs_dmc5_2016.xlsx" 
            DBMS=excel REPLACE;
     SHEET="Program_Details"; 
     GETNAMES=YES;
RUN;

data TFL;
  set tracking;
  keep category output_name item;
  item=upcase(compress(output_name||'.rtf'));
  where index('TABLE LISTING',trim(upcase(category))) and not missing(category);
RUN;

%let rtf=;

%AHGfilesindir(&tfl_output,dlm=%str( ) ,mask='%.rtf',into=rtf,case=0,print=1);    
%macro dosomething;
%local i;
data rtf;
  format item $100.;
  rtf=1;
%do i=1 %to %AHGcount(%str(&rtf));
  item=upcase(scan("&rtf",&i,' '));
  output; 

%end;

run;

%mend;
%doSomething

%AHGmergedsn(tfl,rtf,all,by=item,joinstyle=full/*left right full matched*/);


%AHGfilesindir(&tfl_output,dlm=%str( ) ,mask='%.rtf',into=rtf,case=0,print=1);   


data sasuser.actions;
  format action $200.;
  infile datalines truncover;
  input action 1-200;
  cards4;
%AHGmergedsn(dsn1,dsn2,outdsn,by=,joinstyle=full/*left right full matched*/);
%AHGpm();
%AHGdatasort(data = , out = , by = );

;;;;
run; 






proc sort data=qc_adexsum OUT=NEW NODUPKEY; by studyid usubjid avisitn   paramcd  ; run;

%AHGordvar(new,studyid usubjid paramn parqual saffl trtp trtpn trta trtan param paramcd aval avalc astdtc
		astdt aendt aendtc avisit avisitn anl01fl anl02fl anl03fl avalca1n avalcat1 srcdom srcseq,out=,keepall=0);

%AHGordvar(adexsum,studyid usubjid paramn parqual saffl trtp trtpn trta trtan param paramcd aval avalc astdtc
		astdt aendt aendtc avisit avisitn anl01fl anl02fl anl03fl avalca1n avalcat1 srcdom srcseq,out=,keepall=0);
 
proc sql;
  create table more as
  select *
  from adexsum
  except 
  select *
  from new
  ;
  quit;
 
$pshost = get-host
$pswindow = $pshost.ui.rawui

$newsize = $pswindow.buffersize
$newsize.height = 160
$newsize.width = 120
$pswindow.buffersize = $newsize

$newsize = $pswindow.windowsize
$newsize.height = 50
$newsize.width = 120
$pswindow.windowsize = $newsize

PROC SQL;
  CREATE TABLE max as
  select *
  from
  (select *,count(*) as cnt
  from adam.adae
  group by usubjid
  )
  having cnt=max(cnt)
  order by astdt, aeseq
  ;

  quit;



