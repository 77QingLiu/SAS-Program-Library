%macro cluwe_catalog(refresh,files=,net=0);
%local hstore kanbox;
OPTION NOXWAIT;
%let kanbox=\\Gh3users\private\H\HUI.L\newsas;
%let hstore=\\Gh3users\private\H\HUI.L\saspal;
option SASMSTORE="&hstore";
    %if %upcase(&sysuserid)=C187781 %then 
      %do;
       data _null_;
        filename pip pipe "dir ""&kanbox\core\*.sas "" /b";
        infile pip;
        length file $100 com $300;
        input file ;
        if index(file,'refreshmac.sas') then return;
        if ("&files" ne '') and (not index(upcase("&files"),trim(upcase(file)))) then return;
        com=("%include ""&kanbox\core\"||file||'";');
        put com=;
        call execute(com);
      run;
      data _null_;
        filename pip pipe "dir ""&kanbox\inter\*.sas "" /b";
        infile pip;
        length file $100 com $300;
        input file ;
        if index(file,'refreshmac.sas') then return;
        if ("&files" ne '') and (not index(upcase("&files"),trim(upcase(file)))) then return;
        com=("%include ""&kanbox\inter\"||file||'";');
        put com=;
        call execute(com);
      run;

      data _null_;
        filename pip pipe "dir ""&kanbox\chn_\*.sas "" /b";
        infile pip;
        length file $100 com $300;
        input file ;
        if index(file,'refreshmac.sas') then return;
        if ("&files" ne '') and (not index(upcase("&files"),trim(upcase(file)))) then return;
        com=("%include ""&kanbox\chn_\"||file||'";');
        put com=;
        call execute(com);
      run;

      data _null_;
        filename pip pipe "dir ""\\gh3nas01\gh3nas_sales.grp\LCDDMAC\STATS\SA\Macro library\Macro learning tool\macros\*.sas "" /b";
        infile pip;
        length file $100 com $300;
        input file ;
        if index(file,'refreshmac.sas') then return;
        if ("&files" ne '') and (not index(upcase("&files"),trim(upcase(file)))) then return;
        com=("%include ""\\gh3nas01\gh3nas_sales.grp\LCDDMAC\STATS\SA\Macro library\Macro learning tool\macros\"||file||'";');
        put com=;
        call execute(com);
      run;

      

      %end; 
   

 
    %local macbackup;
    %let macbackup=&hstore;
    option noxwait;
    %AHGmkdir(&macbackup);
    
    
    libname netmac "&macbackup";
    %local mydt;
    data _null_;
      call symput('mydt',translate(put(date(),yymmdd10.)||'_'||put(time(),time8.),'__','-:') );
    run;
    %put mydt=&mydt;
    
    %if &refresh=1 %then
        %do;
        x mkdir &macbackup\cluwe&mydt;   
        x copy  &macbackup\*.* &macbackup\cluwe&mydt\;    
        proc datasets lib=work;
          copy out=netmac memtype=catalog;
        run;
        quit;
        %end;
    %if &net %then x copy &hstore\sasmacr.sas7bcat "\\gh3nas01\gh3nas_sales.grp\LCDDMAC\STATS\SA\Macro library\cluwe.sas7bcat" /y ;
%mend;

%cluwe_catalog(1,NET=1);

