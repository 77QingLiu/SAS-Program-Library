%macro hstore(refresh,files=,net=0);
%local hstore kanbox;
OPTION NOXWAIT;
%let kanbox=d:\newsas;
%let hstore=h:\saspal;
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
        filename pip pipe "dir ""&kanbox\adhoc\*.sas "" /b";
        infile pip;
        length file $100 com $300;
        input file ;
        if index(file,'refreshmac.sas') then return;
        if ("&files" ne '') and (not index(upcase("&files"),trim(upcase(file)))) then return;
        com=("%include ""&kanbox\adhoc\"||file||'";');
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
        x mkdir &macbackup\&mydt;   
        x copy  &macbackup\*.* &macbackup&mydt\;    
        proc datasets lib=work;
          copy out=netmac memtype=catalog;
        run;
        quit;
        %end;
    %if &net %then x copy &hstore\sasmacr.sas7bcat "\\gh3nas01\gh3nas_sales.grp\LCDDMAC\STATS\SA\Macro library\" /y ;
%mend;

%hstore(1,NET=1);

