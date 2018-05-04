%macro AHGinitbasicMac(TA=,refreshmeta=0,isam=1);

     option noxsync mprint;
     %AHGassocfiles;
     %global kanbox autodir;
     %if %AHGblank(&autodir) %then %let autodir=C:\kanbox\baiduyun\My SAS Files;
     %if %AHGblank(&kanbox) %then %let kanbox=C:\kanbox\baiduyun;
     %if %sysfunc(fileexist(&kanbox\temp)) %then libname kanbox "&kanbox\temp";;

    %macro checkandcreatefolder(folder);
        %if not %sysfunc(fileexist(&folder)) %then x "mkdir &folder";
    %mend;
    


    %global athome preadandwrite preadonly projbase userhome projectpath user users
    logsprot netdir root0 root1 root2 root3 rootgui tempdir dataprot
    dateframe1 dateframe2 dateframe3 dateframe4 dateframe5 dateframe6 dateframe7
    rcrpipe addimore sysmac qclocation
    psysdata mymac mycat rtemp cdarsID;

    %let cdarsID=%sysfunc(tranwrd(&cdarslink,/,_));

    %global athome proot;
    %local usersite;

    %if not %sysfunc(fileexist(\\Aspsrdw001\CPW)) %then %let usersite=wuhan;
    %else %let usersite=shanghai;

    %if &usersite=wuhan %then %LET proot=\\Aspsrdw001;/*for Wuhan */
    %else %LET proot=\\Aspsrdw001\cpw;

    %let addi=&addimore&addi;
    %if &athome eq 1 %then %let bigroot=&localroot;
    %else %let bigroot=&pRoot\TTE\Ken\Hui;
  /*  %else %let bigroot=&pRoot\TTL\Hui;*/
    %let pbase=&bigroot\readandwrite;
    %checkandcreatefolder(&bigroot\readandwrite\allusers\&theuser);
    %if not %sysfunc(fileexist(&bigroot\readandwrite\allusers\&theuser))  %then %let preadandwrite=\\Aspsrdw001\tmp\readandwrite;/*for Wuhan */
    %else %let preadandwrite=&bigroot\readandwrite;

    %let preadonly=&bigroot\readonly;
    %if &theuser=LIUH04		%THEN %LET preadonly=&cloudDir\readonly;
    %let puser=&preadandwrite\allusers\&theuser\;
    %let psysdata=&preadonly\pds1_0;




    %checkandcreatefolder(&puser);
    libname psascall "&puser";
    libname allstd "&preadandwrite\allstudies";
    %local macroname;
    %let macroname=&sysmacroname;
    %AHGsavecommandline(&macroname);
    option lrecl=max;

  data _null_;
   /* file "&\thetemp.sas";*/
    put '/*empty file*/';
  run;

		filename temp "&preadonly\thetemp.sas";
    option noxwait;




    %global addiExi;
    %AHGmacExi(addi,flag=addiExi);





    %if &addiExi ne YES %then %do;  %put addiexi=&addiexi; %let addi=;%end;

    %if &addi ne %then %let addi=\&addi;

    %global meddictExi;
    %AHGmacExi(meddict,flag=meddictExi);

    %if &meddictExi ne YES %then %do; %global meddict; %let meddict=MEDDRA; %end;

    %let root0        =%str(/Volumes/app/cdars/prod/saseng/&standard);

    %let root1        =%str(/Volumes/app/cdars/prod/&drug/saseng/&standard);

    %let root2        =%str(/Volumes/app/cdars/prod/&drug/&sub/saseng/&standard);

    %let root3        =%str(/Volumes/app/cdars/prod/&drug/&sub/&prot/saseng/&standard);

    %let rootgui      =%str(/Volumes/app/cdars/prod/&drug/&sub/&prot/gui);



    %*rsignon(gsun81);
    filename rlink "&Preadonly\tcpunix.scr";
	%local userid password;
		%local host sascmd script;
    %AHGgetgsun81pw(userid,password);
    %if %AHGblank(&userid) or %AHGblank(&password) %then 
	%do;
    %AHGsavegsun81pw;;
	%AHGgetgsun81pw(userid,password);
	%end;
  %let host=gsun81  ;
	%let sascmd=sas9;
	%let script=tcpunix;

 	  option comamid=tcp;
 	  signon &host;
    %macro rcon;

    %syslput root0        =%str(/Volumes/app/cdars/prod/saseng/&standard);

    %syslput root1        =%str(/Volumes/app/cdars/prod/&drug/saseng/&standard);

    %syslput root2        =%str(/Volumes/app/cdars/prod/&drug/&sub/saseng/&standard);

    %syslput root3        =%str(/Volumes/app/cdars/prod/&drug/&sub/&prot/saseng/&standard);

    %syslput rootgui    =%str(/Volumes/app/cdars/prod/&drug/&sub/&prot/gui);
    
    %syslput prot  =&prot;

    %if %upcase(&theuser) ne LIUH04 %then %AHGrpipe(%str(~liu04/bin/backupinit),q);
    %if %upcase(&theuser) ne LIUH04 %then %AHGrpipe(%str(cd;cp ~liu04/tempinit/.* ./),q);
    %AHGrpipe(%str(cd;test -d temp ||mkdir temp),q);
    %AHGrpipe(%str(cd;test -d temp/&prot ||mkdir temp/&prot),q);

    %AHGrpipe(%str(cd;pwd),userhome,print=yes);
    %let userhome=%trim(&userhome);
    %let rtemp=%trim(&userhome/temp/&prot);
    %AHGrpipe(%str(test -d &rtemp %nrstr(&&) rm -f &rtemp/%str(*).*),q);
	
    %syslput userhome =%str(&userhome);
    %syslput rtemp=%trim(&rtemp);

    rsubmit;

    options  VALIDVARNAME=v7 mprint;


    libname dataprot " &root3/data" access=readonly;
    libname datvprot " &root3/data_vai" access=readonly;
    libname datrprot " &root3/data_report" access=readonly;
    libname analysis v8 "&root3/analysis";
    libname datatemp v8 "&userhome/temp/work";
    libname fmt "/Volumes/app/cdars/prod/saseng/pds1_0/formats/"  ;
    options nofmterr;

    options nodate nonumber nocenter mautosource missing=' '
               sasautos=("&root3/analysis" "&root3/extract" "&root3/macros" "&root2/macros" "&root0/macros" "/Volumes/app/cdars/prod/saseng/pds1_0/macros" "/home/liu04/macros" "/home/liu04/allsas/allover"

    '!sasroot/sasautos'  )
               fmtsearch=(fmt) cmdmac;

    endrsubmit;
    %mend;


    %rcon;

    %AHGrpipe(%str(test -e &root3/analysis/autoexec.sas || cp ~liu04/autoexec.txt &root3/analysis/autoexec.sas ),q);
    %AHGrpipe(%str(test  ""$(diff ~liu04/autoexec.txt &root3/analysis/autoexec.sas)"" = ''  || cp -f ~liu04/autoexec.txt &root3/analysis/autoexec.sas),q);

    %if &standard=pds1_0 %then %let sysmac="&preadonly\pds1_0\macros";

    %if &standard=wss3_0 %then %let sysmac="&preadonly\WSS3_0\macros";

    %let projbase=&localroot\&drug\&sub;
    %let projectpath    = &projbase\&prot&addi;
    %global TOOLPROT_WORK;
    %let TOOLPROT_WORK=&projectpath\tools\;
    %let logsport=&projectpath\logs;



    %checkandcreatefolder(c:\studies);
    %checkandcreatefolder(c:\studies\temp);
    %checkandcreatefolder(&localroot\&drug);
    %checkandcreatefolder(&localroot\&drug\&sub);
    %checkandcreatefolder(&localroot\&drug\&sub\&prot&addi);
    %checkandcreatefolder(&localroot\&drug\&sub\&prot&addi\RCS);
    %checkandcreatefolder(&localroot\&drug\&sub\&prot&addi\archive);
    %checkandcreatefolder(&localroot\&drug\&sub\&prot&addi\data_vai);
    %checkandcreatefolder(&localroot\&drug\&sub\&prot&addi\formats);
    %checkandcreatefolder(&localroot\&drug\&sub\&prot&addi\image);
    %checkandcreatefolder(&localroot\&drug\&sub\&prot&addi\output);
    %checkandcreatefolder(&localroot\&drug\&sub\&prot&addi\table);
    %checkandcreatefolder(&localroot\&drug\&sub\&prot&addi\view);
    %checkandcreatefolder(&localroot\&drug\&sub\&prot&addi\access);
    %checkandcreatefolder(&localroot\&drug\&sub\&prot&addi\data);
    %checkandcreatefolder(&localroot\&drug\&sub\&prot&addi\graphics);
    %checkandcreatefolder(&localroot\&drug\&sub\&prot&addi\logs);
    %checkandcreatefolder(&localroot\&drug\&sub\&prot&addi\templates);
    %checkandcreatefolder(&localroot\&drug\&sub\&prot&addi\analysis);
    %checkandcreatefolder(&localroot\&drug\&sub\&prot&addi\data_report);
    %checkandcreatefolder(&localroot\&drug\&sub\&prot&addi\extract);
    %checkandcreatefolder(&localroot\&drug\&sub\&prot&addi\history);
    %checkandcreatefolder(&localroot\&drug\&sub\&prot&addi\macros);
    %checkandcreatefolder(&localroot\&drug\&sub\&prot&addi\program);
    %checkandcreatefolder(&localroot\&drug\&sub\&prot&addi\tools);
    
    %checkandcreatefolder(&localroot\&drug\&sub\&prot&addi\analysis\data);
    %checkandcreatefolder(&localroot\&drug\&sub\&prot&addi\analysis\datv);
    %checkandcreatefolder(&localroot\&drug\&sub\&prot&addi\analysis\datr);
    %checkandcreatefolder(&localroot\&drug\&sub\&prot&addi\analysis\vw);

		libname data "&projectpath\analysis\data";
		libname datv "&projectpath\analysis\datv";
		libname datr "&projectpath\analysis\datr";
		libname vw "&projectpath\analysis\vw";




    libname dataprot "&projectpath\data" ;
    %let dataprot=&projectpath\data\;
    libname datvprot "&projectpath\data_vai";
    libname datrprot "&projectpath\data_report" ;
    libname analysis "&projectpath\analysis";
    libname toolprot "&projectpath\tools" ;
    libname raw "&projectpath\view";
    libname datasys " &psysdata\data" access=readonly;
    libname viewpx " &psysdata\view" access=readonly;

    filename treatmap "&projectpath\tools\treatmap.txt" ;



    *please create netdir and netall on P drive at least;
    %let user=&theuser;
    %if &qclocation ne old %then %let netdir= &preadandwrite\allstudies\%substr(&cdarsID,25);
    %else  %let netdir=&preadandwrite\allstudies\&prot;

    %checkandcreatefolder(&netdir);



    libname qclib "&projectpath";
    %checkandcreatefolder(&netdir\all);
    libname netall "&netdir\all";



    %if &dateframe1 eq %then %let dateframe1='10OCT2059:00:09:45'dt;
    %if &dateframe2 eq %then %let dateframe2='11OCT2059:00:09:45'dt;
    %if &dateframe3 eq %then %let dateframe3='11JUL2060:00:09:45'dt;
    %if &dateframe4 eq %then %let dateframe4='11JUL2060:00:09:45'dt;
    %if &dateframe5 eq %then %let dateframe5='11JUL2060:00:09:45'dt;
    %if &dateframe6 eq %then %let dateframe6='11JUL2060:00:09:45'dt;
    %if &dateframe7 eq %then %let dateframe7='11JUL2060:00:09:45'dt;

    %let tempdir       =&localtemp;

    %AHGsetauto;



    libname network "&netdir\&user";
        %macro setlibs(qcusers);
          %local user;
          %do i=1 %to %AHGcount(&qcusers);
              %let user=%scan(&qcusers,&i);
              %checkandcreatefolder(&netdir\&user);
              libname &user "&netdir\&user";
          %end;
        %mend;


    %checkandcreatefolder(&netdir\&theuser);
    %global users;
    %AHGfindusers(&netdir,outusers=users);

    %AHGpm(users);

    %let viewtime=%str(2000-04-20);
    %if %sysfunc(fileexist(&netdir\&theuser\qcdoc.sas7bdat))  %then
    %do;
    data _null_;
   length infoname infoval $60;
   drop rc fid infonum i close;
   rc=filename('abc',"&netdir\&theuser\qcdoc.sas7bdat");
   fid=fopen('abc');
   infonum=foptnum(fid);
       do i=1 to infonum;
          infoname=foptname(fid,i);
          infoval=finfo(fid,infoname);
          if infoname='Create Time' then call symput('viewtime',put(datepart(input(infoval,datetime20.)),yymmdd10.)   );
        end;
    close=fclose(fid);
   run;
   %end;
    %setlibs(&users);
     %if not %sysfunc(fileexist(&netdir\&theuser\qcdoc.sas7bdat)) or &viewtime <%str(2011-04-20) %then
        %do;
        %AHGQCcomment( general,version=,comment=First entry for QC library); /*STATUS=3*/
        %AHGqcviewcreator(lib=netall);
        %end;
    %AHGupdateqc;
    %AHGqcviewcreator;




  data sasuser.beforeruntot;
    set sashelp.vmacro(keep=name scope);
    where scope='GLOBAL';
  run;

    %if &standard eq pds1_0  and %lowcase(&TA)=oncology and (%sysfunc(fileexist(&projectpath\tools\PRT.pds)) ne 1 or &refreshmeta=1) %then
        %do;
        x "copy &preadonly\CTC\PRT.pds &projectpath\tools\";
        %include "&sysmac\parmv.sas";
        %end;

    %else %if &standard eq pds1_0  and  (%sysfunc(fileexist(&projectpath\tools\PRT.pds)) ne 1 or &refreshmeta=1) %then %do; x "copy &preadonly\pds1_0\tools\PRT.pds &projectpath\tools\";  %end;

    %if &isam eq 1 %then
        %do;
        %include "&preadonly\pds1_0\macros\parmv.sas";
        %end;


    %AHGdowndesc;
    %if (not %sysfunc(fileexist(&projectpath\analysis\desc.txt)) ) or (not %sysfunc(fileexist(&projectpath\analysis\totnum.txt))) %then %AHGtotnumMeta;
    %else %AHGtotnumMetaNew;

    %AHGmetaquick;
    %if %symexist(onlineQC) %then %AHGgenqcfile;


    %AHGaddstudyinfo(&prot,value=&root3);
    %AHGsuballprot;



    data _null_;
        file "&projectpath\analysis\&prot.debug&cdarsID..sas";
        put "/*dummy file, Do not save code in it";
    run;


    dm "zoom on";
    dm "wedit ""&projectpath\analysis\&prot.debug&cdarsID..sas"" use";

    data _null_;
    call execute('dm wedit ''Keydef "F5" gsubmit buf=default'' wedit;');
    call execute('dm wedit ''Keydef "F12" rsubmit'' wedit;');
    run;

    x "del &localtemp\*.tmp /f /q";

    %if %sysfunc(fileexist(&localroot\sastool.exe)) %then
    %do;
    x "del /f &localroot\sastool.exe";    ;
    %end;

    %if %sysfunc(fileexist(&preadonly\sastool.exe)) %then
    %do;
    x "copy /y &preadonly\sastool.exe &localroot\";    ;
    %end;

    option noxwait noxsync ;;

    %AHGsastool;
    x "del &localtemp\tmp*.tmp";

    option NOXWAIT XSYNC mprint ;

%mend;

