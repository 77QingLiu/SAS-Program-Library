%macro AHGinitLite;
    %macro checkandcreatefolder(folder);
        %if not %sysfunc(fileexist(&folder)) %then x "mkdir &folder";
    %mend;
        %global kanbox;
        %if %sysfunc(fileexist(c:\baiduyun)) %then %let kanbox=c:\baiduyun;
        %if %sysfunc(fileexist(c:\kanbox\baiduyun)) %then %let kanbox=c:\kanbox\baiduyun;        

    %checkandcreatefolder(&localtemp\AHG_sas9mac);
    %checkandcreatefolder(&localroot\AHG_sas9mac);
%macro dosomething/*copy automac from P drive or skip if no P drive connection */;
	%local workdir;
	  data _null_;
	    work=getoption('work');
	    put work=;
	    call symput('workdir',trim(work));
	  run;
	%if %sysfunc(fileexist(&proot\TTE\Ken\Hui\readandwrite\automac\AHG_sas9mac)) %then 	x "copy &proot\TTE\Ken\Hui\readandwrite\automac\AHG_sas9mac  &localroot\AHG_sas9mac"; ;

	%if %sysfunc(fileexist(&proot\TTE\Ken\Hui\readonly\AHGautoexec.sas)) %then x "copy &proot\TTE\Ken\Hui\readonly\AHGautoexec.sas &localroot\"; ;
	%if %sysfunc(fileexist(&proot\TTE\Ken\Hui\readonly\sastool.exe)) %then x "copy &proot\TTE\Ken\Hui\readonly\sastool.exe &localroot\"; ;

	%if not %sysfunc(fileexist(&localroot\tcpunix.scr)) %then x "copy &proot\TTE\Ken\Hui\readonly\tcpunix.scr &localroot\ "; ;
	%global netmac;


%mend;
%if not &athome=1 %then %doSomething;
/*%goto getout;*/
%if %sysfunc(fileexist(&localroot\AHG_sas9mac )) %then x "copy &localroot\AHG_sas9mac &localtemp\AHG_sas9mac "; ;
  libname netmac "&localtemp\AHG_sas9mac";
  options MSTORED SASMSTORE = netmac;  	


    %global athome preadandwrite preadonly projbase userhome projectpath user users
    logsprot netdir root0 root1 root2 root3 rootgui tempdir dataprot
    dateframe1 dateframe2 dateframe3 dateframe4 dateframe5 dateframe6 dateframe7
    rcrpipe addimore sysmac qclocation
    psysdata mymac mycat rtemp cdarsID;

    %let cdarsID=%sysfunc(tranwrd(&cdarslink,/,_));

    %let addi=&addimore&addi;
	%macro AHGsavecommandline(scope,excludeVARs=MACRONAME);
	%mend;
    %let bigroot=&localroot;
    %let preadandwrite=&bigroot\readandwrite;
    %let preadonly=&bigroot\readonly;
    %let psysdata=&preadonly\pds1_0;
	%checkandcreatefolder(&preadandwrite);
	%checkandcreatefolder(&preadonly);
	%checkandcreatefolder(&psysdata);
	%checkandcreatefolder(&preadandwrite\allstudies);
    libname allstd "&preadandwrite\allstudies";
    option lrecl=max;

	  data _null_;
	    file "&preadandwrite\thetemp.sas";
	    put '/*empty file*/';
	  run;

		filename temp "&preadandwrite\thetemp.sas";
    option noxwait;

    %global addi;
    %if &addi ne %then %let addi=\&addi;

    %global meddict;

    %if &meddict eq %then  %let meddict=MEDDRA; 

    %let root0        =%str(/Volumes/app/cdars/prod/saseng/&standard);

    %let root1        =%str(/Volumes/app/cdars/prod/&drug/saseng/&standard);

    %let root2        =%str(/Volumes/app/cdars/prod/&drug/&sub/saseng/&standard);

    %let root3        =%str(/Volumes/app/cdars/prod/&drug/&sub/&prot/saseng/&standard);

    %let rootgui      =%str(/Volumes/app/cdars/prod/&drug/&sub/&prot/gui);



    %*rsignon(gsun81);

    filename rlink "&localroot\tcpunix.scr";
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

	%global rcon;
	%AHGdefault(rcon,1);
    %if &rcon eq 1 %then 
	%do;
	signon &host;
	%rcon;
	%end;

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
    
    %checkandcreatefolder(&localroot\&drug\&sub\&prot&addi\analysis\alldata);
    %checkandcreatefolder(&localroot\&drug\&sub\&prot&addi\analysis\alldatv);


		libname alldata "&projectpath\analysis\alldata";
		libname alldatv "&projectpath\analysis\alldatv";

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

    %let tempdir       =&localtemp;
    /*
    options nodate nonumber nocenter mautosource missing=' ' font=("Courier New" 9)
                   sasautos=(  %if &mymac ne %then "&mymac"; '!sasroot/sasautos' '!sasroot\base\sasmacro' "&projectpath\analysis" "&readonly\pds1_0\macros" "&projectpath\extract"  "&projectpath\macros"  '!sasroot\base\sasmacro'    sasautos  )
                   fmtsearch=(work.formats ) cmdmac;
                   */
    %AHGsetauto;

        option ls=180;
        option nofmterr;


  data sasuser.beforeruntot;
    set sashelp.vmacro(keep=name scope);
    where scope='GLOBAL';
  run;

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

option nomprint nosymbolgen nomacrogen;


option nomprint nosymbolgen nomacrogen;

data _null_;
    set sasuser.gsun81(pw=hcEE3B32);
    call symput('unixid',userid);
    call symput('pw',password);
run;    


    dm "zoom on";
    dm "wedit ""&projectpath\analysis\&prot.debug&cdarsID..sas"" use";
    option noxsync;
    %let addAHG=1;

        %if %sysfunc(fileexist( &localroot\sastool.exe)) %then
        %do;
        x "&localroot\sastool.exe &projectpath\ ""SAS - [&prot.debug&cdarsID..sas]""   ""&root3"" ""&root1 &root2 &root3 &rootgui &unixid &pw &localtemp &root0 &addAHG"" ";
        %end;

    option mprint nosymbolgen ;  

%getout:
%mend;

